---
title: Notification Architecture
updated: 2026-04-29
---

## Summary

Lazurite currently supports in-app notifications (alerts feed + unread badge), but
it does not deliver OS-level notifications when the app is backgrounded or killed.
This spec defines a defensive, staged path from polling-only behavior to robust
push + local notification delivery.

## Current State (Lazurite)

What exists today:

- `app.bsky.notification.listNotifications` for alerts feed
- `app.bsky.notification.getUnreadCount` polled every 30s in foreground
- `app.bsky.notification.updateSeen` on read/open flows
- `workmanager` already integrated for scheduled posts

What is missing:

- No device push token lifecycle
- No `registerPush` / `unregisterPush` integration
- No local notification renderer/channels/categories
- No durable dedupe state for "already notified" events
- No background notification sync worker

## Research Findings

### Bluesky notification APIs

Core endpoints (auth required):

- `app.bsky.notification.listNotifications`
  - Params include `cursor`, `limit` (1-100), optional `reasons`, optional `seenAt`
  - Response includes `notifications[]`, optional `cursor`, optional `seenAt`
- `app.bsky.notification.getUnreadCount`
  - Returns unread `count`
- `app.bsky.notification.updateSeen`
  - Marks notifications as seen at a timestamp
- `app.bsky.notification.registerPush`
  - Required body: `serviceDid`, `token`, `platform`, `appId`
  - Optional body: `ageRestricted`
- `app.bsky.notification.unregisterPush`
  - Required body: `serviceDid`, `token`, `platform`, `appId`
- `app.bsky.notification.putPreferencesV2`
  - Server-side notification preference controls (follow/like/reply/etc.)

Important nuance:

- Official Bluesky app passes an `atproto-proxy` header for push registration:
  `did:web:api.bsky.app#bsky_notif`
- Official Bluesky app uses `serviceDid: did:web:api.bsky.app` (or staging DID)

### Reference implementation patterns

Strong patterns worth reusing:

- Android FCM entrypoint (`FirebaseMessagingService`) parses push payload keys:
  `senderDid`, `targetDid`, `recordUri`, `reason`
- Push payload is treated as a trigger, not trusted display content:
  - Resolve full record via authenticated API
  - Apply moderation/filtering before display
- Defensive processing contract:
  - Timeout-bound notification processing (10s)
  - Explicit processed/dropped ack state
  - Dedup by stable notification identifiers
- Permission UX:
  - Runtime request + rationale + settings fallback
- Delivery UX:
  - Channel per reason family (likes/replies/follows/etc.)
  - Deep links for post/profile targets

Architecture-specific behavior to avoid coupling to:

- Routing token registration through a custom backend endpoint can be valid, but
  it is optional and not required for a direct Bluesky `registerPush` strategy.

### Platform/Flutter constraints

- Android 13+: `POST_NOTIFICATIONS` runtime permission required
- Android periodic background work minimum interval is 15 minutes
- Android exact-alarm behavior tightened on Android 14 (not suitable as default)
- iOS background execution is system-managed and non-deterministic
  (`earliestBeginDate` is not a guarantee)
- iOS background push updates are low priority and can be throttled
- Flutter background handlers must be top-level entry points
  (`@pragma('vm:entry-point')` where required)

## Assumptions and Open Questions

Assumptions (to validate during implementation):

- Lazurite can register directly against Bluesky notification service DID
  (`did:web:api.bsky.app`) using `atproto-proxy: ...#bsky_notif`.
- Notification payload and reason mapping from Bluesky are stable enough to map
  into local channel/category policy.

Open questions:

- Multi-account policy: should each account register separate token records?
- Opt-out semantics: unregister on logout vs keep per-account registration?
- Should we support Android foreground service fallback for tighter latency, or
  accept periodic/background best-effort only?
- Do we expose per-reason push toggles locally first, or defer to server-side
  `putPreferencesV2` only?

## Architecture Options

### Option A: Polling only (foreground + background)

Pros:

- No FCM/APNs setup required
- Simpler backend story

Cons:

- Delayed delivery (>=15 min in background)
- iOS execution unpredictability
- Higher API/battery overhead

### Option B: Push only

Pros:

- Fastest delivery
- Lower polling load

Cons:

- Requires strict token lifecycle and permission handling
- Delivery depends on push transport + payload correctness

### Option C: Hybrid (recommended)

