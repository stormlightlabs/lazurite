import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/feeds/application/feed_providers.dart';
import '../../../infrastructure/db/daos/timeline_dao.dart';
import 'timeline_providers.dart';

part 'timeline_notifier.g.dart';

@riverpod
class TimelineNotifier extends _$TimelineNotifier {
  @override
  Stream<List<TimelineFeedItem>> build() {
    final activeFeedUri = ref.watch(activeFeedProvider);
    final repository = ref.watch(timelineRepositoryProvider);

    final feedKey = _feedKeyFromUri(activeFeedUri);
    return repository.watchTimeline(feedKey: feedKey);
  }

  /// Derives a feedKey from a feed URI.
  ///
  /// Uses 'home' for the home feed, otherwise uses the full URI.
  String _feedKeyFromUri(String feedUri) {
    return feedUri == 'home' ? 'home' : feedUri;
  }

  /// Refreshes the current timeline.
  ///
  /// Fetches the latest posts from the active feed and caches them locally.
  Future<void> refresh() async {
    final activeFeedUri = ref.read(activeFeedProvider);
    final repository = ref.read(timelineRepositoryProvider);

    final feedUri = activeFeedUri == 'home' ? null : activeFeedUri;
    await repository.fetchAndCacheTimeline(feedUri: feedUri);
  }

  /// Loads more posts for the current timeline.
  ///
  /// Fetches the next page using the stored cursor for the active feed.
  Future<void> loadMore() async {
    final activeFeedUri = ref.read(activeFeedProvider);
    final repository = ref.read(timelineRepositoryProvider);

    final feedKey = _feedKeyFromUri(activeFeedUri);
    final cursor = await repository.getCursor(feedKey);

    if (cursor != null) {
      final feedUri = activeFeedUri == 'home' ? null : activeFeedUri;
      await repository.fetchAndCacheTimeline(cursor: cursor, feedUri: feedUri);
    }
  }

  /// Clears the timeline for the current feed.
  ///
  /// Removes all cached items and cursor for the active feed.
  Future<void> clearTimeline() async {
    final activeFeedUri = ref.read(activeFeedProvider);
    final repository = ref.read(timelineRepositoryProvider);

    final feedKey = _feedKeyFromUri(activeFeedUri);
    await repository.clearTimeline(feedKey);
  }
}
