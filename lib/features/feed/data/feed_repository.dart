import 'dart:convert';

import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_getauthorfeed.dart';
import 'package:bluesky/bluesky.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';

class FeedRepository {
  FeedRepository({
    required Bluesky bluesky,
    required AppDatabase database,
    required String accountDid,
    ModerationService? moderationService,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
  }) : _bluesky = bluesky,
       _database = database,
       _accountDid = accountDid,
       _moderationService = moderationService,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       );

  final Bluesky _bluesky;
  final AppDatabase _database;
  final String _accountDid;
  final ModerationService? _moderationService;
  final AppViewRequestContext _appViewContext;

  static const String timelineCacheKey = 'timeline';

  static String cacheKeyForSavedFeed(SavedFeed feed) {
    final feedType = feed.type;
    if (feedType is SavedFeedTypeKnownValue && feedType.data == KnownSavedFeedType.timeline) {
      return timelineCacheKey;
    }

    return 'feed:${feed.value}';
  }

  Future<FeedResult> getAuthorFeed({
    required String actor,
    FeedFilter filter = FeedFilter.postsAndAuthorThreads,
    String? cursor,
    int limit = 50,
  }) async {
    final bskyFilter = filter.bskyFilter;
    final headers = _appViewContext.appBskyHeaders(await _moderationService?.headersForRequest());

    final response = await _bluesky.feed.getAuthorFeed(
      actor: actor,
      cursor: cursor,
      limit: limit,
      filter: bskyFilter,
      $headers: headers,
    );

    return FeedResult(posts: _filterFeedPosts(response.data.feed), cursor: response.data.cursor);
  }

  Future<FeedResult> getTimeline({String? cursor, int limit = 50}) async {
    final response = await _bluesky.feed.getTimeline(
      cursor: cursor,
      limit: limit,
      $headers: _appViewContext.appBskyHeaders(await _moderationService?.headersForRequest()),
    );

    final result = FeedResult(posts: _filterFeedPosts(response.data.feed), cursor: response.data.cursor);
    await _cacheFirstPageIfNeeded(feedKey: timelineCacheKey, result: result, cursor: cursor);
    return result;
  }

  Future<FeedResult> getFeed({required AtUri feedUri, String? cursor, int limit = 50}) async {
    final response = await _bluesky.feed.getFeed(
      feed: feedUri,
      cursor: cursor,
      limit: limit,
      $headers: _appViewContext.appBskyHeaders(await _moderationService?.headersForRequest()),
    );

    final result = FeedResult(posts: _filterFeedPosts(response.data.feed), cursor: response.data.cursor);
    await _cacheFirstPageIfNeeded(feedKey: 'feed:${feedUri.toString()}', result: result, cursor: cursor);
    return result;
  }

  Future<FeedResult?> getCachedFeedPage(String feedKey) async {
    final cached = await _database.getCachedFeedPage(_accountDid, feedKey);
    if (cached == null) {
      return null;
    }

    final decoded = jsonDecode(cached.payload) as Map<String, dynamic>;
    final rawPosts = decoded['posts'] as List<dynamic>? ?? const [];
    final posts = rawPosts
        .map((entry) => FeedViewPost.fromJson(Map<String, dynamic>.from(entry as Map)))
        .toList(growable: false);

    return FeedResult(posts: posts, cursor: decoded['cursor'] as String?);
  }

  Future<PreferencesResult> getPreferences() async {
    final response = await _bluesky.actor.getPreferences(
      $headers: _appViewContext.appBskyHeaders(await _moderationService?.headersForRequest()),
    );
    return PreferencesResult(preferences: response.data.preferences);
  }

  Future<void> putPreferences({required List<UPreferences> preferences}) async {
    await _bluesky.actor.putPreferences(
      preferences: preferences,
      $headers: _appViewContext.appBskyHeaders(await _moderationService?.headersForRequest()),
    );
  }

  Future<List<GeneratorView>> getSuggestedFeeds({String? cursor, int limit = 50}) async {
    final response = await _bluesky.feed.getSuggestedFeeds(
      cursor: cursor,
      limit: limit,
      $headers: _appViewContext.appBskyHeaders(await _moderationService?.headersForRequest()),
    );
    return response.data.feeds;
  }

  Future<GeneratorView> getFeedGenerator(AtUri feedUri) async {
    final response = await _bluesky.feed.getFeedGenerator(
      feed: feedUri,
      $headers: _appViewContext.appBskyHeaders(await _moderationService?.headersForRequest()),
    );
    return response.data.view;
  }

  Future<List<GeneratorView>> getFeedGenerators(List<AtUri> feedUris) async {
    if (feedUris.isEmpty) return [];
    final response = await _bluesky.feed.getFeedGenerators(
      feeds: feedUris,
      $headers: _appViewContext.appBskyHeaders(await _moderationService?.headersForRequest()),
    );
    return response.data.feeds;
  }

  List<FeedViewPost> _filterFeedPosts(List<FeedViewPost> posts) {
    final moderationService = _moderationService;
    if (moderationService == null) {
      return posts;
    }

    return posts.where((post) => !moderationService.shouldFilterFeedViewPostInList(post)).toList();
  }

  Future<void> _cacheFirstPageIfNeeded({
    required String feedKey,
    required FeedResult result,
    required String? cursor,
  }) async {
    if (cursor != null) {
      return;
    }

    await _database.cacheFeedPage(
      accountDid: _accountDid,
      feedKey: feedKey,
      payload: jsonEncode({
        'cursor': result.cursor,
        'posts': result.posts.map((post) => post.toJson()).toList(growable: false),
      }),
    );
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

enum FeedFilter {
  postsNoReplies,
  postsWithMedia,
  postsAndAuthorThreads;

  String get emptyLabel {
    switch (this) {
      case FeedFilter.postsNoReplies:
        return 'No posts yet';
      case FeedFilter.postsAndAuthorThreads:
        return 'No replies or threads yet';
      case FeedFilter.postsWithMedia:
        return 'No media posts yet';
    }
  }

  FeedGetAuthorFeedFilter get bskyFilter {
    switch (this) {
      case FeedFilter.postsNoReplies:
        return const FeedGetAuthorFeedFilter.knownValue(data: KnownFeedGetAuthorFeedFilter.posts_no_replies);
      case FeedFilter.postsWithMedia:
        return const FeedGetAuthorFeedFilter.knownValue(data: KnownFeedGetAuthorFeedFilter.posts_with_media);
      case FeedFilter.postsAndAuthorThreads:
        return const FeedGetAuthorFeedFilter.knownValue(data: KnownFeedGetAuthorFeedFilter.posts_and_author_threads);
    }
  }
}
