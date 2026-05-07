---
title: Compose Notifications And Actions Developer Notes
updated: 2026-05-07
---

# Compose Notifications And Actions Developer Notes

Phase 3 covered compose, notification polling, post and profile actions, and
local saved posts. These features are write-heavy, so they use optimistic UI
only where rollback behavior is clear and tested.

## Compose

Posts are written with `com.atproto.repo.createRecord` in the
`app.bsky.feed.post` collection. The compose state tracks text, facets, media,
reply refs, quote refs, language tags, and submission status.

Text length is counted with Dart grapheme clusters, not code units. The submit
action is disabled for empty text and over-limit posts. Rich text facets are
detected before submission and rendered as a live preview while the user types.

Images upload through `com.atproto.repo.uploadBlob` and are embedded as
`app.bsky.embed.images`. A post may include up to four images. Video upload
uses `app.bsky.video.uploadVideo`, then polls job status until the processed
blob is available. Video and image embeds are mutually exclusive; switching
between them should ask before replacing existing attachments.

Drafts are account-scoped Drift rows. Network failure and explicit save both
persist the draft. Scheduled posts extend the draft model with a future publish
time and rely on platform background scheduling to retry when connectivity
returns.

## Notifications

Polling notifications use `app.bsky.notification.listNotifications`,
`getUnreadCount`, and `updateSeen`. Notifications are grouped by day and render
author, reason, reason icon, read state, and an optional post preview.

Foreground unread polling runs on an interval while the app is active. Opening
the notifications screen marks current notifications as seen. Tapping a
notification routes to the relevant post or profile. Later push notification
work builds on this navigation and seen-state model.

## Post And Profile Actions

Likes, reposts, follows, and blocks are AT Protocol records. Muting is a server
procedure call. The action repositories should derive delete keys from viewer
state URIs rather than guessing record keys.

Post actions manage like, repost, reply, share, save, report, and copy-link
behavior. Profile actions manage follow, mute, block, report, DID copy, and
profile sharing. Destructive actions require confirmation where user intent
could be ambiguous.

Optimistic updates immediately adjust icon state and counts, run the network
request, then reconcile with the server response. On failure, state rolls back
and the user receives a snackbar. Tests should cover success, rollback, and
viewer-state hydration.

## Saved Posts

Saved posts are private and local-only. They are stored in Drift with
`account_did`, `post_uri`, serialized post JSON, and `saved_at`. The table has a
unique account/post constraint so repeated saves update one row instead of
creating duplicates.

The save action is shown from post controls and overflow menus. Saved posts are
read back through a Cubit that exposes both the saved-post list and a quick
lookup stream for filled bookmark state in feeds.
