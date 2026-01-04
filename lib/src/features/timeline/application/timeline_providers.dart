import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/timeline/infrastructure/timeline_repository.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timeline_providers.g.dart';

@riverpod
TimelineRepository timelineRepository(Ref ref) {
  final api = ref.watch(xrpcClientProvider);
  final db = ref.watch(appDatabaseProvider);
  final logger = ref.watch(loggerProvider('TimelineRepository'));
  return TimelineRepository(api, db.timelineDao, logger);
}
