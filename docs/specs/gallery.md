---
title: Gallery Viewing Spec
updated: 2026-04-25
---

## Summary

Add two immersive viewing modes for feeds containing media:

1. **Slideshow** - full-screen image carousel for image-heavy feeds
2. **Short-form vertical** - TikTok-style vertical swipe for video or mixed feeds

These modes activate from any feed context (timeline, profile, search, list feed,
hashtag, saved posts) when the feed's content qualifies.

## Content Classification

Before entering gallery mode, classify the filtered feed to determine which viewer
to offer. Only posts with image or video embeds participate.

| Embed type                          | Classification |
| ----------------------------------- | -------------- |
| `embedImagesView`                   | image          |
| `embedVideoView`                    | video          |
| `embedRecordWithMediaView` (images) | image          |
| `embedRecordWithMediaView` (video)  | video          |
| `embedExternalView`, text-only      | excluded       |

A `GalleryMediaItem` model normalises these into a uniform structure:

```dart
class GalleryMediaItem {
  final FeedViewPost feedViewPost;
  final GalleryMediaType type; // image, video
  final List<ImageViewerItem> images; // populated for image type
  final VideoPlayerRouteArgs? video;  // populated for video type
}
```

### Feed filtering

Extract media items from a `List<FeedViewPost>` via a utility:

```dart
List<GalleryMediaItem> extractGalleryItems(List<FeedViewPost> posts);
```

This walks each post's embed (and `recordWithMedia.media`), skipping posts without
qualifying embeds. Moderation filtering applies - `contentMedia` blur/filter
decisions are respected.

## Slideshow Mode (Images)

### Entry point

A "Gallery" icon button in the feed app bar (or FAB) that appears when
`extractGalleryItems` returns at least one item. Tapping it opens
`GalleryScreen` with the extracted items, starting at the first item (or the
item nearest the current scroll position).

### Screen: `GalleryScreen`

Full-screen `PageView` with `PageController`. Each page renders based on
`GalleryMediaType`:

**Image pages:** `PhotoViewGallery` (reuse existing `photo_view` dependency)
showing all images from the post. Multi-image posts use a nested horizontal
`PageView` within the vertical page, with a dot indicator. Pinch-to-zoom and
pan via `PhotoView`. Hero animation from the feed thumbnail when entering from
a specific post.

**Video pages:** Inline `VideoPlayerController` + `Chewie` (reuse existing
dependencies). Auto-play when the page is visible, pause when swiped away.
GIF-style videos (`presentation: "gif"`) loop muted with no controls.

### Navigation

- **Vertical swipe** (default): swipe up/down to move between posts - TikTok
  style. Uses `PageView` with `scrollDirection: Axis.vertical`.
- **Horizontal swipe** (slideshow): swipe left/right. Configurable via a toggle
  in the gallery toolbar.
- Swipe-to-dismiss: vertical drag past threshold when in horizontal mode (or
  horizontal drag in vertical mode) pops the screen.

### Chrome overlay

Semi-transparent top and bottom bars, auto-hiding after 3 seconds of
inactivity. Tap anywhere to toggle.

**Top bar:**

- Close button (X)
- Post author avatar + handle (tap → navigate to profile)
- Page counter (e.g. "3 / 12")

**Bottom bar:**

- Post text snippet (first 2 lines, tap to expand)
- Like / repost / reply action row (reuse `PostActionBar` pattern via
  `PostActionCubit`)
- Download / share buttons (reuse `MediaActions`)
- Alt text badge when present (tap to show full alt text in a sheet)

### State management

`GalleryCubit` manages:

```dart
class GalleryState {
  final List<GalleryMediaItem> items;
  final int currentIndex;
  final bool chromeVisible;
  final Axis scrollDirection;
}
```

Events: `PageChanged`, `ChromeToggled`, `DirectionToggled`.

The cubit receives the pre-filtered list of `GalleryMediaItem` - no additional
API calls. Pagination piggybacks on the parent feed's `FeedBloc` cursor: when
the user reaches the last few pages, the cubit signals the parent to load more,
and new items are appended.

### Preloading

Preload adjacent pages to reduce perceived latency:

- Images: `precacheImage` for ±1 pages
- Videos: initialise `VideoPlayerController` for +1 page, dispose -2 pages

## Short-Form Vertical Video Mode

For feeds that are primarily video, the gallery defaults to vertical scroll
direction with video-first UX:

- Full-bleed video fills the screen (respect `aspectRatio` from embed, pillarbox
  for non-9:16 content)
- Auto-play on visibility, auto-pause on swipe-away
- Tap to pause/resume (no explicit controls unless user taps)
- Double-tap right side → like, double-tap left side → rewind 5s
- Long-press → playback speed options (1x, 1.5x, 2x)
- Progress bar at bottom (thin, YouTube Shorts style)

### Video lifecycle

Use `VisibilityDetector` pattern (or `PageView.onPageChanged`) to:

1. Pause video leaving viewport
2. Play video entering viewport
3. Dispose controllers for pages > 2 positions away
4. Pre-initialise controller for the next page

## Mixed feeds

When a feed has both images and videos, gallery mode interleaves them in feed
order. Each page adapts its renderer based on `GalleryMediaType`. The bottom
bar shows a media type icon (camera/video) so users know what's coming next.

