# CHANGELOG

## [Unreleased]

### Added

#### [2026-01-09]

- User-facing DevTools for ATProto repository browsing, record inspection, and
  JSON exploration with full security test coverage.
- Internal debug overlay (kDebugMode) with system info and network inspector.

#### [2026-01-08]

- Direct messaging with conversation list, message detail, outbox-based delivery,
  message requests, and read state synchronization

- Notifications with cached feeds, unread badges, mark-as-seen syncing, grouping polish,
  and deep links to threads/profiles.

#### [2026-01-07]

- Material 3 motion with persisted settings UI, transitions, and accessibility
  compliance.

- Persisted CustomThemeDrafts with editor previews, validation, and JSON import/export
  so users can safely tweak and share themes.

- Bundled Catppuccin, Nord, Rosé Pine, Oxocarbon, and One Dark/Light packs mapped to
  Material 3 roles with lint coverage for every variant.

- Appearance settings screen with pack/variant selectors, live preview cards, and a
  theme JSON export for quick switching.

- Post composer with local drafts, media uploads (4 images + alt text),
  reply/quote support, rich text facets (mentions, links), and global FAB

- Comprehensive settings system with theme persistence, content moderation, feed &
  thread preferences, muted words filtering, and bidirectional Bluesky pref sync.

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
