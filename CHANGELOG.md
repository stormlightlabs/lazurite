# CHANGELOG

## [Unreleased]

### Added

#### [2026-01-07]

Comprehensive settings system with theme persistence, content moderation, feed & thread
preferences, muted words filtering, and bidirectional Bluesky pref sync.

#### [2026-01-06]

- Migrated NavigationBar, FilterChips, Cards, and text emphasis to M3 role-based theming
  with surfaceContainer hierarchy and outlineVariant dividers.
- Created ThemePack/ThemeVariant/ThemeSpec domain types with ThemeFactory centralizing
  component themes using full M3 ColorScheme roles.
- Complete profile and thread rendering with verification badges, viewer relationship &
  interaction states, all embed types, content labels with warnings, thread structure
  with parent/reply chains, and pinned posts.
- Safe syncing, cached search, and feed discovery flow polish.

#### [2026-01-05]

- Multi-feed support with discovery, switching, caching, & offline resilience.

#### [2026-01-04]

- Profiles, search, and the full social graph experience are complete with cached
  profile data, deep-linkable search, and responsive follow/following workflows.

- Drift-backed timeline and thread experiences now ship with cache-first reads, infinite
  scroll, pull-to-refresh, and deep links to thread views for every post.

- Identity bootstrap and OAuth session flows are fully wired with secure sign-in,
  protected routing, and refreshed sessions for authenticated accounts.

#### [2026-01-03]

- App shell and navigation scaffold deliver all primary routes with reusable UI
  primitives and state handling.

- Networking stack with Dio clients, interceptors, and routing matrix is finished with
  standardized failure handling.

- Repository skeleton, feature-first layout, and CI quality gates are fully in place.
