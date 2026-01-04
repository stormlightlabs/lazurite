import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/db/daos/timeline_dao.dart';
import 'timeline_providers.dart';

part 'timeline_notifier.g.dart';

@riverpod
class TimelineNotifier extends _$TimelineNotifier {
  @override
  Stream<List<TimelineFeedItem>> build() {
    final repository = ref.watch(timelineRepositoryProvider);
    return repository.watchTimeline();
  }

  // TODO: implement pull-to-refresh logic
  Future<void> refresh() async {
    final repository = ref.read(timelineRepositoryProvider);
    await repository.fetchAndCacheTimeline();
  }

  /// TODO: Get last cursor from DB and fetch next page
  /// We need to expose `getCursor` in repository
  Future<void> loadMore() async {}
}
