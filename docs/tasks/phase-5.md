---
title: Phase 5 Task Breakdown
updated: 2026-03-25
---

# Phase 5 Milestones

## M20 — Starter Pack Search

### Core

- [ ] `SearchRepository.searchStarterPacks()` — call `bluesky.graph.searchStarterPacks(q:, limit:, cursor:)`, return result with `List<StarterPackViewBasic>` and cursor
- [ ] Add `starterPacks` value to `SearchTab` enum, update `SearchTabLabel` extension

### Cubit

- [ ] `SearchBloc` — handle starter packs tab: dispatch search on tab switch if query present, handle `LoadMoreRequested` with cursor pagination
- [ ] `SearchState` — add `starterPacks` list and `starterPacksCursor` fields

### UI

- [ ] Search screen UI — add third "Starter Packs" tab pill in `_buildTab` row
- [ ] Starter pack result tile widget — show name, creator handle, member count, joined stats; reuse pattern from profile starter packs tab
- [ ] Tap result → navigate to existing starter pack detail screen (`/starter-pack?uri=`)
- [ ] Infinite scroll pagination for starter packs tab

### Tests

- [ ] Unit tests: `SearchRepository.searchStarterPacks`, bloc events for new tab, pagination
- [ ] Widget tests: third tab renders, results display, empty state, tap navigation

## M21 — Suggested Follows Sheet

### Core

- [ ] `ProfileRepository.getSuggestedFollows()` — call `bluesky.graph.getSuggestedFollowsByActor(actor:)`, return `List<ProfileView>`

### Cubit

- [ ] `SuggestedFollowsCubit` — `load(actor:)` fetches suggestions, exposes loaded/loading/error states

### UI

- [ ] Suggested follows sheet widget — `DraggableScrollableSheet` listing `ProfileView` tiles with follow/unfollow toggle buttons
- [ ] Profile screen overflow menu — add "Suggested Follows" `ListTile` entry; hide when viewing own profile
- [ ] Tap entry → create cubit, show sheet with `BlocProvider.value`, close cubit on sheet dismiss via `.whenComplete`
- [ ] Tap profile tile → pop sheet, navigate to profile screen
- [ ] Empty state when no suggestions returned

### Tests

- [ ] Unit tests: repository method, cubit state transitions
- [ ] Widget tests: sheet renders profiles, follow button toggles, own-profile menu hides entry, empty state

## M22 — Video Upload Limits

### Core

- [ ] `VideoRepository` (or extend settings repository) — `getUploadLimits()` calling `bluesky.video.getUploadLimits()`, return typed result

### Cubit

- [ ] `VideoUploadLimitsCubit` — fetch on init, expose `canUpload`, remaining counts, message/error

### UI

- [ ] Settings screen — new tile in Account section: "Video Upload Limits"
- [ ] Tile UI — show remaining daily video count, remaining bytes formatted as MB/GB, `canUpload` status badge
- [ ] Loading state while fetching, error state if request fails
- [ ] Display server `message` if present; show `error` text with warning styling if `canUpload` is false

### Tests

- [ ] Unit tests: repository method, cubit state transitions and formatting
- [ ] Widget tests: tile renders limits, loading indicator, error state, message display
