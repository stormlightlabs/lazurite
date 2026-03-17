import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_getauthorfeed.dart';
import 'package:bluesky/bluesky.dart';

class FeedRepository {
  FeedRepository({required Bluesky bluesky}) : _bluesky = bluesky;

  final Bluesky _bluesky;

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

  Future<FeedResult> getTimeline({String? cursor, int limit = 50}) async {
    final response = await _bluesky.feed.getTimeline(cursor: cursor, limit: limit);

    return FeedResult(posts: response.data.feed, cursor: response.data.cursor);
  }

  Future<FeedResult> getFeed({required AtUri feedUri, String? cursor, int limit = 50}) async {
    final response = await _bluesky.feed.getFeed(feed: feedUri, cursor: cursor, limit: limit);

    return FeedResult(posts: response.data.feed, cursor: response.data.cursor);
  }

  Future<PreferencesResult> getPreferences() async {
    final response = await _bluesky.actor.getPreferences();
    return PreferencesResult(preferences: response.data.preferences);
  }

  Future<void> putPreferences({required List<UPreferences> preferences}) async {
    await _bluesky.actor.putPreferences(preferences: preferences);
  }

  Future<List<GeneratorView>> getSuggestedFeeds({String? cursor, int limit = 50}) async {
    final response = await _bluesky.feed.getSuggestedFeeds(cursor: cursor, limit: limit);
    return response.data.feeds;
  }

  Future<GeneratorView> getFeedGenerator(AtUri feedUri) async {
    final response = await _bluesky.feed.getFeedGenerator(feed: feedUri);
    return response.data.view;
  }

  Future<List<GeneratorView>> getFeedGenerators(List<AtUri> feedUris) async {
    if (feedUris.isEmpty) return [];
    final response = await _bluesky.feed.getFeedGenerators(feeds: feedUris);
    return response.data.feeds;
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

class PreferencesResult {
  PreferencesResult({required this.preferences});
  final List<UPreferences> preferences;
}

enum FeedFilter { postsNoReplies, postsWithMedia, postsAndAuthorThreads }
