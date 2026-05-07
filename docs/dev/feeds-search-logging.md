---
title: Feeds Search And Logging Developer Notes
updated: 2026-05-07
---

# Feeds Search And Logging Developer Notes

Phase 2 added operational visibility, the home feed, search, and the in-app PDS
explorer. These features share two rules: repositories hide network details,
and UI state stays explicit enough to test without live services.

## Logging

`AppLogger` is the shared logging entry point. Feature code should log through
that wrapper so filtering, redaction, file output, and in-app viewing stay
consistent.

Console logging is development-only. File logging is available in all builds
and writes rotated daily files in the app documents directory. HTTP logging
must redact authorization data and avoid full request or response bodies. Use
summary fields, route names, status codes, and bounded body previews.

The log viewer lives under Settings and reads persisted log files from disk. It
supports level filtering, text search, sharing the current log, and clearing
logs with confirmation. It is intentionally state-light: file reads and UI
filters belong in a Cubit rather than a larger feature Bloc.

## Home Feeds

The home feed combines the Following timeline with user-pinned feed generators.
The timeline uses `app.bsky.feed.getTimeline`. Generator feeds use
`app.bsky.feed.getFeed` with the generator AT-URI. Both return hydrated post
views and paginate by cursor.

Pinned feed preferences live in the user's Bluesky preferences, backed by
local Drift caching for offline startup. The `savedFeedsPrefV2` array controls
which feeds appear as tabs, their order, and whether each entry is a timeline,
generator, or list. Mutations should update local state optimistically, persist
to the server, and reconcile with the returned preference state.

The feed renderer reuses the shared post-card stack. Feed-specific code should
own only pagination, refresh state, and feed identity.

## Search

Post search uses `app.bsky.feed.searchPosts`. Actor search uses
`app.bsky.actor.searchActors`, and handle autocomplete uses the typeahead path
documented in [typeahead.md](./typeahead.md).

Search history is account-scoped in Drift. Insertions update the timestamp for
repeat queries, and each account keeps a bounded recent history. UI actions
include re-running a past search, deleting one entry, and clearing all entries.

Search state should keep result type, query, pagination cursor, loading state,
and error state separate. Avoid mixing actor typeahead into post-search
pagination state; the shared typeahead repository and cubit own autocomplete.

## PDS Explorer

The PDS explorer is a developer tool for inspecting AT Protocol repositories.
It resolves handles to DIDs, lists repo collections, paginates records, and
opens individual records as formatted JSON. It also accepts AT-URIs so a
developer can jump directly to a record.

Explorer requests use `com.atproto.identity.resolveHandle`,
`com.atproto.repo.describeRepo`, `com.atproto.repo.listRecords`, and
`com.atproto.repo.getRecord`. The tool is read-only and should stay isolated
from production feed or profile state.
