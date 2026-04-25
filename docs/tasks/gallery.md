# Gallery Viewing Milestones

## M0 - Data Layer & Models

- [ ] Create `lib/features/gallery/data/gallery_media_item.dart` - `GalleryMediaItem` model with `feedViewPost`, `type` enum (`image`/`video`), `images` list, `video` args
- [ ] Create `lib/features/gallery/data/gallery_utils.dart` - `extractGalleryItems(List<FeedViewPost>)` utility
  - Walk `embed.isEmbedImagesView`, `embed.isEmbedVideoView`, `embed.isEmbedRecordWithMediaView`
  - Skip external-only and text-only posts
  - Apply moderation filtering (`contentMedia` blur/filter)
- [ ] Create `lib/features/gallery/data/gallery_route_args.dart` - `GalleryRouteArgs` with items, initial index, initial direction
- [ ] Unit tests for `extractGalleryItems` - image-only, video-only, mixed, text-only, moderated, record-with-media edge cases

## M1 - GalleryCubit

- [ ] Create `lib/features/gallery/cubit/gallery_cubit.dart`
- [ ] Create `lib/features/gallery/cubit/gallery_state.dart`
  - State: `items`, `currentIndex`, `chromeVisible`, `scrollDirection`
  - Methods: `onPageChanged`, `toggleChrome`, `toggleDirection`, `appendItems`
- [ ] Unit tests for cubit - page transitions, chrome toggle, direction toggle, item append

## M2 - Gallery Screen (Images)

- [ ] Create `lib/features/gallery/presentation/gallery_screen.dart`
  - Full-screen `PageView` with `scrollDirection` from cubit
  - Image pages: `PhotoViewGallery` (reuse `photo_view`) for single/multi-image posts
  - Nested horizontal `PageView` + dot indicator for multi-image posts within vertical scroll
  - Swipe-to-dismiss gesture detection
  - Background opacity fade on drag
- [ ] Chrome overlay - auto-hiding top/bottom bars with 3s timer
  - Top: close, author avatar+handle, page counter
  - Bottom: post text snippet, action buttons, download/share, alt text badge
- [ ] Preloading: `precacheImage` for ±1 adjacent image pages
- [ ] Register `/gallery` route in `app_router.dart`
- [ ] Widget tests for gallery screen - page swipe, chrome toggle, dismiss gesture

## M3 - Gallery Screen (Videos)

- [ ] Video page renderer within `GalleryScreen`
  - `VideoPlayerController` + `Chewie` for video items
  - Auto-play on page visible, auto-pause on swipe away
  - GIF handling: loop + mute + no controls
  - Full-bleed with pillarbox for non-9:16 aspect ratios
- [ ] Video lifecycle management
  - Pause leaving viewport, play entering viewport
  - Dispose controllers >2 pages away, pre-init +1 page
- [ ] Short-form interactions
  - Tap to pause/resume
  - Double-tap right → like animation + action
  - Double-tap left → rewind 5s
  - Long-press → speed selector (1x, 1.5x, 2x)
  - Thin progress bar at bottom
- [ ] Widget tests for video pages - play/pause, lifecycle, gesture handling

## M4 - Feed Entry Points

- [ ] Add gallery icon button to `LazuriteAppBar` actions in `HomeFeedScreen`
  - Visible when `extractGalleryItems` returns ≥1 item from loaded posts
  - Tap opens `/gallery` with extracted items
- [ ] Add gallery icon to `ProfileScreen` feed tab section
- [ ] Add gallery icon to `SearchScreen` app bar (when post results have media)
- [ ] Add gallery icon to `HashtagScreen` app bar
- [ ] Add gallery icon to `ListDetailScreen` feed tab
- [ ] Add gallery icon to `SavedPostsScreen` app bar
- [ ] Post thread: tapping media opens gallery seeded with thread's media items
- [ ] Widget tests for entry point visibility - shown/hidden based on media presence

## M5 - Infinite Scroll & Pagination

- [ ] Add `onLoadMore` callback and post stream/listener to `GalleryCubit`
  - Decoupled from specific feed source - works with `FeedBloc`, `HashtagCubit`, `ListFeedBloc`, `SearchBloc`
  - When user reaches last 3 pages, invoke callback to trigger parent feed load-more
- [ ] `GalleryCubit.appendItems` - filter new posts through `extractGalleryItems`, merge into item list
- [ ] Loading shimmer on final page while fetch is in progress
- [ ] End-of-feed indicator when cursor is exhausted
- [ ] For profile feeds, use `FeedFilter.postsWithMedia` to maximise gallery density
- [ ] Higher `limit` (100) on feed fetches when gallery mode is active
- [ ] Integration tests: gallery pagination triggers feed load-more, cursor exhaustion handled

## M6 - Notification Media & Offline Gallery

- [ ] Extract media from notification subjects
  - Walk `subjectPost` / `reasonSubject` from notification views through `extractGalleryItems`
  - Add gallery entry point in `NotificationsScreen` when media-bearing notifications exist
- [ ] Offline gallery support
  - Parse `CachedFeedPages.payload` JSON into `FeedViewPost` objects for `extractGalleryItems`
  - Parse `SavedPosts.postJson` and `LikedPosts.postJson` for gallery items
  - Gallery entry point visible when `ConnectivityCubit.isOffline` and cached data has media
  - Disable like/repost/reply buttons (disabled state + "Offline" tooltip)
  - Disable download/share for uncached media
  - Show "Offline - showing cached posts" indicator at end of gallery
  - Pagination unavailable offline - only show cached items
- [ ] Unit tests: offline gallery from cached data, disabled actions, end indicator
- [ ] Widget tests: notification gallery entry point, offline gallery rendering

## M7 - Media Density & Polish

- [ ] Media density indicator in chrome overlay (e.g. "12 media from 47 loaded")
- [ ] `Semantics` labels on gallery pages (author + media type)
- [ ] Alt text exposed to screen readers for images and videos
- [ ] Chrome overlay elements focusable and labeled
- [ ] Keyboard navigation: arrow keys for pages, Escape to dismiss
- [ ] Haptic feedback on like (double-tap)
- [ ] Smooth page transition animations
- [ ] `flutter analyze` clean
- [ ] Full test suite passes
