#!/usr/bin/env bun

import { parseArgs } from "util";

const MICROCOSM_XRPC_BASE = "https://constellation.microcosm.blue/xrpc";
const PUBLIC_BSKY_XRPC_BASE = "https://public.api.bsky.app/xrpc";
const BLOCK_SOURCE = "app.bsky.graph.block:subject";
const BACKLINK_LIMIT = 16;
const PROFILE_BATCH_SIZE = 25;

type JsonMap = Record<string, unknown>;

type FetchResult = {
  status: number;
  ok: boolean;
  text: string;
  data: JsonMap | null;
};

type OrderedEntry =
  | {
      did: string;
      status: "resolved";
      handle: string;
      displayName: string | null;
    }
  | {
      did: string;
      status: "unavailable";
      reason: string;
    };

function buildXrpcUrl(base: string, method: string, params: Record<string, string | number | null | undefined>): URL {
  const url = new URL(`${base}/${method}`);
  for (const [key, value] of Object.entries(params)) {
    if (value !== null && value !== undefined) {
      url.searchParams.set(key, String(value));
    }
  }
  return url;
}

async function fetchJson(url: URL): Promise<FetchResult> {
  const response = await fetch(url, {
    headers: {
      Accept: "application/json",
      "User-Agent": "lazurite",
    },
  });
  const text = await response.text();

  let data: JsonMap | null = null;
  try {
    data = text.length > 0 ? (JSON.parse(text) as JsonMap) : null;
  } catch {
    data = null;
  }

  return {
    status: response.status,
    ok: response.ok,
    text,
    data,
  };
}

function getListFieldAny(data: JsonMap | null, keys: string[]): unknown[] {
  if (!data) return [];

  for (const key of keys) {
    const value = data[key];
    if (Array.isArray(value)) {
      return value;
    }
  }

  return [];
}

function asString(value: unknown): string | null {
  return typeof value === "string" && value.trim().length > 0 ? value.trim() : null;
}

function classifyProfileFailure(result: FetchResult): string {
  const error = asString(result.data?.error);
  const message = asString(result.data?.message) ?? result.text;
  const combined = `${error ?? ""} ${message}`.toLowerCase();

  if (combined.includes("accounttakedown") || combined.includes("suspended")) {
    return "Suspended account";
  }
  if (result.status === 404 || combined.includes("not found")) {
    return "Profile unavailable";
  }
  return "Public profile lookup failed";
}

function chunk<T>(items: T[], size: number): T[][] {
  const output: T[][] = [];
  for (let index = 0; index < items.length; index += size) {
    output.push(items.slice(index, index + size));
  }
  return output;
}

async function fetchBlockedByCount(did: string): Promise<number> {
  const url = buildXrpcUrl(MICROCOSM_XRPC_BASE, "blue.microcosm.links.getBacklinksCount", {
    subject: did,
    source: BLOCK_SOURCE,
  });
  const result = await fetchJson(url);

  if (!result.ok || typeof result.data?.total !== "number") {
    throw new Error(`getBacklinksCount failed (${result.status}): ${result.text}`);
  }

  return result.data.total as number;
}

async function fetchDistinct(did: string): Promise<FetchResult> {
  const url = buildXrpcUrl(MICROCOSM_XRPC_BASE, "blue.microcosm.links.getDistinct", {
    subject: did,
    source: BLOCK_SOURCE,
    limit: BACKLINK_LIMIT,
  });
  return fetchJson(url);
}

async function fetchAllBacklinkDids(
  did: string,
): Promise<{ orderedDids: string[]; pages: Array<{ page: number; cursorIn: string | null; cursorOut: string | null; recordCount: number }> }> {
  const orderedDids: string[] = [];
  const seen = new Set<string>();
  const pages: Array<{ page: number; cursorIn: string | null; cursorOut: string | null; recordCount: number }> = [];

  let cursor: string | null = null;
  let page = 1;

  do {
    const url = buildXrpcUrl(MICROCOSM_XRPC_BASE, "blue.microcosm.links.getBacklinks", {
      subject: did,
      source: BLOCK_SOURCE,
      limit: BACKLINK_LIMIT,
      cursor,
    });
    const result = await fetchJson(url);
    if (!result.ok) {
      throw new Error(`getBacklinks failed (${result.status}) on page ${page}: ${result.text}`);
    }

    const records = getListFieldAny(result.data, ["records", "linking_records"]);
    for (const record of records) {
      if (record && typeof record === "object") {
        const blockerDid = asString((record as JsonMap).did);
        if (blockerDid && !seen.has(blockerDid)) {
          seen.add(blockerDid);
          orderedDids.push(blockerDid);
        }
      }
    }

    const nextCursor = asString(result.data?.cursor);
    pages.push({
      page,
      cursorIn: cursor,
      cursorOut: nextCursor,
      recordCount: records.length,
    });
    cursor = nextCursor;
    page += 1;
  } while (cursor !== null);

  return { orderedDids, pages };
}

