import 'package:lazurite/src/features/feeds/application/feed_content_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/logger_provider.dart';
import '../../../infrastructure/db/daos/feed_content_dao.dart';
import '../infrastructure/feed_content_repository.dart';
import '../infrastructure/feed_repository.dart';

part 'feed_content_notifier.g.dart';

/// Notifier for managing feed content (posts from the active feed).
///
/// Watches the active feed and provides a stream of posts from that feed.
/// Supports refresh, load more, and clear operations.
@riverpod
class FeedContentNotifier extends _$FeedContentNotifier {
  @override
  Stream<List<FeedPost>> build(String feedUri) {
    final repository = ref.watch(feedContentRepositoryProvider);
    final logger = ref.watch(loggerProvider('FeedContentNotifier'));

    final feedKey = _feedKeyFromUri(feedUri);
    logger.debug('Watching feed content stream', {'feedKey': feedKey, 'feedUri': feedUri});

    return repository.watchFeedContent(feedKey: feedKey).map((items) {
      logger.debug('Stream emitted', {'itemCount': items.length, 'feedKey': feedKey});
      return items;
    });
  }

  /// Derives a feedKey from a feed URI.
  ///
  /// Uses the internal home feed key for the home feed, otherwise uses the full URI.
  String _feedKeyFromUri(String feedUri) {
    return feedUri == FeedRepository.kHomeFeedUri
        ? FeedContentRepository.kInternalHomeFeedKey
        : feedUri;
  }

  /// Refreshes the current feed content.
  ///
  /// Fetches the latest posts from the active feed and caches them locally.
  Future<void> refresh() async {
    final repository = ref.read(feedContentRepositoryProvider);

    final actualFeedUri = feedUri == FeedRepository.kHomeFeedUri ? null : feedUri;
    await repository.fetchAndCacheFeed(feedUri: actualFeedUri);
  }

  /// Loads more posts for the current feed.
  ///
  /// Fetches the next page using the stored cursor for the active feed.
  Future<void> loadMore() async {
    final repository = ref.read(feedContentRepositoryProvider);

    final feedKey = _feedKeyFromUri(feedUri);
    final cursor = await repository.getCursor(feedKey);

    if (cursor != null) {
      final actualFeedUri = feedUri == FeedRepository.kHomeFeedUri ? null : feedUri;
      await repository.fetchAndCacheFeed(cursor: cursor, feedUri: actualFeedUri);
    }
  }

  /// Clears the content for the current feed.
  ///
  /// Removes all cached items and cursor for the active feed.
  Future<void> clearFeedContent() async {
    final repository = ref.read(feedContentRepositoryProvider);

    final feedKey = _feedKeyFromUri(feedUri);
    await repository.clearFeedContent(feedKey);
  }
}
