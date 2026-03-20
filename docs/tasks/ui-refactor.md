# UI Refactor Milestones

## M0 — Foundation & Layout Settings Persistence

- [x] Add `ui_density` and `feed_architecture` keys to Drift `settings` table
- [x] Drift migration for new settings keys
- [x] Extend `SettingsCubit` / `SettingsState` with density and feed architecture fields
- [x] `UiDensity` enum (`compact`, `standard`, `relaxed`) with padding scale factors
- [x] `FeedArchitecture` enum (`grid`, `linear`)
- [x] Theme extension or `InheritedWidget` that provides density-scaled spacing values

## M1 — Navigation Chrome

- [x] Custom top app bar widget replacing stock `AppBar` — hamburger, section label, avatar
- [x] Home-screen variant with inline feed switcher tabs
- [x] Navigation drawer with Messages and Settings entries
- [x] Refactor `AppShell` bottom nav: 6 tabs → 4 (Home, Search, Alerts, Profile)
- [x] Bottom nav styling: `h-80`, semi-transparent blur background, labels, filled active icon
- [x] Route updates — Messages and Settings accessible via drawer instead of bottom tabs
- [x] Tests for navigation (drawer opens, tabs switch, routes resolve)

## M2 — Post Card Variants

- [x] Refactor `PostCard` to the linear variant: square avatars, uppercase handle, bordered footer
- [x] New `GridPostCard` widget — image region, content region, footer
- [x] Text-only grid card variant (no image — expanded body text)
- [x] Shared `PostCardFooter` widget (action icons left, timestamp right, top border)
- [x] Wire both variants to `PostCardWithActions` for action state management
- [x] Tests for both card variants

## M3 — Home Feed Grid Layout

- [ ] `HomeFeedScreen` reads `feed_architecture` from `SettingsCubit`
- [ ] Grid mode: responsive `SliverGrid` with breakpoint-based column count
- [ ] Linear mode: existing `ListView` of linear post cards (no change)
- [ ] Feed architecture toggle triggers rebuild without re-fetch
- [ ] Tests for grid/linear switching and column count at breakpoints

## M4 — Profile Screen Refactor

- [ ] Profile header: square avatar, cover image (grayscale, opacity), stats row with border
- [ ] Display name uppercase + tight tracking, handle below
- [ ] Sticky tab bar with backdrop blur and uppercase labels
- [ ] Bento grid layout for profile posts (8+4 featured row, 6+6 pairs) in grid mode
- [ ] Linear fallback for profile posts when feed architecture is "linear"
- [ ] Tests for profile header rendering and layout mode switching

## M5 — Layout Settings Screen

- [ ] UI Density selector — three radio-style cards with schematic icons
- [ ] Feed Architecture selector — two square toggle cards
- [ ] Viewport Preview wireframe that updates live with selections
- [ ] Settings screen entry point (new section or drawer link)
- [ ] Persist selections to Drift on change
- [ ] Tests for settings screen interactions and persistence round-trip
