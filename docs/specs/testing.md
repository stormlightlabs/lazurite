# Testing Strategy

Audit of the presentation layer and evaluation of visual testing tooling to
improve test coverage, reduce code duplication, and establish a golden testing
baseline.

## Presentation Layer Audit

A full audit of `lib/features/*/presentation/` identified significant
duplication across 40+ files. The findings group into ten categories.

### 1. Duplicated Utility Functions

| Function                | Pattern                              | Occurrences                                                                                                                                        |
| ----------------------- | ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| `_initials(String)`     | Generates initials from display name | 10 files (post_card, grid_post_card, post_embed_view, notification items, suggested_follows, labeler_detail, moderation_settings, search, hashtag) |
| `_formatCount(int)`     | Formats numbers with K/M suffixes    | 5 files (post_action_bar, post_card_footer, starter_pack_card, starter_pack_detail, profile_screen)                                                |
| `_formatTime(DateTime)` | Relative time strings ("2h ago")     | 4 files (notification items, search, hashtag) — overlaps with `formatPostTime()` in post_card_footer                                               |

**Target**: Extract to `lib/shared/utils/format_utils.dart`.

### 2. Duplicated Widgets

**Avatar display** — 14 files repeat `CircleAvatar` / `ModeratedAvatar` with
identical styling. Extract to a configurable `ProfileAvatar` widget.

**Author name + handle** — Repeated two-line text widget (displayName / @handle)
in post_card, grid_post_card, post_embed_view, convo_list_item. Extract to
`ActorNameWidget`.

**Greyscale color filter** — Identical 4x5 color matrix defined in
grid_post_card and profile_screen. Extract to `lib/core/theme/color_filters.dart`.

**Notification reason icon** — Large switch statement mapping notification
reasons to icons/colors duplicated identically in notification_list_item and
grouped_notification_list_item. Extract to `NotificationIconMapper`.

### 3. Bottom Sheets & Dialogs

**Modal bottom sheets** — 9 files repeat `showModalBottomSheet` with ListTile
option lists. Create `OptionsSheet` builder.

**Confirmation dialogs** — 26 occurrences of AlertDialog with
title/content/cancel/confirm. Create `ConfirmationDialog(title, content,
confirmLabel, onConfirm)`.

### 4. State Handling Patterns

**Loading** — `Center(child: CircularProgressIndicator())` in 8+ screens.
**Error with retry** — Center + error message + retry button in 8+ screens.
**Empty state** — Center + message + optional action in multiple screens.

Create `LoadingState`, `ErrorState(message, onRetry)`, `EmptyState(message,
icon, action)` widgets in `lib/shared/presentation/widgets/`.

### 5. SnackBar Display

`ScaffoldMessenger.of(context).showSnackBar(SnackBar(..., behavior:
floating))` appears in 14 files. Create `showAppSnackBar(context, message,
{isError})` helper.

### 6. Theme Access Boilerplate

`Theme.of(context).colorScheme.*` appears 142 times across 27 files.
`Border.all(color: colorScheme.outlineVariant)` is the most common repeated
decoration. Consider a `BuildContext` extension:

```dart
extension ThemeX on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
```

### 7. Spacing Constants

`EdgeInsets.symmetric(horizontal: 16)` appears 34+ times. `SizedBox(height: 8)`
and variants repeat throughout. Define constants in
`lib/core/theme/spacing.dart`.

### 8. Navigation Helpers

Profile navigation (`GoRouter.maybeOf(context)?.push('/profile/view?actor=...')`)
repeated across post cards and notification items. Extract to route helper
functions.

### 9. Haptic Feedback

17 occurrences of `HapticFeedback.mediumImpact()` across 6 files. Minor, but a
`HapticHelper` would centralize.

### 10. List Item Tiles

23 occurrences of ListTile with avatar/title/subtitle across features. A
`BaseListItemTile` could reduce this, though diversity of layouts may limit
reuse.

## Visual Testing Evaluation

### Current State

- 122 test files across 16 feature modules
- Stack: `flutter_test`, `bloc_test`, `mocktail`
- Test types: unit (cubits, repos, services) + widget (screens, widgets)
- **No golden tests, no integration tests, no visual regression testing**

### Widgetbook

Component catalog + visual testing platform for Flutter (v3.22.0 stable,
v4.0.0-beta.3).

| Capability        | Detail                                                    |
| ----------------- | --------------------------------------------------------- |
| Component catalog | Render widgets in isolation with configurable knobs       |
| Visual regression | `widgetbook_golden_test` generates goldens from use cases |
| Widgetbook Cloud  | CI visual diffs, platform-independent rendering (paid)    |
| Addons            | Multi-theme, locale, text scale, device frame testing     |

**Verdict: Not recommended for Lazurite at this time.**

Reasons:

- Requires building/maintaining a separate Widgetbook app with use-case
  definitions for every widget — high overhead for a small team
- The project's gap is golden tests and integration tests, not a design catalog
- No dedicated designer reviewing components, so collaborative review value is
  unrealized
- Converting 122 existing widget tests into Widgetbook use cases is low ROI

**When to reconsider**: If a shared design system emerges, a designer joins, or
PR visual review becomes a bottleneck.

### Recommended Approach

**Golden Toolkit** (`golden_toolkit` package) — add visual regression to
existing widget tests with minimal overhead:

- One or two lines per existing test to capture golden snapshots
- No separate app to maintain
- Works with existing `pumpWidget` patterns
- `multiScreenGolden` for multi-device-size snapshots

**Patrol** — consider later if native feature testing (permissions, deep links)
becomes important.

**Built-in integration tests** — add end-to-end flow tests using
`integration_test` package for critical paths (compose, auth, navigation).

### Platform Rendering Note

Golden tests produce platform-dependent pixel output (macOS dev vs Linux CI).
Mitigations:

- Tolerance thresholds in comparisons
- CI-only golden generation with committed baselines
- Or Widgetbook Cloud (if budget allows) for platform-independent rendering
