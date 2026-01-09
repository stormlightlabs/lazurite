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

  @override
  Stream<List<GroupedNotification>> build() {
    final repository = ref.watch(notificationsRepositoryProvider);
    final authState = ref.watch(authProvider);

    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) {
      return const Stream.empty();
    }

    _logger.debug('Building grouped notifications stream', {'ownerDid': ownerDid});

    Future.microtask(
      () => refresh().catchError((error, stack) {
        _logger.error('Failed to refresh notifications on build', error, stack);
      }),
    );

    return repository.watchNotifications(ownerDid).map(GroupedNotification.groupNotifications);
  }

  /// Refreshes notifications from the API.
  Future<void> refresh() async {
    final authState = ref.read(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) {
      _logger.debug('Skipping refresh: not authenticated or unknown owner', {});
      return;
    }

    final repository = ref.read(notificationsRepositoryProvider);

    try {
      await repository.fetchNotifications(ownerDid: ownerDid);
      _logger.info('Notifications refreshed', {'ownerDid': ownerDid});
    } catch (error, stack) {
      _logger.error('Failed to refresh notifications', error, stack);
      rethrow;
    }
  }

  /// Loads more notifications using cursor-based pagination.
  Future<void> loadMore() async {
    final authState = ref.read(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) {
      _logger.debug('Skipping loadMore: not authenticated', {});
      return;
    }

    final repository = ref.read(notificationsRepositoryProvider);
    final cursor = await repository.getCursor(ownerDid);

    if (cursor == null) {
      _logger.debug('No cursor available for loadMore', {});
      return;
    }

    try {
      await repository.fetchNotifications(ownerDid: ownerDid, cursor: cursor);
      _logger.info('Loaded more notifications', {'cursor': cursor});
    } catch (error, stack) {
      _logger.error('Failed to load more notifications', error, stack);
      rethrow;
    }
  }

  /// Marks all notifications as read.
  Future<void> markAllAsRead() async {
    final authState = ref.read(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) return;

    final repository = ref.read(notificationsRepositoryProvider);
    final markAsSeenService = ref.read(markAsSeenServiceProvider);

    try {
      await markAsSeenService.flush();

      await repository.markAllAsRead(ownerDid);

      await repository.markAsSeenLocally(DateTime.now(), ownerDid);

      _logger.info('Marked all notifications as read', {});
    } catch (error, stack) {
      _logger.error('Failed to mark all as read', error, stack);
      rethrow;
    }
  }
}
