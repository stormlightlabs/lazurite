# Phase 1

BLoC for state management via `flutter_bloc`. Each feature gets its own
Bloc/Cubit—keep them small and focused. Use `BlocProvider` for DI,
`BlocBuilder` / `BlocSelector` for granular rebuilds, and `BlocListener` for
one-shot side effects (navigation, snackbars). All state classes must be
immutable with `copyWith()`. Use `HydratedBloc` where session persistence is
needed (e.g. theme preference).

Drift (formerly Moor) for SQLite persistence. Type-safe, reactive (stream-based
queries auto-update the UI), compile-time checked SQL, and built-in migration
support. Tables: `accounts` (DID, handle, tokens), `cached_profiles`,
`cached_posts`, `settings`.

Feature-first folder structure:

```sh
lib/
  core/         # shared models, theme, routing, DI
  features/
    auth/       # bloc, data, presentation
    profile/    # bloc, data, presentation
    settings/   # bloc, data, presentation
```

## Packages

| Package          | Purpose                                           |
| ---------------- | ------------------------------------------------- |
| `bluesky`        | Full AT Protocol + `app.bsky.*` / `chat.bsky.*`   |
| `atproto_oauth`  | AT Protocol OAuth 2.0 for Flutter                 |
| `bluesky_text`   | Rich text / facet parsing                         |
| `flutter_bloc`   | BLoC / Cubit state management                     |
| `drift`          | Type-safe reactive SQLite ORM                     |
| `go_router`      | Declarative routing                               |

## Authentication

### 1. OAuth 2.0 (Production)

AT Protocol mandates **DPoP + PAR + PKCE** for all clients. Lazurite is a
public native client (`token_endpoint_auth_method: "none"`,
`application_type: "native"`).

**Constants:**

```dart
static const kClientId = 'https://lazurite.stormlightlabs.org/client-metadata.json';
static const kRedirectUri = 'http://127.0.0.1/callback';
static const kScope = 'atproto transition:generic';
```

Client metadata is hosted at `https://lazurite.stormlightlabs.org/client-metadata.json`.
The PDS fetches this document to verify the client during the OAuth flow.

**Flow:**

1. Generate a DPoP keypair (store private key in platform keychain; non-exportable).
2. Generate PKCE `code_verifier` → `code_challenge`.
3. POST to the PDS **PAR endpoint** with `kClientId`, `code_challenge`,
   `kScope`, and an initial DPoP Proof JWT → receive a `request_uri`.
4. Open system browser / `ASWebAuthenticationSession` /
   `CustomTabsIntent` to the PDS **authorization endpoint** with the
   `request_uri`.
5. User authenticates on their PDS and grants consent.
6. PDS redirects to the **loopback redirect** (`http://127.0.0.1/callback`)
   with an authorization `code`. The app starts a temporary local HTTP server
   to capture the callback.
7. Exchange `code` + `code_verifier` + new DPoP Proof JWT at the **token
   endpoint** → receive DPoP-bound `access_token` + `refresh_token`.
8. Every API request sends the `access_token` in `Authorization` and a fresh
   DPoP Proof JWT in the `DPoP` header.

Token lifetimes: `access_token` ~2 h, `refresh_token` ~2 months. The
`atproto_oauth` package handles automatic refresh.

### 2. App Password (Debug Only)

Calls `com.atproto.server.createSession` with handle + app password
(`xxxx-xxxx-xxxx-xxxx`). Returns `accessJwt` / `refreshJwt` + DID / handle.
Rate limit: 30 req / 5 min, 300 / day.

App passwords cannot delete or migrate the account, nor create other app
passwords. Guard this path behind a compile-time debug flag
(`kDebugMode` / `--dart-define`).

### 3. Login & Logout

- **Login screen:** handle input + "Sign in with BlueSky" button (OAuth) and,
  in debug builds, an app-password form.
- **Session restore:** on launch, read stored tokens from Drift → attempt
  silent refresh → land on home or login.
- **Logout:** revoke tokens, wipe Drift session row, clear in-memory Bloc
  state, navigate to login.
- **Multi-account (stretch):** `accounts` table supports multiple DIDs; account
  switcher in settings.

## Profile Rendering

Data source: `app.bsky.actor.getProfile` (single) /
`app.bsky.actor.getProfiles` (batch).

**Profile fields to render:**

