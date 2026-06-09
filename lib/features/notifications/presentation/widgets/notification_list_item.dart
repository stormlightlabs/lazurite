import 'package:bluesky_poptart/app/bsky/notification/list_notifications.dart' as bsky;
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:poptart_bluesky_moderation/poptart_bluesky_moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart' hide Notification;
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/label_detail_sheet.dart';
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
    final isUnread = !notification.isRead;
    final moderationService = maybeModerationService(context);
    final notificationUi =
        moderationService?.notificationUi(notification, bsky_moderation.ModerationBehaviorContext.contentList) ??
        const bsky_moderation.ModerationUI();

    return InkWell(
      onTap: () => _onTap(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: isUnread ? BorderSide(color: context.colorScheme.primary, width: 3) : BorderSide.none),
          color: isUnread ? context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReasonIcon(context.theme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActorRow(context),
                    const SizedBox(height: 4),
                    _buildSummary(context),
                    const SizedBox(height: 2),
                    _buildTime(context),
                    if (notificationUi.alert || notificationUi.inform) ...[
                      const SizedBox(height: 8),
                      ModerationBadgeRow(ui: notificationUi, onLabelTap: labelDetailTapHandler(context)),
                    ],
                    if (_shouldShowPreview) ...[const SizedBox(height: 8), _buildPreview(context)],
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
    final moderationService = maybeModerationService(context);
    final avatarUi =
        moderationService?.profileUi(notification.author, bsky_moderation.ModerationBehaviorContext.avatar) ??
        const bsky_moderation.ModerationUI();

    return Row(
      children: [
        ProfileAvatar(
          size: 28,
          moderationUi: avatarUi,
          imageUrl: notification.author.avatar,
          fallbackText: notification.author.displayName ?? notification.author.handle,
          shape: BoxShape.circle,
          placeholderTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context) => RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: notification.author.displayName ?? notification.author.handle,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.onSurface,
          ),
        ),
        TextSpan(
          text: ' ${_getReasonText(context)}',
          style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
      ],
    ),
  );

  String _getReasonText(BuildContext context) {
    return NotificationReasonUtils.summaryTextForReason(notification.reason, l10n: context.l10n);
  }

  Widget _buildTime(BuildContext context) => Text(
    formatRelativeTime(notification.indexedAt, nowLabel: context.l10n.commonJustNow, includeAgo: true),
    style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
  );

  bool get _shouldShowPreview => !NotificationReasonUtils.isProfileNavigationReason(notification.reason);

  Widget _buildPreview(BuildContext context) {
    final text = notification.record['text'] as String?;
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
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.theme.dividerColor),
        ),
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
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