async function fetchProfilesBatch(dids: string[]): Promise<Map<string, OrderedEntry>> {
  const resolved = new Map<string, OrderedEntry>();

  for (const batch of chunk(dids, PROFILE_BATCH_SIZE)) {
    const url = new URL(`${PUBLIC_BSKY_XRPC_BASE}/app.bsky.actor.getProfiles`);
    for (const did of batch) {
      url.searchParams.append("actors", did);
    }

    const batchResult = await fetchJson(url);
    const batchProfiles = batchResult.ok ? getListFieldAny(batchResult.data, ["profiles"]) : [];
    const batchResolved = new Map<string, OrderedEntry>();

    for (const profile of batchProfiles) {
      if (!profile || typeof profile !== "object") continue;
      const record = profile as JsonMap;
      const did = asString(record.did);
      const handle = asString(record.handle);
      if (!did || !handle) continue;

      batchResolved.set(did, {
        did,
        status: "resolved",
        handle,
        displayName: asString(record.displayName),
      });
    }

    for (const did of batch) {
      const existing = batchResolved.get(did);
      if (existing) {
        resolved.set(did, existing);
        continue;
      }

      const singleUrl = buildXrpcUrl(PUBLIC_BSKY_XRPC_BASE, "app.bsky.actor.getProfile", {
        actor: did,
      });
      const singleResult = await fetchJson(singleUrl);

      if (singleResult.ok) {
        const handle = asString(singleResult.data?.handle);
        if (handle) {
          resolved.set(did, {
            did,
            status: "resolved",
            handle,
            displayName: asString(singleResult.data?.displayName),
          });
          continue;
        }
      }

      resolved.set(did, {
        did,
        status: "unavailable",
        reason: classifyProfileFailure(singleResult),
      });
    }
  }

  return resolved;
}

function printUsage(): void {
  console.error("Usage: bun run profile-context.ts --did <did:plc:...>");
}

async function main(): Promise<void> {
  const { values } = parseArgs({
    args: Bun.argv.slice(2),
    options: {
      did: {
        type: "string",
      },
      help: {
        type: "boolean",
        short: "h",
        default: false,
      },
    },
    strict: true,
    allowPositionals: false,
  });

  if (values.help) {
    printUsage();
    process.exit(0);
  }

  const did = asString(values.did);
  if (!did) {
    printUsage();
    process.exit(1);
  }

  const count = await fetchBlockedByCount(did);
  const distinct = await fetchDistinct(did);
  const backlinks = await fetchAllBacklinkDids(did);
  const hydrated = await fetchProfilesBatch(backlinks.orderedDids);
  const orderedEntries = backlinks.orderedDids.map((blockerDid) => {
    return (
      hydrated.get(blockerDid) ?? {
        did: blockerDid,
        status: "unavailable" as const,
        reason: "Public profile lookup failed",
      }
    );
  });

  const resolvedCount = orderedEntries.filter((entry) => entry.status === "resolved").length;
  const unavailableEntries = orderedEntries.filter((entry) => entry.status === "unavailable");

  console.log(`Target DID: ${did}`);
  console.log(`Microcosm blocked-by count: ${count}`);
  console.log(
    `Microcosm getDistinct: HTTP ${distinct.status}${distinct.ok ? "" : ` ${distinct.text.trim()}`}`,
  );
  console.log("");
  console.log("Backlink pages:");
  for (const page of backlinks.pages) {
    console.log(
      `  page ${page.page}: cursorIn=${page.cursorIn ?? "null"} records=${page.recordCount} cursorOut=${page.cursorOut ?? "null"}`,
    );
  }
  console.log("");
  console.log(`Collected blocker DIDs: ${backlinks.orderedDids.length}`);
  console.log(`Resolved public profiles: ${resolvedCount}`);
  console.log(`Unavailable public profiles: ${unavailableEntries.length}`);
  console.log("");
  console.log("Ordered results:");
  orderedEntries.forEach((entry, index) => {
    if (entry.status === "resolved") {
      const display = entry.displayName ? ` (${entry.displayName})` : "";
      console.log(`${String(index + 1).padStart(2, "0")}. RESOLVED ${entry.did} -> @${entry.handle}${display}`);
      return;
    }

    console.log(`${String(index + 1).padStart(2, "0")}. UNAVAILABLE ${entry.did} -> ${entry.reason}`);
  });
}

await main();
