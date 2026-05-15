import 'package:bluesky_poptart/app/bsky/notification/list_notifications.dart' as bsky;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/notifications/bloc/notification_bloc.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';
import 'package:lazurite/features/notifications/presentation/widgets/grouped_notification_list_item.dart';
import 'package:lazurite/features/notifications/presentation/widgets/notification_list_item.dart';
import 'package:lazurite/shared/presentation/widgets/animated_refresh_indicator.dart';
import 'package:lazurite/shared/presentation/widgets/empty_state.dart';
import 'package:lazurite/shared/presentation/widgets/error_state.dart';
import 'package:lazurite/shared/presentation/widgets/loading_state.dart';
import 'package:lazurite/shared/presentation/widgets/staggered_entrance.dart';

class NotificationsPane extends StatefulWidget {
  const NotificationsPane({super.key});

  @override
  State<NotificationsPane> createState() => _NotificationsPaneState();
}

class _NotificationsPaneState extends State<NotificationsPane> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _seenNotificationKeys = <String>{};
  Timer? _pollTimer;

  static const _pollInterval = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (context.read<NotificationBloc>().state.status == NotificationStatus.initial) {
      context.read<NotificationBloc>().add(const NotificationsRequested());
      context.read<NotificationBloc>().add(const NotificationsMarkedRead());
      context.read<UnreadCountCubit>().refresh();
    }
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollForUpdates());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _pollTimer?.cancel();
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

  void _pollForUpdates() {
    if (!mounted) {
      return;
    }
    context.read<NotificationBloc>().add(const NotificationsRefreshed());
    context.read<NotificationBloc>().add(const NotificationsMarkedRead());
    context.read<UnreadCountCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final isOffline = context.select<ConnectivityCubit, bool>((cubit) => cubit.state.isOffline);
        if (state.status == NotificationStatus.initial ||
            (state.status == NotificationStatus.loading && state.notifications.isEmpty)) {
          if (isOffline) {
            return const _OfflineNotificationsState();
          }
          return const LoadingState();
        }

        if (state.status == NotificationStatus.error && state.notifications.isEmpty) {
          if (isOffline) {
            return const _OfflineNotificationsState();
          }
          return ErrorState(
            title: context.l10n.errorFailedToLoadNotifications,
            message: state.errorMessage ?? context.l10n.errorUnknown,
            onRetry: () => context.read<NotificationBloc>().add(const NotificationsRequested()),
          );
        }

        if (state.notifications.isEmpty) {
          if (isOffline) {
            return const _OfflineNotificationsState();
          }
          return EmptyState(message: context.l10n.messageNoNotificationsYet, icon: Icons.notifications_none_outlined);
        }

        final groupedNotifications = _groupNotificationsByDay(state.notifications);

        return AnimatedRefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _calculateItemCount(groupedNotifications, state),
            itemBuilder: (context, index) {
              final item = _getItemAtIndex(context, groupedNotifications, index);

              if (item is String) {
                return _DayHeader(title: item);
              } else if (item is NotificationGroup) {
                final key = '${item.latest.uri}:${item.latest.indexedAt.toIso8601String()}';
                final child = item.count == 1
                    ? NotificationListItem(notification: item.latest)
                    : GroupedNotificationListItem(group: item);
                return StaggeredEntrance(itemKey: key, index: index, seenKeys: _seenNotificationKeys, child: child);
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

  dynamic _getItemAtIndex(BuildContext context, Map<DateTime, List<NotificationGroup>> grouped, int index) {
    int currentIndex = 0;

    for (final entry in grouped.entries) {
      if (currentIndex == index) {
        return _formatDayHeader(context, entry.key);
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

  String _formatDayHeader(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return context.l10n.messageToday;
    } else if (date == yesterday) {
      return context.l10n.messageYesterday;
    }

    return _formatDate(context, date);
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.MMMMd(locale).format(date);
  }
}

class _OfflineNotificationsState extends StatelessWidget {
  const _OfflineNotificationsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: context.colorScheme.outline),
            const SizedBox(height: 12),
            Text(context.l10n.messageNoConnection, style: context.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              context.l10n.messageReconnectToLoadNotifications,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
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
