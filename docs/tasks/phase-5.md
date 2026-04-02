---
title: Phase 5 Task Breakdown
updated: 2026-04-01
---

# Phase 5 Milestones

## M20 - Starter Pack Search

### Core

- [x] `SearchRepository.searchStarterPacks()` - call `bluesky.graph.searchStarterPacks(q:, limit:, cursor:)`, return result with `List<StarterPackViewBasic>` and cursor
- [x] Add `starterPacks` value to `SearchTab` enum, update `SearchTabLabel` extension

### Cubit

- [x] `SearchBloc` - handle starter packs tab: dispatch search on tab switch if query present, handle `LoadMoreRequested` with cursor pagination
- [x] `SearchState` - add `starterPacks` list and `starterPacksCursor` fields

### UI

- [ ] Search screen UI - add third "Starter Packs" tab pill in `_buildTab` row
- [ ] Starter pack result tile widget - show name, creator handle, member count, joined stats; reuse pattern from profile starter packs tab
- [ ] Tap result → navigate to existing starter pack detail screen (`/starter-pack?uri=`)
- [ ] Infinite scroll pagination for starter packs tab

### Tests

- [x] Unit tests: `SearchRepository.searchStarterPacks`, bloc events for new tab, pagination
- [ ] Widget tests: third tab renders, results display, empty state, tap navigation

## M21 - Suggested Follows Sheet

### Core

- [ ] `ProfileRepository.getSuggestedFollows()` - call `bluesky.graph.getSuggestedFollowsByActor(actor:)`, return `List<ProfileView>`

### Cubit

- [ ] `SuggestedFollowsCubit` - `load(actor:)` fetches suggestions, exposes loaded/loading/error states

### UI

- [ ] Suggested follows sheet widget - `DraggableScrollableSheet` listing `ProfileView` tiles with follow/unfollow toggle buttons
- [ ] Profile screen overflow menu - add "Suggested Follows" `ListTile` entry; hide when viewing own profile
- [ ] Tap entry → create cubit, show sheet with `BlocProvider.value`, close cubit on sheet dismiss via `.whenComplete`
- [ ] Tap profile tile → pop sheet, navigate to profile screen
- [ ] Empty state when no suggestions returned

### Tests

- [ ] Unit tests: repository method, cubit state transitions
- [ ] Widget tests: sheet renders profiles, follow button toggles, own-profile menu hides entry, empty state

## M22 - Video Upload Limits

### Core

- [ ] `VideoRepository` (or extend settings repository) - `getUploadLimits()` calling `bluesky.video.getUploadLimits()`, return typed result

### Cubit

- [ ] `VideoUploadLimitsCubit` - fetch on init, expose `canUpload`, remaining counts, message/error

### UI

- [ ] Settings screen - new tile in Account section: "Video Upload Limits"
- [ ] Tile UI - show remaining daily video count, remaining bytes formatted as MB/GB, `canUpload` status badge
- [ ] Loading state while fetching, error state if request fails
- [ ] Display server `message` if present; show `error` text with warning styling if `canUpload` is false

### Tests

- [ ] Unit tests: repository method, cubit state transitions and formatting
- [ ] Widget tests: tile renders limits, loading indicator, error state, message display

## M23 - Profile Context (Constellation)

### Core - Constellation Client

- [x] `ConstellationClient` - thin HTTP client (`http` package) targeting configurable base URL (default `https://constellation.microcosm.blue`), 10s timeout, `User-Agent: lazurite`
- [x] `Settings` - add `constellation_url` key with default value; expose in Settings screen under "Advanced"
- [x] `getBacklinksCount(subject, source)` → `int` total
- [x] `getDistinct(subject, source, {limit, cursor})` → `({int total, List<String> dids, String? cursor})`
- [x] `getBacklinks(subject, source, {limit, cursor})` → `({int total, List<ConstellationLinkRecord> records, String? cursor})`
- [x] `getManyToMany(subject, source, pathToOther, {limit, cursor})` → `({List<ManyToManyItem> items, String? cursor})`
- [x] `ConstellationLinkRecord` model - `did`, `collection`, `rkey`
- [x] `ManyToManyItem` model - `linkRecord: ConstellationLinkRecord`, `otherSubject: String`

### Core - Profile Context Repository

- [x] `ProfileContextRepository` - depends on `ConstellationClient` + `Bluesky`
- [x] `getBlockedByCount(did)` - calls `getBacklinksCount(did, 'app.bsky.graph.block:subject')`
- [x] `getBlockedByProfiles(did, {cursor})` - calls `getDistinct`, hydrates DIDs via `bluesky.actor.getProfiles` (batched 25), returns `({List<ProfileView> profiles, String? cursor, int total})`
- [x] `getBlockingProfiles(did, {cursor})` - calls `com.atproto.repo.listRecords(repo: did, collection: 'app.bsky.graph.block')`, extracts subject DIDs, hydrates via `getProfiles`, returns same shape
- [x] `getListsOn(did, {cursor})` - calls `getManyToMany(did, 'app.bsky.graph.listitem:subject', 'list')`, derives list AT-URIs from `otherSubject`, hydrates via `bluesky.graph.getList`, returns `({List<ListView> lists, String? cursor, int total})`

### Cubit

- [x] `ProfileContextCubit` - manages tab state, loads counts on init for all three tabs
- [x] `ProfileContextState` - fields: `blockedByCount`, `blockingCount`, `listsOnCount`, per-tab `status` (initial/loading/loaded/error), per-tab item list + cursor
- [x] `loadBlockedBy({cursor})` - fetches page of blocked-by profiles, appends to state
- [x] `loadBlocking({cursor})` - fetches page of blocking profiles, appends to state
- [x] `loadListsOn({cursor})` - fetches page of lists, appends to state
- [x] Handle own-profile vs other-profile: blocking tab only available for own profile

### UI

- [x] Profile screen overflow menu - add "Profile Context" entry (available for all profiles)
- [x] Route: `/profile-context?did={DID}` in `app_router.dart`
- [x] `ProfileContextScreen` - `AppBar` (title + handle subtitle), `TabBar` with 3 tabs, `BlocProvider` creating cubit
- [x] **Blocked By tab** - count header, "Show accounts" expand, paginated profile tiles (avatar, name, handle), tap → profile navigation, contextualizing note text
- [x] **Blocking tab** - same layout; hidden or explanatory text when viewing other profiles
- [x] **Lists tab** - list cards (name, owner, purpose badge, member count, description), grouped by purpose, tap → `/list?uri=`
- [x] Per-tab states: skeleton shimmer (loading), contextual empty state, inline error with retry
- [x] Pull-to-refresh per tab
- [x] Infinite scroll pagination per tab

### Tests

- [x] Unit tests: `ConstellationClient` - each endpoint method, error handling, timeout, URL construction
- [x] Unit tests: `ProfileContextRepository` - DID hydration batching, list URI derivation, cursor passthrough
- [x] Unit tests: `ProfileContextCubit` - state transitions for each tab, own-profile vs other-profile logic, pagination appending
- [x] Widget tests: screen renders 3 tabs, blocked-by count + expand, profile tiles render and navigate, list cards render and navigate, empty states, error + retry, blocking tab hidden for non-own profiles
