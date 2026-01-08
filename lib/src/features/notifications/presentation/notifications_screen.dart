import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/animations/animation_utils.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/pull_to_refresh_wrapper.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/notifications/application/notifications_notifier.dart';
import 'package:lazurite/src/features/notifications/presentation/widgets/notification_list_item_skeleton.dart';

import 'widgets/grouped_notification_item.dart';

/// Notifications screen displaying the user's notifications.
///
/// Features:
/// - Pull-to-refresh to fetch new notifications
/// - Infinite scroll with cursor-based pagination
/// - Loading, error, and empty states
/// - Tap navigation to thread or profile
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasTriggeredInitialLoad = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState is AuthStateAuthenticated;

    if (!isAuthenticated) {
      return _buildUnauthenticatedState(context);
    }

    final notificationsAsync = ref.watch(notificationsProvider);

    if (!_hasTriggeredInitialLoad) {
      _hasTriggeredInitialLoad = true;
      Future.microtask(() {
        if (mounted) {
          ref.read(notificationsProvider.notifier).refresh();
        }
      });
    }

    return Scaffold(
      body: AnimatedContentSwitcher(
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return _buildEmptyState(context);
            }

            return PullToRefreshWrapper(
              key: const ValueKey('notifications_list'),
              onRefresh: () async {
                await ref.read(notificationsProvider.notifier).refresh();
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    title: const Text('Notifications'),
                    floating: true,
                    snap: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.done_all),
                        tooltip: 'Mark all as read',
                        onPressed: () {
                          ref.read(notificationsProvider.notifier).markAllAsRead();
                        },
                      ),
                    ],
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return AnimatedItem(
                        index: index,
                        child: GroupedNotificationItem(group: notifications[index]),
                      );
                    }, childCount: notifications.length),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                ],
              ),
            );
          },
          loading: () => Scaffold(
            key: const ValueKey('loading'),
            appBar: AppBar(title: const Text('Notifications')),
            body: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) => const NotificationListItemSkeleton(),
            ),
          ),
          error: (err, stack) => ErrorView(
            key: const ValueKey('error'),
            title: 'Failed to load notifications',
            message: err.toString(),
            onRetry: () => ref.read(notificationsProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedState(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.bell, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Notifications', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Sign in to see your notifications',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.bell, size: 64, color: theme.colorScheme.onSurface.withAlpha(102)),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When someone interacts with you, it will show up here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(102),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
