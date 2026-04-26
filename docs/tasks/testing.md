# Testing Milestones

## M0 - Shared Utilities Extraction

- [x] Create `lib/shared/utils/format_utils.dart` with `formatInitials`, `formatCount`, `formatRelativeTime`
- [x] Replace `_initials`
- [x] Replace `_formatCount`
- [x] Consolidate `_formatTime` with existing `formatPostTime` in `post_card_footer.dart`
- [x] Unit tests for all format functions (edge cases: empty string, zero, negative, boundary values)

## M1 - Shared State Widgets

- [x] Create `lib/shared/presentation/widgets/loading_state.dart`
- [x] Create `lib/shared/presentation/widgets/error_state.dart` - `ErrorState(message, onRetry)`
- [x] Create `lib/shared/presentation/widgets/empty_state.dart` - `EmptyState(message, icon, action)`
- [x] Replace loading/error/empty states across the app with new widgets
- [x] Widget tests for each state widget

## M2 - Dialog & Sheet Consolidation

- [x] Create `lib/shared/presentation/widgets/confirmation_dialog.dart`
- [x] Create `lib/shared/presentation/widgets/options_sheet.dart`
- [x] Create `lib/shared/presentation/helpers/snackbar_helper.dart` - `showAppSnackBar`
- [x] Replace confirmation dialogs
- [x] Replace modal bottom sheets
- [x] Replace SnackBar patterns
- [x] Tests for dialog/sheet/snackbar helpers

## M3 - Theme & Spacing Constants

- [x] Create `lib/core/theme/theme_extensions.dart` - `BuildContext` extension for `colorScheme` access
- [x] Create `lib/core/theme/spacing.dart` with padding/margin constants
- [x] Create `lib/core/theme/color_filters.dart` - extract greyscale matrix
- [x] Refactor files to use new constants/extensions
- [x] Tests for theme extension

## M4 - Widget Extraction

- [x] Create `lib/shared/presentation/widgets/profile_avatar.dart` (configurable size, shape, fallback)
- [x] Create `lib/shared/presentation/widgets/actor_name_widget.dart` (displayName + handle)
- [x] Create `lib/shared/presentation/helpers/notification_icon_mapper.dart`
- [x] Replace avatar patterns
- [x] Replace author name patterns
- [x] Replace notification icon switch
- [x] Widget tests for extracted widgets

## M5 - Navigation & Haptics Helpers

- [ ] Create `lib/shared/presentation/helpers/navigation_helpers.dart` (`navigateToProfile`, `navigateToPost`)
- [ ] Create `lib/shared/presentation/helpers/haptic_helper.dart`
- [ ] Replace navigation patterns in:
  - `lib/features/feed/presentation/widgets/post_card.dart`
  - `lib/features/feed/presentation/widgets/grid_post_card.dart`
  - `lib/features/notifications/presentation/widgets/grouped_notification_list_item.dart`
- [ ] Replace haptic feedback call sites (17 occurrences across 6 files)
- [ ] Tests for navigation helpers

## M6 - Golden Testing Setup

- [ ] Add `golden_toolkit` to dev_dependencies
- [ ] Configure golden test threshold for CI tolerance
- [ ] Add golden tests for shared widgets (M1-M4 extractions)
- [ ] Add golden tests for post card variants (linear, grid)
- [ ] Add golden tests for profile screen states
- [ ] Add multi-device-size goldens for key screens
- [ ] CI pipeline step for golden test comparison
- [ ] Document golden update workflow (`flutter test --update-goldens`)

## M7 - Integration Tests

- [ ] Add `integration_test` to dev_dependencies
- [ ] Auth flow end-to-end test
- [ ] Compose + post flow test
- [ ] Navigation flow test (tab switching, drawer, profile)
- [ ] CI pipeline step for integration tests
