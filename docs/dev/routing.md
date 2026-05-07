---
title: AppView Routing
updated: 2026-05-07
---

Lazurite can route AppView reads through Bluesky, Blacksky, or a validated
custom provider. The selected provider controls `app.bsky.*` content routing
and web-link resolution. It does not decide where the user's account
authenticates; OAuth authority still comes from the account's PDS metadata.

## Provider Model

Provider selection is persisted from login and settings. Built-in providers
define a stable key, AppView service DID, public XRPC host, login entryway, and
web base URL. Custom providers require validation before use.

`AppViewRouter` in `lib/core/network/app_view_router.dart` is the runtime
source of provider state. Repositories should ask it for headers, public
endpoint URLs, auth entryway URLs, web-link resolution, and health results.
Long-lived services should not cache provider fields independently.

## Request Policy

`AppBskyRoutingPolicy` applies the request policy. Authenticated `app.bsky.*`
requests route through the user's PDS with an explicit `atproto-proxy` header
for the selected AppView. Signed-out public `app.bsky.*` reads call the
selected provider's public host directly. `com.atproto.*` requests bypass
AppView routing and resolve to the relevant repo or PDS.

Provider switching requires a soft restart. The app persists the new provider,
stops new requests, cancels in-flight work where possible, rebuilds dependency
injection, and drops stale responses by routing epoch. This prevents mixed
provider state across long-lived Cubits and repositories.

## Fallbacks

Cross-provider fallback is opt-in and limited to read-only public endpoints. It
can retry transient failures such as rate limits, server errors, timeouts, or
DNS failure against another built-in provider. It must not retry writes across
providers.

Identity fallback through Slingshot and backlink enrichment through
Constellation are separate settings and separate trust boundaries. Treat
fallback data as recovery or enrichment, not as authority for writes.

## Health And Capability

Provider health probes run at startup and through a manual settings action.
Capability checks track specific endpoints such as profile reads, post-thread
reads, trends, and trending topics. The router uses capability state to avoid
blind retries against a provider that does not support a path.

Logs should include provider, endpoint, fallback reason, and circuit-breaker
state without including auth tokens or full payloads.

## Trending

Trending is a route at `/trending`. `TrendingScreen` loads trending topics and
trend metadata from the selected provider. `lib/features/feed/data/trending_join.dart`
joins topic rows with trend rows by parsed link key first, then by normalized
topic text. If multiple candidates match, the newest trend wins, with a stable
link tie-breaker.

The screen handles provider divergence. Bluesky and Blacksky can return
different link formats and suggested topic sets. Unknown internal links fall
back to provider-aware external URLs. If topic loading fails, the screen shows a
blocking error. If topic loading succeeds but metadata fails, the screen renders
usable topic rows with a non-blocking metadata warning.

## OAuth Boundary

Selected AppView controls content reads. OAuth host selection starts with the
account authority: resolve handle or DID, fetch protected-resource metadata, and
prefer the advertised authorization server. Fallbacks can use the resolved PDS,
then default entryways, but the selected AppView must not override account
authority.
