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

## M10 — Post & Profile Actions

- [ ] `PostActionRepository` — like, repost, delete via `com.atproto.repo.createRecord` / `deleteRecord`
- [ ] `PostActionCubit` — optimistic state updates for like / repost toggle with rollback on failure
- [ ] Like toggle: create `app.bsky.feed.like` record or delete by rkey; update `viewer.like` and `likeCount`
- [ ] Repost toggle: create `app.bsky.feed.repost` record or delete by rkey; update `viewer.repost` and `repostCount`
- [ ] Post action bar UI — like, repost, reply, share buttons with animated state transitions
- [ ] `ProfileActionRepository` — follow, mute, block, report
- [ ] `ProfileActionCubit` — optimistic follow/mute/block state with rollback
- [ ] Follow toggle: create `app.bsky.graph.follow` record or delete by rkey; update `viewer.following`
- [ ] Mute toggle via `app.bsky.graph.muteActor` / `unmuteActor`; update `viewer.muted`
- [ ] Block toggle: create `app.bsky.graph.block` record or delete by rkey; update `viewer.blocking`
- [ ] Profile action buttons: Follow / Following / Mute / Block in profile header and overflow menu
- [ ] Report dialog: reason picker + optional description, submit via `com.atproto.moderation.createReport`
- [ ] Report for both posts (RepoStrongRef subject) and accounts (RepoRef subject)
- [ ] Confirmation dialog before mute / block actions
- [ ] Thread muting via `app.bsky.feed.threadgate` awareness (show muted-thread indicator)

## M11 — Saved Posts

- [ ] Drift migration: add `saved_posts` table (id, account_did, post_uri, post_json, saved_at) with unique constraint on (account_did, post_uri)
- [ ] `SavedPostsCubit` — read/write saved posts, expose stream of saved URIs for icon state
- [ ] Bookmark icon on post action bar — toggle saved state
- [ ] Saved posts list screen accessible from profile or settings
