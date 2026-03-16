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

### 2. Custom Themes

Ship built-in theme palettes. Each theme provides a dark and light variant.
Persist the user's theme choice in the Drift `settings` table. Expose each
via factory constructors (e.g. `CatppuccinTheme.dark()`).

#### Oxocarbon (IBM Carbon inspired)

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

#### Catppuccin

A community-driven pastel theme. Use **Mocha** (dark) and **Latte** (light).

**Mocha (Dark)**:

| Token     | Hex       | Role                        |
| --------- | --------- | --------------------------- |
| base      | `#1e1e2e` | Background                  |
| mantle    | `#181825` | Surface / card              |
| surface0  | `#313244` | Selection / divider         |
| surface1  | `#45475a` | Muted text                  |
| subtext0  | `#a6adc8` | Secondary text              |
| text      | `#cdd6f4` | Primary text                |
| lavender  | `#b4befe` | Primary accent              |
| blue      | `#89b4fa` | Blue accent                 |
| sapphire  | `#74c7ec` | Cyan highlight              |
| green     | `#a6e3a1` | Green / success             |
| red       | `#f38ba8` | Red / error                 |
| peach     | `#fab387` | Orange / warning            |
| mauve     | `#cba6f7` | Purple accent               |
| pink      | `#f5c2e7` | Pink accent                 |
| rosewater | `#f5e0dc` | Warm highlight              |

**Latte (Light)**:

| Token     | Hex       | Role                        |
| --------- | --------- | --------------------------- |
| base      | `#eff1f5` | Background                  |
| mantle    | `#e6e9ef` | Surface / card              |
| surface0  | `#ccd0da` | Selection / divider         |
| surface1  | `#bcc0cc` | Muted text                  |
| subtext0  | `#6c6f85` | Secondary text              |
| text      | `#4c4f69` | Primary text                |
| lavender  | `#7287fd` | Primary accent              |
| blue      | `#1e66f5` | Blue accent                 |
| sapphire  | `#209fb5` | Cyan highlight              |
| green     | `#40a02b` | Green / success             |
| red       | `#d20f39` | Red / error                 |
| peach     | `#fe640b` | Orange / warning            |
| mauve     | `#8839ef` | Purple accent               |
| pink      | `#ea76cb` | Pink accent                 |
| rosewater | `#dc8a78` | Warm highlight              |

Map to `CatppuccinTheme.dark()` / `CatppuccinTheme.light()`.

#### Nord

An arctic, north-bluish palette inspired by the polar night and aurora
borealis.

**Polar Night (Dark)**:

| Token   | Hex       | Role                        |
| ------- | --------- | --------------------------- |
| nord0   | `#2e3440` | Background                  |
| nord1   | `#3b4252` | Surface / card              |
| nord2   | `#434c5e` | Selection / divider         |
| nord3   | `#4c566a` | Muted text                  |
| nord4   | `#d8dee9` | Secondary text              |
| nord5   | `#e5e9f0` | Primary text                |
| nord6   | `#eceff4` | Bright text                 |
| nord7   | `#8fbcbb` | Teal accent                 |
| nord8   | `#88c0d0` | Cyan / primary accent       |
| nord9   | `#81a1c1` | Blue accent                 |
| nord10  | `#5e81ac` | Deep blue                   |
| nord11  | `#bf616a` | Red / error                 |
| nord12  | `#d08770` | Orange / warning            |
| nord13  | `#ebcb8b` | Yellow                      |
| nord14  | `#a3be8c` | Green / success             |
| nord15  | `#b48ead` | Purple accent               |

**Snow Storm (Light)**:

| Token   | Hex       | Role                        |
| ------- | --------- | --------------------------- |
| nord0   | `#eceff4` | Background                  |
| nord1   | `#e5e9f0` | Surface / card              |
| nord2   | `#d8dee9` | Selection / divider         |
| nord3   | `#4c566a` | Primary text                |
| nord4   | `#434c5e` | Secondary text              |
| nord5   | `#3b4252` | Subheading text             |
| nord6   | `#2e3440` | Bright / heading text       |
| nord7   | `#8fbcbb` | Teal accent                 |
| nord8   | `#88c0d0` | Cyan / primary accent       |
| nord9   | `#81a1c1` | Blue accent                 |
| nord10  | `#5e81ac` | Deep blue                   |
| nord11  | `#bf616a` | Red / error                 |
| nord12  | `#d08770` | Orange / warning            |
| nord13  | `#ebcb8b` | Yellow                      |
| nord14  | `#a3be8c` | Green / success             |
| nord15  | `#b48ead` | Purple accent               |

Map to `NordTheme.dark()` / `NordTheme.light()`.

#### Rosé Pine

An all-natural pine theme with muted, elegant tones.

**Main (Dark)**:

| Token          | Hex       | Role                        |
| -------------- | --------- | --------------------------- |
| base           | `#191724` | Background                  |
| surface        | `#1f1d2e` | Surface / card              |
| overlay        | `#26233a` | Selection / divider         |
| muted          | `#6e6a86` | Muted text                  |
| subtle         | `#908caa` | Secondary text              |
| text           | `#e0def4` | Primary text                |
| love           | `#eb6f92` | Red / error                 |
| gold           | `#f6c177` | Yellow / warning            |
| rose           | `#ebbcba` | Rose accent (primary)       |
| pine           | `#31748f` | Teal / deep accent          |
| foam           | `#9ccfd8` | Cyan highlight              |
| iris           | `#c4a7e7` | Purple accent               |

**Dawn (Light)**:

| Token          | Hex       | Role                        |
| -------------- | --------- | --------------------------- |
| base           | `#faf4ed` | Background                  |
| surface        | `#fffaf3` | Surface / card              |
| overlay        | `#f2e9e1` | Selection / divider         |
| muted          | `#9893a5` | Muted text                  |
| subtle         | `#797593` | Secondary text              |
| text           | `#575279` | Primary text                |
| love           | `#b4637a` | Red / error                 |
| gold           | `#ea9d34` | Yellow / warning            |
| rose           | `#d7827e` | Rose accent (primary)       |
| pine           | `#286983` | Teal / deep accent          |
| foam           | `#56949f` | Cyan highlight              |
| iris           | `#907aa9` | Purple accent               |

Map to `RosePineTheme.dark()` / `RosePineTheme.light()`.
