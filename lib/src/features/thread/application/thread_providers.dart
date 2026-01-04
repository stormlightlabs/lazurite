import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/providers.dart';
import '../../../infrastructure/network/providers.dart';
import '../infrastructure/thread_repository.dart';

part 'thread_providers.g.dart';

@riverpod
ThreadRepository threadRepository(Ref ref) {
  final api = ref.watch(xrpcClientProvider);
  final db = ref.watch(appDatabaseProvider);
  return ThreadRepository(api, db.timelineDao);
}
