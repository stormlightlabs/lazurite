---
title: Smoke Test Checklist
updated: 2026-04-01
---

A manual walkthrough to verify core functionality after a build. Each section covers a
feature area with steps and expected outcomes.
Test on both iOS and Android unless noted otherwise.

---

## 1. Authentication

### OAuth Login

- [ ] Launch app → Login screen appears
- [ ] Enter a valid handle and tap "Sign in with BlueSky"
- [ ] System browser opens → complete OAuth flow
- [ ] Redirected back to app → Home feed loads

### App Password Login (Debug only)

- [ ] Toggle to app-password mode
- [ ] Enter handle + app password (xxxx-xxxx-xxxx-xxxx)
- [ ] Tap sign in → Home feed loads

### Session Restore

- [ ] Kill and relaunch app → session restores without login prompt
- [ ] Token refresh works silently (wait for expiry or force)

### Logout

- [ ] Log out from settings → returns to login screen
- [ ] Relaunching app shows login screen (session cleared)

---

## 2. Home Feed

### Feed Loading

- [ ] Following feed loads with posts on launch
- [ ] Pull-to-refresh fetches new posts
- [ ] Scroll down → infinite pagination loads more posts

### Post Cards

- [ ] Posts display: avatar, name, handle, relative timestamp
- [ ] Rich text renders correctly (mentions, links, hashtags highlighted)
- [ ] Image embeds display (single + multi-image grids)
- [ ] Video embeds display with thumbnail
- [ ] Link card embeds render (title, description, thumbnail)
- [ ] Quote posts render inline
- [ ] Engagement counts shown (likes, reposts, replies)

### Post Actions

- [ ] Tap like → icon fills, count increments (optimistic)
- [ ] Tap like again → unlike, count decrements
- [ ] Tap repost → menu: "Repost" and "Quote Post"
- [ ] Repost → count increments
- [ ] Tap reply → compose modal opens with reply context
- [ ] Tap share → system share sheet
- [ ] Overflow → Save post (bookmark icon fills)
- [ ] Overflow → Copy link

### Navigation from Feed

- [ ] Tap post body → thread view opens
- [ ] Tap avatar or name → profile screen opens

---

## 3. Feed Management

- [ ] Open feed management from home screen
- [ ] Pinned feeds listed (Following + custom generators)
- [ ] Drag to reorder feeds → order persists
- [ ] Toggle pin off → feed removed from home tabs
- [ ] Add a suggested feed → appears in home tabs

---

## 4. Post Composition

### Basic Compose

- [ ] Tap compose FAB → compose screen opens
- [ ] Type text → character counter updates (max 300 graphemes)
- [ ] Mentions auto-highlight as typed
- [ ] Links and hashtags auto-highlight
- [ ] Submit → post appears in feed

### Media

- [ ] Attach 1–4 images → thumbnails shown
- [ ] Add alt text to an image
- [ ] Remove an image attachment
- [ ] Attach a video → upload progress shown
- [ ] Images and video are mutually exclusive (UI enforces)

### Reply & Quote

- [ ] Compose as reply → parent post context shown above input
- [ ] Compose as quote → quoted post shown below input

### Drafts

- [ ] Save draft → confirmation shown
- [ ] Open drafts → saved draft listed
- [ ] Load draft → text and media restored
- [ ] Submit loaded draft → posts successfully

### Scheduled Posts

- [ ] Schedule a post for a future time → confirmation shown
- [ ] Post publishes at scheduled time (background task)

## 5. Search

### Post Search

- [ ] Type query → results load
- [ ] Sort toggle: "Top" vs "Latest" works
- [ ] Tap result → thread view opens

### Actor Search

- [ ] Switch to Actors tab → type query
- [ ] Autocomplete suggestions appear as you type
- [ ] Tap result → profile screen opens

### Starter Pack Search

- [ ] Switch to Starter Packs tab → type query
- [ ] Results show pack cards
- [ ] Tap result → starter pack detail opens

