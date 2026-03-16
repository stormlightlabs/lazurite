# Lazurite Phase 2 Spec

## Logging

Structured logging for development debugging and in-app log inspection. Uses
the [`logger`](https://pub.dev/packages/logger) package (v2.x) — the most
widely adopted Flutter logging library — with file-based persistence via its
built-in `AdvancedFileOutput`.

### Log Levels

| Level     | Usage                                       |
| --------- | ------------------------------------------- |
| `trace`   | Fine-grained control flow (loop iterations) |
| `debug`   | Development-only diagnostics                |
| `info`    | Significant lifecycle events (login, nav)   |
| `warning` | Recoverable issues (retry, fallback)        |
| `error`   | Failures with stack traces                  |
| `fatal`   | Unrecoverable errors (crash-level)          |

### Architecture

A single `AppLogger` wrapper class exposes a top-level `log` instance injected
via the service locator. All subsystems log through this instance.

```sh
AppLogger
├── LogFilter  (DevelopmentFilter / ProductionFilter)
├── LogPrinter (PrettyPrinter for dev, SimplePrinter for file)
└── LogOutput
    ├── ConsoleOutput      (always, dev only)
    └── AdvancedFileOutput  (always, all builds)
```

**Console output** — enabled only in debug builds via `DevelopmentFilter`.
Uses `PrettyPrinter` with method counts, colors, and emojis for readability
in the terminal.

**File output** — enabled in all builds. Uses `AdvancedFileOutput` which
writes to the app's documents directory (`getApplicationDocumentsDirectory()`).
Files are rotated daily with a configurable retention window (default 3 days).
File format: `lazurite_YYYY-MM-DD.log`, one line per event using
`SimplePrinter(colors: false)`.

### Integration Points

| Subsystem | What gets logged                                |
| --------- | ----------------------------------------------- |
| BLoC      | State transitions via `BlocObserver` override   |
| HTTP      | Request/response summaries (no auth headers)    |
| Auth      | OAuth flow steps, token refresh, session events |
| Nav       | Route changes via `NavigatorObserver`           |
| DB        | Drift query errors                              |

**Security:** Never log access tokens, refresh tokens, passwords, or full
request/response bodies. HTTP logging redacts the `Authorization` header and
truncates bodies to 200 chars.

### In-App Log Viewer

Accessible via Settings → Dev Tools → Logs. Reads log files from disk and
displays entries in a scrollable, filterable list.

**Features:**

1. **Level filter** — chip bar to toggle visibility per level
2. **Search** — free-text filter across log messages
3. **Auto-scroll** — locks to bottom for live tailing; unlocks on manual scroll
4. **Share** — export current day's log file via the system share sheet
5. **Clear** — delete all log files with confirmation

Each log entry renders as a single row:

| Element   | Format                              |
| --------- | ----------------------------------- |
| Timestamp | `HH:mm:ss.SSS` in monospace         |
| Level     | Colored badge (E / W / I / D)       |
| Message   | Truncated to 2 lines, tap to expand |

No Bloc needed — use a `LogViewerCubit` with simple file-read state, since
this is a stateless inspection tool.

## Feeds

Phase 1 builds profile author feeds only. Phase 2 adds the full home feed
experience: the user's timeline, custom feed generators, and feed management.

### Timeline

`app.bsky.feed.getTimeline` — reverse-chronological feed of posts from
followed accounts. Paginate with `cursor`; `limit` 1–100 (default 50).

### Feed Generators

Feed generators are third-party algorithmic feeds identified by AT-URIs
(e.g. `at://did:plc:…/app.bsky.feed.generator/whats-hot`).

| Endpoint                          | Purpose                                |
| --------------------------------- | -------------------------------------- |
| `app.bsky.feed.getFeed`           | Fetch hydrated posts from a generator  |
| `app.bsky.feed.getFeedGenerator`  | Metadata for a single generator        |
| `app.bsky.feed.getFeedGenerators` | Batch metadata for multiple generators |
| `app.bsky.feed.getSuggestedFeeds` | Discover new feed generators           |

`getFeed` takes the generator's AT-URI + `cursor` / `limit`. The AppView
resolves posts returned by the generator and hydrates them into full
`feedViewPost` views.

### Rendering

Each feed renders as the same post-card list built in Phase 1. The home screen
uses a horizontally-swipable tab bar — one tab per pinned feed, with
"Following" (timeline) as the default.

### Feed Management

User feed preferences are stored server-side via
`app.bsky.actor.putPreferences` / `getPreferences`. The preferences object
contains a `savedFeedsPrefV2` array, where each entry has:

- `id` — unique client-generated identifier
- `type` — `feed` (generator) or `timeline` or `list`
- `value` — AT-URI of the feed generator (or `timeline` literal)
- `pinned` — whether the feed appears as a home tab

**Operations:**

| Action      | Implementation                                           |
| ----------- | -------------------------------------------------------- |
| Pin / Unpin | Toggle `pinned` flag, call `putPreferences`              |
| Reorder     | Drag-to-reorder in settings, update array order, persist |
| Remove      | Remove entry from `savedFeedsPrefV2`, persist            |
| Add         | Browse `getSuggestedFeeds`, append entry, persist        |

Build a `FeedPreferencesCubit` that reads on launch and writes back on
mutation. Cache the preferences array in Drift for offline access.

## Search

### Search Posts

`app.bsky.feed.searchPosts` — full-text search across the network.

| Parameter  | Description                                  |
| ---------- | -------------------------------------------- |
| `q`        | Query string (Lucene syntax supported)       |
| `sort`     | `top` or `latest`                            |
| `author`   | Filter to a specific account (at-identifier) |
| `mentions` | Filter to posts mentioning an account        |
| `lang`     | BCP-47 language filter                       |
| `since`    | Posts after this datetime                    |
| `until`    | Posts before this datetime                   |
| `tag`      | Hashtag filter (without `#`; multiple = AND) |
| `domain`   | Posts containing links to this domain        |
| `url`      | Posts containing this exact URL              |

Returns paginated `postView` objects. `limit` 1–100.

### Search Actors

| Endpoint                               | Purpose                         |
| -------------------------------------- | ------------------------------- |
| `app.bsky.actor.searchActors`          | Full profile search by query    |
| `app.bsky.actor.searchActorsTypeahead` | Prefix autocomplete for handles |

`searchActors` returns `profileView` objects, paginated (`limit` 1–100).
`searchActorsTypeahead` is lightweight, intended for real-time autocomplete
in the search bar.

### Persisted Search History

Store recent queries in a Drift `search_history` table:

| Column        | Type     | Notes                      |
| ------------- | -------- | -------------------------- |
| `id`          | integer  | PK autoincrement           |
| `query`       | text     | The search string          |
| `type`        | text     | `posts` or `actors`        |
| `searched_at` | datetime | Timestamp                  |
| `account_did` | text     | FK to `accounts`, per-user |

Display recent searches below the search bar. Tap to re-execute; swipe to
delete. Cap at 50 entries per account, evicting oldest on insert.

Build a `SearchBloc` with events: `QuerySubmitted`, `TypeaheadRequested`,
`HistoryCleared`, `HistoryEntryDeleted`.

## Dev Tools

### PDS Explorer (pdsls.dev replica)

An in-app developer tool accessible via Settings that replicates the core
functionality of [pdsls.dev](https://pdsls.dev) — a client-side AT Protocol
repository browser.

**Core features:**

1. **Handle / DID resolution** — enter a handle, resolve to DID via
   `com.atproto.identity.resolveHandle`.
2. **Repository overview** — call `com.atproto.repo.describeRepo` to list all
   collections (NSIDs) in a user's repo with record counts.
3. **Collection browser** — select a collection, paginate through records via
   `com.atproto.repo.listRecords` (`limit`, `cursor`, `reverse`).
4. **Record inspector** — tap a record to view the full JSON via
   `com.atproto.repo.getRecord`. Pretty-print with syntax highlighting.
5. **AT-URI input** — paste an `at://` URI to jump directly to a record.

| API Endpoint                         | Usage                                |
| ------------------------------------ | ------------------------------------ |
| `com.atproto.identity.resolveHandle` | Handle → DID                         |
| `com.atproto.repo.describeRepo`      | DID/handle → collection list         |
| `com.atproto.repo.listRecords`       | Collection → paginated record list   |
| `com.atproto.repo.getRecord`         | Collection + rkey → full record JSON |

Accessible via Settings → Dev Tools. No separate Bloc needed — use a
`DevToolsCubit` with simple request/response state, since this is a stateless
exploration tool.
