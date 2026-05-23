import 'package:bluesky_poptart/app/bsky/actor/defs.dart' as actor;
import 'package:bluesky_poptart/app/bsky/notification/list_notifications.dart' as bsky;
import 'package:poptart_bluesky_moderation/poptart_bluesky_moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart' hide Notification;
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_blur_overlay.dart';
import 'package:lazurite/features/notifications/domain/notification_deep_link_navigator.dart';
import 'package:lazurite/features/notifications/domain/notification_reason_utils.dart';
import 'package:lazurite/shared/presentation/helpers/notification_icon_mapper.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';
import 'package:lazurite/shared/utils/format_utils.dart';

class NotificationGroup {
  const NotificationGroup({required this.notifications});

  final List<bsky.Notification> notifications;

  bsky.Notification get latest => notifications.first;

  int get count => notifications.length;

  bool get hasUnread => notifications.any((notification) => !notification.isRead);

  List<actor.ProfileView> get authors {
    final seen = <String>{};
    final result = <actor.ProfileView>[];
    for (final notification in notifications) {
      if (seen.add(notification.author.did)) {
        result.add(notification.author);
      }
    }
    return result;
  }
}

class GroupedNotificationListItem extends StatelessWidget {
  const GroupedNotificationListItem({super.key, required this.group});

  final NotificationGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latest = group.latest;
    final isUnread = group.hasUnread;

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
              _buildReasonIcon(theme, latest),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActorRow(context),
                    const SizedBox(height: 4),
                    _buildSummary(context, theme),
                    const SizedBox(height: 2),
                    _buildTime(context, theme),
                    if (_shouldShowPreview(latest)) ...[
                      const SizedBox(height: 8),
                      _buildPreview(context, theme, latest),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActorRow(BuildContext context) {
    final visibleAuthors = group.authors.take(3).toList();

    return Row(
      children: [
        SizedBox(
          width: 28 + ((visibleAuthors.length - 1) * 18),
          height: 28,
          child: Stack(
            children: [
              for (int index = 0; index < visibleAuthors.length; index++)
                Positioned(left: index * 18, child: _buildAvatar(context, visibleAuthors[index])),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text('${group.count}', style: context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, actor.ProfileView author) {
    final moderationService = maybeModerationService(context);
    final avatarUi =
        moderationService?.profileUi(author, bsky_moderation.ModerationBehaviorContext.avatar) ??
        const bsky_moderation.ModerationUI();

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colorScheme.surface, width: 2),
      ),
      child: ProfileAvatar(
        size: 28,
        moderationUi: avatarUi,
        imageUrl: author.avatar,
        fallbackText: author.displayName ?? author.handle,
        shape: BoxShape.circle,
        placeholderTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
      ),
    );
  }

  Widget _buildReasonIcon(ThemeData theme, bsky.Notification notification) {
    final iconStyle = NotificationIconMapper.map(reason: notification.reason, colorScheme: theme.colorScheme);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: iconStyle.backgroundColor, shape: BoxShape.circle),
      child: Icon(iconStyle.icon, size: 16, color: iconStyle.iconColor),
    );
  }

  Widget _buildSummary(BuildContext context, ThemeData theme) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: _actorSummary(context),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          TextSpan(
            text: ' ${_getReasonText(context, group.latest)}',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _actorSummary(BuildContext context) {
    final names = group.authors.map((author) => author.displayName ?? author.handle).toList();
    if (names.isEmpty) {
      return context.l10n.labelSomeone;
    }
    if (names.length == 1) {
      return names.first;
    }
    if (names.length == 2) {
      return context.l10n.formatActorListTwo(names[0], names[1]);
    }
    return context.l10n.formatActorListWithOthers(names[0], names[1], names.length - 2);
  }

  Widget _buildTime(BuildContext context, ThemeData theme) {
    return Text(
      formatRelativeTime(group.latest.indexedAt, nowLabel: context.l10n.commonJustNow, includeAgo: true),
      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }

  String _getReasonText(BuildContext context, bsky.Notification notification) {
    return NotificationReasonUtils.summaryTextForReason(notification.reason, l10n: context.l10n);
  }

  bool _shouldShowPreview(bsky.Notification notification) {
    return !NotificationReasonUtils.isProfileNavigationReason(notification.reason);
  }

  Widget _buildPreview(BuildContext context, ThemeData theme, bsky.Notification notification) {
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
    final notification = group.latest;
    final deepLink = NotificationReasonUtils.deepLinkForNotification(notification);
    if (deepLink == null) {
      return;
    }
    NotificationDeepLinkNavigator.navigate(GoRouter.of(context), deepLink);
  }
}
