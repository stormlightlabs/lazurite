import 'dart:convert';

import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_searchposts.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:flutter/foundation.dart';
import 'package:lazurite/core/network/app_view_fallback_service.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/core/network/xrpc_network_interceptor.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/search/data/post_search_filters.dart';

class SearchRepository {
  SearchRepository({
    required dynamic bluesky,
    ModerationService? moderationService,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
    bool crossProviderFallbackEnabled = false,
    bool Function()? crossProviderFallbackEnabledResolver,
    AppViewFallbackService? appViewFallbackService,
    int routingEpoch = 0,
    int Function()? routingEpochResolver,
  }) : _bluesky = bluesky,
       _moderationService = moderationService,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       ),
       _crossProviderFallbackEnabled = crossProviderFallbackEnabled,
       _crossProviderFallbackEnabledResolver = crossProviderFallbackEnabledResolver,
       _appViewFallbackService = appViewFallbackService ?? AppViewFallbackService(),
       _routingEpoch = routingEpoch,
       _routingEpochResolver = routingEpochResolver;

  final dynamic _bluesky;
  final ModerationService? _moderationService;
  final AppViewRequestContext _appViewContext;
  final bool _crossProviderFallbackEnabled;
  final bool Function()? _crossProviderFallbackEnabledResolver;
  final AppViewFallbackService _appViewFallbackService;
  final int _routingEpoch;
  final int Function()? _routingEpochResolver;
  static const int _maxBlackskyTopicFeedLimit = 25;

  Future<SearchPostsResult> searchPosts({
    required String query,
    String sort = 'top',
    PostSearchFilters filters = const PostSearchFilters(),
    String? cursor,
    int limit = 50,
  }) async {
    final normalized = PostSearchRequest(
      query: query,
      sort: sort,
      filters: filters,
      cursor: cursor,
      limit: limit,
    ).normalized();

    final sortValue = normalized.sort == 'latest'
        ? const FeedSearchPostsSort.knownValue(data: KnownFeedSearchPostsSort.latest)
        : const FeedSearchPostsSort.knownValue(data: KnownFeedSearchPostsSort.top);

    final response = await _bluesky.feed.searchPosts(
      q: normalized.query.isEmpty ? '*' : normalized.query,
      sort: sortValue,
      since: normalized.filters.sinceIso,
      until: normalized.filters.untilIso,
      mentions: normalized.filters.mentions,
      author: normalized.filters.author,
      lang: normalized.filters.lang,
      domain: normalized.filters.domain,
      url: normalized.filters.url,
      tag: normalized.filters.tags.isEmpty ? null : normalized.filters.tags,
      cursor: normalized.cursor,
      limit: normalized.limit,
      $headers: _appViewContext.appBskyHeadersForEndpoint(
        'app.bsky.feed.searchPosts',
        await _moderationService?.headersForRequest(),
      ),
    );

    return SearchPostsResult(
      posts: _filterPosts(response.data.posts),
      cursor: response.data.cursor,
      hitsTotal: response.data.hitsTotal,
    );
  }

  Future<SearchActorsResult> searchActors({required String query, String? cursor, int limit = 50}) async {
    final response = await _bluesky.actor.searchActors(
      q: query,
      cursor: cursor,
      limit: limit,
      $headers: _appViewContext.appBskyHeadersForEndpoint(
        'app.bsky.actor.searchActors',
        await _moderationService?.headersForRequest(),
      ),
    );

    return SearchActorsResult(actors: _filterProfiles(response.data.actors), cursor: response.data.cursor);
  }

  Future<SearchStarterPacksResult> searchStarterPacks({required String query, String? cursor, int limit = 25}) async {
    final response = await _runPublicReadWithFallback(
      endpointId: 'app.bsky.graph.searchStarterPacks',
      request: (context, headers, {required fallbackUsed}) {
        return _bluesky.graph.searchStarterPacks(
          q: query,
          cursor: cursor,
          limit: limit,
          $service: context.publicServiceHost(),
          $headers: headers,
        );
      },
    );

    return SearchStarterPacksResult(starterPacks: response.data.starterPacks, cursor: response.data.cursor);
  }

  Future<SearchFeedsResult> searchFeedGenerators({required String query, String? cursor, int limit = 25}) async {
    final response = await _runPublicReadWithFallback(
      endpointId: 'app.bsky.unspecced.getPopularFeedGenerators',
      request: (context, headers, {required fallbackUsed}) {
        return _bluesky.unspecced.getPopularFeedGenerators(
          query: query,
          cursor: cursor,
          limit: limit,
          $service: context.publicServiceHost(),
          $headers: headers,
        );
      },
    );

    return SearchFeedsResult(feeds: response.data.feeds, cursor: response.data.cursor);
  }

  Future<List<ProfileViewBasic>> searchActorsTypeahead({required String query, int limit = 10}) async {
    final response = await _bluesky.actor.searchActorsTypeahead(
      q: query,
      limit: limit,
      $headers: _appViewContext.appBskyHeadersForEndpoint(
        'app.bsky.actor.searchActorsTypeahead',
        await _moderationService?.headersForRequest(),
      ),
    );

    return _filterBasicProfiles(response.data.actors);
  }

  Future<TopicPostsResult> searchTopicPosts({
    required String topic,
    String sort = 'top',
    String? cursor,
    int limit = 25,
  }) async {
    final normalizedTopic = topic.trim();
    if (normalizedTopic.isEmpty) {
      return TopicPostsResult(posts: const []);
    }

    final provider = _appViewContext.resolveProviderKey();
    final isBlackskyNumericTopic = provider == 'blacksky' && RegExp(r'^\d+$').hasMatch(normalizedTopic);
    if (isBlackskyNumericTopic) {
      return _searchBlackskyTopicFeed(topicId: normalizedTopic, cursor: cursor, limit: limit);
    }

    final result = await searchPosts(query: normalizedTopic, sort: sort, cursor: cursor, limit: limit);
    return TopicPostsResult(posts: result.posts, cursor: result.cursor, topicName: normalizedTopic);
  }

  Future<TopicPostsResult> _searchBlackskyTopicFeed({
    required String topicId,
    String? cursor,
    required int limit,
  }) async {
    final clampedLimit = limit.clamp(1, _maxBlackskyTopicFeedLimit);
    final params = <String, String>{
      'topicId': topicId,
      'limit': clampedLimit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    };

    final uri = Uri.https(_appViewContext.publicServiceHost(), '/xrpc/app.bsky.unspecced.getTopicFeed', params);
    final baseHeaders = await _moderationService?.headersForRequest();
    final headers = _appViewContext.appBskyHeadersForEndpoint('app.bsky.unspecced.getTopicFeed', baseHeaders);
    final response = await XrpcNetworkInterceptor.wrapGetClient()(uri, headers: headers);
    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch Blacksky topic feed (status ${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final rawPostUris = decoded['posts'] as List<dynamic>? ?? const [];
    final atUris = <AtUri>[];
    for (final raw in rawPostUris) {
      final value = raw is String ? raw.trim() : '';
      if (value.isEmpty) {
        continue;
      }
      try {
        atUris.add(AtUri.parse(value));
      } catch (_) {}
    }

    if (atUris.isEmpty) {
      return TopicPostsResult(
        posts: const [],
        cursor: decoded['cursor'] as String?,
        topicName: _topicNameFromDecoded(decoded),
      );
    }

    final hydrated = await _bluesky.feed.getPosts(
      uris: atUris,
      $service: _appViewContext.publicServiceHost(),
      $headers: _appViewContext.appBskyHeadersForEndpoint(
        'app.bsky.feed.getPosts',
        await _moderationService?.headersForRequest(),
      ),
    );

    return TopicPostsResult(
      posts: _filterPosts(hydrated.data.posts),
      cursor: decoded['cursor'] as String?,
      topicName: _topicNameFromDecoded(decoded),
    );
  }

  String? _topicNameFromDecoded(Map<String, dynamic> decoded) {
    final topic = decoded['topic'];
    if (topic is Map<String, dynamic>) {
      final name = topic['name'];
      if (name is String && name.trim().isNotEmpty) {
        return name.trim();
      }
    }
    return null;
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

  List<PostView> _filterPosts(List<PostView> posts) {
    final moderationService = _moderationService;
    if (moderationService == null) {
      return posts;
    }

    return posts.where((post) => !moderationService.shouldFilterPostInList(post)).toList();
  }

  List<ProfileView> _filterProfiles(List<ProfileView> profiles) {
    final moderationService = _moderationService;
    if (moderationService == null) {
      return profiles;
    }

    return profiles.where((profile) => !moderationService.shouldFilterProfileInList(profile)).toList();
  }

  List<ProfileViewBasic> _filterBasicProfiles(List<ProfileViewBasic> profiles) {
    final moderationService = _moderationService;
    if (moderationService == null) {
      return profiles;
    }

    return profiles.where((profile) => !moderationService.shouldFilterProfileBasicInList(profile)).toList();
  }
}

class SearchPostsResult {
  SearchPostsResult({required this.posts, this.cursor, this.hitsTotal});

  final List<PostView> posts;
  final String? cursor;
  final int? hitsTotal;
}

class SearchActorsResult {
  SearchActorsResult({required this.actors, this.cursor});

  final List<ProfileView> actors;
  final String? cursor;
}

class SearchStarterPacksResult {
  SearchStarterPacksResult({required this.starterPacks, this.cursor});

  final List<StarterPackViewBasic> starterPacks;
  final String? cursor;
}

class SearchFeedsResult {
  SearchFeedsResult({required this.feeds, this.cursor});

  final List<GeneratorView> feeds;
  final String? cursor;
}

class TopicPostsResult {
  TopicPostsResult({required this.posts, this.cursor, this.topicName});

  final List<PostView> posts;
  final String? cursor;
  final String? topicName;
}
