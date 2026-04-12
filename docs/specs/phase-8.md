---
title: Phase 8 Spec
updated: 2026-04-11
---

## Follow Hygiene — Detect & Remove Inactive/Problematic Follows

Audit the authenticated user's follow list to surface accounts that are
deleted, deactivated, suspended, blocking/blocked-by, hidden by moderation, or
the user's own DID. Present a filterable, selectable list and batch-unfollow in
a single action.

### Why

Users accumulate dead follows over time — accounts get suspended, deactivated,
or start blocking. Bluesky provides no built-in way to audit this. The existing
profile action layer handles individual follow/unfollow, but there is no
batch-audit or batch-unfollow capability.

### Data Flow

```text
User taps "Clean Follows"
  → Paginate com.atproto.repo.listRecords(collection: app.bsky.graph.follow)
  → Collect all follow record URIs + subject DIDs
  → Batch-hydrate via app.bsky.actor.getProfiles (25 per batch)
  → For each batch, classify:
      - Missing from response → resolve DID individually → deleted/deactivated/suspended
      - Present but viewer.blockedBy → blocked-by (or mutual block if also blocking)
      - Present but viewer.blocking/blockingByList → blocking
      - Present but labels contain "!hide" → hidden by moderation
      - subject DID == own DID → self-follow
  → Display categorized results
  → User selects accounts → batch delete via com.atproto.repo.applyWrites
```

### Account Classification

Reuse the existing `_hydrateProfiles` pattern from `ProfileContextRepository`
— batch `getProfiles`, then per-DID fallback for missing entries. Extend with
follow-specific status classification:

| Status        | Detection                                                     |
| ------------- | ------------------------------------------------------------- |
| Deleted       | `getProfile` returns "not found" error                        |
| Deactivated   | `getProfile` returns "deactivated" error                      |
| Suspended     | `getProfile` returns "suspended" error                        |
| Blocked By    | `viewer.blockedBy == true` on profile response                |
| Blocking      | `viewer.blocking != null` or `viewer.blockingByList != null`  |
| Mutual Block  | Both `blockedBy` and `blocking` are true                      |
| Hidden        | Profile labels contain `val == "!hide"`                       |
| Self-follow   | Subject DID matches authenticated user's DID                  |

### Batch Unfollow

AT Protocol's `com.atproto.repo.applyWrites` accepts up to 200 operations per
call. The `bluesky` Dart package exposes this as
`atproto.repo.applyWrites(writes: [...])`.

Each delete operation:

```dart
{
  '$type': 'com.atproto.repo.applyWrites#delete',
  'collection': 'app.bsky.graph.follow',
  'rkey': rkey,  // extracted from the follow record URI
}
```

Chunk selected records into batches of 200 and execute sequentially. Update
local state after each successful batch.

### Repository Layer

**`FollowAuditRepository`** — new file in `lib/features/profile/data/`.

Depends on the authenticated `Bluesky` client (same injection pattern as
`ProfileActionRepository` and `ProfileContextRepository`).

**Methods:**

- `fetchAllFollows()` → paginate `atproto.repo.listRecords(repo: did,
  collection: 'app.bsky.graph.follow', limit: 100)` with cursor. Returns
  `List<FollowRecord>` (uri, rkey, subjectDid).
- `classifyFollows(List<FollowRecord>, String ownDid)` → batch
  `getProfiles` (25/batch, 2 concurrent batches, 500ms delay between groups),
  per-DID fallback for missing, return `List<ClassifiedFollow>`.
- `batchUnfollow(List<ClassifiedFollow>)` → `applyWrites` in chunks of 200.

**Models:**

```dart
enum FollowStatus {
  deleted,
  deactivated,
  suspended,
  blockedBy,
  blocking,
  mutualBlock,
  hidden,
  selfFollow,
}

class FollowRecord {
  final String uri;
  final String rkey;
  final String subjectDid;
}

class ClassifiedFollow {
  final FollowRecord record;
  final String? handle;
  final FollowStatus status;
  final String statusLabel;
  bool selected;
}
```

### Rate Limiting

The `bluesky` package's `getProfiles` accepts up to 25 actors. Strategy:

