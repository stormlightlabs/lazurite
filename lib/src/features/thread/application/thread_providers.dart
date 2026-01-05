import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/infrastructure/db/daos/timeline_dao.dart';
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

@riverpod
Stream<List<TimelineFeedItem>> threadCache(Ref ref, String postUri) {
  final db = ref.watch(appDatabaseProvider);
  return db.timelineDao.watchTimeline('thread:$postUri');
}
