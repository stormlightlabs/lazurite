---
title: Follow Hygiene Developer Notes
updated: 2026-05-07
---

# Follow Hygiene Developer Notes

Follow hygiene audits the active account's follow records and helps the user
remove dead or problematic follows in batches. It works from the user's own
repo records, then hydrates followed accounts to classify their current state.

## Audit Flow

The repository paginates `app.bsky.graph.follow` records through
`com.atproto.repo.listRecords` for the active DID. Each record provides the
follow URI, record key, and subject DID. The repository then batch-hydrates
subjects with `app.bsky.actor.getProfiles`.

Missing profiles are resolved individually so the app can distinguish deleted,
deactivated, and suspended accounts where the API exposes that difference.
Profiles that hydrate successfully are classified from viewer state and labels.
The implemented statuses include deleted, deactivated, suspended, blocked by,
blocking, mutual block, hidden, and self-follow.

## Rate Limits And Partial Results

Profile hydration uses the SDK batch limit of 25 actors. Batches run with
bounded concurrency and backoff on transient errors. Partial hydration failure
does not discard the whole audit. The Cubit reports failed profile count and
continues with the results it could classify.

## Batch Unfollow

Batch removal uses `com.atproto.repo.applyWrites` delete operations against the
`app.bsky.graph.follow` collection. Each delete operation uses the rkey from
the original follow record URI. Writes are chunked to the protocol limit and
executed sequentially.

After each successful chunk, local state updates the completed count. If a chunk
fails, the Cubit stops, reports how many accounts were already unfollowed, and
leaves the remaining selected rows available for retry.

## UI Model

The audit screen progresses through fetching records, classifying profiles,
ready, unfollowing, complete, and error states. The UI shows scan progress,
category counts, selectable rows, visibility filters, and selected totals.

Rows include checkbox, handle, truncated DID, status badge, and profile
navigation. The screen renders empty and complete states for clean audits and
finished removals. Entry points are guarded behind the authenticated account and
appear where account maintenance actions are expected.

## Boundaries

The audit does not infer inactivity from posting history. That would require
fetching feeds for every followed account and would be expensive for large
follow lists. There is also no automatic undo; unfollow is a protocol write.
Any future undo flow should keep a local, time-bounded list of removed DIDs and
make re-follow explicit.
