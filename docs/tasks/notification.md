---
title: Notification Milestones
updated: 2026-05-17
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

- [x] Add token acquisition and refresh listeners
- [x] Implement `registerPush` and `unregisterPush`
- [x] Wire account login/switch/logout paths
- [x] Add retries/backoff for registration failures
- [x] Add unit tests for lifecycle transitions

## M4 - Push Payload Processing

- [x] Add background payload entrypoint (`@pragma('vm:entry-point')`)
- [x] Parse defensively: `senderDid`, `targetDid`, `recordUri`, `reason`
- [x] Fetch canonical notification payload before display
- [x] Apply moderation + preference filtering before display
- [x] Add timeout-bound processing and drop accounting

## M5 - Background Reconciliation

- [x] Add periodic background reconcile task (Android 15m+)
- [x] Add iOS background fetch/BGTaskScheduler integration
- [x] Ensure tasks are idempotent and dedupe-safe
- [x] Add test harness for worker entrypoints

## M6 - Preferences and UX

- [ ] Add settings UI for notification controls and permission state
- [ ] Integrate `getPreferences` and `putPreferencesV2`
- [ ] Add contextual permission prompt + denied -> settings flow
- [ ] Add unread badge + seen-state reconciliation tests

## M7 - Reliability and Release Readiness

- [ ] Add structured logs + debug counters for notification flows
- [ ] Add smoke checklist for Android/iOS permission and delivery scenarios
- [ ] Validate multi-account behavior and token cleanup

## M8 - Firebase/APNs Production Push Setup

- [x] Create/configure Firebase project apps for iOS + Android
- [x] Add `GoogleService-Info.plist` to iOS target and `google-services.json` to `android/app`
- [x] Configure Apple Push Notifications capability/provisioning in Apple Developer
- [x] Upload APNs auth key/certificate to Firebase Cloud Messaging settings
- [x] Validate end-to-end remote push delivery (foreground, background, terminated) on iOS + Android
