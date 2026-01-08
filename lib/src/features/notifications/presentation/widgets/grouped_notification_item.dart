import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/utils/date_formatter.dart';
import 'package:lazurite/src/core/widgets/widgets.dart';
import 'package:lazurite/src/features/notifications/application/notifications_providers.dart';
import 'package:lazurite/src/features/notifications/domain/grouped_notification.dart';
import 'package:lazurite/src/features/notifications/domain/notification_type.dart';

import 'notification_type_icon.dart';

/// A widget displaying a grouped notification with expand/collapse.
///
/// Shows multiple actors who performed the same action (e.g., "Alice, Bob
/// and 3 others liked your post") with expandable actor list.
class GroupedNotificationItem extends ConsumerStatefulWidget {
  const GroupedNotificationItem({required this.group, this.onTap, super.key});

  /// The grouped notification to display.
  final GroupedNotification group;

  /// Optional tap callback. If not provided, navigates to subject content.
  final VoidCallback? onTap;

  @override
  ConsumerState<GroupedNotificationItem> createState() => _GroupedNotificationItemState();
}

class _GroupedNotificationItemState extends ConsumerState<GroupedNotificationItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final group = widget.group;

    final backgroundColor = group.hasUnread ? colorScheme.surfaceContainerHighest : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      color: backgroundColor,
      child: InkWell(
        onTap: widget.onTap ?? () => _handleTap(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatarStack(group),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.displayText,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            NotificationTypeIcon(type: group.type, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              _getSubjectPreview(group),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormatter.formatRelative(group.mostRecentTimestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (group.totalCount > 1) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: _toggleExpanded,
                          child: Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (_isExpanded && group.totalCount > 1) _buildExpandedActorList(context, group),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack(GroupedNotification group) {
    if (group.actors.isEmpty) {
      return const SizedBox(width: 40, height: 40);
    }

    if (group.actors.length == 1) {
      return Avatar(imageUrl: group.actors.first.avatar, radius: 20);
    }

    final displayActors = group.actors.take(3).toList();
    return SizedBox(
      width: 40 + (displayActors.length - 1) * 10,
      height: 40,
      child: Stack(
        children: [
          for (var i = displayActors.length - 1; i >= 0; i--)
            Positioned(
              left: i * 10.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                ),
                child: Avatar(imageUrl: displayActors[i].avatar, radius: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedActorList(BuildContext context, GroupedNotification group) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant.withAlpha(51))),
      ),
      child: Column(
        children: [
          for (final actor in group.actors)
            InkWell(
              onTap: () => _navigateToProfile(context, actor.did),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Avatar(imageUrl: actor.avatar, radius: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            actor.displayName ?? actor.handle,
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '@${actor.handle}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getSubjectPreview(GroupedNotification group) {
    if (group.type == NotificationType.follow) {
      return '';
    }
    return group.subjectUri != null ? 'View post' : '';
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _handleTap(BuildContext context) {
    final group = widget.group;

    if (group.type == NotificationType.follow) {
      if (group.actors.isNotEmpty) {
        _navigateToProfile(context, group.actors.first.did);
      }
      return;
    }

    if (group.subjectUri != null) {
      final service = ref.read(markAsSeenServiceProvider);
      service.markAsSeen(group.mostRecentTimestamp);

      final encodedUri = Uri.encodeComponent(group.subjectUri!);
      GoRouter.of(context).push('/home/t/$encodedUri');
    } else if (group.actors.isNotEmpty) {
      _navigateToProfile(context, group.actors.first.did);
    }
  }

  void _navigateToProfile(BuildContext context, String did) {
    final encodedDid = Uri.encodeComponent(did);
    GoRouter.of(context).push('/home/u/$encodedDid');
  }
}
