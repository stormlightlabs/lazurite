# CHANGELOG

## v1.0.0 (Alpha 10)

### Added

- Similar posts on thread pages, using shared public-like relationships with
  moderation-filtered AppView hydration.
- Mentions tab on authenticated profile pages, including pagination, duplicate
  filtering, and lightweight mention ranking.
- Provider-aware account settings for Bluesky and BlackSky.
- BlackSky AI preference controls backed by `community.lexicon.preference.ai` repo
  records.
- Thread reply sort preference in account settings.
- Font size setting for content text.
- Scrollable, bounded alt-text panel for full-screen image and video viewers.
- Opaque OAuth token support and OAuth session restoration after app restart.
- Shared test fixtures, router/widget harnesses, and network fixtures.

### Changed

- Profile Context now uses the nested `/profile/:actor/context` route, with
  compatibility redirects
- Thread pages have an explicit back button with authenticated and public-route
  fallbacks.
- Public post navigation pushes onto the stack for better back behavior.
- Settings has broader English localization coverage and narrower state selection
  during rendering.
- Normal content text defaults to 16px, with compact and nested post text scaled from
  the configured content size.
- Feed layout naming now uses Comfortable/Compact
- Session identity and recovery helpers are shared across the app's lifecycle

### Fixed

- Pending OAuth state is persisted and restored so app restarts during login no longer
  strand callback handling.
- Notification Screen crash
- Long media alt text is no longer truncated in full-screen viewers.

## v1.0.0 (Alpha 9)

### Added

- Signed-out/public browsing for feeds, profiles, posts, topics, and settings.
- Feed display preferences in account settings.
- Known followers tab in profile connections.
- Recursive quote rendering and expanded record embed support.
- AT Explorer now a first-class entry point.

### Changed

- Split routing into authenticated and unauthenticated shells
- Centralized unauthorized-response recovery and session refresh handling.
- Updated moderation behavior for public browsing.
- Cleaned up settings layout and account settings state.
- Centralized URL launching helpers.

### Fixed

- Constant logout/session-loss behavior from token refresh races.
- Session refresh preserving or resurrecting the wrong account state.
- Public routes rendering outside the unauthenticated shell after logout.
- `ListTile` material assertions (from the update to Flutter 3.44)

## v1.0.0 (Alpha 8)

### Added

- Pull to refresh threads
- Customizable/configurable fonts

### Changed

- Changed profile routing policy to keep "me" in the stateful shell route and route to
  the profile stack for `:actor` paths (basically going back from profiles takes you
  back to the previous screen instead of the feed)

### Fixed

- Removed global moderation blur for users requiring authenticated viewers
- Save actions from post in threads (save to "cloud"/BlueSky)

## v1.0.0 (Alpha 7)

### Added

- Repost context on feed cards, compact cards, and grid cards.
- Runtime app version/build labels in Settings, About, Privacy Policy, and Terms screens.

### Fixed

- Token refresh races that could persist stale sessions or invalidate a newer session
  after a failed refresh.
- OAuth callback exchanges when the callback issuer differs from the pending auth
  service.
- Feed management refresh behavior so stale cached preferences are not shown before
  refresh, with cached fallback messaging on refresh failure.

### Changed

- Migrated AT Protocol/Bluesky networking to the split Poptart package set.
- Reworked Bluesky network access around typed Poptart records and service wrappers,
  with typed moderation domain models.

## v1.0.0 (Alpha 6)

### Added

- Edit profile screen with support for updating display name, bio, images, pronouns,
and website
- Display pronouns and website (with link to browser) on profile screens
- English localization foundation and expanded localized UI coverage.

### Changed

- Reorganized dev docs

## v1.0.0 (Alpha 5)

### Added

- Account switcher access from the login screen.
- Settings access while signed out, including public routes for logs, about,
  legal pages, and developer tools (AT Explorer).