- Avatar + banner images (CDN URIs)
- `displayName`, `handle`, `description`
- Follower / following / post counts
- `pronouns`, `website`

### 1. Posts

Fetch via `app.bsky.feed.getAuthorFeed`. Paginate with `cursor`; support
`filter` values: `posts_no_replies`, `posts_with_media`,
`posts_and_author_threads`.

Each feed item is an `app.bsky.feed.defs#feedViewPost` containing a `post`
view. Key fields: `text`, `createdAt`, `embed` (images ≤ 4, quote posts,
external link cards, video), `reply` parent/root refs, `langs`.

### 2. Post Facets (Rich Text)

Facets annotate byte ranges of the UTF-8 `text` field. Each facet has an
`index` (`byteStart` inclusive, `byteEnd` exclusive) and a `features` array.

| Feature type                       | Payload   |
| ---------------------------------- | --------- |
| `app.bsky.richtext.facet#mention`  | `did`     |
| `app.bsky.richtext.facet#link`     | `uri`     |
| `app.bsky.richtext.facet#tag`      | `tag`     |

Use the `bluesky_text` package to parse facets. Render mentions as tappable
profile links, URIs as tappable external links, and hashtags as tappable search
links. Byte indices are **UTF-8**—do not use Dart's UTF-16 string indices
directly.

## Settings

### 1. Light / Dark Mode

System default, Light, and Dark. Persist choice in Drift `settings` table.
Apply via `ThemeMode` on `MaterialApp`. Use `HydratedBloc` or a `SettingsCubit`
that reads/writes the preference.

### 2. Custom Themes — Oxocarbon

Ship two built-in themes derived from the Oxocarbon palette (IBM Carbon
inspired):

**Dark**:

| Token    | Hex       | Role                        |
| -------- | --------- | --------------------------- |
| base00   | `#161616` | Background                  |
| base01   | `#262626` | Surface / card              |
| base02   | `#393939` | Selection / divider         |
| base03   | `#525252` | Muted text                  |
| base04   | `#dde1e6` | Secondary text              |
| base05   | `#f2f4f8` | Primary text                |
| base06   | `#ffffff` | Bright text                 |
| base07   | `#08bdba` | Teal accent                 |
| base08   | `#3ddbd9` | Cyan highlight              |
| base09   | `#78a9ff` | Blue accent                 |
| base0A   | `#ee5396` | Pink / error                |
| base0B   | `#33b1ff` | Light blue                  |
| base0C   | `#ff7eb6` | Magenta                     |
| base0D   | `#42be65` | Green / success             |
| base0E   | `#be95ff` | Purple accent               |
| base0F   | `#82cfff` | Sky blue                    |

**Light**:

| Token    | Hex       | Role                        |
| -------- | --------- | --------------------------- |
| base00   | `#ffffff` | Background                  |
| base01   | `#f2f2f2` | Surface / card              |
| base02   | `#d0d0d0` | Selection / divider         |
| base03   | `#161616` | Primary text                |
| base04   | `#37474F` | Secondary text              |
| base05   | `#90A4AE` | Muted text                  |
| base06   | `#525252` | Subheading text             |
| base07   | `#08bdba` | Teal accent                 |
| base08   | `#ff7eb6` | Pink accent                 |
| base09   | `#ee5396` | Error                       |
| base0A   | `#FF6F00` | Orange / warning            |
| base0B   | `#0f62fe` | Primary blue                |
| base0C   | `#673AB7` | Purple accent               |
| base0D   | `#42be65` | Green / success             |
| base0E   | `#be95ff` | Lavender accent             |
| base0F   | `#FFAB91` | Salmon                      |

Map these tokens to a `ThemeData` / `ColorScheme` and expose a
`OxocarbonTheme.dark()` / `OxocarbonTheme.light()` factory.

## Development

`/scripts` directory with Python utilities for inspecting AT Protocol / BlueSky
API data.

Scripts to include:

| Script              | Purpose                                              |
| ------------------- | ---------------------------------------------------- |
| `fetch_profile.py`  | Fetch and pretty-print a profile via `getProfile`    |
| `fetch_feed.py`     | Fetch author feed and dump post/facet structures     |
| `resolve_handle.py` | Resolve handle → DID via `com.atproto.identity`      |

Use the `atproto` Python SDK (`atproto` on PyPI). Each script should accept
CLI args (handle, limit, etc.) and output JSON to stdout.
