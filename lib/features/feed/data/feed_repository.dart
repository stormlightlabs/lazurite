import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_getauthorfeed.dart';

class FeedRepository {
  FeedRepository({required dynamic bluesky}) : _bluesky = bluesky;

  final dynamic _bluesky;

  Future<FeedResult> getAuthorFeed({
    required String actor,
    FeedFilter filter = FeedFilter.postsAndAuthorThreads,
    String? cursor,
    int limit = 50,
  }) async {
    final bskyFilter = _mapToBskyFilter(filter);

    final response = await _bluesky.feed.getAuthorFeed(actor: actor, cursor: cursor, limit: limit, filter: bskyFilter);

    return FeedResult(posts: response.data.feed, cursor: response.data.cursor);
  }

  FeedGetAuthorFeedFilter? _mapToBskyFilter(FeedFilter filter) {
    switch (filter) {
      case FeedFilter.postsNoReplies:
        return const FeedGetAuthorFeedFilter.knownValue(data: KnownFeedGetAuthorFeedFilter.posts_no_replies);
      case FeedFilter.postsWithMedia:
        return const FeedGetAuthorFeedFilter.knownValue(data: KnownFeedGetAuthorFeedFilter.posts_with_media);
      case FeedFilter.postsAndAuthorThreads:
        return const FeedGetAuthorFeedFilter.knownValue(data: KnownFeedGetAuthorFeedFilter.posts_and_author_threads);
    }
  }
}

class FeedResult {
  FeedResult({required this.posts, this.cursor});
  final List<FeedViewPost> posts;
  final String? cursor;
}

enum FeedFilter { postsNoReplies, postsWithMedia, postsAndAuthorThreads }
