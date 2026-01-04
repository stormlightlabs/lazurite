import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/providers.dart';
import '../../../infrastructure/network/providers.dart';
import '../infrastructure/timeline_repository.dart';

part 'timeline_providers.g.dart';

@riverpod
TimelineRepository timelineRepository(Ref ref) {
  final api = ref.watch(xrpcClientProvider);
  final db = ref.watch(appDatabaseProvider);
  return TimelineRepository(api, db.timelineDao);
}
