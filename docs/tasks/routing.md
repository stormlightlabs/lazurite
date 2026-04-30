---
title: AppView Routing + Trending Milestones
updated: 2026-04-30
---

## M1 - Core Routing Model

- [x] Add `appview_provider` setting with defaults and validation
- [x] Add login-screen provider selector (Bluesky + Blacksky visible by default)
- [x] Persist login-screen provider choice before any auth/network call
- [x] Add provider descriptor (`serviceDid`, `publicBaseUrl`, `entrywayUrl`, `webBaseUrl`)
- [x] Add `AppViewRouter` abstraction for endpoint/header/link resolution
- [x] Add unit tests for provider normalization/defaults and bootstrap ordering

## M2 - Header + Request Integration

- [x] Inject explicit `atproto-proxy` for authenticated `app.bsky.*`
- [x] Route signed-out public `app.bsky.*` reads via selected provider host
- [x] Ensure `com.atproto.*` bypasses AppView routing

## M3 - Trending Surface

- [x] Add Home app bar `Trending` action button
- [x] Add `/trending` route and `TrendingScreen`
- [x] Implement `getTrendingTopics(limit=10)` fetch path
- [x] Implement required `getTrends(limit=10)` enrichment path for richer metadata
- [x] Hide `Suggested` section when provider returns empty list
- [x] Add loading/empty/error states for trending screen
- [x] Add analytics/logging for provider and fallback used on trending requests

## M4 - Trend Link Routing

- [x] Add provider-aware trend link resolver (`resolveWebLink`)
- [x] Support `/profile/<actor>/feed/<rkey>` links
- [x] Support `/topic/<id>` links
- [x] Degrade unknown link formats to safe external open
- [x] Add unit tests for link parsing and fallback resolution

## M5 - Fallback Engine

- [x] Add user setting for cross-provider fallback (default off)
- [x] Implement bounded fallback chain for read-only public endpoints
- [x] Add circuit-breaker window per provider/endpoint
- [x] Add structured logs for provider/fallback decisions
- [x] Add tests for timeout/429/5xx transitions with fallback enabled/disabled

## M6 - microcosm Fallbacks

- [x] Keep Constellation fallback paths first-class for backlink enrichments
- [x] Add setting-gated Slingshot identity fallback for degraded handle resolution
- [x] Add tests for fallback parsing and failure handling
- [x] Document opt-in behavior and trust boundaries

## M7 - Settings and UX

- [ ] Add AppView provider controls in Settings (Bluesky/Blacksky)
- [ ] Add provider-change confirmation that performs app soft restart
- [ ] Confirm reset copy: stay signed in, no local data deletion
- [ ] Show concise warning about moderation/ranking/provider differences
- [ ] Add diagnostics view (active provider, last fallback, last error)
- [ ] Add manual `Refresh Provider Health` action

## M8 - Auth + Reset Safety

- [x] Resolve OAuth entryway from account authority first (PDS `authorization_servers`), with provider/default fallbacks
- [ ] Ensure app-password and OAuth flows remain backward compatible
- [ ] Add migration behavior for existing saved sessions/accounts
- [ ] Ensure provider switch rebuilds DI/blocs/services before new requests
- [ ] Add routing epoch/version guard to drop stale pre-reset responses

## M9 - Hardening + Release

- [ ] Run provider health probes at startup
- [ ] Gate retries by capability matrix (`getTrends`, `getTrendingTopics`, etc.)
- [ ] Add end-to-end regression coverage for routing + trending + fallback flows
- [ ] Stage rollout behind feature flag if telemetry indicates instability
