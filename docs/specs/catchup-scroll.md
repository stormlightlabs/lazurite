---
title: Catch-Up and Saved Scroll Spec
updated: 2026-05-08
---

## Summary

Add two related feed reading features:

1. **Saved scroll position** - restore each feed to the user's last reading position
   across tab switches and app restarts.
2. **Catch-up** - create a compact, filterable reading view for posts collected over a
   selected time range.

Saved scroll should ship first. It reduces accidental feed jumps and provides the
durable state that catch-up can build on later.

## Goals

- Preserve reading position for home timeline and pinned custom feeds.
- Avoid replacing the feed under the user when newer posts arrive.
- Give users a clear way to load newer posts when they are ready.
- Support offline restoration from existing feed caches.
- Provide a catch-up view for scanning posts by time range, author, content category,
  and engagement.

## Non-Goals

- Server-side read receipts or cross-device sync.
- Marking individual posts read on Bluesky.
- Replacing normal home feed behavior with catch-up.
- Fetching every possible post for unbounded time ranges.

## Current State

`HomeFeedScreen` renders pinned feeds as `PageView` tabs. Each tab uses
`_FeedListView` with its own `ScrollController` and `AutomaticKeepAliveClientMixin`.
This preserves in-memory scroll while the widget remains alive, but the state is lost
after app restart.

`FeedRepository` already caches feed windows:

- `CachedFeedPages` stores per-feed metadata JSON.
- `CachedFeedPosts` stores ordered serialized `FeedViewPost` rows.
- `getCachedFeedPage(feedKey)` restores cached posts before the network refresh.
- `_cacheFeedWindow` dedupes by post URI and keeps a bounded merged feed window.

Missing pieces:

- No durable per-feed viewing state.
- No saved visible-item anchor.
- Refresh replaces `_posts` immediately, which can move the reading position.
- No "new posts available" state separate from loaded posts.
- No catch-up snapshot storage or digest screen.

## Data Model

### Feed View State

Add a Drift table with migration:

```dart
@DataClassName('FeedViewStateEntry')
class FeedViewStates extends Table {
  TextColumn get accountDid => text()();
  TextColumn get feedKey => text()();
  TextColumn get anchorPostUri => text().nullable()();
  RealColumn get anchorScrollOffset => real().nullable()();
  RealColumn get scrollPixels => real().nullable()();
  TextColumn get lastSeenPostUri => text().nullable()();
  BoolColumn get showNewer => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastCheckedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {accountDid, feedKey};
}
```

Field meaning:

- `anchorPostUri`: stable post URI for the first visible post.
- `anchorScrollOffset`: pixel offset from the viewport top to that post.
- `scrollPixels`: fallback raw scroll offset when the anchor post is missing.
- `lastSeenPostUri`: highest or topmost post the user has seen in this feed.
- `showNewer`: whether the UI should offer newer posts without auto-jumping.
- `lastCheckedAt`: last time the feed checked for newer content.
- `updatedAt`: last state write.

### Catch-Up Snapshot

Add a separate table:

