import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/logger.dart';
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
  Logger get _logger => ref.read(loggerProvider('UnreadCountNotifier'));

  bool get _isAuthenticated => ref.read(authProvider) is AuthStateAuthenticated;

  @override
  Stream<int> build() {
    if (!_isAuthenticated) {
      _logger.debug('Not authenticated, returning 0 unread count', {});
      return Stream.value(0);
    }

    final repository = ref.watch(notificationsRepositoryProvider);
    _logger.debug('Building unread count stream', {});
    return repository.watchUnreadCount();
  }
}
