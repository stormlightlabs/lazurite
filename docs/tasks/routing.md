---
title: AppView Routing + Trending Milestones
updated: 2026-04-29
---

## M1 - Core Routing Model

- [x] Add `appview_provider` setting with defaults and validation
- [x] Add login-screen provider selector (Bluesky + Blacksky visible by default)
- [x] Persist login-screen provider choice before any auth/network call
- [x] Add provider descriptor (`serviceDid`, `publicBaseUrl`, `entrywayUrl`, `webBaseUrl`)
- [x] Add `AppViewRouter` abstraction for endpoint/header/link resolution
- [x] Add unit tests for provider normalization/defaults and bootstrap ordering

## M2 - Header + Request Integration

- [ ] Inject explicit `atproto-proxy` for authenticated `app.bsky.*`
- [ ] Route signed-out public `app.bsky.*` reads via selected provider host
- [ ] Ensure `com.atproto.*` bypasses AppView routing
- [ ] Add integration tests for Bluesky/Blacksky provider selection

## M3 - Trending Surface

- [ ] Add Home app bar `Trending` action button
- [ ] Add `/trending` route and `TrendingScreen`
- [ ] Implement `getTrendingTopics(limit=10)` fetch path
- [ ] Implement required `getTrends(limit=10)` enrichment path for richer metadata
- [ ] Hide `Suggested` section when provider returns empty list
- [ ] Add loading/empty/error states for trending screen
- [ ] Add analytics/logging for provider and fallback used on trending requests

## M4 - Trend Link Routing

- [ ] Add provider-aware trend link resolver (`resolveWebLink`)
- [ ] Support `/profile/<actor>/feed/<rkey>` links
- [ ] Support `/topic/<id>` links
- [ ] Degrade unknown link formats to safe external open
- [ ] Add unit tests for link parsing and fallback resolution

## M5 - Fallback Engine

- [ ] Add user setting for cross-provider fallback (default off)
- [ ] Implement bounded fallback chain for read-only public endpoints
- [ ] Add circuit-breaker window per provider/endpoint
- [ ] Add structured logs for provider/fallback decisions
- [ ] Add tests for timeout/429/5xx transitions with fallback enabled/disabled

## M6 - microcosm Fallbacks

- [ ] Keep Constellation fallback paths first-class for backlink enrichments
- [ ] Add setting-gated Slingshot identity fallback for degraded handle resolution
- [ ] Add tests for fallback parsing and failure handling
- [ ] Document opt-in behavior and trust boundaries

## M7 - Settings and UX

- [ ] Add AppView provider controls in Settings (Bluesky/Blacksky)
- [ ] Add provider-change confirmation that performs app soft restart
- [ ] Confirm reset copy: stay signed in, no local data deletion
- [ ] Show concise warning about moderation/ranking/provider differences
- [ ] Add diagnostics view (active provider, last fallback, last error)
- [ ] Add manual `Refresh Provider Health` action

## M8 - Auth + Reset Safety

- [ ] Tie OAuth entryway default to selected provider (`bsky.social` / `blacksky.app`)
- [ ] Ensure app-password and OAuth flows remain backward compatible
- [ ] Add migration behavior for existing saved sessions/accounts
- [ ] Ensure provider switch rebuilds DI/blocs/services before new requests
- [ ] Add routing epoch/version guard to drop stale pre-reset responses

## M9 - Hardening + Release

- [ ] Run provider health probes at startup
- [ ] Gate retries by capability matrix (`getTrends`, `getTrendingTopics`, etc.)
- [ ] Add end-to-end regression coverage for routing + trending + fallback flows
- [ ] Stage rollout behind feature flag if telemetry indicates instability
