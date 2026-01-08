import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/avatar.dart';
import '../../../../core/widgets/visibility_detector.dart';
import '../../application/notifications_providers.dart';
import '../../domain/notification.dart';
import '../../domain/notification_type.dart';
import 'notification_type_icon.dart';

/// A list item widget for displaying a single notification.
///
/// Displays the actor's avatar, display name, notification type, timestamp,
/// and provides tap navigation to the related content.
///
/// Automatically marks the notification as seen when it scrolls into view.
class NotificationListItem extends ConsumerWidget {
  const NotificationListItem({required this.notification, this.onTap, super.key});

  /// The notification to display.
  final AppNotification notification;

  /// Optional tap callback. If not provided, navigates to thread or profile.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = notification.isRead ? null : colorScheme.surfaceContainerHighest;

    final card = Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      color: backgroundColor,
      child: InkWell(
        onTap: onTap ?? () => _handleTap(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _navigateToProfile(context),
                child: Avatar(imageUrl: notification.actor.avatar, radius: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            notification.actor.displayName ?? notification.actor.handle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '@${notification.actor.handle}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        NotificationTypeIcon(type: notification.type, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            notification.type.displayText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormatter.formatRelative(notification.indexedAt),
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );

    if (notification.isRead) {
      return card;
    }

    return VisibilityDetector(
      onVisible: () {
        final authState = ref.read(authProvider);
        if (authState is AuthStateAuthenticated) {
          final service = ref.read(markAsSeenServiceProvider);
          service.markAsSeen(notification.indexedAt, authState.session.did);
        }
      },
      child: card,
    );
  }

  void _handleTap(BuildContext context) {
    if (notification.type == NotificationType.follow) {
      _navigateToProfile(context);
      return;
    }

    if (notification.reasonSubjectUri != null) {
      final encodedUri = Uri.encodeComponent(notification.reasonSubjectUri!);
      GoRouter.of(context).push('/home/t/$encodedUri');
    } else {
      _navigateToProfile(context);
    }
  }

  void _navigateToProfile(BuildContext context) {
    final encodedDid = Uri.encodeComponent(notification.actor.did);
    GoRouter.of(context).push('/home/u/$encodedDid');
  }
}
