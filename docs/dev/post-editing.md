---
title: Post Editing
updated: 2026-05-24
---

Lazurite implements post editing by replacing the authenticated user's
`app.bsky.feed.post` record at the same rkey. This preserves the AT URI while
letting the user change supported fields.

## Scope

The edit entry point is currently thread-only. Compose enters edit mode with the
original post URI, CID, record, and text. Edit mode changes labels to edit copy,
shows the algorithm-impact notice, and disables create-only controls such as
drafts, scheduling, and media changes.

Editable fields:

- post text
- regenerated rich-text facets

Preserved fields:

- reply refs
- embed
- languages
- labels and tags
- unknown record fields
- `createdAt`, when present and valid

## Write behavior

The repository deletes and recreates the record on the original rkey with a
`swapRecord` guard against the current CID. If the guard fails, the app treats the
edit as a conflict and asks the user to reopen the post before retrying.

If recreate fails after delete, Lazurite attempts to restore the original record
on the same rkey. Keep this recovery path conservative and logged.

## User-facing caveat

Editing can affect indexing and distribution. `indexedAt` may change, feeds and
search may lag, and counters can briefly look stale while Bluesky services
reconcile the replacement. Keep this explanation visible in compose edit mode.
