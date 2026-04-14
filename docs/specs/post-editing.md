---
title: Post Editing Spec (v1)
updated: 2026-04-14
---

## Summary

Add AT Protocol post editing to Lazurite by replacing post records via
`com.atproto.repo.deleteRecord` + `com.atproto.repo.createRecord` (same `rkey`,
same URI), with a v1 scope of:

- Entry point: thread screen only
- Editable fields: post text + regenerated facets
- Preserved fields: reply/embed/langs/labels/tags/unknown fields
- Concurrency control: `swapRecord` with the current post CID

## Protocol Mechanics

### Record Replacement

Use delete + recreate on the existing `app.bsky.feed.post` rkey:

- `repo`: authenticated account DID
- `collection`: `app.bsky.feed.post`
- `rkey`: extracted from post AT-URI
- Delete guard: `swapRecord` with latest/current CID from the post view
- Recreate: `createRecord` with the same `rkey` to preserve AT-URI

The edit payload is built from the original record, replacing only:

- `text`
- `facets` (recomputed from updated text; removed when empty)

`createdAt` is preserved from the original record when present. If missing or
invalid, fallback to current UTC timestamp as a defensive safeguard.

### Conflict Handling

When delete/recreate detects stale state (`InvalidSwap`) or changed ownership,
Lazurite treats the edit as a conflict and shows a non-merge message instructing
the user to reopen and retry.

If recreate fails after delete, Lazurite attempts defensive recovery by
restoring the original record on the same `rkey`.

## UX and Flow

### Thread Entry

For author-owned posts in the thread action sheet:

- Add `Edit Post` action.
- Navigate to compose with edit context:
  - `editPostUri`
  - `editPostCid`
  - `editRecord`
  - `initialText`

On successful edit completion, refresh the thread by reloading the current
post URI.

### Compose Edit Mode

Compose supports explicit edit mode via route context.

Edit-mode behavior:

- Title/action labels switch to edit wording (`Edit Post`, `Save Changes`)
- Inline algorithm-impact notice is shown with an info dialog
- Unsupported create-flow controls are disabled/hidden:
  - Save Draft
  - Schedule
  - Add/remove image
  - Add/remove video
- Submission performs `putRecord` update rather than `createRecord`

## Algorithmic Implications (User Notice)

Editing can change how the post is indexed and distributed:

- Post metadata like `indexedAt` may change after edits
- Feed ranking and search visibility may shift after re-indexing
- Read-after-write propagation can be delayed across services and surfaces
- Because edits are saved as delete+recreate on the same URI, counters and
  visibility can briefly lag while services reconcile state

Lazurite informs users inline in compose edit mode and provides an info action
for additional context.

## Limitations

- Edit action is exposed only in thread view
- Only text/facets are user-editable
- No merge flow for edit conflicts

## Beyond

- Add edit entry points in timeline/search/saved post cards
- Consider edit-history affordances and richer conflict resolution UX
  - The question here is where do we store history? What happens between logins? At what
    point does Lazurite need its own lexicons for features like this?
