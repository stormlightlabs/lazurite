---
title: AppView Routing Milestones
updated: 2026-04-29
---

## M1 - Core Routing Model

- [ ] Add `appview_provider` setting with defaults and validation
- [ ] Add login-screen provider selector (Bluesky + Blacksky visible by default)
- [ ] Persist login-screen provider choice before any auth/network call starts
- [ ] Add provider descriptor model (`serviceDid`, `publicBaseUrl`, `entrywayUrl`)
- [ ] Add `AppViewRouter` abstraction for endpoint/header resolution
- [ ] Add unit tests for provider normalization/defaults and bootstrap ordering

## M2 - Header + Request Integration

- [ ] Inject explicit `atproto-proxy` for authenticated `app.bsky.*` requests
- [ ] Route signed-out public `app.bsky.*` reads via selected provider host
- [ ] Ensure `com.atproto.*` flows bypass AppView routing changes
- [ ] Add integration tests for Bluesky/Blacksky provider selection

## M3 - Fallback Engine

- [ ] Add user setting for cross-provider fallback (default off)
- [ ] Implement bounded fallback chain for read-only public endpoints
- [ ] Add circuit-breaker window per provider/endpoint
- [ ] Add structured logs for provider/fallback decisions
- [ ] Add tests for timeout/429/5xx transitions with fallback enabled/disabled

## M4 - microcosm Fallbacks

- [ ] Keep Constellation fallback paths first-class for backlink-style enrichments
- [ ] Add setting-gated Slingshot identity fallback for degraded handle resolution
- [ ] Add tests for fallback parsing and failure handling
- [ ] Document opt-in behavior and trust boundaries

## M5 - Settings and UX

- [ ] Add AppView provider controls in Settings (bluesky/blacksky)
- [ ] Add provider-change confirmation that performs app reset
- [ ] Define reset copy: stay signed in, no local data deletion, restart required
- [ ] Show concise warning about moderation/ranking/provider differences
- [ ] Add advanced diagnostics view (active provider, last fallback, last error)
- [ ] Add manual "Refresh Provider Health" action

## M6 - Auth Flow Alignment

- [ ] Tie OAuth entryway default to selected provider (`bsky.social`/`blacksky.app`)
- [ ] Validate app-password and OAuth flows remain backward compatible
- [ ] Add migration behavior for existing saved sessions/accounts
- [ ] Ensure app-level soft restart rebuilds DI/blocs/repositories after provider switch
- [ ] Ensure stale pre-reset responses are ignored (routing epoch/version guard)

## M7 - Hardening and Release

- [ ] Add provider health probes at startup
- [ ] Add capability matrix checks before retries
