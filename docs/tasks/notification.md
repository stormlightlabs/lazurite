---
title: Notification Milestones
updated: 2026-04-29
---

## M1 - Foundation Hardening (Polling Baseline)

- [x] Introduce `NotificationDomainService` orchestration layer
- [x] Add Drift `notification_deliveries` table with migration
- [x] Route existing polling paths through orchestration layer
- [x] Add unit tests for dedupe and state persistence

## M2 - Local Notifications from Reconcile

- [x] Add local notification adapter abstraction
- [x] Android channels by reason family
- [x] iOS category + payload deep-link mapping
- [x] Show local notifications for newly discovered unseen items
- [x] Add widget/integration tests for tap -> route behavior

## M3 - Push Registration Lifecycle

- [ ] Add token acquisition and refresh listeners
- [ ] Implement `registerPush` and `unregisterPush`
- [ ] Wire account login/switch/logout paths
- [ ] Add retries/backoff for registration failures
- [ ] Add unit tests for lifecycle transitions

## M4 - Push Payload Processing

- [ ] Add background payload entrypoint (`@pragma('vm:entry-point')`)
- [ ] Parse defensively: `senderDid`, `targetDid`, `recordUri`, `reason`
- [ ] Fetch canonical notification payload before display
- [ ] Apply moderation + preference filtering before display
- [ ] Add timeout-bound processing and drop accounting

## M5 - Background Reconciliation

- [ ] Add periodic background reconcile task (Android 15m+)
- [ ] Add iOS background fetch/BGTaskScheduler integration
- [ ] Ensure tasks are idempotent and dedupe-safe
- [ ] Add test harness for worker entrypoints

## M6 - Preferences and UX

- [ ] Add settings UI for notification controls and permission state
- [ ] Integrate `getPreferences` and `putPreferencesV2`
- [ ] Add contextual permission prompt + denied -> settings flow
- [ ] Add unread badge + seen-state reconciliation tests

## M7 - Reliability and Release Readiness

- [ ] Add structured logs + debug counters for notification flows
- [ ] Add smoke checklist for Android/iOS permission and delivery scenarios
- [ ] Validate multi-account behavior and token cleanup
- [ ] Run full `flutter analyze` and full test suite
