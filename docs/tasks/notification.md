---
title: Notification Follow-up Tasks
updated: 2026-05-24
---

Completed polling, local notification, push registration, payload processing,
background reconcile, and Firebase/APNs setup milestones are recorded in
[CHANGELOG.md, v1.0.0 (Alpha 1)](../../CHANGELOG.md#v100-alpha-1).

Notes live in [docs/dev/notifications.md](../dev/notifications.md).

## M6 - Preferences and UX

- [ ] Add settings UI for notification controls and permission state
- [ ] Integrate `getPreferences` and `putPreferencesV2`
- [ ] Add contextual permission prompt + denied -> settings flow
- [ ] Add unread badge + seen-state reconciliation tests

## M7 - Reliability and Release Readiness

- [ ] Add structured logs + debug counters for notification flows
- [ ] Add smoke checklist for Android/iOS permission and delivery scenarios
- [ ] Validate multi-account behavior and token cleanup
