import 'package:bluesky/app_bsky_notification_listnotifications.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/notifications/bloc/notification_bloc.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';
import 'package:lazurite/features/notifications/presentation/widgets/grouped_notification_list_item.dart';
import 'package:lazurite/features/notifications/presentation/widgets/notification_list_item.dart';

class NotificationsPane extends StatefulWidget {
  const NotificationsPane({super.key});

  @override
  State<NotificationsPane> createState() => _NotificationsPaneState();
}

class _NotificationsPaneState extends State<NotificationsPane> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (context.read<NotificationBloc>().state.status == NotificationStatus.initial) {
      context.read<NotificationBloc>().add(const NotificationsRequested());
      context.read<NotificationBloc>().add(const NotificationsMarkedRead());
      context.read<UnreadCountCubit>().refresh();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationBloc>().add(const NotificationsPageLoaded());
    }
  }

  Future<void> _onRefresh() async {
    context.read<NotificationBloc>().add(const NotificationsRefreshed());
    context.read<NotificationBloc>().add(const NotificationsMarkedRead());
    await context.read<UnreadCountCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state.status == NotificationStatus.initial ||
            (state.status == NotificationStatus.loading && state.notifications.isEmpty)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == NotificationStatus.error && state.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Failed to load notifications', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(state.errorMessage ?? 'Unknown error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.read<NotificationBloc>().add(const NotificationsRequested()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.notifications.isEmpty) {
          return Center(child: Text('No notifications yet', style: Theme.of(context).textTheme.bodyLarge));
        }

        final groupedNotifications = _groupNotificationsByDay(state.notifications);

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _calculateItemCount(groupedNotifications, state),
            itemBuilder: (context, index) {
              final item = _getItemAtIndex(groupedNotifications, index);

              if (item is String) {
                return _DayHeader(title: item);
              } else if (item is NotificationGroup) {
                if (item.count == 1) {
                  return NotificationListItem(notification: item.latest);
                }
                return GroupedNotificationListItem(group: item);
              } else if (item == null) {
                return const Center(
                  child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Map<DateTime, List<NotificationGroup>> _groupNotificationsByDay(List<bsky.Notification> notifications) {
    final grouped = <DateTime, Map<String, List<bsky.Notification>>>{};
    final sorted = [...notifications]..sort((a, b) => b.indexedAt.compareTo(a.indexedAt));

    for (final notification in sorted) {
      final date = DateTime(notification.indexedAt.year, notification.indexedAt.month, notification.indexedAt.day);
      final groupKey = _groupKey(notification);

      grouped.putIfAbsent(date, () => <String, List<bsky.Notification>>{});
      grouped[date]!.putIfAbsent(groupKey, () => <bsky.Notification>[]).add(notification);
    }

    final sortedDays = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final result = <DateTime, List<NotificationGroup>>{};

    for (final day in sortedDays) {
      final groups =
          grouped[day]!.values.map((notifications) => NotificationGroup(notifications: notifications)).toList()
            ..sort((a, b) => b.latest.indexedAt.compareTo(a.latest.indexedAt));
      result[day] = groups;
    }

    return result;
  }

  String _groupKey(bsky.Notification notification) {
    if (notification.reason.isKnownValue) {
      final reason = notification.reason.knownValue;
      if (reason == bsky.KnownNotificationReason.follow) {
        return 'follow';
      }

      final subject = notification.reasonSubject?.toString() ?? notification.uri.toString();
      return '${reason.toString()}:$subject';
    }

    return 'unknown:${notification.reasonSubject ?? notification.uri}';
  }

  int _calculateItemCount(Map<DateTime, List<NotificationGroup>> grouped, NotificationState state) {
    int count = 0;
    for (final entry in grouped.entries) {
      count++;
      count += entry.value.length;
    }
    if (state.isLoadingMore) {
      count++;
    }
    return count;
  }

  dynamic _getItemAtIndex(Map<DateTime, List<NotificationGroup>> grouped, int index) {
    int currentIndex = 0;

    for (final entry in grouped.entries) {
      if (currentIndex == index) {
        return _formatDayHeader(entry.key);
      }
      currentIndex++;

      for (final notificationGroup in entry.value) {
        if (currentIndex == index) {
          return notificationGroup;
        }
        currentIndex++;
      }
    }

    return null;
  }

  String _formatDayHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    }

    return _formatDate(date);
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}';
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
