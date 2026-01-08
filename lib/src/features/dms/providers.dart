import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/providers.dart';
import '../../core/utils/logger_provider.dart';
import '../../infrastructure/network/providers.dart';
import 'infrastructure/dms_repository.dart';
import 'infrastructure/outbox_repository.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
DmsRepository dmsRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return DmsRepository(
    ref.watch(xrpcClientProvider),
    db.dmConvosDao,
    db.dmMessagesDao,
    ref.watch(loggerProvider('DmsRepository')),
  );
}

@Riverpod(keepAlive: true)
OutboxRepository outboxRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return OutboxRepository(
    ref.watch(xrpcClientProvider),
    db.dmOutboxDao,
    db.dmMessagesDao,
    ref.watch(loggerProvider('OutboxRepository')),
  );
}
