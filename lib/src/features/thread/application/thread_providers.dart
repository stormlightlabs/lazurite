import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/thread_repository.dart';

part 'thread_providers.g.dart';

@riverpod
ThreadRepository threadRepository(Ref ref) {
  final api = ref.watch(xrpcClientProvider);
  final db = ref.watch(appDatabaseProvider);
  final logger = ref.watch(loggerProvider('ThreadRepository'));
  return ThreadRepository(api, db.timelineDao, logger);
}
