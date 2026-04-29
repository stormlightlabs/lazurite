---
title: AppView Routing + Trending (Bluesky + Blacksky + microcosm Fallbacks)
updated: 2026-04-29
---

Introduce explicit AppView routing so Lazurite can target:

1. Bluesky (`did:web:api.bsky.app#bsky_appview`)
2. Blacksky (`did:web:api.blacksky.community#bsky_appview`)
3. microcosm fallbacks for specific degraded paths (identity and backlink enrichments)

Design goal: route intentionally, fail predictably, and avoid hidden dependence on one provider.

## Product Decisions

1. Provider selection is chosen on the login screen.
2. Provider selection can be changed in Settings, but change requires app reset.
3. Cross-provider fallback (A -> B) is user-controlled (default off).
4. Slingshot identity fallback is setting-gated.
5. Provider health/capability probes run at startup, with manual refresh in Settings.
6. Blacksky is available by default on login/onboarding.
7. Trending is first-class: Home/Feed includes a Trending action, and app has a dedicated Trending screen.

## Current State (Lazurite)

- OAuth entryway is hardcoded to `bsky.social` in auth flow.
- There is no shared AppView routing abstraction and no user-selectable AppView provider.
- Home feed app bar has feed-management action only; no Trending action.
- Router has no `/trending` route.

## Research Findings

### 1. Routing and proxy expectations

- `app.bsky.*` should route via user PDS for authenticated requests, with explicit `atproto-proxy` toward selected AppView.
- Public `app.bsky.*` reads can call AppView host directly (`public.api.bsky.app` for Bluesky).
- Clients should not rely on legacy default forwarding behavior.

### 2. Verified AppViews and compatibility (live checks, 2026-04-29)

- Bluesky DID/service:
  - `did:web:api.bsky.app#bsky_appview`
  - public host: `https://public.api.bsky.app`
- Blacksky DID/service:
  - `did:web:api.blacksky.community#bsky_appview`
  - public host: `https://api.blacksky.community`
- Both hosts currently respond for:
  - `app.bsky.actor.getProfile`
  - `app.bsky.unspecced.getTrends`
  - `app.bsky.unspecced.getTrendingTopics`

### 3. Trending endpoint contract (official lexicons)

- `app.bsky.unspecced.getTrends`
  - params: `limit` (default 10, min 1, max 25)
  - output: `trends[]` (`trendView`)
- `app.bsky.unspecced.getTrendingTopics`
  - params: `viewer?` DID, `limit` (default 10, min 1, max 25)
  - output: `topics[]` + `suggested[]` (`trendingTopic`)

### 4. Live provider divergence relevant to UI

- Bluesky `getTrendingTopics` currently returns both `topics` and non-empty `suggested`.
- Blacksky `getTrendingTopics` currently returns `topics` and often empty `suggested`.
- Link formats differ:
  - Bluesky trend links often `/profile/.../feed/...`
  - Blacksky trend links often `/topic/<id>`

### 5. Other AppViews in ecosystem

- There are additional self-hosted/experimental AppView implementations in the ecosystem.
- For this phase, treat these as `custom` providers only (advanced path), not default onboarding options, until each candidate is validated for DID/service health and endpoint parity.

## Design

### AppView provider model

Add settings-backed provider selection:

- `bluesky` (default)
- `blacksky`
- `custom` (advanced, validation-gated)

Provider descriptor:

```dart
class AppViewProvider {
  final String key; // bluesky, blacksky, custom
  final String serviceDid; // did:web:...#bsky_appview
  final Uri publicBaseUrl; // public app.bsky host
  final Uri entrywayUrl; // login/account entryway
  final Uri webBaseUrl; // provider web base for relative trend links
}
```

Built-in defaults:

- Bluesky: `public.api.bsky.app`, `bsky.social`, `https://bsky.app`
- Blacksky: `api.blacksky.community`, `blacksky.app`, `https://blacksky.app`

### Router abstraction

Introduce `AppViewRouter` as single source of truth:

- `Map<String, String> appBskyProxyHeaders()`
- `Uri publicEndpoint(String xrpcPath, Map<String, String> query)`
- `Uri entrywayForAuth()`
- `Uri resolveWebLink(String relativeOrAbsolute)`
- `Future<AppViewHealth> probeProvider()`

### Request routing policy

1. Authenticated `app.bsky.*`
- Route through PDS.
- Set explicit `atproto-proxy` to selected provider DID.

2. Signed-out/public `app.bsky.*`
- Call selected provider `publicBaseUrl` directly.

3. `com.atproto.*`
- Never AppView-routed; resolve PDS by DID/handle as normal.

### Trending UX and routing

1. Home app bar adds `Trending` action button.
- Route target: `/trending`.

2. Add dedicated `TrendingScreen`.
- Primary data source: `getTrendingTopics(limit=10)`.
- Required enrichment (initial implementation): `getTrends(limit=10)` for richer metadata (actors, postCount, status/category).
- UI sections:
  - `Topics`
  - `Suggested` (hidden when empty)

Implementation note:

- The first shipped Trending screen must join `getTrendingTopics` + `getTrends` data in one load flow.
- If `getTrends` fails and cross-provider fallback is disabled or unavailable, render `topics` with a degraded metadata state and explicit non-blocking error indicator.

Deterministic join contract:

- Build a stable join key for both `topics[]` and `trends[]` before matching.
- Key precedence (in order):
1. Parsed link key (preferred):
  - `/topic/<id>` -> `topic:<id>`
  - `/profile/<actor>/feed/<rkey>` -> `feed:<actor>:<rkey>`
2. Normalized topic string fallback:
  - lowercase
  - trim
  - collapse internal whitespace
  - drop leading `#`
