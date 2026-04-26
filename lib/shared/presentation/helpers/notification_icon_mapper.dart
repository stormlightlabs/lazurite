import 'package:bluesky/app_bsky_notification_listnotifications.dart' as bsky;
import 'package:flutter/material.dart';

class NotificationIconStyle {
  const NotificationIconStyle({required this.backgroundColor, required this.iconColor, required this.icon});

  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
}

abstract final class NotificationIconMapper {
  static NotificationIconStyle map({required bsky.NotificationReason reason, required ColorScheme colorScheme}) {
    if (!reason.isKnownValue) {
      return NotificationIconStyle(
        backgroundColor: colorScheme.surfaceContainerHighest,
        iconColor: colorScheme.onSurfaceVariant,
        icon: Icons.notifications,
      );
    }

    switch (reason.knownValue) {
      case bsky.KnownNotificationReason.like:
        return NotificationIconStyle(
          backgroundColor: colorScheme.error.withValues(alpha: 0.1),
          iconColor: colorScheme.error,
          icon: Icons.favorite,
        );
      case bsky.KnownNotificationReason.repost:
        return NotificationIconStyle(
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          iconColor: Colors.green,
          icon: Icons.repeat,
        );
      case bsky.KnownNotificationReason.follow:
        return NotificationIconStyle(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          iconColor: colorScheme.primary,
          icon: Icons.person_add,
        );
      case bsky.KnownNotificationReason.reply:
        return NotificationIconStyle(
          backgroundColor: colorScheme.secondary.withValues(alpha: 0.1),
          iconColor: colorScheme.secondary,
          icon: Icons.chat_bubble,
        );
      case bsky.KnownNotificationReason.mention:
        return NotificationIconStyle(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          iconColor: colorScheme.primary,
          icon: Icons.alternate_email,
        );
      case bsky.KnownNotificationReason.quote:
        return NotificationIconStyle(
          backgroundColor: Colors.purple.withValues(alpha: 0.1),
          iconColor: Colors.purple,
          icon: Icons.format_quote,
        );
      default:
        return NotificationIconStyle(
          backgroundColor: colorScheme.surfaceContainerHighest,
          iconColor: colorScheme.onSurfaceVariant,
          icon: Icons.notifications,
        );
    }
  }
}
