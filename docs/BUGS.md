---
title: Bugs (Post Actions & Notifications — Fix Specification)
updated: 2026-03-17
---

## Checklist

- [x] [1. Post Thread Screen](#1-post-thread-screen)
- [x] [2. Post Tap Navigation](#2-post-tap-navigation)
- [x] [3. Avatar Tap Navigation](#3-avatar-tap-navigation)
- [x] [4. Quoted Post Tap Navigation](#4-quoted-post-tap-navigation)
- [x] [5. Notification Tap Navigation](#5-notification-tap-navigation)
- [x] [6. Viewer State on Own Posts](#6-viewer-state-on-own-posts)
- [x] [7. Saved Posts Screen — Render Actual Posts](#7-saved-posts-screen--render-actual-posts)
- [x] [8. Saved Posts — Accessible from Profile](#8-saved-posts--accessible-from-profile)
- [x] [9. Saved Posts — Long Press for Local, Tap for Menu](#9-saved-posts--long-press-for-local-tap-for-menu)
- [x] [10. Saved Posts — Show Save Counts](#10-saved-posts--show-save-counts)
- [ ] [11. Saved Posts — Cloud Save via AT Protocol](#11-saved-posts--cloud-save-via-at-protocol)
- [ ] [12. Failed Action Snackbar with Revert](#12-failed-action-snackbar-with-revert)
- [ ] [13. Delete Post — Remove from Feed](#13-delete-post--remove-from-feed)

## 1. Post Thread Screen

**Status:** Missing — no `/post` route or screen exists.

**Problem:** Multiple features navigate to `/post?uri=...` or `/post/{uri}`, but the
route is not defined in `app_router.dart` and no screen exists. This breaks:

- Notification taps (like, repost, reply, mention, quote)
- Saved post "open" action
- Any future post deeplink

**Fix:**

- Create `lib/features/feed/presentation/post_thread_screen.dart`.
- Use `designs/thread.html` as a reference for the UI.
- Use the Bluesky `getPostThread` API to fetch the thread (parent chain + replies).
- Display the focused post with full content plus its parent posts above and replies
  below, each rendered as `PostCardWithActions`.
- Register route in `app_router.dart`:
  - Path: `/post` with query param `uri` (e.g. `/post?uri=at://...`).
- Handle loading, error, and blocked/not-found thread states.

**Files:**

- New: `lib/features/feed/presentation/post_thread_screen.dart`
- New: `lib/features/feed/data/post_thread_repository.dart` (wraps `getPostThread`)
- Edit: `lib/core/router/app_router.dart` — add `/post` route

## 2. Post Tap Navigation

**Status:** Broken — tapping a post body does nothing.

**Problem:** `PostCard` is not wrapped in a tap detector. The only interactive elements
are the action bar buttons and embedded media. Users expect tapping a post to open it.

**Fix:**

- Wrap the post content area (header + text + embed, excluding the action bar) in an
  `InkWell` that navigates to `/post?uri={postUri}`.
- The action bar itself should NOT trigger navigation — only the content area above it.

**Files:**

- Edit: `lib/features/feed/presentation/widgets/post_card.dart` — wrap content in
  `InkWell` with navigation callback
- Edit: `lib/features/feed/presentation/widgets/post_card_with_actions.dart` — pass
  `onTap` callback through to `PostCard`

## 3. Avatar Tap Navigation

**Status:** Broken — tapping a post author's avatar does nothing.

**Problem:** The avatar `CircleAvatar` in `PostCard._buildHeader` is not tappable.
Users expect tapping an avatar to navigate to that user's profile.

**Fix:**

- Wrap the `CircleAvatar` in `_buildHeader` with a `GestureDetector` that navigates to
  `/profile/view?actor={author.did}`.
- Requires passing the navigation callback or `BuildContext` with router access.

**Files:**

- Edit: `lib/features/feed/presentation/widgets/post_card.dart` — `_buildHeader`
  (line ~55)

## 4. Quoted Post Tap Navigation

**Status:** Incorrect — tapping a quoted post navigates to the quoted author's profile
instead of the quoted post.

**Problem:** `PostCard._buildQuotedRecord` (line 342-346) navigates to
`/profile/view?actor={quoted.author.did}`. It should open the quoted post in the thread
screen.

**Fix:**

- Change the `onTap` in `_buildQuotedRecord` to navigate to
  `/post?uri={quoted.uri}` instead of the author's profile.

**Files:**

- Edit: `lib/features/feed/presentation/widgets/post_card.dart` — `_buildQuotedRecord`
  (line ~342)

## 5. Notification Tap Navigation

**Status:** Broken — tapping non-follow notifications crashes or does nothing (route
doesn't exist).

**Problem:** `notification_list_item.dart:263` pushes `/post?uri=...` but the route is
undefined. This is blocked by [#1](#1-post-thread-screen).

**Fix:**

- Once the `/post` route exists ([#1](#1-post-thread-screen)), notification taps will
  work. Verify the URI encoding is consistent (`Uri.encodeComponent` vs query param).
- Current code: `context.push('/post?uri=${Uri.encodeComponent(uri.toString())}')`
- Ensure the route handler decodes this correctly.
- For like/repost notifications, `notification.uri` may point to the *liker's record*,
  not the original post. Verify that `reasonSubject` (the post that was liked) is used
  instead when appropriate.

**Files:**

- Edit: `lib/features/notifications/presentation/widgets/notification_list_item.dart`
  — `_onTap` (line ~256). May need to use `notification.reasonSubject` for like/repost
  notifications instead of `notification.uri`.

## 6. Viewer State on Own Posts

**Status:** Broken — current user's liked/reposted/saved posts don't show as active in
the feed.

**Problem:** `PostCardWithActions` initializes `PostActionCubit` from `viewer.like` and
`viewer.repost` (lines 35-36), which correctly reflects the API state. However:

- After the user likes a post, scrolls away, and scrolls back, the cubit is recreated
  from the stale `FeedViewPost` data (the original API response), losing the local
  optimistic state.
- Saved state works correctly because `SavedPostsCubit` is global and checks the DB.

**Fix:**

- Maintain a lightweight in-memory cache (e.g. `Map<String, PostActionState>`) in a
  higher-level provider that `PostActionCubit` reads from on creation and writes to on
  state changes. This way, scrolling away and back preserves the user's actions within
  the session.
- Alternatively, store the `likeUri`/`repostUri` in the feed bloc state so it survives
  cubit recreation.

**Files:**

- New or edit: A post action cache/provider (could be a simple `ChangeNotifier` or
  cubit at the feed level)
- Edit: `lib/features/feed/presentation/widgets/post_card_with_actions.dart` — read
  from cache on cubit creation
- Edit: `lib/features/feed/cubit/post_action_cubit.dart` — write to cache on state
  changes

## 7. Saved Posts Screen — Render Actual Posts

**Status:** Incomplete — saved posts screen shows metadata cards, not the actual post
content.

**Problem:** `_SavedPostCard` in `saved_posts_screen.dart` shows a generic "Saved Post"
`ListTile` with a date and action buttons. The full post JSON is stored in the DB
(`postJson` column) but is never deserialized and rendered.

**Fix:**

- Deserialize `savedPost.postJson` back into a `PostView` and render it with
  `PostCardWithActions` (or a read-only variant).
- The "open" button should navigate to `/post?uri={postUri}` (once [#1](#1-post-thread-screen) exists).
- Keep swipe-to-dismiss for unsaving.

**Files:**

- Edit: `lib/features/feed/presentation/saved_posts_screen.dart` — replace
  `_SavedPostCard` with actual post rendering
- The route in `_openPost` (line 186) currently uses path-style
  `/post/${Uri.encodeComponent(...)}` but should use query-style
  `/post?uri=${Uri.encodeComponent(...)}` to match the route definition.

## 8. Saved Posts — Accessible from Profile

**Status:** Incorrect location — saved posts are behind Settings, not on profiles.

**Problem:** The saved posts link is in `settings_screen.dart` (line 56-61). The
requirement is that it should be accessible from profiles.

**Fix:**

- Add a "Saved Posts" button/tab on the current user's own profile screen.
- Keep (or remove) the Settings entry as a secondary access point.

**Files:**

- Edit: profile screen (add saved posts navigation for the current user's profile)
- Optionally edit: `lib/features/settings/presentation/settings_screen.dart`

## 9. Saved Posts — Long Press for Local, Tap for Menu

**Status:** Missing — only tap-to-toggle exists, no long press or menu.

**Problem:** The bookmark button in `PostActionBar` only has `onTap` (line 82). The
requirement is:

- **Long press** → save/unsave locally (instant, different icon color)
- **Normal press** → show menu with options: save/remove locally, save/remove from
  cloud (ATProto)

Cloud save is not yet implemented, but the menu structure should be in place.

**Fix:**

- Add `onLongPress` to the bookmark `_ActionButton` in `PostActionBar`.
- Long press: toggle local save immediately (current behavior), use a distinct color
  (e.g. amber/gold for local saves vs primary for cloud).
- Normal press: show a bottom sheet with options:
  - "Save locally" / "Remove local save"
  - "Save to Bluesky" / "Remove from Bluesky" (disabled/placeholder until cloud is
    implemented)
- Update `SavedPostsState` to distinguish local vs cloud saves.

**Files:**

- Edit: `lib/features/feed/presentation/widgets/post_action_bar.dart` — add
  `onLongPress`, show menu on tap
- Edit: `lib/features/feed/cubit/saved_posts_cubit.dart` — support save type
  distinction
- Edit: `lib/core/database/tables.dart` — add `saveType` column (local/cloud/both)
  with migration

## 10. Saved Posts — Show Save Counts

**Status:** Missing — hardcoded to `0` and hidden.

**Problem:** `PostActionBar` line 80: `count: 0` for the bookmark button. Save counts
are never fetched or displayed.

**Fix:**

- The Bluesky API provides `PostView.bookmarkCount` (nullable `int`). Pass this value
  through to `PostActionBar` instead of the hardcoded `0`.
- Wire it up the same way `likeCount`/`repostCount` are: read from `post.bookmarkCount`
  in `PostCardWithActions` and pass to `PostActionBar`.

**Files:**

- Edit: `lib/features/feed/presentation/widgets/post_card_with_actions.dart` — read
  `post.bookmarkCount ?? 0` and pass to action bar
- Edit: `lib/features/feed/presentation/widgets/post_action_bar.dart` — use the passed
  count instead of hardcoded `0`

## 11. Saved Posts — Cloud Save via AT Protocol

**Status:** Not implemented — "Save to Bluesky" option is disabled with "Coming soon" placeholder.

**Problem:** The save menu in `PostActionBar._showSaveOptions()` has a disabled "Save to
Bluesky" option. The `bluesky` package already exposes a bookmark API
(`app.bsky.bookmark.*`) but it is not wired up. Currently all saves are local-only.

**Fix:**

- Add bookmark methods to `PostActionRepository` using the existing `_bluesky.bookmark`
  service:
  - `createBookmark({uri, cid})` → `_bluesky.bookmark.createBookmark(uri, cid)`
  - `deleteBookmark({uri})` → `_bluesky.bookmark.deleteBookmark(uri)`
  - `getBookmarks({limit, cursor})` → `_bluesky.bookmark.getBookmarks(limit, cursor)`
- Add `cloudSave` and `cloudUnsave` methods to `SavedPostsCubit`:
  - Call `PostActionRepository.createBookmark` / `deleteBookmark`.
  - On success, upsert the local DB row with `saveType: 'cloud'` (or `'both'` if already
    saved locally). On cloud unsave, downgrade `saveType` to `'local'` if a local save
    exists, or delete the row entirely.
  - Use optimistic UI: update the icon immediately, revert on failure.
- Enable the "Save to Bluesky" / "Remove from Bluesky" option in
  `PostActionBar._showSaveOptions()` and wire it to `SavedPostsCubit.cloudSave` /
  `cloudUnsave` via a new callback.
- Distinguish cloud vs local saves visually:
  - Local-only: amber/gold bookmark icon.
  - Cloud (or both): primary/blue bookmark icon.
  - `PostActionBar` already receives `isSaved`; extend it with a `saveType` parameter
    (or similar) so the icon color reflects the save type.
- Add a one-time sync on login: call `getBookmarks` (paginated) and merge results into
  the local DB so cloud saves made on other clients appear. Mark these as `saveType:
  'cloud'`.

**Files:**

- Edit: `lib/features/feed/data/post_action_repository.dart` — add `createBookmark`,
  `deleteBookmark`, `getBookmarks` methods
- Edit: `lib/features/feed/cubit/saved_posts_cubit.dart` — add `cloudSave`,
  `cloudUnsave`, `syncCloudBookmarks` methods; handle `saveType` transitions
- Edit: `lib/features/feed/presentation/widgets/post_action_bar.dart` — enable cloud
  save option, accept `saveType` parameter, update icon color logic
- Edit: `lib/features/feed/presentation/widgets/post_card_with_actions.dart` — pass
  `saveType` and cloud save/unsave callbacks to `PostActionBar`

## 12. Failed Action Snackbar with Revert

**Status:** Partially implemented — rollback works but snackbar is basic.

**Problem:** `PostActionCubit` correctly reverts optimistic updates on failure and shows
a snackbar via `BlocListener` in `post_card_with_actions.dart` (lines 55-64). However:

- The snackbar has no retry action button.
- There's no visual indication during the loading state (the icon just sits there while
  `isLoadingLike`/`isLoadingRepost` is true).

**Fix:**

- Add a "Retry" `SnackBarAction` to the error snackbar.
- Show a subtle loading indicator on the action button while the network call is
  in-flight (e.g., replace the icon with a small spinner, or dim it). The
  `isLoadingLike`/`isLoadingRepost` fields already exist in state.

**Files:**

- Edit: `lib/features/feed/presentation/widgets/post_card_with_actions.dart` — add
  retry action to snackbar
- Edit: `lib/features/feed/presentation/widgets/post_action_bar.dart` — show loading
  state visually on like/repost buttons

## 13. Delete Post — Remove from Feed

**Status:** Incomplete — post is deleted on the server but remains visible in the feed.

**Problem:** `PostActionCubit.deletePost()` (line 186-193) calls the API to delete but
does not remove the post from the feed list. The deleted post card remains visible until
the user refreshes.

**Fix:**

- After successful deletion, notify the parent feed bloc/cubit to remove the post from
  its list.
- This could be done via a callback, a shared event bus, or by having the feed bloc
  listen for deletion events.
- Show a confirmation snackbar: "Post deleted".

**Files:**

- Edit: `lib/features/feed/cubit/post_action_cubit.dart` — emit a "deleted" state or
  invoke a callback
- Edit: feed bloc/cubit — handle post removal from list
- Edit: `lib/features/feed/presentation/widgets/post_card_with_actions.dart` — wire up
  deletion callback
