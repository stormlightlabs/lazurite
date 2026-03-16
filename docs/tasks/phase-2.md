# Phase 2 Milestones

## M5 — Feeds

- [ ] Build home screen with horizontally-swipable tab bar (one tab per pinned feed)
- [ ] Implement timeline feed via `getTimeline` with cursor pagination
- [ ] Implement feed generator rendering via `getFeed` (AT-URI + pagination)
- [ ] `FeedPreferencesCubit` — read/write `savedFeedsPrefV2` via `getPreferences` / `putPreferences`
- [ ] Cache feed preferences in Drift for offline access
- [ ] Feed discovery screen via `getSuggestedFeeds` — browse and add generators
- [ ] Feed management UI — pin/unpin, drag-to-reorder, remove saved feeds

## M6 — Search

- [ ] Search screen with text input, sort toggle (`top` / `latest`), and result tabs (posts / actors)
- [ ] `SearchBloc` — events: `QuerySubmitted`, `TypeaheadRequested`, `HistoryCleared`, `HistoryEntryDeleted`
- [ ] Post search via `searchPosts` with paginated results
- [ ] Actor search via `searchActors` with paginated results
- [ ] Typeahead autocomplete via `searchActorsTypeahead`
- [ ] Drift migration: add `search_history` table (query, type, searched_at, account_did)
- [ ] Persisted search history — display recent queries, tap to re-execute, swipe to delete, cap at 50 per account

## M7 — Dev Tools (PDS Explorer)

- [ ] `DevToolsCubit` with request/response state for stateless exploration
- [ ] Handle / DID input with resolution via `resolveHandle`
- [ ] Repository overview via `describeRepo` — list collections with record counts
- [ ] Collection browser via `listRecords` — paginated record list per collection
- [ ] Record inspector via `getRecord` — pretty-printed JSON with syntax highlighting
- [ ] AT-URI input — paste `at://` URI to jump directly to a record
- [ ] Add Dev Tools entry in Settings screen, navigable by all users
