import 'package:bluesky/app_bsky_notification_listnotifications.dart' as bsky;
import 'package:flutter/material.dart' hide Notification;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class NotificationListItem extends StatelessWidget {
  const NotificationListItem({super.key, required this.notification});

  final bsky.Notification notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

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
                    _buildActorRow(),
                    const SizedBox(height: 4),
                    _buildSummary(theme),
                    const SizedBox(height: 2),
                    _buildTime(theme),
                    if (_shouldShowPreview) ...[const SizedBox(height: 8), _buildPreview(theme)],
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

  Widget _buildActorRow() {
    final author = notification.author;
    final avatarUrl = author.avatar;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
          child: avatarUrl != null
              ? ClipOval(
                  child: Image.network(
                    avatarUrl,
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildAvatarPlaceholder(),
                  ),
                )
              : _buildAvatarPlaceholder(),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder() {
    final author = notification.author;
    final displayName = author.displayName;
    final handle = author.handle;
    final initials = _getInitials(displayName ?? handle);

    return Center(
      child: Text(
        initials,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
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

  Widget _buildTime(ThemeData theme) {
    return Text(
      _formatTime(notification.indexedAt),
      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }

  bool get _shouldShowPreview {
    final reason = notification.reason;
    if (reason.isKnownValue) {
      return reason.knownValue != bsky.KnownNotificationReason.follow;
    }
    return false;
  }

  Widget _buildPreview(ThemeData theme) {
    final record = notification.record;
    final text = record['text'] as String?;

    if (text == null || text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
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
    );
  }

  void _onTap(BuildContext context) {
    final reason = notification.reason;

    if (reason.isKnownValue && reason.knownValue == bsky.KnownNotificationReason.follow) {
      context.push('/profile/view?actor=${notification.author.did}');
    } else {
      final isLikeOrRepost =
          reason.isKnownValue &&
          (reason.knownValue == bsky.KnownNotificationReason.like ||
              reason.knownValue == bsky.KnownNotificationReason.repost);
      final uri = isLikeOrRepost ? (notification.reasonSubject ?? notification.uri) : notification.uri;
      context.push('/post?uri=${Uri.encodeComponent(uri.toString())}');
    }
  }
}
