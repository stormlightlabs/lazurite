---
title: AppView Routing (Bluesky + Blacksky + microcosm Fallbacks)
updated: 2026-04-29
---

Introduce explicit AppView routing so Lazurite can target:

1. Bluesky (`did:web:api.bsky.app#bsky_appview`)
2. Blacksky (`did:web:api.blacksky.community#bsky_appview`)
3. microcosm fallbacks for specific degraded paths (identity and backlink-style enrichments)

Design goal: route intentionally, fail predictably, and avoid hidden dependence on any single provider.

## Product Decisions

1. Provider selection is chosen on the login screen.
2. Provider selection can be changed later in Settings, but change requires app reset.
3. Cross-provider fallback (provider A -> provider B) is user-controlled, not automatic by default.
4. Slingshot identity fallback is controlled by a setting.
5. Provider health/capability probes run at startup, with manual refresh in Settings.
6. Blacksky must be available by default on login/onboarding (no advanced-toggle gate).

## Current State (Lazurite)

- OAuth entryway is currently hardcoded to `bsky.social` in auth flow.
- App-level settings already support configurable network services in some areas:
  - Typeahead provider (`bluesky`/`community`)
  - Constellation base URL (default `https://constellation.microcosm.blue`)
- Public profile context lookups already use direct AppView host `public.api.bsky.app` in one path.
- There is no shared AppView routing abstraction and no user-selectable AppView provider.

## Research Findings

### 1. Official routing expectations

- Bluesky docs: authenticated `app.bsky.*` requests go through the user's PDS and are proxied to AppView.
- Bluesky docs: public `app.bsky.*` endpoints can be called directly on `https://public.api.bsky.app`.
- AT Protocol roadmap: clients should set `atproto-proxy` explicitly and should not depend on legacy default forwarding.

### 2. Live AppView DID documents (verified)

- `https://api.bsky.app/.well-known/did.json` includes:
  - `#bsky_appview` at `https://api.bsky.app`
  - `#bsky_notif` at `https://api.bsky.app`
- `https://api.blacksky.community/.well-known/did.json` includes:
  - `#bsky_appview` at `https://api.blacksky.community`
  - `#bsky_notif` at `https://api.blacksky.community`

### 3. Live Blacksky API compatibility (spot checks)

- `https://api.blacksky.community/xrpc/app.bsky.actor.getProfile?...` returns valid profile payload.
- `https://api.blacksky.community/xrpc/app.bsky.unspecced.getTrends` returns trends payload.

### 4. microcosm services (verified)

- Constellation endpoint is live for backlink-style counts:
  - `https://constellation.microcosm.blue/xrpc/blue.microcosm.links.getBacklinksCount`
- Slingshot identity endpoint is live:
  - `https://slingshot.microcosm.blue/xrpc/com.bad-example.identity.resolveMiniDoc`
  - Returns DID, handle, and PDS.

## Design

### AppView provider model

Add settings-backed provider selection:

- `bluesky` (default)
- `blacksky`
- `custom` (optional advanced path; disabled in UI until validated)

Selection lifecycle:

- Initial selection is made on the login screen before auth flow starts.
- Post-login changes are allowed in Settings but must trigger an app reset flow to avoid mixed-session routing state.

Provider descriptor:

```dart
class AppViewProvider {
  final String key; // bluesky, blacksky, custom
  final String serviceDid; // did:web:...#bsky_appview
  final Uri publicBaseUrl; // public unauthenticated app.bsky host
  final Uri entrywayUrl; // login/account entryway
}
```

Built-in defaults:

- Bluesky:
  - service DID: `did:web:api.bsky.app#bsky_appview`
  - public base: `https://public.api.bsky.app`
  - entryway: `https://bsky.social`
- Blacksky:
  - service DID: `did:web:api.blacksky.community#bsky_appview`
  - public base: `https://api.blacksky.community`
  - entryway: `https://blacksky.app`

### Router abstraction

Introduce `AppViewRouter` as a single source of truth:

- `Map<String, String> appBskyProxyHeaders()`
- `Uri publicEndpoint(String xrpcPath, Map<String, String> query)`
- `Uri entrywayForAuth()`
- `Future<AppViewHealth> probeProvider()`

This keeps routing policy out of individual repositories.

### Request routing policy

1. **Authenticated `app.bsky.*`**
   - Route through PDS as today.
   - Explicitly set `atproto-proxy` to selected provider DID.
2. **Signed-out/public `app.bsky.*`**
   - Call selected provider `publicBaseUrl` directly.
3. **`com.atproto.*`**
   - Never AppView-routed. Resolve target PDS by DID/handle as normal.

