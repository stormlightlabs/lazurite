# Phase 4 Milestones

## M12 — Direct Messages

Completed [2026-03-19](../../CHANGELOG.md#2026-03-19)

## M13 — Media Playback & Download

Completed [2026-03-19](../../CHANGELOG.md#2026-03-19)

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

Completed [2026-03-19](../../CHANGELOG.md#2026-03-19)

## M17 — Labelers & Content Moderation

Completed [2026-03-21](../../CHANGELOG.md#2026-03-21)

## M18 — Lists

Completed [2026-03-21](../../CHANGELOG.md#2026-03-21)

### Core

- [x] `ListBloc` — events: `ListRequested`, `ListRefreshed`, `ListItemAdded`, `ListItemRemoved`, `ListMuted`, `ListUnmuted`, `ListBlocked`, `ListUnblocked`
- [x] `MyListsCubit` — load user's lists via `getLists`
- [x] `ListFeedBloc` — paginated feed via `getListFeed`, reuse existing feed pattern

### List CRUD

- [x] Create list — name, description, avatar, purpose selector (curation/moderation) via `com.atproto.repo.createRecord`
- [x] Edit list — update name, description, avatar via `com.atproto.repo.putRecord`
- [x] Delete list via `com.atproto.repo.deleteRecord`
- [x] Add members — search via `searchActorsTypeahead`, create `listitem` records
- [x] Remove members — delete `listitem` records

### Moderation Actions

- [x] Mute list via `muteActorList` / unmute via `unmuteActorList`
- [x] Block via list — create `listblock` record; unblock — delete `listblock` record

### Screens

- [x] My Lists screen — curation and moderation tabs, FAB to create new list
- [x] List detail screen — header (name, avatar, description, creator, member count), Feed tab (curation lists), Members tab
- [x] Add/remove members screen — search field + current members with remove buttons
- [x] Create/edit list dialog — name, description, avatar picker, purpose selector

### Profile Integration

- [x] "Lists" tab on profile screens via `getLists`
- [x] "Add to list" option in profile overflow menu using `getListsWithMembership`

## M19 — Starter Packs

### Core

- [x] `StarterPackBloc` — events: `StarterPackRequested`, `StarterPackCreated`, `StarterPackUpdated`, `StarterPackDeleted`, `MemberAdded`, `MemberRemoved`
- [x] `ActorStarterPacksCubit` — load starter packs for an actor via `getActorStarterPacks`

### Viewing

- [x] Starter pack detail screen — name, description, creator, join stats, member sample (up to 12), recommended feeds (up to 3)
- [x] "See all members" — navigate to full member list via backing reference list
- [x] "Follow all" button — follow every member in the pack
- [x] Actor starter packs screen — paginated list via `getActorStarterPacks`

### Creation & Editing

- [x] Create starter pack — name (max 50 graphemes), description, member search, feed picker (up to 3)
- [x] Creation flow: create reference list → add `listitem` records → create starter pack record
- [x] Edit starter pack — update name/description/feeds via `putRecord`, add/remove members via `listitem` CRUD
- [x] Delete starter pack and its backing reference list

### Profile Integration

- [x] "Starter Packs" section on profile screens showing packs created by actor
- [x] Starter pack cards — name, creator, member count, join stats
