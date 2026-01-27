# Developer Tooling

Lazurite includes two developer-focused features: an internal debug overlay for development
and user-facing ATProto DevTools similar to [pdsls.dev](https://pdsls.dev/).

## Overview

| Feature          | Availability    | Purpose                                                |
| ---------------- | --------------- | ------------------------------------------------------ |
| Debug Overlay    | kDebugMode only | System diagnostics, network inspection, session info   |
| ATProto DevTools | All builds      | Repository exploration, record inspection, JSON viewer |

Both features share database tables but serve different audiences. The debug overlay helps
developers diagnose issues during development. DevTools let power users explore their
ATProto repository data.

## Debug Overlay (Internal)

### Activation

Available only in Flutter debug builds (`kDebugMode == true`).

- **Desktop:** ALT+F12
- **Mobile:** 2-finger long-press for 2 seconds

The overlay appears as a sliding drawer from the right edge.

### Architecture

**DebugOverlayHost** (`lib/src/features/debug/presentation/debug_overlay_host.dart`)
wraps the entire app when in debug mode. It listens for activation gestures and renders
the overlay as a Stack layer above the main content.

**DebugOverlayController** (`lib/src/features/debug/application/debug_overlay_controller.dart`)
manages visibility state and active tab selection via Riverpod StateNotifier.

### Tabs

**System Info** - Flutter version, platform, screen dimensions, memory usage

**ATProto Session** - Current DID, handle, PDS host, session validity (tokens never shown)

**Network Inspector** - Recent XRPC calls with method, status, duration. Captured by
`DebugNetworkInterceptor` attached to Dio. Logs stored in `dev_network_logs` table with
LRU eviction at 1000 entries.

### Network Interception

The interceptor (`lib/src/features/debug/infrastructure/debug_network_interceptor.dart`)
captures all Dio requests/responses and persists them to the database.

Security: Authorization headers must be redacted before storage. The interceptor should
replace token values with `Bearer ***` to prevent accidental exposure.

## ATProto DevTools (User-Facing)

### Purpose

Provide transparency into the user's ATProto repository. Users can browse collections,
inspect records, and understand the underlying data structure. Read-only by default.

### Access Control

Gated by Settings toggle (stored in `dev_settings` table):

- **Enable Developer Tools** - Shows DevTools in navigation
- **Allow viewing other repos** - Enables browsing public DIDs beyond own repo
- **Enable record editing** - Triple-gated write mode (deferred to parking lot)

### Routes

```text
/devtools                     → DevToolsHomePage
/devtools/collections         → CollectionsPage
/devtools/:collection         → RecordsPage
/devtools/:collection/:rkey   → RecordDetailPage
```

All routes check the enabled toggle before rendering content.

### Feature Structure

```sh
lib/src/features/developer_tools/
├── application/
│   ├── devtools_providers.dart      # Riverpod providers
│   └── dev_settings_providers.dart  # Settings state
├── domain/
│   ├── repo_collection.dart         # Collection model
│   └── repo_record.dart             # Record model with AT URI parsing
├── infrastructure/
│   └── devtools_repository.dart     # ATProto API calls
└── presentation/screens/
    ├── dev_tools_home_page.dart     # Entry point, DID display
    ├── collections_page.dart        # Collection browser with search
    ├── records_page.dart            # Paginated record list
    └── record_detail_page.dart      # JSON tree viewer
```

### Providers

**devtoolsRepositoryProvider** - Repository wrapping XrpcClient for ATProto calls

**collectionsProvider** - Fetches collections via `com.atproto.repo.describeRepo`

**recordsProvider** - AsyncNotifierFamily for paginated records with cursor support

**recordDetailProvider** - Fetches single record by collection + rkey

**pinnedUrisProvider** - Streams pinned collections and records from database

### Repository Methods

`DevtoolsRepository` (`lib/src/features/developer_tools/infrastructure/devtools_repository.dart`)
calls the user's PDS directly without the `atproto-proxy` header:

- `describeRepo(did)` - List collections for a DID
- `listRecords(repo, collection, limit, cursor)` - Paginated record list
- `getRecord(repo, collection, rkey)` - Single record fetch

Write methods (`createRecord`, `putRecord`, `deleteRecord`) exist in the spec but are
not implemented pending write mode feature.

### UI Components

**CollectionsPage** - Searchable list with pin/unpin toggle. Tapping navigates to records.

**RecordsPage** - Infinite scroll with cursor pagination. Rich previews for known types
(posts, profiles, follows, likes). Pin button per record.

**RecordDetailPage** - Metadata card (AT URI, CID, indexedAt) with copy buttons. JSON tree
viewer using `flutter_json` package. Blob detection shows thumbnail previews for images.

### Rich Previews

Records are displayed with type-specific previews:

- `app.bsky.feed.post` - Text content and createdAt timestamp
- `app.bsky.actor.profile` - Display name and description
- `app.bsky.graph.follow` - Target subject DID
- `app.bsky.feed.like` - Liked subject URI
- Unknown types - Fallback to generic JSON snippet

## Database Schema

Four tables in `lib/src/infrastructure/db/tables.dart`:

**DevSettings** - Key-value store for feature toggles (enabled, allowOtherRepos,
enableRecordEditing, maxCachedJsonBytes)

**DevNetworkLogs** - Network request/response capture with uuid, method, url, statusCode,
durationMs, headers, body, timestamp

**DevPins** - Pinned collections and records with uri, label, type, createdAt

**DevRecentRecords** - Recently viewed records with uri, cid, viewedAt (schema expansion
planned for JSON caching)

### DAO

`DevToolsDao` (`lib/src/infrastructure/db/daos/dev_tools_dao.dart`) provides:

- Settings: `getSetting()`, `setSetting()`
- Network logs: `logRequest()`, `watchLogs()`, `clearLogs()`, `pruneLogs()`
- Pins: `savePin()`, `deletePin()`, `watchPins()`
- Recent records: `addRecentRecord()`, `watchRecentRecords()`, `pruneRecentRecords()`

## Security Boundaries

### Secrets Protection

Never display or log:

- Access tokens or refresh tokens
- DPoP private keys
- Secure storage keys

Network logs must redact Authorization header values.

### Other DID Inspection

When viewing other users' repos:

- Read-only operations only (describeRepo, listRecords, getRecord)
- Display banner indicating public data view
- Never call write endpoints for other DIDs

### Defensive JSON Rendering

Records may contain hostile or malformed JSON:

- Limit tree depth to 50 levels
- Truncate long strings in preview (1000 chars)
- Handle deeply nested objects gracefully
- Escape HTML entities in string values

## Remaining Work (as of 2026-01-26)

- Performance metrics tab in debug overlay
- Settings toggle UI exposure
- Other DID inspection feature
- DevRecentRecords schema enhancement
- Filter/sort controls in records list
- File export functionality
- Authorization header redaction

## References

- [pdsls.dev](https://pdsls.dev/) - ATProto explorer by @juli.ee
- [com.atproto.repo.listRecords](https://docs.bsky.app/docs/api/com-atproto-repo-list-records)
- [com.atproto.repo.getRecord](https://docs.bsky.app/docs/api/com-atproto-repo-get-record)
- [AT Protocol Repository Spec](https://atproto.com/specs/repository)
