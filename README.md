# Lazurite

Cross-platform Bluesky client built with Flutter and Dart using Material You (M3) design.

## Features

- Auth + identity resolution
- Home timeline + threads + profiles + search + notifications
- Compose (with media) + likes/reposts/replies
- DMs (read + write): convo list, messages, send, read state
- Local features:
    - Smart folders (local-only "feeds" built from cached posts)
    - Local post drafts (offline compose; later publish)

### Maybes

- Firehose ingestion, custom feed generator hosting, heavy moderation tooling

## Architecture

### Stack

Flutter + Dart, Drift (SQLite), Dio (networking), Riverpod (state), go_router (navigation)

### Data flow

- Authenticated requests → user's PDS
- Public reads → public.api.bsky.app
- Chat → PDS with service proxy header

### Storage

- Drift tables for posts, profiles, timeline, notifications, DMs,
  [smart folders](#smart-folders), and [drafts](#drafts)
- Auth secrets in secure storage (not Drift).

## Local Dev

Use `just` targets:

- `just format` - runs `dart format lib test`
- `just lint` - proxies `flutter analyze`
- `just test` - executes the full `flutter test` suite
- `just gen` - invokes `dart run build_runner build --delete-conflicting-outputs`
- `just check` - performs format + lint + test before commits

For local smoke runs:

```sh
flutter pub get
flutter run -d android
flutter run -d chrome
flutter run -d ios
```

<!-- markdownlint-disable MD033 -->
<details>
<summary>Endpoint Routing & Host Strategy</summary>

### Host Selection

Host selection is a first-class concern:

1. **Unauthenticated, public reads** (fast path)

    - Base URL: `https://public.api.bsky.app`
    - Use for: browsing without login (profiles, public feeds, threads, search)

2. **Authenticated requests** (normal logged-in mode)

    - Base URL: the user's PDS (discovered from identity resolution)
    - Why: authenticated requests are "usually made to the user's PDS, with automatic service proxying"

3. **Service proxying** (chat + some services)
    - Make the request to the user's PDS, and set the service proxy header to target the downstream service
    - Bluesky chat endpoints require proxying to `did:web:api.bsky.chat`

### Endpoint Map by Feature

#### Identity + Sessions

| Endpoint                               | Method | Host | Auth | Notes                                             |
| -------------------------------------- | ------ | ---- | ---- | ------------------------------------------------- |
| `com.atproto.identity.resolveHandle`   | GET    | PDS  | None | Resolve handle → DID                              |
| `com.atproto.identity.resolveDid`      | GET    | PDS  | None | Resolve DID → DID document                        |
| `com.atproto.identity.resolveIdentity` | GET    | PDS  | None | Resolve handle or DID → DID doc + verified handle |
| `com.atproto.server.createSession`     | POST   | PDS  | None | Legacy login (app passwords)                      |
| `com.atproto.server.getSession`        | GET    | PDS  | User | Check current session                             |

#### Core Reading

| Endpoint                      | Method | Host          | Auth        | Notes                        |
| ----------------------------- | ------ | ------------- | ----------- | ---------------------------- |
| `app.bsky.feed.getTimeline`   | GET    | PDS / AppView | User        | Home timeline                |
| `app.bsky.actor.getProfile`   | GET    | PDS / AppView | None / User | Actor profile                |
| `app.bsky.feed.getAuthorFeed` | GET    | PDS / AppView | None        | Actor feed (posts + reposts) |
| `app.bsky.feed.getPostThread` | GET    | PDS / AppView | None / User | Thread view                  |
| `app.bsky.feed.getPosts`      | GET    | PDS / AppView | None        | Hydrate posts by AT-URI      |
| `app.bsky.feed.searchPosts`   | GET    | PDS / AppView | None / User | Search posts                 |
| `app.bsky.feed.getLikes`      | GET    | PDS / AppView | None        | Who liked a post             |
| `app.bsky.feed.getRepostedBy` | GET    | PDS / AppView | None        | Who reposted a post          |
| `app.bsky.graph.getFollowers` | GET    | PDS / AppView | None        | Get followers                |
| `app.bsky.graph.getFollows`   | GET    | PDS / AppView | None        | Get follows                  |

#### Notifications

| Endpoint                                  | Method | Host | Auth | Notes              |
| ----------------------------------------- | ------ | ---- | ---- | ------------------ |
| `app.bsky.notification.listNotifications` | GET    | PDS  | User | List notifications |
| `app.bsky.notification.getUnreadCount`    | GET    | PDS  | User | Unread count       |

#### Writing (Posts, Likes, Reposts, Follows)

| Endpoint                        | Method | Host | Auth | Notes                           |
| ------------------------------- | ------ | ---- | ---- | ------------------------------- |
| `com.atproto.repo.createRecord` | POST   | PDS  | User | Create a record (generic write) |
| `com.atproto.repo.putRecord`    | POST   | PDS  | User | Update a record                 |
| `com.atproto.repo.deleteRecord` | POST   | PDS  | User | Delete a record                 |
| `com.atproto.repo.applyWrites`  | POST   | PDS  | User | Batch writes (atomic-ish)       |
| `com.atproto.repo.uploadBlob`   | POST   | PDS  | User | Upload media blob               |

Collections used with createRecord/putRecord/deleteRecord:

- Post: `app.bsky.feed.post`
- Like: `app.bsky.feed.like`
- Repost: `app.bsky.feed.repost`
- Follow: `app.bsky.graph.follow`

#### DMs (Bluesky Chat via PDS proxy)

| Endpoint                      | Method | Host | Auth | Proxy                   | Notes                     |
| ----------------------------- | ------ | ---- | ---- | ----------------------- | ------------------------- |
| `chat.bsky.convo.listConvos`  | GET    | PDS  | User | `did:web:api.bsky.chat` | Convo list (inbox)        |
| `chat.bsky.convo.getMessages` | GET    | PDS  | User | `did:web:api.bsky.chat` | Fetch messages in a convo |
| `chat.bsky.convo.sendMessage` | POST   | PDS  | User | `did:web:api.bsky.chat` | Send message              |
| `chat.bsky.convo.updateRead`  | POST   | PDS  | User | `did:web:api.bsky.chat` | Mark convo read           |
| `chat.bsky.convo.acceptConvo` | POST   | PDS  | User | `did:web:api.bsky.chat` | Accept convo request      |

**Implementation note:** The "proxying header" mechanism is standardized in XRPC HTTP specs; implement it once in Dio as an interceptor/RequestOptions hook, then reuse.

### Local-only Features

#### "Smart" folders

- Definition: locally stored queries over cached timeline/threads + local labels
- Example folder rules: "Unread", "From follows only", "Mentions + keyword", "Media only", "Saved"
- Inputs (network): whatever you choose to cache (timeline/author feed/thread/etc.)
- Output: purely local projection; no server-side "custom feed generator" required

#### Local post drafts

- Stored in Drift only; not published until you call repo.createRecord/applyWrites

</details>

<details>
<summary>Routing</summary>

### Why go_router?

- URL-based navigation (deep links, shareable routes, desktop parity)
- Nested navigation with persistent tab state
- Auth gating via redirect()
- Path + query parameters, nested routes, and redirection support

### Router Shape

Use `StatefulShellRoute.indexedStack` for bottom tabs so each tab preserves state (scroll position, nested stacks).

**Tabs (StatefulShellRoute branches):**

- Home
- Search
- Notifications
- DMs
- Profile (Me)

**Rules:**

- Put "detail" routes (thread, profile, convo) as children of the branch where the user is coming from, so the bottom bar stays visible
- Put "global modals" (compose, settings) on the root navigator so they present above tabs

### Route Map

| Path                 | Description         | Notes        |
| -------------------- | ------------------- | ------------ |
| `/splash`            | (optional)          |              |
| `/login`             | Login screen        |              |
| `/settings`          | Settings screen     |              |
| `/compose`           | Compose modal       | Root modal   |
| `/drafts`            | Local-only list     |              |
| `/drafts/:draftId`   | Edit draft          |              |
| `/home`              | Home tab            |              |
| `/home/t/:postKey`   | Thread from home    |              |
| `/home/u/:did`       | Profile from home   |              |
| `/search`            | Search tab          |              |
| `/search?q=<query>`  | Search results      | Query params |
| `/search/t/:postKey` | Thread from search  |              |
| `/search/u/:did`     | Profile from search |              |
| `/notifs`            | Notifications tab   |              |
| `/notifs/t/:postKey` | Thread from notifs  |              |
| `/notifs/u/:did`     | Profile from notifs |              |
| `/dms`               | DMs tab             |              |
| `/dms/c/:convoId`    | Convo detail        |              |
| `/me`                | Profile (me) tab    |              |
| `/me/u/:did`         | Profile view        |              |

**About `:postKey`:** Don't put raw `at://did/...` in the path. Encode it as a URL-safe token (base64url(atUri) or percent-encode into a query param like `/home/t?uri=...`).

### Auth Gating + Reactive Redirects (Riverpod)

go_router redirects are not automatically reactive; you must provide a `refreshListenable` if you want auth changes to trigger redirects reliably.

**Pattern (opinionated, reliable):**

- Auth state lives in Riverpod (e.g., AuthController Notifier)
- Create a small Listenable bridge for GoRouter.refreshListenable:
    - `ValueNotifier<int>` "tick"
    - `ref.listen(authProvider, (_, __) => tick.value++)`
- In `redirect()`, read auth state and return:
    - unauthenticated → `/login` for protected routes
    - authenticated → redirect away from `/login` to `/home`

**Protected vs public routes:**

- Public allowed: `/home` (read-only), `/search`, viewing threads/profiles
- Auth required: `/notifs`, `/dms`, `/compose` publish, follow/like/repost actions

### Deep Linking (Android/iOS)

- Use go_router URL paths that mirror shareable content
- Configure Android App Links + iOS Universal Links so `https://<yourdomain>/...` can open the app to a matching route
- Prefer path params for required IDs; query params for optional filters/search

</details>

<details>
<summary>State Management</summary>

### Why Riverpod?

- Dependency injection (Dio clients, DB, repositories)
- View-model state (timeline paging, thread loading, draft autosave, DM outbox)
- Flutter's architecture guide recommends separation of concerns and "Views + ViewModels" with repositories in the data layer
- Riverpod recommends (Async)Notifier/(Async)NotifierProvider for state that changes via user interaction

### Provider Types

| Type                          | Example                                                    | Use Case                                                       |
| ----------------------------- | ---------------------------------------------------------- | -------------------------------------------------------------- |
| `Provider<T>`                 | `Provider<AppDb>`                                          | Singletons / resources (DB, Dio, secure storage, endpoint map) |
| `Provider<T>`                 | `Provider<TimelineRepository>`                             | Repositories (data layer)                                      |
| `AsyncNotifierProvider<T, S>` | `AsyncNotifierProvider<TimelineController, TimelineState>` | ViewModels with I/O (network/db)                               |
| `NotifierProvider<T, S>`      | `NotifierProvider<ComposerController, ComposerState>`      | ViewModels with sync state (text fields + local draft)         |

**Dependencies (singletons / resources):**

- `Provider<AppDb>` (Drift DB)
- `Provider<Dio>` dioPublic
- `Provider<Dio>` dioPds
- `Provider<AuthSessionStore>` (secure storage-backed)
- `Provider<EndpointMap>` (single source of routing truth)

**Repositories (data layer):**

- `Provider<TimelineRepository>`
- `Provider<ThreadRepository>`
- `Provider<DmRepository>`
- `Provider<DraftRepository>`

**ViewModels (presentation layer):**

- `AsyncNotifierProvider<TimelineController, TimelineState>`
- `AsyncNotifierProvider<ThreadController, ThreadState>`
- `NotifierProvider<ComposerController, ComposerState>` (sync + autosave)
- `AsyncNotifierProvider<DmInboxController, DmInboxState>`
- `AsyncNotifierProvider<DmConvoController, DmConvoState>`

**Rule of thumb:**

- Use `AsyncNotifier` when you do I/O (network/db) or have "loading/error/data"
- Use `Notifier` for purely local synchronous state (text fields + local draft), while persisting via a repository

### File Placement

```sh
lib/src/app/providers.dart
  - global providers for env, dio, db, secure storage, endpoint map

lib/src/infrastructure/...
  - pure Dart classes: XrpcClient, interceptors, DAOs (no Riverpod here)

lib/src/features/<feature>/presentation/<feature>_controller.dart
  - Notifier/AsyncNotifier implementation
  - holds paging cursors, refresh logic, optimistic UI, etc.

lib/src/features/<feature>/domain/usecases/
  - optional: thin usecases called by controllers, especially for complex flows
    (publish draft pipeline, DM outbox flush)
```

### Testing Conventions

- Unit test controllers with `ProviderContainer`:
    - Override repositories with fakes
    - Assert state transitions: loading → data, optimistic updates, retry behavior
- DAO tests run against an in-memory/temporary Drift database
- Network tests mock Dio adapters (or replace XrpcClient in providers)

</details>

<details>
<summary>Database Schema (Drift)</summary>

### Principles

- Use stable keys (DID, at:// URIs)
- Store raw JSON payloads for forward compatibility, plus minimal indexed columns
- Keep auth secrets out of Drift; store them in secure storage

### Core Cache Tables

| Table            | Primary Key          | Purpose                                                  |
| ---------------- | -------------------- | -------------------------------------------------------- |
| `accounts`       | `did`                | User accounts (handle, pdsUrl, active)                   |
| `profiles`       | `did`                | Profile data (handle, json, updatedAt)                   |
| `posts`          | `uri`                | Post data (cid, authorDid, textPreview, indexedAt, json) |
| `timeline_items` | `(feedKey, postUri)` | Timeline cache (sortKey, cursor)                         |
| `notifications`  | `id`                 | Notifications (indexedAt, seenAt, json)                  |

### DMs

| Table         | Primary Key            | Purpose                                                               |
| ------------- | ---------------------- | --------------------------------------------------------------------- |
| `dm_convos`   | `convoId`              | Conversation metadata (lastMessageAt, unreadCount, muted, json)       |
| `dm_members`  | `(convoId, memberDid)` | Conversation members                                                  |
| `dm_messages` | `(convoId, messageId)` | Messages (sentAt, senderDid, status, json)                            |
| `dm_outbox`   | `localId`              | Outgoing messages queue (convoId, payloadJson, attemptCount, retryAt) |

### Smart Folders

| Table                | Primary Key           | Purpose                                                |
| -------------------- | --------------------- | ------------------------------------------------------ |
| `smart_folders`      | `folderId`            | Folder metadata (name, sortMode, createdAt, updatedAt) |
| `smart_folder_rules` | `ruleId`              | Folder rules (folderId, type, payloadJson)             |
| `smart_folder_items` | `(folderId, postUri)` | Optional materialization (score, insertedAt)           |

### Drafts

| Table         | Primary Key               | Purpose                                                                                          |
| ------------- | ------------------------- | ------------------------------------------------------------------------------------------------ |
| `drafts`      | `draftId`                 | Draft metadata (createdAt, updatedAt, status, text, facetsJson, replyToUri, quoteUri, embedJson) |
| `draft_media` | `(draftId, localMediaId)` | Draft media (pathOrUri, mime, size, altText, uploadCid, status)                                  |

</details>

## References

- [Bluesky API Documentation](https://docs.bsky.app/)
- [AT Protocol Specification](https://atproto.com/)
- [Flutter Documentation](https://flutter.dev/docs)

## Credits

Typography inspiration from [Anisota](https://anisota.net/) by [Dame.is](https://dame.is) ([@dame.is](https://bsky.app/profile/dame.is)).

[Witchsky](https://witchsky.app/) ([code](https://tangled.org/jollywhoppers.com/witchsky.app/))
