---
title: Catch-Up and Saved Scroll Milestones
updated: 2026-05-08
---

## M1 - Feed View State Foundation

- [ ] Add `FeedViewStates` Drift table keyed by `(accountDid, feedKey)`
- [ ] Bump `AppDatabase.schemaVersion` and add migration
- [ ] Add database methods for reading, upserting, and deleting feed view state
- [ ] Add `FeedViewState` domain model
- [ ] Add repository wrapper or `FeedRepository` methods for feed view state
- [ ] Add unit tests for CRUD, migration, account scoping, and malformed payload fallback

## M2 - Saved Scroll Anchor Capture

- [ ] Add stable post keys/identifiers to home feed list items
- [ ] Detect the first visible post and its viewport offset in `_FeedListView`
- [ ] Throttle feed view state writes during scroll
- [ ] Persist state before widget disposal
- [ ] Persist raw `scrollPixels` as a fallback
- [ ] Add widget tests for anchor capture and throttled persistence

## M3 - Saved Scroll Restoration

- [ ] Load saved feed view state during `_primeFeed`
- [ ] Restore after cached posts render and layout is available
- [ ] Find `anchorPostUri` in the rendered feed and correct by `anchorScrollOffset`
- [ ] Fall back to clamped `scrollPixels` when the anchor post is missing
- [ ] Ensure network refresh does not race the initial restoration
- [ ] Add widget tests for cached restore, missing-anchor fallback, and offline restore

## M4 - Preserve Position During Feed Mutations

- [ ] Capture anchor before refresh prepends newer posts
- [ ] Preserve anchor after `_posts` changes
- [ ] Capture anchor before pagination appends older posts and cache pruning can shift rows
- [ ] Deduplicate merged posts by URI before rendering
- [ ] Add tests for refresh while scrolled down and load-more while preserving visible content

## M5 - Newer Posts Indicator

- [ ] Add latest-page check that compares returned posts to the current first post URI
- [ ] Store `showNewer` and `lastCheckedAt` in feed view state
- [ ] Show a compact "New posts" control when newer posts exist and the user is scrolled down
- [ ] Show a count when the newest-page check can compute one
- [ ] Merge newer posts on tap while preserving the current anchor
- [ ] Keep existing jump-to-top and tab-retap behavior intact
- [ ] Add widget tests for indicator display, count fallback, merge behavior, and
  top-of-feed refresh

## M6 - Catch-Up Data Layer

- [ ] Add `CatchUpSnapshots` Drift table
- [ ] Bump schema and add migration
- [ ] Create catch-up snapshot model and repository
- [ ] Implement latest-three retention per account
- [ ] Add tests for snapshot CRUD, retention cleanup, account scoping, and offline reads

## M7 - Catch-Up Collection Service

- [ ] Create `CatchUpRepository` or service for timeline collection
- [ ] Fetch `app.bsky.feed.getTimeline` pages with cursor
- [ ] Filter posts by selected time range using `record.createdAt` with `indexedAt` fallback
- [ ] Continue paging until a full page is older than the cutoff, cursor ends, or page
  cap is reached
- [ ] Apply existing moderation/feed filtering
- [ ] Persist completed snapshots
- [ ] Add tests for time-window boundaries, mixed ordering, cursor exhaustion, page cap,
  empty results, and network failure

## M8 - Catch-Up Screen

- [ ] Add catch-up route and screen
- [ ] Add home entry point
- [ ] Add range controls: 1h, 2h, 4h, 8h, 12h, since last catch-up
- [ ] Render loading, empty, error, and result states
- [ ] Render previous snapshot list for the active account
- [ ] Add widget tests for route, range selection, loading, empty, and previous snapshots

## M9 - Catch-Up Digest Controls

- [ ] Render compact digest rows with author, text preview, indicators, stats, and timestamp
- [ ] Add filters: all, originals, replies, reposts, quotes, media, links, filtered
- [ ] Add sorting: oldest first, newest first, engagement
- [ ] Add grouping by author
- [ ] Add top-links toggle
- [ ] Navigate digest row taps to the normal post thread route
- [ ] Add widget tests for filters, sorting, grouping, top links, and row navigation

## M10 - Release Readiness

- [ ] Add debug logs for restore failures, catch-up collection failures, and retention cleanup
- [ ] Add manual smoke checklist for iOS and Android
- [ ] Verify app restart restoration on home timeline and custom feeds
- [ ] Verify catch-up snapshots across account switches