- Batch size: 25 (API max)
- Concurrent batches: 2
- Inter-group delay: 500ms
- On rate-limit (429) or network error: retry with exponential backoff (1s, 2s,
  4s), max 3 retries per batch, then skip and count as failed

### Cubit

**`FollowAuditCubit`** — new file in `lib/features/profile/cubit/`.

**States:**

```dart
enum FollowAuditStatus {
  initial,
  fetching,    // paginating follow records
  classifying, // hydrating + classifying profiles
  ready,       // results displayed
  unfollowing, // batch delete in progress
  complete,    // unfollow finished
  error,
}

class FollowAuditState {
  final FollowAuditStatus status;
  final List<ClassifiedFollow> results;
  final int totalFollows;
  final int progress;         // records processed so far
  final int failedProfiles;   // profiles that couldn't be fetched
  final int unfollowedCount;  // after batch delete
  final String? errorMessage;
  final Set<FollowStatus> visibleStatuses;  // filter toggles
}
```

**Methods:**

- `audit()` — fetch all follows, classify, transition through
  fetching → classifying → ready.
- `toggleSelection(int index)` — toggle `selected` on a single result.
- `selectAllByStatus(FollowStatus)` / `deselectAllByStatus(FollowStatus)` —
  bulk select/deselect by category.
- `toggleVisibility(FollowStatus)` — show/hide a category in the list.
- `confirmUnfollow()` — batch-delete selected, transition to
  unfollowing → complete.

Progress is reported as `progress / totalFollows` during both fetching and
classifying phases.

### UI

**Entry point:** New item in the settings screen under a "Follows" or
"Account Maintenance" section. Also accessible from the profile screen's
overflow menu (three-dot) for the user's own profile.

**Screen: `FollowAuditScreen`**

Layout (top to bottom):

1. **Header** — "Clean Follows" title, subtitle with follow count once loaded.
2. **Action bar** — "Scan" button (initial state) → "Unfollow Selected (N)"
   button (ready state). Disabled during fetching/classifying/unfollowing.
3. **Progress indicator** — linear progress bar during fetch/classify. Shows
   "Fetching follows: 142/1200" or "Classifying: 300/1200". If failed profiles
   > 0, show amber warning text.
4. **Filter sidebar / chip row** — one toggle per `FollowStatus` category.
   Each toggle shows the category label and count. Visibility toggle
   (show/hide in list) + "Select All" checkbox per category. On narrow
   screens, render as a horizontal scrollable chip row above the list; on
   wider screens, render as a sticky sidebar.
5. **Results list** — each row: checkbox, handle (tappable → profile), DID
   (truncated, tappable → copy), status badge. Selected rows have a
   destructive-red background tint. Rows hidden by visibility filter are
   excluded from the list entirely.
6. **Summary footer** — "Selected: 12/47" count. After unfollow:
   "Unfollowed 12 accounts".
7. **Empty/complete states** — "No problematic follows found" or
   "Unfollowed N account(s)".

**Styling:** Follows the UI refactor spec — square geometry, uppercase labels,
`outlineVariant` borders, `surfaceContainerLowest` card backgrounds.

### Error Handling

- Network failure during fetch: show error state with retry button.
- Partial profile hydration failure: continue with available data, show count
  of failed profiles as a warning (not a blocker).
- `applyWrites` failure on a batch: stop, show error with count of successful
  unfollows so far, allow retry for remaining.
- Account not authenticated: guard entry points behind auth state (already
  handled by app shell).

### Limitations & Future Work

- **No "inactive" detection.** We'll only detects hard states (deleted,
  suspended, blocking). Detecting genuinely inactive accounts (no posts in N
  months) would require fetching each account's feed — prohibitively expensive
  for large follow lists. Could be added as an opt-in deep scan later.
- **No undo.** Unfollow is destructive. A future version could cache unfollowed
  DIDs locally and offer a "re-follow" list for a limited time.
- **Single-account.** Runs against the active account only. Multi-account batch
  audit is out of scope.
- **No background execution.** The audit runs in the foreground. For users with
  10k+ follows, this could take 1-2 minutes. A future version could use a
  background isolate with notification on completion.
