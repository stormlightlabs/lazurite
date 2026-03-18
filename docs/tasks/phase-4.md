# Phase 4 Milestones

## M12 — Direct Messages

- [x] Conversation list screen via `chat.bsky.convo.listConvos` with pagination
- [x] `ConvoListBloc` — events: `ConvosRequested`, `ConvosRefreshed`, `ConvoMuted`, `ConvoUnmuted`
- [x] Primary / Requests tab filtering on conversation list
- [x] Message thread screen via `chat.bsky.convo.getMessages` with pagination
- [x] `MessageBloc` — events: `MessagesRequested`, `MessagesPageLoaded`, `MessageSent`, `MessageDeleted`, `ConvoMarkedRead`
- [x] Chat bubble layout — current user right-aligned, others left-aligned
- [x] Send messages via `chat.bsky.convo.sendMessage`
- [x] New conversation via `chat.bsky.convo.getConvoForMembers`
- [x] Long-press to copy individual messages, overflow menu "Copy All" for full thread
- [x] Mute / unmute conversations
- [x] Mark conversation as read via `chat.bsky.convo.updateRead`

## M13 — Media Playback & Download

- [ ] Add `photo_view`, `video_player`, `chewie`, `dio`, `gal`, `permission_handler` to `pubspec.yaml`
- [ ] `ImageViewerScreen` — full-screen `PageView` of `PhotoView` widgets loading `fullsize` URLs with hero animation from thumbnail
- [ ] Page indicator for multi-image posts; alt text bar at the bottom of each page
- [ ] Swipe-down-to-dismiss gesture on image viewer
- [ ] Download button in image viewer toolbar — request permission, download via `dio` with progress indicator, save via `gal`, show snackbar result
- [ ] Share button in image viewer toolbar via `share_plus`
- [ ] Long-press context menu on image thumbnails in post cards — "Save image" and "Share" options
- [ ] `VideoPlayerScreen` — `chewie` wrapping `VideoPlayerController.networkUrl` with HLS `playlist` URL
- [ ] Video player uses embed `aspectRatio` when available, defaults to 16:9
- [ ] Video thumbnail as placeholder until player initialises; controller disposed on screen pop
- [ ] GIF-presentation mode — auto-play, loop, muted, controls hidden when `presentation` is `"gif"`
- [ ] Download button in video player toolbar — parse `.m3u8` for highest-bandwidth variant URL, download MP4 via `dio` with progress, save via `gal`
- [ ] Declare `NSPhotoLibraryAddUsageDescription` in `Info.plist` and storage permissions in `AndroidManifest.xml`
- [ ] Replace `_launchExternal` calls for image/video embeds in `PostCard` with navigation to the new viewer screens

## M14 — Account Switching

- [x] `AccountSwitcherCubit` exposing account list and active DID
- [ ] Account switcher bottom sheet UI — list accounts with avatars and handles
- [x] Store `active_account_did` in Drift `settings` table
- [x] Drift migration: add `account_did` column to `cached_posts` if not present
- [ ] All user-scoped queries filter by active account DID
- [ ] Broadcast `AccountSwitched` event to all Blocs on switch
- [ ] "Add Account" button triggers OAuth flow, inserts new `accounts` row
- [ ] Silent token refresh on account switch; navigate to login on failure

## M15 — Offline Reading & Network Resilience

- [x] `ConnectivityCubit` via **connectivity_plus** — expose network state stream
- [ ] Cache last-fetched feed page as serialised JSON in Drift
- [ ] Display cached data immediately on launch, refresh in background
- [ ] "You're offline" banner when connectivity is lost
- [ ] Disable network-dependent actions (compose, like, repost, follow) when offline with tooltip
- [ ] Notifications and DM screens show "No connection" empty state when offline with no cache

## M16 — Jump to Profile

- [ ] Floating action button on search screen
- [ ] Handle input dialog with autocomplete via `searchActorsTypeahead`
- [ ] Navigate to profile screen on selection or enter
- [ ] Update bottom navigation to include Notifications and Messages tabs (5-tab layout)

## M17 — Labelers & Content Moderation

- [x] Fetch user's labeler subscriptions from preferences via `app.bsky.actor.getPreferences` (`labelersPref`)
- [ ] Include subscribed labeler DIDs in `atproto-accept-labelers` header on all XRPC requests
- [x] `ModerationService` — wraps the `bluesky` package's `moderatePost`, `moderateProfile`, `moderateNotification` functions
- [ ] Run moderation decisions on all displayed posts and profiles
- [ ] Apply `ModerationUI` results: filter, blur, alert, inform per display context (contentList, contentView, contentMedia, avatar, profileList, profileView)
- [ ] Blur overlay on posts/media with click-through "Show content" button
- [ ] Warning badges on profiles and posts for alert/inform labels
- [ ] Content filtering — remove posts with `filter` decisions from feed and notification lists
- [ ] Labeler management screen: list subscribed labelers via `app.bsky.labeler.getServices`
- [ ] Subscribe / unsubscribe to labelers by updating `labelersPref` via `putPreferences`
- [ ] Per-label preference configuration: ignore / warn / hide per label value per labeler
- [ ] Store label preferences as `contentLabelPref` entries via `putPreferences`
- [ ] Adult content toggle (requires `adultContentEnabled` preference)
- [ ] Self-label support — render self-labels embedded in posts and profiles
- [ ] Labeler detail screen: show labeler creator, policies, and custom label definitions with localised names
- [x] Drift table: `labeler_cache` (labeler_did, policies_json, fetched_at) for offline label definition lookup
