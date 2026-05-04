import 'package:bluesky/app_bsky_notification_listnotifications.dart' as bsky;
import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart' hide Notification;
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_blur_overlay.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderation_badge_row.dart';
import 'package:lazurite/features/notifications/domain/notification_deep_link_navigator.dart';
import 'package:lazurite/features/notifications/domain/notification_reason_utils.dart';
import 'package:lazurite/shared/presentation/helpers/notification_icon_mapper.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';
import 'package:lazurite/shared/utils/format_utils.dart';

class NotificationListItem extends StatelessWidget {
  const NotificationListItem({super.key, required this.notification});

  final bsky.Notification notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;
    final moderationService = maybeModerationService(context);
    final notificationUi =
        moderationService?.notificationUi(notification, bsky_moderation.ModerationBehaviorContext.contentList) ??
        const bsky_moderation.ModerationUI();

    return InkWell(
      onTap: () => _onTap(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: isUnread ? BorderSide(color: theme.colorScheme.primary, width: 3) : BorderSide.none),
          color: isUnread ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReasonIcon(theme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActorRow(context),
                    const SizedBox(height: 4),
                    _buildSummary(theme),
                    const SizedBox(height: 2),
                    _buildTime(theme),
                    if (notificationUi.alert || notificationUi.inform) ...[
                      const SizedBox(height: 8),
                      ModerationBadgeRow(ui: notificationUi),
                    ],
                    if (_shouldShowPreview) ...[const SizedBox(height: 8), _buildPreview(context, theme)],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonIcon(ThemeData theme) {
    final iconStyle = NotificationIconMapper.map(reason: notification.reason, colorScheme: theme.colorScheme);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: iconStyle.backgroundColor, shape: BoxShape.circle),
      child: Icon(iconStyle.icon, size: 16, color: iconStyle.iconColor),
    );
  }

  Widget _buildActorRow(BuildContext context) {
    final author = notification.author;
    final moderationService = maybeModerationService(context);
    final avatarUi =
        moderationService?.profileUi(author, bsky_moderation.ModerationBehaviorContext.avatar) ??
        const bsky_moderation.ModerationUI();

    return Row(
      children: [
        ProfileAvatar(
          size: 28,
          moderationUi: avatarUi,
          imageUrl: author.avatar,
          fallbackText: author.displayName ?? author.handle,
          shape: BoxShape.circle,
          placeholderTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildSummary(ThemeData theme) {
    final author = notification.author;
    final displayName = author.displayName ?? author.handle;
    final reasonText = _getReasonText();

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: displayName,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          TextSpan(
            text: ' $reasonText',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _getReasonText() {
    return NotificationReasonUtils.summaryTextForReason(notification.reason);
  }

  Widget _buildTime(ThemeData theme) {
    return Text(
      formatRelativeTime(notification.indexedAt, nowLabel: 'Just now', includeAgo: true),
      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }

  bool get _shouldShowPreview {
    return !NotificationReasonUtils.isProfileNavigationReason(notification.reason);
  }

  Widget _buildPreview(BuildContext context, ThemeData theme) {
    final record = notification.record;
    final text = record['text'] as String?;
    final moderationService = maybeModerationService(context);
    final notificationUi =
        moderationService?.notificationUi(notification, bsky_moderation.ModerationBehaviorContext.contentList) ??
        const bsky_moderation.ModerationUI();

    if (text == null || text.isEmpty) {
      return const SizedBox.shrink();
    }

    return ModeratedBlurOverlay(
      ui: notificationUi,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    final deepLink = NotificationReasonUtils.deepLinkForNotification(notification);
    if (deepLink == null) {
      return;
    }
    NotificationDeepLinkNavigator.navigate(GoRouter.of(context), deepLink);
  }
}
