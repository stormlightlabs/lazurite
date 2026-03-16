# Phase 3 Milestones

## M8 — Post Composition

- [ ] Full-screen compose modal with text input, live grapheme counter (300 max), and submit button
- [ ] `ComposeBloc` — events: `TextChanged`, `MediaAttached`, `MediaRemoved`, `AltTextUpdated`, `DraftSaved`, `DraftLoaded`, `PostScheduled`, `PostSubmitted`
- [ ] Image attachment via `uploadBlob` — up to 4 images, alt text input per image
- [ ] Live facet detection and preview via `bluesky_text` (mentions, links, hashtags)
- [ ] Post creation via `com.atproto.repo.createRecord` with `app.bsky.feed.post` collection
- [ ] Reply support — pass `parent` + `root` refs when composing from a post thread
- [ ] Drift migration: add `drafts` table (id, account_did, text, reply_uri, embed_json, media_paths, created_at, updated_at, scheduled_at)
- [ ] Draft save on network failure, explicit save, and back-navigation
- [ ] Drafts list UI accessible from compose toolbar
- [ ] Scheduled posts — date/time picker, background task via WorkManager / BGTaskScheduler
- [ ] Floating action button on home screen to open compose modal

## M9 — Notifications

- [ ] Notifications screen with grouped-by-day notification list
- [ ] `NotificationBloc` — events: `NotificationsRequested`, `NotificationsRefreshed`, `NotificationsPageLoaded`, `NotificationsMarkedRead`
- [ ] Fetch notifications via `listNotifications` with cursor pagination
- [ ] Render all notification reasons: like, repost, follow, mention, reply, quote
- [ ] Each notification row: author avatar, reason icon, summary text, optional post preview
- [ ] Unread count badge on nav bar via `getUnreadCount` polling (30s interval)
- [ ] Mark as read via `updateSeen` when notifications screen opens
- [ ] Tap notification to navigate to relevant post or profile

## M10 — Direct Messages

- [ ] Conversation list screen via `chat.bsky.convo.listConvos` with pagination
- [ ] `ConvoListBloc` — events: `ConvosRequested`, `ConvosRefreshed`, `ConvoMuted`, `ConvoUnmuted`
- [ ] Primary / Requests tab filtering on conversation list
- [ ] Message thread screen via `chat.bsky.convo.getMessages` with pagination
- [ ] `MessageBloc` — events: `MessagesRequested`, `MessagesPageLoaded`, `MessageSent`, `MessageDeleted`, `ConvoMarkedRead`
- [ ] Chat bubble layout — current user right-aligned, others left-aligned
- [ ] Send messages via `chat.bsky.convo.sendMessage`
- [ ] New conversation via `chat.bsky.convo.getConvoForMembers`
- [ ] Long-press to copy individual messages, overflow menu "Copy All" for full thread
- [ ] Mute / unmute conversations
- [ ] Mark conversation as read via `chat.bsky.convo.updateRead`

## M11 — Account Switching

- [ ] `AccountSwitcherCubit` exposing account list and active DID
- [ ] Account switcher bottom sheet UI — list accounts with avatars and handles
- [ ] Store `active_account_did` in Drift `settings` table
- [ ] Drift migration: add `account_did` column to `cached_posts` if not present
- [ ] All user-scoped queries filter by active account DID
- [ ] Broadcast `AccountSwitched` event to all Blocs on switch
- [ ] "Add Account" button triggers OAuth flow, inserts new `accounts` row
- [ ] Silent token refresh on account switch; navigate to login on failure

## M12 — Offline Reading & Network Resilience

- [ ] `ConnectivityCubit` via **connectivity_plus** — expose network state stream
- [ ] Cache last-fetched feed page as serialised JSON in Drift
- [ ] Display cached data immediately on launch, refresh in background
- [ ] "You're offline" banner when connectivity is lost
- [ ] Disable network-dependent actions (compose, like, repost, follow) when offline with tooltip
- [ ] Notifications and DM screens show "No connection" empty state when offline with no cache

## M13 — Saved Posts

- [ ] Drift migration: add `saved_posts` table (id, account_did, post_uri, post_json, saved_at) with unique constraint on (account_did, post_uri)
- [ ] `SavedPostsCubit` — read/write saved posts, expose stream of saved URIs for icon state
- [ ] Bookmark icon on post action bar — toggle saved state
- [ ] Saved posts list screen accessible from profile or settings

## M14 — Jump to Profile

- [ ] Floating action button on search screen
- [ ] Handle input dialog with autocomplete via `searchActorsTypeahead`
- [ ] Navigate to profile screen on selection or enter
- [ ] Update bottom navigation to include Notifications and Messages tabs (5-tab layout)
