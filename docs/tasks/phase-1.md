# Phase 1 Milestones

## M0 — Project Scaffolding

- [x] Add dependencies (`bluesky`, `atproto_oauth`, `bluesky_text`, `flutter_bloc`, `drift`, `go_router`)
- [ ] Set up feature-first folder structure (`core/`, `features/auth|profile|settings/`)
- [ ] Configure Drift database with `accounts`, `cached_profiles`, `cached_posts`, `settings` tables
- [ ] Configure `go_router` with initial route definitions (login, home, profile, settings)

## M1 — Authentication

- [ ] Implement App Password login (`createSession`) behind `kDebugMode` flag
- [ ] Implement OAuth 2.0 flow (DPoP + PAR + PKCE) via `atproto_oauth`
- [ ] Set up loopback redirect listener (`http://127.0.0.1/callback`)
- [ ] Build `AuthBloc` — events: `LoginRequested`, `LogoutRequested`, `SessionRestored`; states: `Unauthenticated`, `Authenticating`, `Authenticated`, `AuthError`
- [ ] Session persistence: store/restore tokens in Drift, silent refresh on launch
- [ ] Build login screen (handle input, OAuth button, debug app-password form)
- [ ] Logout: revoke tokens, clear Drift row, reset Bloc, navigate to login

## M2 — Profile Rendering

- [ ] Build `ProfileBloc` — fetch via `getProfile` / `getProfiles`
- [ ] Profile screen: avatar, banner, display name, handle, description, stats (followers/following/posts), pronouns, website
- [ ] Build `FeedBloc` — paginated fetch via `getAuthorFeed` with cursor + filter support
- [ ] Post card widget: text, timestamps, embeds (images, quote posts, link cards)
- [ ] Facet rendering: parse via `bluesky_text`, render mentions / links / hashtags as tappable spans (UTF-8 byte-safe)

## M3 — Settings & Theming

- [ ] `SettingsCubit` backed by Drift — theme mode preference (system / light / dark)
- [ ] Oxocarbon Dark `ThemeData` / `ColorScheme`
- [ ] Oxocarbon Light `ThemeData` / `ColorScheme`
- [ ] Theme picker in settings screen
- [ ] Respect system theme when set to "system"

## M4 — Dev Scripts

- [ ] `scripts/fetch_profile.py` — pretty-print profile JSON
- [ ] `scripts/fetch_feed.py` — dump post + facet structures
- [ ] `scripts/resolve_handle.py` — resolve handle → DID
