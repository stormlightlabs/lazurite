import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/logger.dart';
import '../../../core/utils/logger_provider.dart';
import '../../../features/auth/application/auth_providers.dart';
import '../../../features/auth/domain/auth_state.dart';
import '../domain/grouped_notification.dart';
import 'notifications_providers.dart';

part 'notifications_notifier.g.dart';

/// Notifier for managing notification list state.
///
/// Watches the notifications stream and provides methods for
/// refresh and load more pagination. Returns grouped notifications
/// for compact display.
@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  Logger get _logger => ref.read(loggerProvider('NotificationsNotifier'));

  bool get _isAuthenticated => ref.read(authProvider) is AuthStateAuthenticated;

  @override
  Stream<List<GroupedNotification>> build() {
    final repository = ref.watch(notificationsRepositoryProvider);
    _logger.debug('Building grouped notifications stream', {});
    return repository.watchNotifications().map(GroupedNotification.groupNotifications);
  }

  /// Refreshes notifications from the API.
  ///
  /// Fetches the latest notifications and updates the local cache.
  Future<void> refresh() async {
    if (!_isAuthenticated) {
      _logger.debug('Skipping refresh: not authenticated', {});
      return;
    }

    final repository = ref.read(notificationsRepositoryProvider);

    try {
      await repository.fetchNotifications();
      _logger.info('Notifications refreshed', {});
    } catch (error, stack) {
      _logger.error('Failed to refresh notifications', error, stack);
      rethrow;
    }
  }

  /// Loads more notifications using cursor-based pagination.
  Future<void> loadMore() async {
    if (!_isAuthenticated) {
      _logger.debug('Skipping loadMore: not authenticated', {});
      return;
    }

    final repository = ref.read(notificationsRepositoryProvider);
    final cursor = await repository.getCursor();

    if (cursor == null) {
      _logger.debug('No cursor available for loadMore', {});
      return;
    }

    try {
      await repository.fetchNotifications(cursor: cursor);
      _logger.info('Loaded more notifications', {'cursor': cursor});
    } catch (error, stack) {
      _logger.error('Failed to load more notifications', error, stack);
      rethrow;
    }
  }

  /// Marks all notifications as read.
  ///
  /// This flushes any pending mark as seen operations, then marks all
  /// notifications as read locally and syncs with the server.
  Future<void> markAllAsRead() async {
    final repository = ref.read(notificationsRepositoryProvider);
    final markAsSeenService = ref.read(markAsSeenServiceProvider);

    try {
      await markAsSeenService.flush();

      await repository.markAllAsRead();

      await repository.updateSeen(DateTime.now());

      _logger.info('Marked all notifications as read', {});
    } catch (error, stack) {
      _logger.error('Failed to mark all as read', error, stack);
      rethrow;
    }
  }
}
