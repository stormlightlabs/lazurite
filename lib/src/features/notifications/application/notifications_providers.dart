import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/notifications_repository.dart';

part 'notifications_providers.g.dart';

/// Provides the NotificationsRepository instance.
@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  final client = ref.watch(xrpcClientProvider);
  final dao = ref.watch(appDatabaseProvider).notificationsDao;
  final logger = ref.watch(loggerProvider('NotificationsRepository'));
  return NotificationsRepository(client, dao, logger);
}
