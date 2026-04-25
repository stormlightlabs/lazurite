# Testing Milestones

## M0 - Shared Utilities Extraction

- [ ] Create `lib/shared/utils/format_utils.dart` with `formatInitials`, `formatCount`, `formatRelativeTime`
- [ ] Replace `_initials` in:
  - `lib/features/feed/presentation/widgets/post_card.dart`
  - `lib/features/feed/presentation/widgets/grid_post_card.dart`
  - `lib/features/feed/presentation/widgets/post_embed_view.dart`
  - `lib/features/notifications/presentation/widgets/notification_list_item.dart`
  - `lib/features/notifications/presentation/widgets/grouped_notification_list_item.dart`
  - `lib/features/profile/presentation/widgets/suggested_follows_list.dart`
  - `lib/features/moderation/presentation/screens/labeler_detail_screen.dart`
  - `lib/features/moderation/presentation/screens/moderation_settings_screen.dart`
  - `lib/features/search/presentation/search_screen.dart`
  - `lib/features/search/presentation/hashtag_screen.dart`
- [ ] Replace `_formatCount` in:
  - `lib/features/feed/presentation/widgets/post_action_bar.dart`
  - `lib/features/feed/presentation/widgets/post_card_footer.dart`
  - `lib/features/starter_packs/presentation/widgets/starter_pack_card.dart`
  - `lib/features/starter_packs/presentation/starter_pack_detail_screen.dart`
  - `lib/features/profile/presentation/profile_screen.dart`
- [ ] Consolidate `_formatTime` with existing `formatPostTime` in `post_card_footer.dart`:
  - `lib/features/notifications/presentation/widgets/notification_list_item.dart`
  - `lib/features/notifications/presentation/widgets/grouped_notification_list_item.dart`
  - `lib/features/search/presentation/search_screen.dart`
  - `lib/features/search/presentation/hashtag_screen.dart`
- [ ] Unit tests for all format functions (edge cases: empty string, zero, negative, boundary values)

## M1 - Shared State Widgets

- [ ] Create `lib/shared/presentation/widgets/loading_state.dart`
- [ ] Create `lib/shared/presentation/widgets/error_state.dart` - `ErrorState(message, onRetry)`
- [ ] Create `lib/shared/presentation/widgets/empty_state.dart` - `EmptyState(message, icon, action)`
- [ ] Replace loading/error/empty states in:
  - `lib/features/feed/presentation/home_feed_screen.dart`
  - `lib/features/feed/presentation/feed_management_screen.dart`
  - `lib/features/feed/presentation/saved_posts_screen.dart`
  - `lib/features/lists/presentation/my_lists_screen.dart`
  - `lib/features/profile/presentation/widgets/suggested_follows_list.dart`
  - `lib/features/logs/presentation/logs_screen.dart`
  - `lib/features/messages/presentation/messages_screen.dart`
  - `lib/features/notifications/presentation/notifications_screen.dart`
- [ ] Widget tests for each state widget

## M2 - Dialog & Sheet Consolidation

- [ ] Create `lib/shared/presentation/widgets/confirmation_dialog.dart`
- [ ] Create `lib/shared/presentation/widgets/options_sheet.dart`
- [ ] Create `lib/shared/presentation/helpers/snackbar_helper.dart` - `showAppSnackBar`
- [ ] Replace confirmation dialogs in:
  - `lib/features/profile/presentation/widgets/profile_action_buttons.dart` (5 dialogs)
  - `lib/features/compose/presentation/compose_screen.dart` (6 dialogs)
  - `lib/features/search/presentation/search_screen.dart` (2 dialogs)
  - `lib/features/search/presentation/hashtag_screen.dart`
  - `lib/features/feed/presentation/post_thread_screen.dart`
  - `lib/features/feed/presentation/feed_management_screen.dart`
  - `lib/features/lists/presentation/list_detail_screen.dart`
  - `lib/features/settings/presentation/settings_screen.dart`
  - `lib/features/moderation/presentation/screens/moderation_settings_screen.dart`
  - `lib/features/account/presentation/account_switcher_sheet.dart`
- [ ] Replace modal bottom sheets in:
  - `lib/features/feed/presentation/widgets/post_action_bar.dart`
  - `lib/features/feed/presentation/widgets/post_card_footer.dart`
  - `lib/features/feed/presentation/post_thread_screen.dart`
  - `lib/features/search/presentation/hashtag_screen.dart`
  - `lib/features/profile/presentation/profile_screen.dart`
- [ ] Replace SnackBar patterns in:
  - `lib/features/feed/presentation/widgets/post_card_with_actions.dart`
  - `lib/features/feed/presentation/feed_management_screen.dart`
  - `lib/features/compose/presentation/compose_screen.dart`
  - `lib/features/profile/presentation/profile_screen.dart`
  - `lib/features/lists/presentation/list_detail_screen.dart`
  - `lib/features/settings/presentation/settings_screen.dart`
- [ ] Tests for dialog/sheet/snackbar helpers

## M3 - Theme & Spacing Constants

- [ ] Create `lib/core/theme/theme_extensions.dart` - `BuildContext` extension for `colorScheme` access
- [ ] Create `lib/core/theme/spacing.dart` with padding/margin constants
- [ ] Create `lib/core/theme/color_filters.dart` - extract greyscale matrix from:
  - `lib/features/feed/presentation/widgets/grid_post_card.dart`
  - `lib/features/profile/presentation/profile_screen.dart`
- [ ] Refactor files to use new constants/extensions (27 files use `Theme.of(context).colorScheme`)
- [ ] Tests for theme extension

## M4 - Widget Extraction

- [ ] Create `lib/shared/presentation/widgets/profile_avatar.dart` (configurable size, shape, fallback)
- [ ] Create `lib/shared/presentation/widgets/actor_name_widget.dart` (displayName + handle)
- [ ] Create `lib/shared/presentation/helpers/notification_icon_mapper.dart`
- [ ] Replace avatar patterns in:
  - `lib/features/messages/presentation/widgets/convo_list_item.dart`
  - `lib/features/lists/presentation/widgets/list_row_tile.dart`
  - `lib/features/settings/presentation/settings_screen.dart`
  - `lib/features/starter_packs/presentation/widgets/starter_pack_card.dart`
  - `lib/features/starter_packs/presentation/create_edit_starter_pack_screen.dart`
  - `lib/features/account/presentation/account_switcher_sheet.dart`
  - `lib/features/profile/presentation/widgets/suggested_follows_list.dart`
  - `lib/features/feed/presentation/widgets/post_card.dart`
  - `lib/features/feed/presentation/widgets/grid_post_card.dart`
  - `lib/features/feed/presentation/widgets/post_embed_view.dart`
  - `lib/features/notifications/presentation/widgets/notification_list_item.dart`
  - `lib/features/notifications/presentation/widgets/grouped_notification_list_item.dart`
  - `lib/features/search/presentation/search_screen.dart`
  - `lib/features/search/presentation/hashtag_screen.dart`
- [ ] Replace author name patterns in:
  - `lib/features/feed/presentation/widgets/post_card.dart`
  - `lib/features/feed/presentation/widgets/grid_post_card.dart`
  - `lib/features/feed/presentation/widgets/post_embed_view.dart`
  - `lib/features/messages/presentation/widgets/convo_list_item.dart`
- [ ] Replace notification icon switch in:
  - `lib/features/notifications/presentation/widgets/notification_list_item.dart`
  - `lib/features/notifications/presentation/widgets/grouped_notification_list_item.dart`
- [ ] Widget tests for extracted widgets

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