```dart
@DataClassName('CatchUpSnapshotEntry')
class CatchUpSnapshots extends Table {
  TextColumn get id => text()();
  TextColumn get accountDid => text()();
  DateTimeColumn get startAt => dateTime().nullable()();
  DateTimeColumn get endAt => dateTime()();
  IntColumn get postCount => integer()();
  TextColumn get postsJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

Keep the newest three snapshots per account. Delete older snapshots after a new
snapshot is saved.

## Saved Scroll Behavior

### Anchor Capture

For each feed tab, identify the first visible post and store:

- post URI
- vertical offset from viewport top
- raw scroll offset as fallback

Capture should happen:

- on throttled scroll changes
- before app pause where possible
- before widget disposal
- immediately before feed list mutations that insert or remove rows above the
  current viewport

The capture interval should be throttled to avoid frequent database writes.
500-1000ms is acceptable.

### Anchor Restoration

On feed open:

1. Load cached posts.
2. Load saved feed view state.
3. Render cached posts.
4. After layout, find `anchorPostUri`.
5. Adjust scroll so the anchor appears at `anchorScrollOffset`.
6. If the anchor post is not in the cached window, use `scrollPixels` clamped to
   the scroll extent.

Network refresh should not run before the cached render has a chance to restore
position. If refresh completes first, restoration still uses the latest rendered list
and falls back safely.

### Preserving Position During List Changes

Before prepending newer posts or appending older posts with cache pruning:

1. Capture the current anchor.
2. Apply the list change.
3. After layout, find the same anchor post.
4. Adjust the scroll offset by the difference between old and new anchor position.

This keeps the content the user was reading in place while the list changes.

## Newer Posts

Refresh behavior should distinguish between user-at-top and user-reading states.

When the user is near the top:

- Refresh can replace or prepend posts immediately.
- Scroll may stay at the top.
- `showNewer` is cleared.

When the user is scrolled down:

- Check for newer posts without replacing the visible list.
- If newer posts exist, set `showNewer`.
- Show a small top/floating control: "New posts" or "N new posts" when count is known.
- Tapping the control merges newer posts and preserves the current anchor, or jumps to
  top when the user explicitly chooses that action.

Counting can be approximate. If a latest-page check finds posts before the
current first URI, show that count. If the current first URI is not found in the
latest page, show an uncounted "New posts" control.

## Feed Scope

Initial saved-scroll support:

- Home timeline
- Pinned custom feeds

Later scopes:

- List feeds
- Profile posts
- Hashtag/topic feeds
- Search results
- Saved posts

Each scope needs a stable feed key. Use existing `FeedRepository.cacheKeyForSavedFeed`
for home tabs, and define explicit keys for other screens before adding support.

## Catch-Up Behavior

### Entry Point

Add a catch-up entry point from the home app bar or feed actions. The screen
starts with range controls:

- Last 1 hour
- Last 2 hours
- Last 4 hours
- Last 8 hours
- Last 12 hours
- Since last catch-up

If no previous snapshot exists, "Since last catch-up" is disabled.

### Collection

For timeline catch-up:

1. Fetch `app.bsky.feed.getTimeline` pages with cursor.
2. Collect posts whose `record.createdAt` or `post.indexedAt` is within range.
3. Continue paging until a full page is older than the cutoff, the cursor ends,
   or a defensive page cap is reached.
4. Apply the same moderation/list filtering used by normal feed rendering.
5. Persist a catch-up snapshot.

Use `record.createdAt` when present because it matches user-visible post time.
Use `indexedAt` as fallback. Do not stop on the first older item because feed
pages can contain reposts and mixed ordering.

Suggested defensive caps:

- 40-50 posts per page
- 10 pages for default ranges
- hard cap of 500 collected posts per snapshot

### Digest View

The catch-up screen renders compact rows optimized for scanning. Each row should
show:

- author avatar and display name
- post text preview
- media/link indicators
- reply/repost/quote/like counts when available
- relative or absolute timestamp

Controls:

- Filter: all, originals, replies, reposts, quotes, media, links, filtered
- Sort: oldest first, newest first, engagement
- Group: none, author
- Toggle: show top links

Opening a row navigates to the normal post thread route.

### Previous Snapshots

Show up to three recent snapshots for the active account:

- time range
- post count
- created time
- open action

Older snapshots are deleted automatically after a new snapshot is saved.

## Offline Behavior

Saved scroll restoration works offline when cached posts exist.

Catch-up requires network to create a new snapshot. Previously created snapshots
can be opened offline because their posts are stored locally.

## Error Handling

- Cache/state decode failures log a warning and continue with defaults.
- Network failures preserve existing feed content.
- Catch-up collection failures keep any previously saved snapshots intact.
- Empty catch-up results show an empty state with the selected range.
- If restoring an anchor fails, fall back to clamped raw scroll position.

## Testing

### Unit

- Feed view state CRUD and migration tests.
- Catch-up snapshot CRUD and retention cleanup tests.
- Feed key scoping by account and feed.
- Anchor serialization and fallback behavior.
- Catch-up time-window collection stop conditions.

### Widget

- Home feed restores a saved anchor after cached posts render.
- Refresh while scrolled down shows a "New posts" control without jumping.
- Tapping "New posts" preserves the current anchor while posts are prepended.
- Jump-to-top still works after saved scroll is enabled.
- Catch-up range selection starts collection and renders results.
- Catch-up filters and sorting update the digest.

### Integration

- `flutter analyze`
- `flutter test --reporter=failures-only`
- Manual smoke on iOS and Android:
  - scroll feed, kill app, reopen, confirm position
  - receive newer posts while scrolled down, confirm no jump
  - create catch-up, reopen snapshot, switch accounts

## Rollout

1. Saved scroll data model and repository methods.
2. Home feed anchor restore and persistence.
3. Newer-post indicator.
4. Catch-up data model and collection service.
5. Catch-up screen and digest controls.
6. Expand saved-scroll support to non-home feed scopes.