### Search History

- [ ] Recent searches appear below search bar
- [ ] Tap history item → re-executes search
- [ ] Swipe to delete a single entry
- [ ] "Clear all" removes all history

## 6. Notifications

### Notification List

- [ ] Alerts tab shows notifications (likes, reposts, follows, mentions, replies, quotes)
- [ ] Grouped by day
- [ ] Unread count badge on nav tab
- [ ] Tap notification → navigates to post or profile
- [ ] "Mark all as read" clears unread badge

### Unread Polling

- [ ] Leave app open → badge count updates (30s poll interval)

## 7. Direct Messages

### Conversation List

- [ ] Messages sub-tab shows conversations sorted by recency
- [ ] Unread count per conversation displayed
- [ ] Requests sub-tab shows unanswered conversations

### Message Thread

- [ ] Tap conversation → message thread opens
- [ ] Messages paginate (scroll up for older)
- [ ] Own messages right-aligned, others left-aligned
- [ ] Type and send a message → appears immediately
- [ ] Tap message → copy option

### Conversation Actions

- [ ] Mute conversation from overflow → muted indicator shown
- [ ] Unmute → indicator removed

## 8. Profile

### Own Profile

- [ ] Profile tab shows: banner, avatar, display name, handle, bio
- [ ] Follower/following/post counts displayed
- [ ] Posts tab → author's posts (no replies)
- [ ] Replies tab → posts and threads
- [ ] Media tab → only posts with media
- [ ] Lists tab → lists created by user (Curation | Moderation sub-tabs)
- [ ] Packs tab → starter packs created by user

### Other User's Profile

- [ ] Tap user anywhere → their profile loads
- [ ] Follow button shown → tap to follow → button changes
- [ ] Unfollow → button reverts
- [ ] Overflow: Mute, Block, Report, Copy DID, Share

### Suggested Follows

- [ ] Overflow → "Suggested Follows" → sheet with suggestions
- [ ] Follow/unfollow buttons in sheet work

## 9. Profile Context (Constellation)

- [ ] Open profile context from profile overflow menu
- [ ] **Blocked By** tab: shows count, "Show accounts" expands list
- [ ] Paginated account tiles load
- [ ] **Blocking** tab: shows outgoing blocks (own profile only)
- [ ] Shows "unavailable" message for other profiles
- [ ] **Lists** tab: shows lists user is a member of
- [ ] List cards display: name, owner, purpose badge, description
- [ ] Tap account → navigates to profile
- [ ] Tap list → navigates to list detail

## 10. Post Thread

- [ ] Thread loads: parent chain above, replies below
- [ ] Root post visually highlighted
- [ ] Nested reply chains render correctly
- [ ] All post actions work within thread (like, repost, reply, save)
- [ ] Tap profile in thread → profile screen

## 11. Lists

### My Lists

- [ ] Navigate to lists screen
- [ ] Curation and Moderation tabs separate lists correctly
- [ ] Tap list → detail screen

### Create List

- [ ] Tap FAB → create dialog
- [ ] Enter name (1–64 graphemes), optional description, pick avatar
- [ ] Select purpose (curation or moderation)
- [ ] Save → list appears in My Lists

### List Detail

- [ ] Header: name, avatar, description, creator, member count
- [ ] Feed tab (curation lists): shows posts from members
- [ ] Members tab: lists member profiles
- [ ] Overflow: Edit, Delete, Add/Remove members

### List Members

- [ ] Search for actors to add
- [ ] Add member → appears in list
- [ ] Remove member → removed from list

### Moderation Actions

- [ ] Mute list → all members muted
- [ ] Block via list → all members blocked

## 12. Starter Packs

### Starter Pack Detail

- [ ] Header: name, description, creator
- [ ] Stats: joined this week, joined all-time
- [ ] Sample members displayed (up to 12)
- [ ] Recommended feeds displayed (up to 3)
- [ ] "See all members" → navigates to list members
- [ ] "Follow all" → follows all members (with confirmation)

