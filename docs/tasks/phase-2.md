# Phase 2 Milestones

## M4 — Logging

- [x] Add `logger` package dependency
- [x] `AppLogger` wrapper — singleton with `DevelopmentFilter` + `PrettyPrinter` for console, `AdvancedFileOutput` + `SimplePrinter` for file
- [x] File rotation — daily log files in app documents dir (`lazurite_YYYY-MM-DD.log`), 3-day retention
- [x] `LoggingBlocObserver` — log BLoC state transitions at `debug` level
- [x] HTTP logging interceptor — request/response summaries, redact `Authorization` header, truncate bodies
- [x] `NavigatorObserver` subclass — log route changes at `info` level
- [x] Log viewer screen — scrollable list reading from log files on disk
- [x] Level filter chip bar — toggle visibility per log level
- [x] Free-text search across log messages
- [x] Share button — export current day's log file via system share sheet
- [x] Clear all logs with confirmation dialog
- [x] Add "Logs" entry under Dev Tools in Settings screen

## M5 — Feeds

- [x] Build home screen with horizontally-swipable tab bar (one tab per pinned feed)
- [x] Implement timeline feed via `getTimeline` with cursor pagination
- [x] Implement feed generator rendering via `getFeed` (AT-URI + pagination)
- [x] `FeedPreferencesCubit` — read/write `savedFeedsPrefV2` via `getPreferences` / `putPreferences`
- [x] Cache feed preferences in Drift for offline access
- [x] Feed discovery screen via `getSuggestedFeeds` — browse and add generators
- [x] Feed management UI — pin/unpin, drag-to-reorder, remove saved feeds

## M6 — Search

- [x] Search screen with text input, sort toggle (`top` / `latest`), and result tabs (posts / actors)
- [x] `SearchBloc` — events: `QuerySubmitted`, `TypeaheadRequested`, `HistoryCleared`, `HistoryEntryDeleted`
- [x] Post search via `searchPosts` with paginated results
- [x] Actor search via `searchActors` with paginated results
- [x] Typeahead autocomplete via `searchActorsTypeahead`
- [x] Drift migration: add `search_history` table (query, type, searched_at, account_did)
- [x] Persisted search history — display recent queries, tap to re-execute, swipe to delete, cap at 50 per account
- [x] Search with `@` should autocomplete with avatars + handles (debounced)

## M7 — Dev Tools (PDS Explorer)

- [x] `DevToolsCubit` with request/response state for stateless exploration
- [x] Handle / DID input with resolution via `resolveHandle`
- [x] Repository overview via `describeRepo` — list collections with record counts
- [x] Collection browser via `listRecords` — paginated record list per collection
- [x] Record inspector via `getRecord` — pretty-printed JSON with syntax highlighting
- [x] AT-URI input — paste `at://` URI to jump directly to a record
- [x] Add Dev Tools entry in Settings screen, navigable by all users
- [x] Include link to <https://pds.ls> as inspiration (pdsls)
- [x] Construct <https://aturi.to> links from AT-URI.
  - ex. `at://did:plc:ewvi7nxzyoun6zhxrhs64oiz/app.bsky.feed.post/3m6mwoadjbp2d` becomes
      <https://aturi.to/did:plc:ewvi7nxzyoun6zhxrhs64oiz/app.bsky.feed.post/3m6mwoadjbp2d>