- Matching algorithm:
1. Try exact parsed-link-key match.
2. If absent, try normalized-topic-string match.
3. If multiple trend candidates match, pick the candidate with newest `startedAt`.
4. If still tied, pick lexicographically smallest `link` for deterministic output.
5. If no match, keep topic row and mark metadata as unavailable.

Trending UI state contract:

- `topics` load success + `trends` load success:
  - render fully enriched rows (actors/postCount/status/category when present).
- `topics` load success + `trends` degraded/failure:
  - render topic rows without metadata fields.
  - show non-blocking banner/chip: `Metadata temporarily unavailable`.
  - keep row navigation actions enabled.
- `topics` failure:
  - render blocking error state for Trending screen.

3. Trend row actions:
- Use provider-aware `resolveWebLink` for relative links.
- If link maps to supported internal route, deep-link internally.
- If unsupported, open external browser to provider `webBaseUrl + link`.

4. Link parsing safety:
- Never assume one provider link format.
- Support at least:
  - `/profile/<actor>/feed/<rkey>`
  - `/topic/<id>`
- Unknown path formats degrade to external open.

### Fallback policy (defensive)

1. Try selected provider.
2. If cross-provider fallback setting is ON, then on transient read failures (`429`, `5xx`, timeout, DNS):
- Try alternate built-in provider for read-only public endpoints.
3. For non-AppView enrichments:
- Backlink/index enrichments: Constellation.
- Identity fallback: Slingshot `resolveMiniDoc` only when enabled.
4. Log fallback reason/provider and apply endpoint-level circuit breaker.

Do not fallback across write operations.

### Capability gating

Track endpoint support per provider to avoid blind retries:

- `app.bsky.actor.getProfile`
- `app.bsky.feed.getPostThread`
- `app.bsky.unspecced.getTrends`
- `app.bsky.unspecced.getTrendingTopics`

### Reset UX contract (recommended)

Best contract for provider switching:

1. User selects provider in Settings.
2. Blocking confirmation sheet:
- `Apply and restart now`
- `Cancel`
- Copy: user stays signed in; no local DB wipe.
3. On confirm, perform soft restart:
- Persist provider first.
- Stop new requests and cancel in-flight work.
- Tear down and rebuild app-level DI/blocs/services.
- Return to bootstrap and rehydrate from persisted state.

This avoids mixed in-memory routing state while preserving session continuity.

### State safety requirements

1. `AppViewRouter` is the only runtime source of provider state.
2. Long-lived repos/blocs must not cache provider independently.
3. Provider switch blocks new requests until rebuild completes.
4. Use routing epoch/version so stale pre-reset responses are dropped.

### Login-time persistence ordering

1. Persist login-screen provider selection before any auth/network request.
2. Disable login submission while persistence is in-flight.
3. Construct auth/network clients only after provider setting loads at bootstrap.

### Health probes

- Run once at startup.
- Expose manual `Refresh Provider Health` in Settings.
- No periodic background probes in this phase.

## Adversarial checks

1. Provider advertises `#bsky_appview` but partially implements endpoints.
2. Semantics diverge even when endpoint exists (moderation, trends, topic links).
3. Docs can lag live infrastructure.
4. Trend link paths can drift by provider/version.

Mitigation:

- Startup capability probes.
- Endpoint-level fallback gates.
- Structured logs + provider failure counters.
- Defensive link resolver with safe external fallback.

## Testing Strategy

### Unit

- Provider selection/normalization.
- Login-time provider persistence before auth call.
- Bootstrap ordering (no client creation before provider load).
- Routing epoch stale-response guard.
- Header injection (`atproto-proxy`).
- Fallback + circuit-breaker transitions.
- Trending limit clamping (1..25).
- Trend link parsing and resolver fallback behavior.
- Deterministic topic/trend join precedence and tie-break behavior.
- Topic-string normalization behavior for join fallback.

### Integration

- `/trending` route reachable from Home button.
- Bluesky and Blacksky trending fetch paths.
- Empty `suggested` renders cleanly.
- `topics` success + `trends` failure renders degraded metadata indicator with usable navigation.
- Forced primary failure with fallback ON/OFF.
- Provider switch soft restart fully rebuilds routing consumers.

### Regression

- `com.atproto.*` unaffected.
- OAuth/App Password flows keep correct PDS behavior.
- Provider switch does not mix stale in-memory routing state.

## Non-goals (this phase)

- Auto-switch providers for write operations.
- Unvalidated public listing of arbitrary third-party AppViews in onboarding.
- Replacing existing Constellation features.

## Sources

- <https://docs.bsky.app/docs/advanced-guides/api-directory>
- <https://docs.bsky.app/blog/2025-protocol-roadmap-spring>
- <https://api.bsky.app/.well-known/did.json>
- <https://api.blacksky.community/.well-known/did.json>
- <https://raw.githubusercontent.com/bluesky-social/atproto/main/lexicons/app/bsky/unspecced/getTrends.json>
- <https://raw.githubusercontent.com/bluesky-social/atproto/main/lexicons/app/bsky/unspecced/getTrendingTopics.json>
- <https://raw.githubusercontent.com/bluesky-social/atproto/main/lexicons/app/bsky/unspecced/defs.json>
- <https://raw.githubusercontent.com/bluesky-social/atproto/main/lexicons/app/bsky/unspecced/getTrendsSkeleton.json>
- <https://www.microcosm.blue/>
- <https://constellation.microcosm.blue/>
- <https://slingshot.microcosm.blue/>
- <https://tangled.org/why.bsky.team/konbini>
- <https://sdk.blue/>
