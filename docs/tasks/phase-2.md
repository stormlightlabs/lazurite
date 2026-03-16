# Phase 2 Milestones

## M5 — Logging

- [ ] Add `logger` package dependency
- [ ] `AppLogger` wrapper — singleton with `DevelopmentFilter` + `PrettyPrinter` for console, `AdvancedFileOutput` + `SimplePrinter` for file
- [ ] File rotation — daily log files in app documents dir (`lazurite_YYYY-MM-DD.log`), 3-day retention
- [ ] `LoggingBlocObserver` — log BLoC state transitions at `debug` level
- [ ] HTTP logging interceptor — request/response summaries, redact `Authorization` header, truncate bodies
- [ ] `NavigatorObserver` subclass — log route changes at `info` level
- [ ] Log viewer screen — scrollable list reading from log files on disk
- [ ] Level filter chip bar — toggle visibility per log level
- [ ] Free-text search across log messages
- [ ] Share button — export current day's log file via system share sheet
- [ ] Clear all logs with confirmation dialog
- [ ] Add "Logs" entry under Dev Tools in Settings screen

## M6 — Feeds

- [ ] Build home screen with horizontally-swipable tab bar (one tab per pinned feed)
- [ ] Implement timeline feed via `getTimeline` with cursor pagination
- [ ] Implement feed generator rendering via `getFeed` (AT-URI + pagination)
- [ ] `FeedPreferencesCubit` — read/write `savedFeedsPrefV2` via `getPreferences` / `putPreferences`
- [ ] Cache feed preferences in Drift for offline access
- [ ] Feed discovery screen via `getSuggestedFeeds` — browse and add generators
- [ ] Feed management UI — pin/unpin, drag-to-reorder, remove saved feeds

## M7 — Search

- [ ] Search screen with text input, sort toggle (`top` / `latest`), and result tabs (posts / actors)
- [ ] `SearchBloc` — events: `QuerySubmitted`, `TypeaheadRequested`, `HistoryCleared`, `HistoryEntryDeleted`
- [ ] Post search via `searchPosts` with paginated results
- [ ] Actor search via `searchActors` with paginated results
- [ ] Typeahead autocomplete via `searchActorsTypeahead`
- [ ] Drift migration: add `search_history` table (query, type, searched_at, account_did)
- [ ] Persisted search history — display recent queries, tap to re-execute, swipe to delete, cap at 50 per account

## M8 — Dev Tools (PDS Explorer)

- [ ] `DevToolsCubit` with request/response state for stateless exploration
- [ ] Handle / DID input with resolution via `resolveHandle`
- [ ] Repository overview via `describeRepo` — list collections with record counts
- [ ] Collection browser via `listRecords` — paginated record list per collection
- [ ] Record inspector via `getRecord` — pretty-printed JSON with syntax highlighting
- [ ] AT-URI input — paste `at://` URI to jump directly to a record
- [ ] Add Dev Tools entry in Settings screen, navigable by all users
