# UI Refactor

Refactor the app's visual layer toward a sharp, architectural aesthetic with
square geometry and editorial density. Colors and typography stay as-is — this
spec covers card structure, layout geometry, navigation chrome, and a new
user-facing layout settings screen.

## Top App Bar

The current `AppBar` is stock Material. Replace with a custom header:

- Fixed, full-width, `h-64` (logical pixels), `backdrop-blur` background with
  `surfaceContainerLowest` at ~80% opacity
- **Left**: hamburger menu icon + section label (uppercase, `letterSpacing: 3`,
  `labelSmall`, `onSurfaceVariant`)
- **Right**: user avatar thumbnail (`32×32`, square, `surfaceContainerHigh`
  background, `outlineVariant` border)
- The branding wordmark ("BLUESKY") sits center-right in the home view; on
  other screens it is omitted
- Home screen variant adds inline feed switcher tabs (Feed / Discover / Lists)
  as uppercase label links in the right cluster

## Bottom Navigation Bar

Current: 6-tab `NavigationBar`, icons only, `height: 50`,
`surfaceContainerHighest` background, `RoundedSuperellipseBorder` indicator.

Target: 4-tab bar — Home, Search, Notifications (labeled "Alerts"), Profile.

| Change       | Detail                                                                                    |
| ------------ | ----------------------------------------------------------------------------------------- |
| Tab count    | 6 → 4. Messages and Settings move behind the hamburger menu drawer                        |
| Height       | `50` → `80` (includes safe-area padding)                                                  |
| Background   | Semi-transparent (`surface` at 80% opacity) + backdrop blur                               |
| Indicator    | Drop `RoundedSuperellipseBorder` indicator; active state is filled icon + slight scale-up |
| Labels       | `alwaysHide` → show labels beneath icons (uppercase, `10px`, `letterSpacing: 0.1em`)      |
| Unread badge | Keep existing badge on Notifications                                                      |

## Navigation Drawer

New. Triggered by the hamburger icon in the top app bar.

Contents (top-to-bottom):

- Messages
- Settings
- (extensible — future items like Saved Posts, Lists, Feeds management)

Use `Drawer` with the same backdrop-blur surface treatment as the nav bar.

## Post Card — Linear (List) Layout

Current card uses `Card` with `elevation: 0`, `RoundedRectangleBorder`,
`vertical margin: 1`. Keep this as the "Linear Flow" variant.

Changes:

- Replace `Card` wrapper with a `Container` using `border: Border.all(outlineVariant)` and `surfaceContainerLowest` fill
- Remove `CircleAvatar` — replace with `5×5` square avatar container
  (`surfaceContainerHighest` background, `outlineVariant` border)
- Author handle: uppercase, `letterSpacing: widest`, `labelSmall`, bold
- Timestamp: right-aligned in the action bar row, uppercase, `10px`,
  `onSurfaceVariant`
- Body text: `bodySmall`, `line-clamp: 2` (via `maxLines: 2, overflow: ellipsis`)
- Action bar: move inside a top-bordered footer area
  (`border-t outlineVariant`). Icons only (chat, repeat, favorite, save) in a
  left-aligned row. Timestamp right-aligned in the same row
- Save icon: bookmark icon that opens local/cloud save options on tap (same
  behaviour as the previous action bar). Active state: amber for local-only saves,
  `primary` for cloud saves
- Embed images: keep existing grid logic, but use square aspect ratio in grid view

## Post Card — Grid Layout

New card variant for the "Grid Matrix" feed architecture.

Structure (top-to-bottom):

1. **Image region** — square (`aspectRatio: 1`), `surfaceContainerHigh`
   background, `BoxFit.cover`, grayscale filter by default (colorize on
   hover/press is optional)
2. **Content region** (padding `16`):
   - Author row: `5×5` square avatar + handle (same style as linear)
   - Body text: `bodySmall`, `maxLines: 2`, ellipsis
   - Footer: top-bordered, icons left (chat, repeat, favorite, save), relative timestamp right