- Troubleshooting actions for clearing local cache and resetting sign-in data.
- Persistent OAuth client IDs for session records.

### Changed

- More comfortable composer layout with improved image attachment handling.
- Auth refresh failures are now non-destructive
- Push notification registration, notification reads, profile writes, compose uploads,
  and scheduled posts use improved auth recovery paths.

### Fixed

- OAuth callback duplicate exchange loops.
- Image/blob uploading from compose.
- Failed refreshes incorrectly clearing current sessions.

## v1.0.0 (Alpha 4)

### Changed

#### 2026-05-05

- OAuth callback handling now prefers HTTPS app links/universal links on Android and iOS, with hosted app-association files and custom-scheme fallback retained.

### Fixed

#### 2026-05-04

- Fixed background auth-expiry recovery by adding unauthorized retry + session
  refresh/recovery paths across feed/thread/conversation reads.
- Fixed account-switch reliability.

## v1.0.0 (Alpha 3)

### Added

#### 2026-05-04

- Jump to top action in feed & profile screens.
- Firebase Crashlytics integration for crash reporting and analytics.

### Fixed

- Removed dual loading/refresh spinner/indicator in feeds
- Feed Generator refresh & feed content reload race condition is fixed

## v1.0.0 (Alpha 2)

### Changed

#### 2026-05-04

- Removed localhost loopback for OAuth, instead relying on custom scheme.

## v1.0.0 (Alpha 1)

### Added

#### 2026-03-16

- OAuth2 authentication flow (app password for debugging)
- Theming - Oxocarbon, Rose Pine, Nord, Catppuccin

#### 2026-03-17

- Profile screen (post viewing)
- Feed view and management screens (reordering & pinning)
- Post actions (like, reply, repost)
- Local and ATProto/cloud saving of posts

#### 2026-03-18

- Post composer with persisted drafts
- Post deletion
- "Dev Tools" -> view logs and explore PDS records ([pdsls](https://pds.ls)) style

#### 2026-03-19

- Notification viewing
- Search screen for posts and users
- Jump to profile action from search screen with autocomplete
- Direct messages and requests
- Media players and downloading of images and videos

#### 2026-03-20

- Post thread screen
- Threaded replies with collapse/expand
- Auto-collapse replies after a certain depth

#### 2026-03-21

- Moderation service integration
- Labels added to users in posts

#### 2026-03-22

- Starter pack & list views

#### 2026-03-29

- Offline/low-connectivity detection and handling with cached data display

#### 2026-04-01

- Profile Context (Blocking/Blocked By, Lists, etc.) section accessible from profiles
- Suggested Follows tab (for non-currently authenticated users) in the Profile screen
- Video upload limits in settings

#### 2026-04-11

- Follow hygiene feature to identify and unfollow inactive or problematic accounts

#### 2026-04-12

- Multiple account support (controlled from settings and sidebar/menu)

#### 2026-04-14

- Post editing via delete-recreate
- Added url resolution for in-app links (profiles, posts, hashtags) with dedicated
  hashtag screen (matches bsky.app implementation with Top/Latest sorting)
- Jump to hashtag action from the hashtag screen with related hashtags & search

#### 2026-04-28

- Animated transitions between screens and micro animations for actions

#### 2026-04-29

- Configurable autocomplete/typeahead for login & profile/actor search
- Starter Pack search (not implemented upstream) screen

#### 2026-04-30

- Added [shades of purple](https://github.com/Rigellute/shades-of-purple.vim)/[blacksky](https://blacksky.community)
  inspired theme
- AppView (BlueSky or BlackSky) based routing with swappable provider from Login or
  Settings
- Trending views and feeds/listings based on AppView.

#### 2026-05-01

- Separate views for local and protocol-level saved/bookmarked posts.
- Local notification UI and unread-count badges.
- Push notification registration and delivery flow.

#### 2026-05-03

- Firebase push-notification configuration for iOS and Android.
- Notification reason handling and deep links for notification taps.
