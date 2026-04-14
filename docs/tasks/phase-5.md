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

- [x] Search screen UI - add third "Starter Packs" tab pill in `_buildTab` row
- [x] Starter pack result tile widget - show name, creator handle, member count, joined stats; reuse pattern from profile starter packs tab
- [x] Tap result → navigate to existing starter pack detail screen (`/starter-pack?uri=`)
- [x] Infinite scroll pagination for starter packs tab

### Tests

- [x] Unit tests: `SearchRepository.searchStarterPacks`, bloc events for new tab, pagination
- [x] Widget tests: third tab renders, results display, empty state, tap navigation

## M21 - Suggested Follows Sheet

### Core

- [x] `ProfileRepository.getSuggestedFollows()` - call `bluesky.graph.getSuggestedFollowsByActor(actor:)`, return `List<ProfileView>`

### Cubit

- [x] `SuggestedFollowsCubit` - `load(actor:)` fetches suggestions, exposes loaded/loading/error states

### UI

- [x] Suggested follows sheet widget - `DraggableScrollableSheet` listing `ProfileView` tiles with follow/unfollow toggle buttons
- [x] Profile screen overflow menu - add "Suggested Follows" `ListTile` entry; hide when viewing own profile
- [x] Tap entry → create cubit, show sheet with `BlocProvider.value`, close cubit on sheet dismiss via `.whenComplete`
- [x] Tap profile tile → pop sheet, navigate to profile screen
- [x] Empty state when no suggestions returned

### Tests

- [x] Unit tests: repository method, cubit state transitions
- [x] Widget tests: sheet renders profiles, follow button toggles, own-profile menu hides entry, empty state

## M22 - Video Upload Limits

### Core

- [x] `VideoRepository` (or extend settings repository) - `getUploadLimits()` calling `bluesky.video.getUploadLimits()`, return typed result

### Cubit

- [x] `VideoUploadLimitsCubit` - fetch on init, expose `canUpload`, remaining counts, message/error

### UI

- [x] Settings screen - new tile in Account section: "Video Upload Limits"
- [x] Tile UI - show remaining daily video count, remaining bytes formatted as MB/GB, `canUpload` status badge
- [x] Loading state while fetching, error state if request fails
- [x] Display server `message` if present; show `error` text with warning styling if `canUpload` is false

### Tests

- [x] Unit tests: repository method, cubit state transitions and formatting
- [x] Widget tests: tile renders limits, loading indicator, error state, message display

## M23 - Profile Context (Constellation)

Completed [2026-04-01](../../CHANGELOG.md#2026-04-01)
