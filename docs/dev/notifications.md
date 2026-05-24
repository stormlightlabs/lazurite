---
title: Notifications
updated: 2026-05-24
---

Lazurite uses the Bluesky notification APIs for the in-app alerts feed, unread
badges, push registration, and canonical notification fetches. Firebase supplies
the platform push token transport. Local notifications render OS-level alerts
after Lazurite validates and filters the notification content.

## Main pieces

- `NotificationRepository` wraps `app.bsky.notification.*` calls.
- `NotificationDomainService` owns dedupe, moderation filtering, counters, and
  the common reconcile path.
- `PushRegistrationService` registers and unregisters the active account's token.
- `FlutterLocalNotificationAdapter` maps approved notifications to Android
  channels, iOS categories, and deep-link payloads.
- `notification_background_worker.dart` contains the Firebase and Workmanager
  entrypoints. Keep background handlers top-level and annotated where Flutter
  requires it.
- `notification_deliveries` in Drift records delivered notification URIs per
  account so polling, push, and background reconcile can share dedupe state.

## Processing model

Treat a push payload as a trigger, not display content. The payload parser accepts
`senderDid`, `targetDid`, `recordUri`, and `reason`, then fetches the canonical
notification through the authenticated API. The domain service applies moderation
and preference filters before displaying anything.

All paths should converge on the same domain service methods:

- foreground unread polling
- notification screen reconcile
- background reconcile
- Firebase background push handling
- foreground Firebase messages

This keeps routing, dedupe, and local-notification rendering consistent across app
states.

## Platform notes

Android notification delivery needs runtime permission on Android 13 and newer.
Channels are grouped by reason family. Background reconcile uses Workmanager and
therefore follows platform minimum intervals.

iOS delivery depends on APNs through Firebase. Enable Push Notifications and the
required background modes in Xcode. iOS background execution is opportunistic, so
push handling must stay timeout-bounded and safe to drop.

## Guidelines

- Never show local notification content directly from a push payload.
- Keep token registration account-scoped and unregister during logout or account
  removal where possible.
- Do not leave background catch blocks empty. Log enough context to diagnose
  delivery failures without logging token material.
- Add Drift migrations for any delivery-state schema changes.
- Test dedupe, token lifecycle, payload parsing, and deep-link routing when
  changing notification behavior.
