---
title: Social Features And Moderation
updated: 2026-06-08
---

Messaging, in-app media, multi-account behavior, offline rendering, moderation, lists,
and starter packs extend the same repository, Cubit, and presentation patterns used by
feeds and profiles.

## Direct Messages

Direct messages use the `chat.bsky.*` namespace. `ConvoListBloc` in
`lib/features/messages/bloc` manages conversation list state.
`chat.bsky.convo.listConvos` loads conversations, and message threads paginate
through `chat.bsky.convo.getMessages`. Sending uses `sendMessage`; starting a
thread uses `getConvoForMembers`.

The list separates primary conversations from requests. A request is a conversation
where the active user has not sent a message. Threads render own messages on the
trailing side and other messages on the leading side. Long press copies one message,
while the conversation overflow can copy the full thread.

## Media

Media screens live under `lib/features/feed/presentation/media`. Images open
in an in-app full-screen viewer with paging, zoom, alt text, share, and
download controls. Videos open in an in-app player that uses the embed HLS
playlist, respects aspect ratio, disposes controllers on pop, and handles
GIF-style looping playback.

Downloads ask for media-library permission only when the user starts a save.
Images use their full-size URL. Videos resolve the best available playlist
variant before saving. The UI reports progress and surfaces permission or
download failures through snackbars.

## Accounts And Offline State

The active account DID is persisted in settings. Switching accounts updates the
active DID, rebuilds account-scoped repositories and Cubits, and reloads data
for the new identity. If refresh fails for the selected account, navigation
returns to login for that account.

Offline rendering depends on cached posts and profiles. Screens should show
cached data first, fetch fresh data in the background, and keep rendering cache
if the network call fails. Actions that require network access are disabled
while offline with a clear explanation.

## Moderation

`ModerationService` in `lib/features/moderation/data/moderation_service.dart`
uses Bluesky labelers, user preferences, and the SDK moderation engine. The app
builds moderation options from the active account's preferences and subscribed
labelers, then runs posts, profiles, and notifications through the appropriate
moderation helper before display.

Rendering uses the moderation UI decision for the current context. Filtered
content is removed from lists. Blurred content gets a click-through overlay
unless the decision forbids override. Inform and alert labels render as badges.
Avatar-specific decisions use placeholder avatars when needed.

Subscribed labeler definitions are cached in Drift so preference screens and
moderation decisions can use recent data when offline. The XRPC client includes
the accepted-labelers header on content requests and updates that header when
preferences change.

Moderation label badges are actionable when the UI has an applied protocol
label. Feed cards, thread posts, profile headers, search profile rows, and
notification rows pass the badge's `LabelContext` to the label detail bottom
sheet. The sheet resolves the labeler service and definition on demand, shows
raw protocol metadata when details are partial or offline, and keeps labeler
copy clearly attributed to the third-party labeler rather than Lazurite. The
canonical labeler-service profile route is `/labelers/:did`; use
`labelerProfileLocation`/`openLabelerProfile` instead of linking through
settings-only routes.

## Lists

`ListRepository` in `lib/features/lists/data/list_repository.dart` manages AT
Protocol graph list records. Curation lists provide feeds, moderation lists can
be muted or blocked as a group, and reference lists back starter packs. List
records, list items, and list blocks are created and deleted through
`com.atproto.repo` operations.

My Lists shows lists created by the active account. List detail screens show
metadata, members, and for curation lists, a feed backed by
`app.bsky.feed.getListFeed`. Member management uses actor typeahead, creates
`app.bsky.graph.listitem` records, and deletes the corresponding item records
when removing members.

## Starter Packs

`StarterPackRepository` in `lib/features/starter_packs/data` manages starter
packs. A starter pack points at a reference list for members and can include up
to three feed generator URIs.

Creating a starter pack first creates the reference list, then member list-item
records, then the starter pack record. Editing members changes the backing
reference list. Editing name, description, or feeds updates the starter pack
record.

Starter pack detail screens render creator, description, member sample, feed
recommendations, and join counts. Actor profile surfaces can show starter packs
created by that actor, and search can route directly to a pack detail screen.

## Profile Context

Profile context surfaces public relationship data that helps a user understand an
account before acting on it. Keep the presentation neutral: show lists, blocks,
and related social context without scoring the account or implying intent.

Constellation-backed lookups should stay behind small repository methods. Hydrate
returned DIDs and records through the normal Bluesky profile/list APIs before
rendering, then apply the same moderation filtering used elsewhere. Keep the
Constellation base URL configurable internally, but avoid exposing it as a casual
end-user setting.