## Entry points

| Context                | Trigger                                           |
| ---------------------- | ------------------------------------------------- |
| Home feed tabs         | Gallery icon in `LazuriteAppBar` actions          |
| Profile feed tab       | Gallery icon in profile feed section              |
| Search results (Posts) | Gallery icon in search app bar when results shown |
| Hashtag screen         | Gallery icon in hashtag app bar                   |
| List feed              | Gallery icon in list detail feed tab              |
| Saved posts            | Gallery icon in saved posts app bar               |
| Post thread            | Tap post media opens gallery seeded at that post  |

For thread context, tapping a post's media now opens gallery mode seeded with
just that thread's media items, starting at the tapped item.

## Routing

```dart
GoRoute(
  path: '/gallery',
  parentNavigatorKey: _rootNavigatorKey,
  builder: (context, state) {
    final args = state.extra as GalleryRouteArgs;
    return GalleryScreen(args: args);
  },
),
```

`GalleryRouteArgs`:

```dart
class GalleryRouteArgs {
  final List<GalleryMediaItem> items;
  final int initialIndex;
  final Axis initialDirection;
}
```

## Packages

No new dependencies. Reuses:

- `photo_view` - image zoom/pan
- `video_player` + `chewie` - video playback
- `dio` + `gal` - download
- `share_plus` - sharing
- `permission_handler` - gallery save permissions

## Moderation

All gallery items pass through the existing `ModerationService` pipeline.
`contentMedia` blur overlays render atop the gallery page. `noOverride` blurs
cannot be dismissed. Posts filtered at `contentList` level are excluded from the
gallery item list entirely.

## Infinite Scroll

Gallery mode supports continuous scrolling beyond the initially loaded posts.
When the user reaches the last 3 pages, `GalleryCubit` signals the parent
feed's bloc (or cubit) to load the next page via its existing cursor-based
pagination. New posts are filtered through `extractGalleryItems` and appended
to the gallery's item list. A loading shimmer renders on the final page while
the fetch is in progress. When the cursor is exhausted, the gallery shows an
"end of feed" indicator on the last page.

The gallery receives a callback (`onLoadMore`) and a stream/listener for new
posts from the parent. This keeps the gallery decoupled from specific feed
sources - it works identically whether backed by `FeedBloc`, `HashtagCubit`,
`ListFeedBloc`, or `SearchBloc`.

## DM & Notification Media

### Notifications

Notifications that reference posts with media (likes, reposts, quotes, replies
on media posts) are gallery-eligible. `NotificationBloc` already hydrates
referenced posts. `extractGalleryItems` can process the `subjectPost` or
`reasonSubject` from notification views to extract media.

Add a gallery entry point in the notifications screen when loaded notifications
contain media-bearing posts. The gallery is seeded with media items extracted
from notification subjects.

### DMs

The `chat.bsky.convo` lexicon currently supports text-only messages - no image
or video embeds. Gallery mode for DMs is not applicable until the AT Protocol
adds media message support. When/if `chat.bsky.convo.defs#messageView` gains
an `embed` field, the same `extractGalleryItems` pattern applies by adapting the
extractor to accept message views alongside feed views.

## Offline Gallery

Gallery mode works offline using cached feed data from the Drift database.

**Sources:**

| Cache source       | Table              | Contains embeds? |
|--------------------|--------------------|------------------|
| Feed first pages   | `CachedFeedPages`  | Yes (full JSON)  |
| Saved posts        | `SavedPosts`       | Yes (`postJson`) |
| Liked posts        | `LikedPosts`       | Yes (`postJson`) |

When the `ConnectivityCubit` reports offline, the gallery entry point still
appears if cached data contains media items. `extractGalleryItems` processes
deserialised `FeedViewPost` objects from cached JSON the same way it handles
live data.

Offline gallery disables actions requiring network (like, repost, reply) - these
buttons show a disabled state with a tooltip ("Offline"). Download/share actions
are disabled for images/videos not already in the device cache.

Pagination is unavailable offline - the gallery shows only what's cached, with
an "Offline - showing cached posts" indicator when the user reaches the end.

## Media-Only Feed Filtering

No server-side "media-only" feed filter exists in the AT Protocol. Gallery mode
filters client-side, which means the ratio of media-to-text posts in the
underlying feed affects gallery density. To mitigate:

- **Aggressive prefetch:** When gallery mode is active, the parent feed fetches
  with a higher `limit` (100 vs the default 50) to increase the pool of
  candidate posts.
- **Skip ratio indicator:** The chrome overlay shows the media density
  (e.g. "12 media posts from 47 loaded") so users understand the scope.
- **Feed generator hint:** For profile feeds, use `filter: postsWithMedia`
  (`FeedFilter.postsWithMedia`) which is supported by `getAuthorFeed` - this
  returns only posts containing images or video, making gallery mode fully
  dense for profile contexts.

## Accessibility

- Gallery pages announce post author + media type via `Semantics`
- Alt text is exposed to screen readers for every image/video
- Chrome overlay elements are focusable and labeled
- Physical keyboard: arrow keys navigate pages, Escape dismisses
