import 'package:poptart_core/poptart_core.dart' as atcore show AtUri;
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/embed/record.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/get_author_feed.dart';
import 'package:bluesky_poptart/app/bsky/unspecced/defs.dart';
import 'package:flutter/foundation.dart';
import 'package:lazurite/core/cache/poptart_cache_codecs.dart';
import 'package:lazurite/core/cache/offline_cache_policy.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/app_view_fallback_service.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/unauthorized_recovery_runner.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/feed/data/trending_join.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';

class FeedRepository {
  FeedRepository({
    required Bluesky bluesky,
    required AppDatabase database,
    required String accountDid,
    ModerationService? moderationService,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
    bool crossProviderFallbackEnabled = false,
    bool Function()? crossProviderFallbackEnabledResolver,
    AppViewFallbackService? appViewFallbackService,
    int routingEpoch = 0,
    int Function()? routingEpochResolver,
    Future<AuthTokens?> Function()? onUnauthorized,
    Bluesky? Function(AuthTokens tokens)? blueskyClientFactory,
  }) : _database = database,
       _accountDid = accountDid,
       _moderationService = moderationService,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       ),
       _crossProviderFallbackEnabled = crossProviderFallbackEnabled,
       _crossProviderFallbackEnabledResolver = crossProviderFallbackEnabledResolver,
       _appViewFallbackService = appViewFallbackService ?? AppViewFallbackService(),
       _routingEpoch = routingEpoch,
       _routingEpochResolver = routingEpochResolver {
    _authRecovery = UnauthorizedRecoveryRunner<Bluesky>(
      initialClient: bluesky,
      onUnauthorized: onUnauthorized,
      clientFactory: blueskyClientFactory ?? createBlueskyClient,
      onUnauthorizedException: (error, stackTrace) {
        log.w('feed.auth unauthorized; attempting session recovery', error: error, stackTrace: stackTrace);
      },
    );
  }

  late final UnauthorizedRecoveryRunner<Bluesky> _authRecovery;
  final AppDatabase _database;
  final String _accountDid;
  final ModerationService? _moderationService;
  final AppViewRequestContext _appViewContext;
  final bool _crossProviderFallbackEnabled;
  final bool Function()? _crossProviderFallbackEnabledResolver;
  final AppViewFallbackService _appViewFallbackService;
  final int _routingEpoch;
  final int Function()? _routingEpochResolver;
  List<UPreferences>? _preferencesCache;

  static const String timelineCacheKey = 'timeline';
  static const String homeFeedPreferenceId = 'home';
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
    final headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.feed.getAuthorFeed',
      await _moderationService?.headersForRequest(),
    );

    final response = await _authRecovery.run(
      (client) =>
          client.feed.getAuthorFeed(actor: actor, cursor: cursor, limit: limit, filter: bskyFilter, $headers: headers),
    );

    return FeedResult(posts: _filterModeratedFeedPosts(response.data.feed), cursor: response.data.cursor);
  }

  Future<FeedResult> getTimeline({String? cursor, int limit = 50}) async {
    final headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.feed.getTimeline',
      await _moderationService?.headersForRequest(),
    );
    final response = await _authRecovery.run(
      (client) => client.feed.getTimeline(cursor: cursor, limit: limit, $headers: headers),
    );

    final moderatedPosts = _filterModeratedFeedPosts(response.data.feed);
    final rawResult = FeedResult(posts: moderatedPosts, cursor: response.data.cursor);
    await _cacheFeedWindow(feedKey: timelineCacheKey, result: rawResult, cursor: cursor);
    return FeedResult(
      posts: filterFeedViewPostsByPreference(
        moderatedPosts,
        await _feedViewPreferenceFor(homeFeedPreferenceId),
        currentAccountDid: _accountDid,
      ),
      cursor: response.data.cursor,
    );
  }

  Future<FeedResult> getFeed({required atcore.AtUri feedUri, String? cursor, int limit = 50}) async {
    final headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.feed.getFeed',
      await _moderationService?.headersForRequest(),
    );
    final response = await _authRecovery.run(
      (client) => client.feed.getFeed(feed: feedUri, cursor: cursor, limit: limit, $headers: headers),
    );

    final feedPreferenceId = feedUri.toString();
    final moderatedPosts = _filterModeratedFeedPosts(response.data.feed);
    final rawResult = FeedResult(posts: moderatedPosts, cursor: response.data.cursor);
    await _cacheFeedWindow(feedKey: 'feed:$feedPreferenceId', result: rawResult, cursor: cursor);
    return rawResult;
  }

  Future<FeedResult?> getCachedFeedPage(String feedKey) async {
    final cachedPosts = await _database.getCachedFeedPosts(_accountDid, feedKey);
    if (cachedPosts.isEmpty) {
      return null;
    }

    final posts = <FeedViewPost>[];
    for (final entry in cachedPosts) {
      try {
        posts.add(PoptartCacheCodecs.feedViewPost.decode(entry.postJson));
      } catch (error, stackTrace) {
        log.w(
          'feed.getCachedFeedPage decode failed account=$_accountDid feedKey=$feedKey postUri=${entry.postUri}',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    if (posts.isEmpty) {
      return null;
    }

    final pageMeta = await _database.getCachedFeedPage(_accountDid, feedKey);
    String? cursor;
    if (pageMeta != null) {
      try {
        cursor = PoptartCacheCodecs.decodeFeedPageCursor(pageMeta.payload);
      } catch (error, stackTrace) {
        log.w(
          'feed.getCachedFeedPage pageMeta decode failed account=$_accountDid feedKey=$feedKey',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (feedKey != timelineCacheKey) {
      return FeedResult(posts: posts, cursor: cursor);
    }

    return FeedResult(
      posts: filterFeedViewPostsByPreference(
        posts,
        await _feedViewPreferenceFor(homeFeedPreferenceId),
        currentAccountDid: _accountDid,
      ),
      cursor: cursor,
    );
  }

  Future<PreferencesResult> getPreferences() async {
    final headers = _appViewContext.appBskyHeadersWithoutProxy(await _moderationService?.headersForRequest());
    final response = await _authRecovery.run((client) => client.actor.getPreferences($headers: headers));
    _preferencesCache = response.data.preferences;
    return PreferencesResult(preferences: response.data.preferences);
  }

  Future<void> putPreferences({required List<UPreferences> preferences}) async {
    final headers = _appViewContext.appBskyHeadersWithoutProxy(await _moderationService?.headersForRequest());
    await _authRecovery.run((client) => client.actor.putPreferences(preferences: preferences, $headers: headers));
    _preferencesCache = preferences;
  }

  Future<List<GeneratorView>> getSuggestedFeeds({String? cursor, int limit = 50}) async {
    final headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.feed.getSuggestedFeeds',
      await _moderationService?.headersForRequest(),
    );
    final response = await _authRecovery.run(
      (client) => client.feed.getSuggestedFeeds(cursor: cursor, limit: limit, $headers: headers),
    );
    return response.data.feeds;
  }

  Future<atcore.AtUri> resolveFeedGeneratorUri({required String actor, required String rkey}) async {
    final normalizedActor = actor.trim();
    final normalizedRkey = rkey.trim();
    if (normalizedActor.isEmpty || normalizedRkey.isEmpty) {
      throw ArgumentError('actor and rkey are required to resolve a feed generator URI.');
    }

    if (normalizedActor.startsWith('did:')) {
      return atcore.AtUri.parse('at://$normalizedActor/app.bsky.feed.generator/$normalizedRkey');
    }

    final headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.actor.getProfile',
      await _moderationService?.headersForRequest(),
    );
    final response = await _authRecovery.run(
      (client) => client.actor.getProfile(actor: normalizedActor, $headers: headers),
    );
    final did = response.data.did.trim();
    if (did.isEmpty) {
      throw StateError('Resolved profile did was empty for actor=$normalizedActor');
    }
    return atcore.AtUri.parse('at://$did/app.bsky.feed.generator/$normalizedRkey');
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
        final response = await _authRecovery.client.unspecced.getTrendingTopics(
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
        final response = await _authRecovery.client.unspecced.getTrends(
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
      routingEpoch: _routingEpoch,
      routingEpochResolver: _routingEpochResolver ?? () => _routingEpoch,
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

  Future<GeneratorView> getFeedGenerator(atcore.AtUri feedUri) async {
    final headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.feed.getFeedGenerator',
      await _moderationService?.headersForRequest(),
    );
    final response = await _authRecovery.run(
      (client) => client.feed.getFeedGenerator(feed: feedUri, $headers: headers),
    );
    return response.data.view;
  }

  Future<List<GeneratorView>> getFeedGenerators(List<atcore.AtUri> feedUris) async {
    if (feedUris.isEmpty) return [];
    final headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.feed.getFeedGenerators',
      await _moderationService?.headersForRequest(),
    );
    final response = await _authRecovery.run(
      (client) => client.feed.getFeedGenerators(feeds: feedUris, $headers: headers),
    );
    return response.data.feeds;
  }

  List<FeedViewPost> _filterModeratedFeedPosts(List<FeedViewPost> posts) {
    final moderationService = _moderationService;
    if (moderationService == null) {
      return posts;
    }

    return posts.where((post) => !moderationService.shouldFilterFeedViewPostInList(post)).toList();
  }

  Future<FeedViewPref?> _feedViewPreferenceFor(String feed) async {
    if (_preferencesCache != null) {
      return _cachedFeedViewPreferenceFor(feed);
    }

    try {
      final result = await getPreferences();
      return _feedViewPreferenceFrom(result.preferences, feed);
    } catch (error, stackTrace) {
      log.w(
        'feed.feedViewPreference unavailable account=$_accountDid feed=$feed',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  FeedViewPref? _cachedFeedViewPreferenceFor(String feed) {
    final preferences = _preferencesCache;
    if (preferences == null) {
      return null;
    }
    return _feedViewPreferenceFrom(preferences, feed);
  }

  FeedViewPref? _feedViewPreferenceFrom(List<UPreferences> preferences, String feed) {
    for (final preference in preferences) {
      final feedViewPref = preference.feedViewPref;
      if (feedViewPref != null && feedViewPref.feed == feed) {
        return feedViewPref;
      }
    }
    return null;
  }

  /// When refreshing, the newest page goes first
  ///
  /// Cache writes are best-effort and must never break feed rendering.
  Future<void> _cacheFeedWindow({required String feedKey, required FeedResult result, required String? cursor}) async {
    try {
      await _database.runSerializedWrite(() async {
        final existingPosts = await _database.getCachedFeedPosts(_accountDid, feedKey);

        final merged = <FeedViewPost>[];
        final seen = <String>{};

        void addPost(FeedViewPost post) {
          final uri = post.post.uri.toString();
          if (seen.add(uri)) {
            merged.add(post);
          }
        }

        if (cursor == null) {
          for (final post in result.posts) {
            addPost(post);
          }
          for (final cached in existingPosts) {
            if (seen.contains(cached.postUri)) {
              continue;
            }
            try {
              addPost(PoptartCacheCodecs.feedViewPost.decode(cached.postJson));
            } catch (error, stackTrace) {
              log.w(
                'feed.cacheWindow decode failed account=$_accountDid feedKey=$feedKey postUri=${cached.postUri}',
                error: error,
                stackTrace: stackTrace,
              );
            }
          }
        } else {
          for (final cached in existingPosts) {
            try {
              addPost(PoptartCacheCodecs.feedViewPost.decode(cached.postJson));
            } catch (error, stackTrace) {
              log.w(
                'feed.cacheWindow decode failed account=$_accountDid feedKey=$feedKey postUri=${cached.postUri}',
                error: error,
                stackTrace: stackTrace,
              );
            }
          }
          for (final post in result.posts) {
            addPost(post);
          }
        }

        final limited = merged.take(OfflineCachePolicy.feedPostLimit).toList(growable: false);
        final companions = <CachedFeedPostsCompanion>[];
        for (var i = 0; i < limited.length; i++) {
          final post = limited[i];
          final uri = post.post.uri.toString();
          final sortOrder = OfflineCachePolicy.feedPostLimit - i;
          companions.add(
            CachedFeedPostsCompanion.insert(
              accountDid: _accountDid,
              feedKey: feedKey,
              postUri: uri,
              postJson: PoptartCacheCodecs.feedViewPost.encode(post),
              sortOrder: sortOrder,
            ),
          );
        }

        await _database.transaction(() async {
          await _database.deleteCachedFeedPostsForFeed(_accountDid, feedKey);
          await _database.upsertCachedFeedPosts(accountDid: _accountDid, feedKey: feedKey, posts: companions);
          await _database.cacheFeedPage(
            accountDid: _accountDid,
            feedKey: feedKey,
            payload: PoptartCacheCodecs.encodeFeedPageMetadata(cursor: result.cursor, lastRequestCursor: cursor),
          );
        });
      });
    } catch (error, stackTrace) {
      log.w(
        'feed.cacheWindow failed account=$_accountDid feedKey=$feedKey cursor=$cursor reason=$error',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

@visibleForTesting
List<FeedViewPost> filterFeedViewPostsByPreference(
  List<FeedViewPost> posts,
  FeedViewPref? preference, {
  String? currentAccountDid,
}) {
  if (preference == null) {
    return posts;
  }

  return posts
      .where((feedViewPost) {
        if (preference.hideReposts == true && feedViewPost.reason?.isReasonRepost == true) {
          return false;
        }

        final isReply = _isReply(feedViewPost);
        if (isReply) {
          if (preference.hideReplies == true) {
            return false;
          }
          if (preference.hideRepliesByUnfollowed && !_isSelfOrFollowed(feedViewPost.post.author, currentAccountDid)) {
            return false;
          }

          final likeThreshold = preference.hideRepliesByLikeCount;
          if (likeThreshold != null && (feedViewPost.post.likeCount ?? 0) < likeThreshold) {
            return false;
          }
        }

        if (preference.hideQuotePosts == true && _isQuotePost(feedViewPost.post.embed)) {
          return false;
        }

        return true;
      })
      .toList(growable: false);
}

bool _isReply(FeedViewPost feedViewPost) => feedViewPost.reply != null || feedViewPost.post.record['reply'] != null;

bool _isSelfOrFollowed(ProfileViewBasic author, String? currentAccountDid) {
  if (author.did == currentAccountDid) {
    return true;
  }
  return author.viewer?.following != null;
}

bool _isQuotePost(UPostViewEmbed? embed) {
  if (embed == null) {
    return false;
  }
  if (embed.isEmbedRecordWithMediaView) {
    return true;
  }
  final record = embed.embedRecordView?.record;
  return record != null &&
      (record.isEmbedRecordViewRecord ||
          record.isEmbedRecordViewNotFound ||
          record.isEmbedRecordViewBlocked ||
          record.isEmbedRecordViewDetached);
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
  postsWithReplies,
  postsNoReplies,
  postsWithMedia,
  postsAndAuthorThreads;

  String get emptyLabel {
    switch (this) {
      case FeedFilter.postsWithReplies:
        return 'No posts or replies yet';
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
      case FeedFilter.postsWithReplies:
        return const FeedGetAuthorFeedFilter.knownValue(data: KnownFeedGetAuthorFeedFilter.posts_with_replies);
      case FeedFilter.postsNoReplies:
        return const FeedGetAuthorFeedFilter.knownValue(data: KnownFeedGetAuthorFeedFilter.posts_no_replies);
      case FeedFilter.postsWithMedia:
        return const FeedGetAuthorFeedFilter.knownValue(data: KnownFeedGetAuthorFeedFilter.posts_with_media);
      case FeedFilter.postsAndAuthorThreads:
        return const FeedGetAuthorFeedFilter.knownValue(data: KnownFeedGetAuthorFeedFilter.posts_and_author_threads);
    }
  }
}