Text-only variant (no image): content region expands to fill the card with
larger body text (`titleMedium`, `tracking: tight`). Secondary text below in
`labelSmall`.

Outer container: `surfaceContainerLowest`, `border: outlineVariant`,
`hover:border: primary` (interaction feedback).

## Profile Screen

Current: `NestedScrollView` with collapsible header, `CircleAvatar`,
`TabBar` (Posts / Replies / Media).

Refactor to an asymmetric "bento" layout:

### Header

- Cover image: `h-192` to `h-256` (responsive), grayscale, `opacity: 0.5`,
  `surfaceContainerHigh` fallback, `outlineVariant` bottom border
- Avatar: `96×96` to `128×128` square (not circle), `surfaceContainerLowest`
  background, `4px` background-color border
- Display name: `headlineLarge`, semibold, `tracking: tight`, uppercase
- Handle: `labelMedium`, `onSurfaceVariant`
- Bio: `bodyMedium`, max-width `~500px`
- Stats row: inside a `border-y outlineVariant` container.
  Each stat: value (`titleMedium`, bold) above label (uppercase, `11px`,
  `letterSpacing: 0.1em`, `onSurfaceVariant`)
- Edit Profile / Follow button: uppercase, `letterSpacing: widest`, `labelSmall`,
  bold, `primary` fill with `onPrimary` text

### Tabs

- Sticky below top app bar
- Backdrop-blur background
- Tab labels: uppercase, `11px`, `letterSpacing: 0.2em`, bold
- Active indicator: `2px` bottom border in `primary`

### Content Area

Profile posts use a `12-column` asymmetric bento grid:

- Pinned post spans `8 columns` (featured, with full image embed)
- Metadata / info card spans `4 columns` (`surfaceContainerHigh` background)
- Remaining posts in `6+6` two-column pairs

The bento grid applies when the feed architecture is set to "Grid Matrix".
When set to "Linear Flow", profile posts render as a standard vertical list
using the linear post card.

## Feed Architecture — Home Screen Grid

When the user selects "Grid Matrix" layout, the home feed renders in a
responsive grid:

| Breakpoint                 | Columns |
| -------------------------- | ------- |
| `< 600px` (phone portrait) | 1       |
| `600–839px`                | 2       |
| `840–1199px`               | 3       |
| `≥ 1200px`                 | 4       |

Use `SliverGrid` with `SliverGridDelegateWithFixedCrossAxisCount`. Cards are
the grid post card variant described above.

When set to "Linear Flow", keep the current `ListView` of linear post cards.

## Layout Settings Screen

New settings section (accessible from the Settings screen or the drawer).

### UI Density

Three radio-style cards:

| Option                 | Description                                      |
| ---------------------- | ------------------------------------------------ |
| **Compact**            | Maximum information density. Minimal whitespace. |
| **Standard** (default) | Balanced proportions.                            |
| **Relaxed**            | Expansive margins. Focus-oriented layout.        |

Each option renders as a selectable card with a schematic icon (horizontal
bars of varying spacing), title, subtitle, and a square checkbox indicator
(filled = selected, outlined = deselected).

Density values map to padding/margin scale factors applied globally via an
`InheritedWidget` or theme extension.

### Feed Architecture

Two square toggle cards:

| Option                    | Description        |
| ------------------------- | ------------------ |
| **Grid Matrix** (default) | 2×2 schematic icon |
| **Linear Flow**           | 3-row stacked icon |

Selected state: `2px primary` border. Unselected: `1px outlineVariant` border,
`hover:primary`.

### Viewport Preview

Sticky sidebar (or bottom section on narrow screens) showing a schematic
wireframe preview of the selected layout configuration. Updates live as the
user toggles density and feed architecture options.

### Persistence

Store `ui_density` (`compact` | `standard` | `relaxed`) and
`feed_architecture` (`grid` | `linear`) in the Drift `settings` table. Expose
via `SettingsCubit` alongside existing theme preferences.

## Shared Geometry Tokens

All `0px` border-radius throughout (square corners). Ensure no Flutter widgets
use rounded corners except where explicitly noted (e.g., circular unread
badges).
