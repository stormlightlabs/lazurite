import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/thread_repository.dart';

part 'thread_providers.g.dart';

@riverpod
ThreadRepository threadRepository(Ref ref) {
  final api = ref.watch(xrpcClientProvider);
  final db = ref.watch(appDatabaseProvider);
  final logger = ref.watch(loggerProvider('ThreadRepository'));
  return ThreadRepository(api, db.feedContentDao, logger);
}

@riverpod
Stream<List<FeedPost>> threadCache(Ref ref, String postUri) {
  final db = ref.watch(appDatabaseProvider);
  final authState = ref.watch(authProvider);
  final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : 'anonymous';
  return db.feedContentDao.watchFeedContent('thread:$postUri', ownerDid);
}
