import 'dart:convert';

import 'package:atproto_core/atproto_core.dart' show AtUri;
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_getauthorfeed.dart';
import 'package:bluesky/app_bsky_unspecced_defs.dart';
import 'package:flutter/foundation.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/app_view_fallback_service.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/features/feed/data/trending_join.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';

class FeedRepository {
  FeedRepository({
    required dynamic bluesky,
    required AppDatabase database,
    required String accountDid,
    ModerationService? moderationService,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
    bool crossProviderFallbackEnabled = false,
    bool Function()? crossProviderFallbackEnabledResolver,
    AppViewFallbackService? appViewFallbackService,
  }) : _bluesky = bluesky,
       _database = database,
       _accountDid = accountDid,
       _moderationService = moderationService,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       ),
       _crossProviderFallbackEnabled = crossProviderFallbackEnabled,
       _crossProviderFallbackEnabledResolver = crossProviderFallbackEnabledResolver,
       _appViewFallbackService = appViewFallbackService ?? AppViewFallbackService();

  final dynamic _bluesky;
  final AppDatabase _database;
  final String _accountDid;
  final ModerationService? _moderationService;
  final AppViewRequestContext _appViewContext;
  final bool _crossProviderFallbackEnabled;
  final bool Function()? _crossProviderFallbackEnabledResolver;
  final AppViewFallbackService _appViewFallbackService;

  static const String timelineCacheKey = 'timeline';
  static const int _minTrendingLimit = 1;
  static const int _maxTrendingLimit = 25;

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
    final headers = _appViewContext.appBskyHeadersWithoutProxy(await _moderationService?.headersForRequest());
    final response = await _bluesky.actor.getPreferences($headers: headers);
    return PreferencesResult(preferences: response.data.preferences);
  }

  Future<void> putPreferences({required List<UPreferences> preferences}) async {
    final headers = _appViewContext.appBskyHeadersWithoutProxy(await _moderationService?.headersForRequest());
    await _bluesky.actor.putPreferences(preferences: preferences, $headers: headers);
  }

  Future<List<GeneratorView>> getSuggestedFeeds({String? cursor, int limit = 50}) async {
    final response = await _bluesky.feed.getSuggestedFeeds(
      cursor: cursor,
      limit: limit,
      $headers: _appViewContext.appBskyHeaders(await _moderationService?.headersForRequest()),
    );
    return response.data.feeds;
  }

  Future<AtUri> resolveFeedGeneratorUri({required String actor, required String rkey}) async {
    final normalizedActor = actor.trim();
    final normalizedRkey = rkey.trim();
    if (normalizedActor.isEmpty || normalizedRkey.isEmpty) {
      throw ArgumentError('actor and rkey are required to resolve a feed generator URI.');
    }

    if (normalizedActor.startsWith('did:')) {
      return AtUri.parse('at://$normalizedActor/app.bsky.feed.generator/$normalizedRkey');
    }

    final response = await _bluesky.actor.getProfile(
      actor: normalizedActor,
      $headers: _appViewContext.appBskyHeaders(await _moderationService?.headersForRequest()),
    );
    final did = response.data.did.trim();
    if (did.isEmpty) {
      throw StateError('Resolved profile did was empty for actor=$normalizedActor');
    }
    return AtUri.parse('at://$did/app.bsky.feed.generator/$normalizedRkey');
  }

  Future<TrendingScreenData> getTrendingScreenData({int limit = 10}) async {
    final topicsResult = await getTrendingTopics(limit: limit);

    List<TrendView> trends = const [];
    var metadataUnavailable = false;
    try {
      trends = await getTrends(limit: limit);
    } catch (error, stackTrace) {
      metadataUnavailable = true;
      final provider = _appViewContext.resolveProviderKey();
      log.w(
        'trending.getTrends degraded provider=$provider fallback=none reason=$error',
        error: error,
        stackTrace: stackTrace,
      );
    }

    return TrendingScreenData(
      topics: enrichTrendingTopics(topics: topicsResult.topics, trends: trends),
      suggested: enrichTrendingTopics(topics: topicsResult.suggested, trends: trends),
      metadataUnavailable: metadataUnavailable,
    );
  }

  Future<TrendingTopicsResult> getTrendingTopics({int limit = 10}) async {
    final clampedLimit = _clampTrendingLimit(limit);
    return _runPublicReadWithFallback(
      endpointId: 'app.bsky.unspecced.getTrendingTopics',
      request: (context, headers, {required fallbackUsed}) async {
        final response = await _bluesky.unspecced.getTrendingTopics(
          limit: clampedLimit,
          $service: context.publicServiceHost(),
          $headers: headers,
        );
        return TrendingTopicsResult(topics: response.data.topics, suggested: response.data.suggested);
      },
    );
  }

  Future<List<TrendView>> getTrends({int limit = 10}) async {
    final clampedLimit = _clampTrendingLimit(limit);
    return _runPublicReadWithFallback(
      endpointId: 'app.bsky.unspecced.getTrends',
      request: (context, headers, {required fallbackUsed}) async {
        final response = await _bluesky.unspecced.getTrends(
          limit: clampedLimit,
          $service: context.publicServiceHost(),
          $headers: headers,
        );
        return response.data.trends;
      },
    );
  }

  int _clampTrendingLimit(int limit) {
    if (limit < _minTrendingLimit) {
      return _minTrendingLimit;
    }
    if (limit > _maxTrendingLimit) {
      return _maxTrendingLimit;
    }
    return limit;
  }

  Future<T> _runPublicReadWithFallback<T>({
    required String endpointId,
    required Future<T> Function(
      AppViewRequestContext context,
      Map<String, String> headers, {
      required bool fallbackUsed,
    })
    request,
  }) async {
    final fallbackEnabled = _crossProviderFallbackEnabledResolver?.call() ?? _crossProviderFallbackEnabled;
    final baseHeaders = await _moderationService?.headersForRequest();
    return _appViewFallbackService.run(
      endpointId: endpointId,
      primaryProviderKey: _appViewContext.resolveProviderKey(),
      fallbackEnabled: fallbackEnabled,
      baseHeaders: baseHeaders,
      request: request,
    );
  }

  @visibleForTesting
  Future<T> runPublicReadWithFallbackForTest<T>({
    required String endpointId,
    required Future<T> Function(String providerKey) request,
  }) {
    return _runPublicReadWithFallback(
      endpointId: endpointId,
      request: (context, _, {required fallbackUsed}) => request(context.resolveProviderKey()),
    );
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

class TrendingTopicsResult {
  TrendingTopicsResult({required this.topics, required this.suggested});

  final List<TrendingTopic> topics;
  final List<TrendingTopic> suggested;
}

class TrendingScreenData {
  TrendingScreenData({required this.topics, required this.suggested, required this.metadataUnavailable});

  final List<EnrichedTrendingTopic> topics;
  final List<EnrichedTrendingTopic> suggested;
  final bool metadataUnavailable;

  bool get isEmpty => topics.isEmpty && suggested.isEmpty;
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
