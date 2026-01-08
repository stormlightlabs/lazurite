import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/notifications_repository.dart';
import 'mark_as_seen_service.dart';

part 'notifications_providers.g.dart';

/// Provides the NotificationsRepository instance.
@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  final client = ref.watch(xrpcClientProvider);
  final dao = ref.watch(appDatabaseProvider).notificationsDao;
  final syncQueue = ref.watch(appDatabaseProvider).notificationsSyncQueueDao;
  final logger = ref.watch(loggerProvider('NotificationsRepository'));
  return NotificationsRepository(client, dao, syncQueue, logger);
}

/// Provides the MarkAsSeenService instance.
///
/// This service batches mark as seen operations to avoid excessive API calls.
@Riverpod(keepAlive: true)
MarkAsSeenService markAsSeenService(Ref ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  final syncQueue = ref.watch(appDatabaseProvider).notificationsSyncQueueDao;
  final logger = ref.watch(loggerProvider('MarkAsSeenService'));
  final service = MarkAsSeenService(repository, syncQueue, logger);

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}
