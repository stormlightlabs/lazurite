import 'package:lazurite/src/app/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_status_provider.g.dart';

@riverpod
Stream<bool> hasPendingSync(Ref ref) {
  final dao = ref.watch(appDatabaseProvider).preferenceSyncQueueDao;
  return dao.watchPendingItems().map((items) => items.isNotEmpty);
}