### Create Starter Pack

- [ ] Tap create from own profile's Packs tab
- [ ] Enter name (max 50 graphemes), optional description
- [ ] Search and add members
- [ ] Pick up to 3 feeds
- [ ] Save → pack appears on profile

### Edit / Delete

- [ ] Edit pack → update name, description, feeds
- [ ] Delete pack → removed from profile

## 13. Media

### Image Viewer

- [ ] Tap image → full-screen viewer
- [ ] Pinch to zoom, pan around
- [ ] Multi-image post → swipe between images
- [ ] Alt text shown at bottom (if present)
- [ ] Download → saved to gallery
- [ ] Share → system sheet
- [ ] Swipe down → dismiss viewer

### Video Player

- [ ] Tap video → full-screen player
- [ ] Play/pause, seek bar, mute controls work
- [ ] Elapsed/total time displayed
- [ ] Fullscreen toggle works

### Long-Press Context Menu

- [ ] Long-press image thumbnail → Save / Share options

---

## 14. Saved Posts

- [ ] Navigate to saved posts screen
- [ ] Previously saved posts listed
- [ ] Tap post → thread view
- [ ] Unsave → removed from list
- [ ] Empty state shown when no saved posts

---

## 15. Moderation & Labelers

### Content Filtering

- [ ] Blurred content shows click-through overlay
- [ ] Alert badge renders on warned content
- [ ] Filtered content hidden from feeds
- [ ] Media blur shows blurred images, text visible

### Labeler Management

- [ ] Settings → Moderation → labeler list shown
- [ ] Tap labeler → detail with label definitions
- [ ] Toggle per-label preference (ignore/warn/hide)
- [ ] Subscribe to new labeler
- [ ] Unsubscribe from labeler
- [ ] Adult content toggle gates 18+ labels

---

## 16. Connectivity & Offline

### Network Loss

- [ ] Disable network → offline banner appears at top
- [ ] Cached feed data still displays
- [ ] Post actions (like, repost, compose) disabled with tooltip
- [ ] Notifications/DMs show empty or cached state

### Network Restore

- [ ] Re-enable network → banner disappears
- [ ] Actions re-enabled
- [ ] Pull-to-refresh loads fresh data

### Optimistic Updates

- [ ] Like a post on slow connection → UI updates immediately
- [ ] If API fails → UI rolls back, error snackbar shown

---

## 17. Settings & Preferences

### Theme

- [ ] Change theme palette (Oxocarbon, Catppuccin, Nord, Rosé Pine)
- [ ] Toggle Light / Dark / System mode
- [ ] Theme applies immediately across all screens

### Account Switching

- [ ] Open account switcher → all accounts listed
- [ ] Switch to another account → feeds/profile reload for new account
- [ ] Add new account → OAuth flow → account added to list

### Dev Tools

- [ ] Logs: view logs, filter by level, search text, share log file
- [ ] PDS Explorer: resolve handle, browse collections, view record JSON

### About

- [ ] App version and build number displayed
- [ ] Licenses accessible

---

## 18. Cross-Cutting Concerns

### Navigation

- [ ] Bottom nav switches between Home, Search, Alerts, Profile
- [ ] Back button / swipe-back navigates correctly through stack
- [ ] Deep link to a post URI opens thread view

### Performance

- [ ] Feed scroll is smooth (no jank)
- [ ] Image loading doesn't block UI
- [ ] Search results appear within reasonable time

### Error States

- [ ] Invalid handle on login → error message shown
- [ ] Network error on post submit → error snackbar, draft preserved
- [ ] 404 on deleted post → appropriate error state

### State Persistence

- [ ] Kill app mid-scroll → relaunch restores session
- [ ] Drafts survive app restart
- [ ] Saved posts survive app restart
- [ ] Search history survives app restart
- [ ] Theme selection survives app restart
