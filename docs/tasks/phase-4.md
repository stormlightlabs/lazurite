# Phase 4 Milestones

## M12 — Direct Messages

- [ ] Conversation list screen via `chat.bsky.convo.listConvos` with pagination
- [x] `ConvoListBloc` — events: `ConvosRequested`, `ConvosRefreshed`, `ConvoMuted`, `ConvoUnmuted`
- [x] Primary / Requests tab filtering on conversation list
- [ ] Message thread screen via `chat.bsky.convo.getMessages` with pagination
- [x] `MessageBloc` — events: `MessagesRequested`, `MessagesPageLoaded`, `MessageSent`, `MessageDeleted`, `ConvoMarkedRead`
- [ ] Chat bubble layout — current user right-aligned, others left-aligned
- [x] Send messages via `chat.bsky.convo.sendMessage`
- [x] New conversation via `chat.bsky.convo.getConvoForMembers`
- [ ] Long-press to copy individual messages, overflow menu "Copy All" for full thread
- [x] Mute / unmute conversations
- [x] Mark conversation as read via `chat.bsky.convo.updateRead`

## M13 — Account Switching

- [x] `AccountSwitcherCubit` exposing account list and active DID
- [ ] Account switcher bottom sheet UI — list accounts with avatars and handles
- [x] Store `active_account_did` in Drift `settings` table
- [x] Drift migration: add `account_did` column to `cached_posts` if not present
- [ ] All user-scoped queries filter by active account DID
- [ ] Broadcast `AccountSwitched` event to all Blocs on switch
- [ ] "Add Account" button triggers OAuth flow, inserts new `accounts` row
- [ ] Silent token refresh on account switch; navigate to login on failure

## M14 — Offline Reading & Network Resilience

- [x] `ConnectivityCubit` via **connectivity_plus** — expose network state stream
- [ ] Cache last-fetched feed page as serialised JSON in Drift
- [ ] Display cached data immediately on launch, refresh in background
- [ ] "You're offline" banner when connectivity is lost
- [ ] Disable network-dependent actions (compose, like, repost, follow) when offline with tooltip
- [ ] Notifications and DM screens show "No connection" empty state when offline with no cache

## M15 — Jump to Profile

- [ ] Floating action button on search screen
- [ ] Handle input dialog with autocomplete via `searchActorsTypeahead`
- [ ] Navigate to profile screen on selection or enter
- [ ] Update bottom navigation to include Notifications and Messages tabs (5-tab layout)

## M16 — Labelers & Content Moderation

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
