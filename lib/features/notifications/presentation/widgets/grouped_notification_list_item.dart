import 'package:bluesky/app_bsky_actor_defs.dart' as actor;
import 'package:bluesky/app_bsky_notification_listnotifications.dart' as bsky;
import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart' hide Notification;
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_avatar.dart';
import 'package:lazurite/features/moderation/presentation/widgets/moderated_blur_overlay.dart';
import 'package:lazurite/shared/utils/format_utils.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

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
                    _buildSummary(theme),
                    const SizedBox(height: 2),
                    _buildTime(theme),
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
      child: ModeratedAvatar(
        size: 28,
        ui: avatarUi,
        imageUrl: author.avatar,
        initials: _getInitials(author.displayName ?? author.handle),
        shape: BoxShape.circle,
        placeholderTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
      ),
    );
  }

  Widget _buildReasonIcon(ThemeData theme, bsky.Notification notification) {
    final reason = notification.reason;
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color iconColor;
    IconData iconData;

    if (reason.isKnownValue) {
      switch (reason.knownValue) {
        case bsky.KnownNotificationReason.like:
          backgroundColor = colorScheme.error.withValues(alpha: 0.1);
          iconColor = colorScheme.error;
          iconData = Icons.favorite;
        case bsky.KnownNotificationReason.repost:
          backgroundColor = Colors.green.withValues(alpha: 0.1);
          iconColor = Colors.green;
          iconData = Icons.repeat;
        case bsky.KnownNotificationReason.follow:
          backgroundColor = colorScheme.primary.withValues(alpha: 0.1);
          iconColor = colorScheme.primary;
          iconData = Icons.person_add;
        case bsky.KnownNotificationReason.reply:
          backgroundColor = colorScheme.secondary.withValues(alpha: 0.1);
          iconColor = colorScheme.secondary;
          iconData = Icons.chat_bubble;
        case bsky.KnownNotificationReason.mention:
          backgroundColor = colorScheme.primary.withValues(alpha: 0.1);
          iconColor = colorScheme.primary;
          iconData = Icons.alternate_email;
        case bsky.KnownNotificationReason.quote:
          backgroundColor = Colors.purple.withValues(alpha: 0.1);
          iconColor = Colors.purple;
          iconData = Icons.format_quote;
        default:
          backgroundColor = colorScheme.surfaceContainerHighest;
          iconColor = colorScheme.onSurfaceVariant;
          iconData = Icons.notifications;
      }
    } else {
      backgroundColor = colorScheme.surfaceContainerHighest;
      iconColor = colorScheme.onSurfaceVariant;
      iconData = Icons.notifications;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Icon(iconData, size: 16, color: iconColor),
    );
  }

  Widget _buildSummary(ThemeData theme) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: _actorSummary(),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          TextSpan(
            text: ' ${_getReasonText(group.latest)}',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _actorSummary() {
    final names = group.authors.map((author) => author.displayName ?? author.handle).toList();
    if (names.isEmpty) {
      return 'Someone';
    }
    if (names.length == 1) {
      return names.first;
    }
    if (names.length == 2) {
      return '${names[0]} and ${names[1]}';
    }
    return '${names[0]}, ${names[1]}, and ${names.length - 2} others';
  }

  Widget _buildTime(ThemeData theme) {
    return Text(
      formatRelativeTime(group.latest.indexedAt, nowLabel: 'Just now', includeAgo: true),
      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }

  String _getReasonText(bsky.Notification notification) {
    final reason = notification.reason;

    if (reason.isKnownValue) {
      switch (reason.knownValue) {
        case bsky.KnownNotificationReason.like:
          return 'liked your post';
        case bsky.KnownNotificationReason.repost:
          return 'reposted your post';
        case bsky.KnownNotificationReason.follow:
          return 'followed you';
        case bsky.KnownNotificationReason.mention:
          return 'mentioned you';
        case bsky.KnownNotificationReason.reply:
          return 'replied to your post';
        case bsky.KnownNotificationReason.quote:
          return 'quoted your post';
        default:
          return 'interacted with you';
      }
    }

    return 'interacted with you';
  }

  bool _shouldShowPreview(bsky.Notification notification) {
    final reason = notification.reason;
    if (reason.isKnownValue) {
      return reason.knownValue != bsky.KnownNotificationReason.follow;
    }
    return false;
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

  String _getInitials(String text) {
    final parts = text.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return text.substring(0, text.length >= 2 ? 2 : 1).toUpperCase();
  }

  void _onTap(BuildContext context) {
    final notification = group.latest;
    final reason = notification.reason;

    if (reason.isKnownValue && reason.knownValue == bsky.KnownNotificationReason.follow) {
      context.push('/profile/view?actor=${notification.author.did}');
      return;
    }

    final isLikeOrRepost =
        reason.isKnownValue &&
        (reason.knownValue == bsky.KnownNotificationReason.like ||
            reason.knownValue == bsky.KnownNotificationReason.repost);
    final uri = isLikeOrRepost ? (notification.reasonSubject ?? notification.uri) : notification.uri;
    context.push('/post?uri=${Uri.encodeComponent(uri.toString())}');
  }
}
