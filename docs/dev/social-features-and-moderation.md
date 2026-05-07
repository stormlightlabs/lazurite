---
title: Social Features And Moderation Developer Notes
updated: 2026-05-07
---

Phase 4 added messaging, in-app media, multi-account behavior, offline
rendering, moderation, lists, and starter packs. Most of this work connects
existing shared patterns to more AT Protocol surfaces.

## Direct Messages

Direct messages use the `chat.bsky.*` namespace. Conversation lists come from
`chat.bsky.convo.listConvos`, and message threads paginate through
`chat.bsky.convo.getMessages`. Sending uses `sendMessage`; starting a thread
uses `getConvoForMembers`.

The list separates primary conversations from requests. A request is a
conversation where the active user has not sent a message. Threads render own
messages on the trailing side and other messages on the leading side. Long
press copies one message, while the conversation overflow can copy the full
thread.

## Media

Images open in an in-app full-screen viewer with paging, zoom, alt text, share,
and download controls. Videos open in an in-app player that uses the embed HLS
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

Moderation uses Bluesky labelers, user preferences, and the SDK moderation
engine. The app builds moderation options from the active account's preferences
and subscribed labelers, then runs posts, profiles, and notifications through
the appropriate moderation helper before display.

Rendering uses the moderation UI decision for the current context. Filtered
content is removed from lists. Blurred content gets a click-through overlay
unless the decision forbids override. Inform and alert labels render as badges.
Avatar-specific decisions use placeholder avatars when needed.

Subscribed labeler definitions are cached in Drift so preference screens and
moderation decisions can use recent data when offline. The XRPC client includes
the accepted-labelers header on content requests and updates that header when
preferences change.

## Lists

Lists are AT Protocol graph records. Curation lists provide feeds, moderation
lists can be muted or blocked as a group, and reference lists back starter
packs. List records, list items, and list blocks are created and deleted
through `com.atproto.repo` operations.

My Lists shows lists created by the active account. List detail screens show
metadata, members, and for curation lists, a feed backed by
`app.bsky.feed.getListFeed`. Member management uses actor typeahead, creates
`app.bsky.graph.listitem` records, and deletes the corresponding item records
when removing members.

## Starter Packs

Starter packs bundle recommended accounts and feeds. A starter pack points at a
reference list for members and can include up to three feed generator URIs.

Creating a starter pack first creates the reference list, then member list-item
records, then the starter pack record. Editing members changes the backing
reference list. Editing name, description, or feeds updates the starter pack
record.

Starter pack detail screens render creator, description, member sample, feed
recommendations, and join counts. Actor profile surfaces can show starter packs
created by that actor, and search can route directly to a pack detail screen.