### Fallback policy (defensive)

Fallback order must be explicit and bounded:

1. Try selected provider.
2. If user enabled "Cross-provider fallback", then on transient failure (`429`, `5xx`, timeout, DNS):
   - Try alternate built-in provider for read-only public endpoints.
3. For specific non-AppView enrichments:
   - Backlink/social graph counts and related index lookups: Constellation.
   - Identity mini-doc resolution when handle resolution is flaky: Slingshot `resolveMiniDoc` (only when enabled in settings).
4. Record failure reason and chosen fallback in logs.
5. Apply a short circuit-breaker window per failed provider/endpoint to prevent retry storms.

Do not fallback across write operations.

### Capability gating

Track endpoint support per provider to avoid blind retries:

- `app.bsky.actor.getProfile` (public read): bluesky + blacksky
- `app.bsky.feed.getPostThread` (public read): bluesky + blacksky
- `app.bsky.unspecced.getTrends` (public read): bluesky + blacksky (verify by probe)
- Custom namespaces: provider-specific only

### Auth and account UX implications

- If user selects Blacksky provider, default login entryway should become `https://blacksky.app`.
- Existing accounts keep current PDS/session behavior; AppView selection changes only request routing.
- Add a warning in settings: provider choice affects content ranking, moderation context, and availability.
- Login/onboarding must show both Bluesky and Blacksky as first-class provider options by default.
- Changing provider in settings must present a reset confirmation flow.

### Reset UX contract (recommended)

Best UX contract for provider switching:

1. User selects a new provider in Settings.
2. App shows a blocking confirmation sheet:
   - "Apply and restart now"
   - "Cancel"
   - Message: "You will remain signed in. No local data will be deleted."
3. On confirm, app performs a soft restart:
   - Persist new provider selection first.
   - Cancel in-flight requests.
   - Tear down and rebuild app-level DI/blocs/repositories.
   - Return to bootstrap/splash and rehydrate from persisted state.

For this phase, do not log out users and do not wipe local database on provider change.

### State safety requirements

To avoid mixed in-memory routing state:

1. `AppViewRouter` is the only runtime source of provider state.
2. Long-lived repositories/blocs must not cache provider values separately.
3. Provider switch path must block new requests until rebuild completes.
4. Use a routing epoch/version so stale pre-reset responses are ignored post-reset.

### Login-time persistence ordering

To ensure provider choice is honored from first network call:

1. Persist login-screen provider choice before starting OAuth/app-password calls.
2. Disable login submission while provider persistence is in flight.
3. Construct auth/network clients only after persisted provider is available in bootstrap.

### Health probes

- Run provider health/capability probes once at startup.
- Expose a manual "Refresh Provider Health" control in Settings.
- Do not run periodic background probes in this phase.

## Adversarial checks (assumptions to challenge)

1. A provider advertises `#bsky_appview` but only partially implements endpoints.
2. A provider endpoint is live but semantically diverges (labels, trends, moderation filters).
3. Docs may lag live infrastructure (observed for Blacksky roadmap vs live API host).
4. Transient success can mask long-tail reliability problems without health telemetry.

Mitigation:

- Runtime capability probes.
- Endpoint-level fallback gates.
- Structured logs + per-provider failure counters.

## Testing Strategy

### Unit

- Provider selection and normalization.
- Login-time provider selection persistence + settings-change reset requirement.
- Bootstrap ordering: no auth/network client creation before provider setting load.
- Routing epoch/version stale-response guard behavior.
- Header injection (`atproto-proxy`) per request class.
- Fallback state machine and circuit breaker behavior.
- Capability matrix enforcement.

### Integration

- Signed-out profile/thread fetch through Bluesky and Blacksky.
- Forced primary failure -> alternate provider fallback (when enabled).
- Forced primary failure -> no cross-provider fallback (when disabled).
- Constellation + Slingshot fallback success path.

### Regression

- Ensure `com.atproto.*` routes are unaffected.
- Ensure OAuth/App Password auth flows still resolve correct PDS.

## Non-goals (for this phase)

- Supporting arbitrary third-party AppViews in UI without validation.
- Automatic provider switching for write endpoints.
- Replacing existing Constellation features.

## Sources

- <https://docs.bsky.app/docs/advanced-guides/api-directory>
- <https://atproto.com/blog/2025-protocol-roadmap-spring>
- <https://api.bsky.app/.well-known/did.json>
- <https://api.blacksky.community/.well-known/did.json>
- <https://docs.blacksky.community/list-of-our-services>
- <https://www.microcosm.blue/>
- <https://constellation.microcosm.blue/>
- <https://slingshot.microcosm.blue/>