- Push is primary trigger for near-real-time delivery
- Polling remains as fallback and for reconciliation
- Foreground unread badge polling can remain lightweight

## Recommended Design

### 1. NotificationDomainService

Create a domain orchestrator that all entry points call:

- `onForegroundTick()` (badge + optional reconcile)
- `onBackgroundTick()` (reconcile window)
- `onPushPayload(Map<String, String>)`
- `markSeen(DateTime at)`

Responsibilities:

- Parse/validate payload defensively
- Fetch canonical notification details from Bluesky
- Filter by moderation + user prefs
- Dedupe and persist delivery state
- Trigger OS local notification display

### 2. Push token lifecycle

Add `PushRegistrationService`:

- Acquire platform token (FCM/APNs bridge)
- Register with Bluesky `registerPush`
- Re-register on token refresh, login, account switch, app upgrade
- Unregister on logout/account removal (`unregisterPush`)

Inputs:

- `serviceDid` (prod/staging aware)
- `platform` (`ios`/`android`)
- `appId` (bundle/package identifier)
- `token`

### 3. Local notifications

Use a local notification adapter abstraction with platform implementations.

- Android:
  - Channel groups by reason family (`mentions`, `replies`, `follows`, `likes`, `misc`)
  - Tap routes to `/post?uri=...` or `/profile/view?actor=...`
- iOS:
  - Category identifiers for future actions
  - Deep link userInfo payload for route restoration

### 4. Dedupe + delivery state (Drift)

Add a new table (with migration): `notification_deliveries`

Suggested fields:

- `id` (PK)
- `accountDid` (text)
- `notificationUri` (text, indexed)
- `notificationCid` (text nullable)
- `reason` (text)
- `indexedAt` (datetime)
- `source` (`push|poll`)
- `deliveredAt` (datetime)
- `openedAt` (datetime nullable)
- `dismissedAt` (datetime nullable)
- unique constraint on (`accountDid`, `notificationUri`)

Use this table to avoid duplicate OS notifications across push and poll paths.

### 5. Background execution

Reuse existing `workmanager` foundation.

- Android:
  - Periodic reconcile task at 15m+ cadence
  - Network-connected constraint
- iOS:
  - Background fetch / BGTaskScheduler best-effort reconcile
  - Keep tasks short and idempotent

### 6. Permission UX

- Ask only after contextual primer (alerts/home), not on first launch
- On deny, show "Open Settings" path
- Keep in-app alerts functional even when OS permission is denied

## Rollout Plan

### Phase N0 - Foundation hardening

- Extract notification orchestration service
- Add delivery-state persistence + migrations
- Keep behavior polling-only

### Phase N1 - Local notifications from polling

- Emit OS local notifications for new unseen items discovered via reconcile
- Validate routing, dedupe, and permissions

### Phase N2 - Push registration and handling

- Add token registration/unregistration
- Add background push payload handler -> fetch canonical record -> display

### Phase N3 - Preference integration

- Add server preference sync (`getPreferences` / `putPreferencesV2`)
- Add local controls mapped to server fields

### Phase N4 - Reliability/observability

- Add structured notification logs + debug screen counters
- Add failure metrics (token register failures, dropped payloads, dedupe suppressions)

## Testing Strategy

Required coverage per phase:

- Unit tests:
  - Payload parsing/validation
  - Dedupe decisions
  - token lifecycle state machine
- Bloc/cubit tests:
  - Permission gating
  - unread count reconcile behavior
- Integration tests:
  - deep link open from notification payload
  - background worker reconciliation path
- Manual smoke matrix:
  - Android 13+ deny/allow paths
  - iOS allow/deny/settings round trip
  - multi-account register/unregister correctness

## Risks and Mitigations

- Risk: Duplicate alerts from push + poll race
  - Mitigation: persisted dedupe with unique key on notification URI
- Risk: Background handlers killed or delayed
  - Mitigation: hybrid model + reconcile worker + idempotent processing
- Risk: API/proxy mismatches for `registerPush`
  - Mitigation: stage against test account, log raw request/response status
- Risk: Permission denial degrades trust
  - Mitigation: contextual request timing, clear fallback behavior

## Deferred (Not in initial rollout)

- Rich actions (reply/like from notification shade)
- Notification grouping by thread/conversation
- Server-driven quiet hours / digest mode
- Desktop/web parity
