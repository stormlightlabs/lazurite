import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/logger_provider.dart';
import '../../../features/auth/application/auth_providers.dart';
import '../../../features/auth/domain/auth_state.dart';
import 'notifications_providers.dart';

part 'unread_count_notifier.g.dart';

/// Notifier for managing unread notification count.
///
/// Watches the unread count stream from the database and provides
/// reactive updates when notifications are marked as read.
@riverpod
class UnreadCountNotifier extends _$UnreadCountNotifier {
  @override
  Stream<int> build() {
    final logger = ref.read(loggerProvider('UnreadCountNotifier'));
    final authState = ref.watch(authProvider);
    final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

    if (ownerDid == null) {
      logger.debug('Not authenticated, returning 0 unread count', {});
      return Stream.value(0);
    }

    final repository = ref.watch(notificationsRepositoryProvider);
    logger.debug('Building unread count stream', {});
    return repository.watchUnreadCount(ownerDid);
  }
}
