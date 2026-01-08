import 'package:flutter/material.dart';

import '../../domain/notification_type.dart';

/// Widget that displays an icon for a notification type.
///
/// Maps each [NotificationType] to a specific Material icon with
/// an appropriate color to help users quickly identify notification types.
class NotificationTypeIcon extends StatelessWidget {
  const NotificationTypeIcon({required this.type, this.size = 20, super.key});

  /// The notification type to display an icon for.
  final NotificationType type;

  /// The size of the icon.
  final double size;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _getIconAndColor(context);
    return Icon(icon, size: size, color: color);
  }

  (IconData, Color) _getIconAndColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (type) {
      case NotificationType.like:
        return (Icons.favorite, Colors.pink);
      case NotificationType.repost:
        return (Icons.repeat, Colors.green);
      case NotificationType.follow:
        return (Icons.person_add, colorScheme.primary);
      case NotificationType.mention:
        return (Icons.alternate_email, Colors.purple);
      case NotificationType.reply:
        return (Icons.reply, colorScheme.onSurfaceVariant);
      case NotificationType.quote:
        return (Icons.format_quote, Colors.teal);
      case NotificationType.starterpackJoined:
        return (Icons.group_add, Colors.amber);
    }
  }
}
