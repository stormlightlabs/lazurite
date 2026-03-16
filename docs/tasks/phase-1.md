# Phase 1 Milestones

## M0 — Project Scaffolding

- [x] Add dependencies (`bluesky`, `atproto_oauth`, `bluesky_text`, `flutter_bloc`, `drift`, `go_router`)
- [x] Set up feature-first folder structure (`core/`, `features/auth|profile|settings/`)
- [x] Configure Drift database with `accounts`, `cached_profiles`, `cached_posts`, `settings` tables
- [x] Configure `go_router` with initial route definitions (login, home, profile, settings)

## M1 — Authentication

- [x] Implement App Password login (`createSession`) behind `kDebugMode` flag
- [x] Implement OAuth 2.0 flow (DPoP + PAR + PKCE) via `atproto_oauth`
- [x] Set up loopback redirect listener (`http://127.0.0.1/callback`)
- [x] Build `AuthBloc` — events: `LoginRequested`, `LogoutRequested`, `SessionRestored`; states: `Unauthenticated`, `Authenticating`, `Authenticated`, `AuthError`
- [x] Session persistence: store/restore tokens in Drift, silent refresh on launch
- [x] Build login screen (handle input, OAuth button, debug app-password form)
- [x] Logout: revoke tokens, clear Drift row, reset Bloc, navigate to login

## M2 — Profile Rendering

- [x] Build `ProfileBloc` — fetch via `getProfile` / `getProfiles`
- [x] Profile screen: avatar, banner, display name, handle, description, stats (followers/following/posts), pronouns, website
- [x] Build `FeedBloc` — paginated fetch via `getAuthorFeed` with cursor + filter support
- [x] Post card widget: text, timestamps, embeds (images, quote posts, link cards)
- [x] Facet rendering: parse via `bluesky_text`, render mentions / links / hashtags as tappable spans (UTF-8 byte-safe)

## M3 — Settings & Theming

- [x] `SettingsCubit` backed by Drift — theme mode preference (system / light / dark)
- [x] Oxocarbon Dark `ThemeData` / `ColorScheme`
- [x] Oxocarbon Light `ThemeData` / `ColorScheme`
- [x] Catppuccin Mocha (Dark) `ThemeData` / `ColorScheme`
- [x] Catppuccin Latte (Light) `ThemeData` / `ColorScheme`
- [x] Nord Polar Night (Dark) `ThemeData` / `ColorScheme`
- [x] Nord Snow Storm (Light) `ThemeData` / `ColorScheme`
- [x] Rosé Pine Main (Dark) `ThemeData` / `ColorScheme`
- [x] Rosé Pine Dawn (Light) `ThemeData` / `ColorScheme`
- [x] Theme picker in settings screen (all 4 palettes × 2 variants + system)
- [x] Respect system theme when set to "system"
- NOTE: sans font changed to dmsans from geist

## M4 — Dev Scripts

- [ ] Create `uv` project in directory `scripts`
- [ ] `scripts/fetch_profile.py` — pretty-print profile JSON
- [ ] `scripts/fetch_feed.py` — dump post + facet structures
- [ ] `scripts/resolve_handle.py` — resolve handle → DID
