---
title: Compose, Notifications, And Actions
updated: 2026-05-07
---

Compose, notification polling, post actions, profile actions, and saved posts
touch local state and network writes. Use optimistic UI only where rollback
behavior is clear and tested.

## Compose

`ComposeBloc` in `lib/features/compose/bloc/compose_bloc.dart` tracks text,
facets, media, reply refs, quote refs, language tags, and submission status.
Posts are written through `ComposeRepository` with `com.atproto.repo.createRecord`
in the `app.bsky.feed.post` collection.

Text length is counted with Dart grapheme clusters, not code units. The submit
action is disabled for empty text and over-limit posts. Rich text facets are
detected before submission and rendered as a live preview while the user types.
Post editing reuses compose in a restricted edit mode; see
[post-editing.md](./post-editing.md).

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

`NotificationBloc` in `lib/features/notifications/bloc` owns alerts-screen state.
`NotificationDomainService` owns polling, push-triggered reconcile, delivery
dedupe, and local notification display. See [notifications.md](./notifications.md)
for the full processing model.

Foreground unread polling runs on an interval while the app is active. Opening
the notifications screen marks current notifications as seen. Tapping a
notification routes to the relevant post or profile.

## Post And Profile Actions

Likes, reposts, follows, and blocks are AT Protocol records. Muting is a server
procedure call. `PostActionRepository` and `ProfileActionRepository` should
derive delete keys from viewer state URIs rather than guessing record keys.

Post actions manage like, repost, reply, share, save, report, and copy-link
behavior. Profile actions manage follow, mute, block, report, DID copy, and
profile sharing. Destructive actions require confirmation where user intent
could be ambiguous.

Optimistic updates immediately adjust icon state and counts, run the network
request, then reconcile with the server response. On failure, state rolls back
and the user receives a snackbar. Tests should cover success, rollback, and
viewer-state hydration.

## Saved Posts

Saved posts are private and local-only. `SavedPostsCubit` reads and writes
Drift rows with
`account_did`, `post_uri`, serialized post JSON, and `saved_at`. The table has a
unique account/post constraint so repeated saves update one row instead of
creating duplicates.

The save action is shown from post controls and overflow menus. Saved posts are
read back through a Cubit that exposes both the saved-post list and a quick
lookup stream for filled bookmark state in feeds.
