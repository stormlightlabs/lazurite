import 'dart:async';

import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/foundation.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/core/network/constellation_client.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/unauthorized_recovery_runner.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:poptart_core/poptart_core.dart' as atcore;

/// Source key used by Constellation to describe a like record pointing at a
/// post subject URI.
///
/// The feature intentionally treats Constellation as a relationship index only:
/// it discovers candidate post URIs, while AppView hydration below decides what
/// is safe and current enough to render.
const String similarPostsLikeSource = 'app.bsky.feed.like:subject.uri';

/// Returns posts that are related to a seed post through shared public likes.
///
/// Data flow:
/// 1. Constellation receives the seed post URI and returns other post URIs liked
///    by accounts that also liked the seed.
/// 2. The repository ranks those URIs locally by shared-like count.
/// 3. The top URIs are hydrated with one `app.bsky.feed.getPosts` request.
/// 4. Hydrated posts are filtered through the same moderation service used by
///    feeds before they reach the UI.
///
/// This keeps the repository/network cost bounded: one graph lookup plus one
/// AppView hydration request per page, with a short in-memory cache for repeat
/// thread opens.
class SimilarPostsRepository {
  SimilarPostsRepository({
    required Bluesky bluesky,
    required ConstellationClient constellationClient,
    ModerationService? moderationService,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
    Future<AuthTokens?> Function()? onUnauthorized,
    Bluesky? Function(AuthTokens tokens)? blueskyClientFactory,
    DateTime Function()? now,
    Duration cacheTtl = const Duration(hours: 1),
    @visibleForTesting
    Future<({List<ManyToManyItem> items, String? cursor})> Function(String postUri, String? cursor, int limit)?
    relationshipLoader,
    @visibleForTesting Future<List<PostView>> Function(List<atcore.AtUri> uris)? postHydrator,
  }) : _constellationClient = constellationClient,
       _moderationService = moderationService,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       ),
       _now = now ?? DateTime.now,
       _cacheTtl = cacheTtl,
       _relationshipLoaderForTest = relationshipLoader,
       _postHydratorForTest = postHydrator {
    _authRecovery = UnauthorizedRecoveryRunner<Bluesky>(
      initialClient: bluesky,
      onUnauthorized: onUnauthorized,
      clientFactory: blueskyClientFactory ?? createBlueskyClient,
      onUnauthorizedException: (error, stackTrace) {
        log.w('similar_posts.auth unauthorized; attempting session recovery', error: error, stackTrace: stackTrace);
      },
    );
  }

  late final UnauthorizedRecoveryRunner<Bluesky> _authRecovery;
  final ConstellationClient _constellationClient;
  final ModerationService? _moderationService;
  final AppViewRequestContext _appViewContext;
  final DateTime Function() _now;
  final Duration _cacheTtl;
  final Future<({List<ManyToManyItem> items, String? cursor})> Function(String postUri, String? cursor, int limit)?
  _relationshipLoaderForTest;
  final Future<List<PostView>> Function(List<atcore.AtUri> uris)? _postHydratorForTest;

  final Map<String, _CachedSimilarPostsPage> _cache = <String, _CachedSimilarPostsPage>{};

  static const int defaultRelationshipLimit = 100;
  static const int defaultHydrationLimit = 10;
  static const int _maxHydrationBatchSize = 25;

  /// Loads one page of posts similar to [postUri].
  ///
  /// [cursor] is the Constellation cursor from a previous call. The returned
  /// cursor should be passed back unchanged when the UI asks for more. Cached
  /// pages are keyed by post URI and cursor so a thread reopen does not repeat
  /// the graph/hydration work inside [_cacheTtl].
  Future<SimilarPostsPage> getSimilarPosts({
    required String postUri,
    String? cursor,
    int relationshipLimit = defaultRelationshipLimit,
    int hydrationLimit = defaultHydrationLimit,
  }) async {
    final normalizedPostUri = postUri.trim();
    if (normalizedPostUri.isEmpty || relationshipLimit <= 0 || hydrationLimit <= 0) {
      return const SimilarPostsPage(posts: <PostView>[]);
    }

    final cacheKey = _cacheKey(normalizedPostUri, cursor, relationshipLimit, hydrationLimit);
    final cached = _cache[cacheKey];
    if (cached != null && _now().difference(cached.storedAt) < _cacheTtl) {
      return cached.page;
    }

    final relationships = await _loadRelationships(normalizedPostUri, cursor, relationshipLimit);
    final rankedUris = _rankCandidateUris(normalizedPostUri, relationships.items);
    if (rankedUris.isEmpty) {
      final empty = SimilarPostsPage(posts: const <PostView>[], cursor: relationships.cursor);
      _cache[cacheKey] = _CachedSimilarPostsPage(empty, _now());
      return empty;
    }

    final hydrated = await _hydrateRankedPosts(rankedUris.take(hydrationLimit).toList(growable: false));
    final page = SimilarPostsPage(posts: hydrated, cursor: relationships.cursor);
    _cache[cacheKey] = _CachedSimilarPostsPage(page, _now());
    return page;
  }

  Future<({List<ManyToManyItem> items, String? cursor})> _loadRelationships(String postUri, String? cursor, int limit) {
    final loader = _relationshipLoaderForTest;
    if (loader != null) {
      return loader(postUri, cursor, limit);
    }
    return _constellationClient.getManyToMany(
      postUri,
      similarPostsLikeSource,
      'subject.uri',
      limit: limit,
      cursor: cursor,
    );
  }

  /// Counts duplicate candidate URIs from Constellation. A duplicate means more
  /// than one account liked both the seed post and the candidate post, which is
  /// the MVP definition of stronger similarity.
  List<String> _rankCandidateUris(String seedPostUri, List<ManyToManyItem> items) {
    final counts = <String, int>{};
    for (final item in items) {
      final candidateUri = item.otherSubject.trim();
      if (candidateUri.isEmpty || candidateUri == seedPostUri || !_isPostUri(candidateUri)) {
        continue;
      }
      counts[candidateUri] = (counts[candidateUri] ?? 0) + 1;
    }

    final ranked = counts.entries.toList()
      ..sort((a, b) {
        final bySharedLikes = b.value.compareTo(a.value);
        if (bySharedLikes != 0) return bySharedLikes;
        return a.key.compareTo(b.key);
      });
    return ranked.map((entry) => entry.key).toList(growable: false);
  }

  bool _isPostUri(String value) {
    try {
      final uri = atcore.AtUri.parse(value);
      return uri.collection.toString() == 'app.bsky.feed.post' && uri.rkey.isNotEmpty;
    } catch (error, stackTrace) {
      log.d('similar_posts skipping invalid candidate URI: $value', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// Hydrates ranked URI strings and restores the ranking after AppView returns
  /// whatever posts are still available to this viewer. Missing/deleted/blocked
  /// posts are naturally dropped because they are absent from the response.
  Future<List<PostView>> _hydrateRankedPosts(List<String> rankedUris) async {
    final uris = <atcore.AtUri>[];
    for (final value in rankedUris.take(_maxHydrationBatchSize)) {
      try {
        uris.add(atcore.AtUri.parse(value));
      } catch (error, stackTrace) {
        log.d('similar_posts failed to parse ranked URI: $value', error: error, stackTrace: stackTrace);
      }
    }
    if (uris.isEmpty) return const <PostView>[];

    final hydrator = _postHydratorForTest;
    final posts = hydrator == null ? await _hydratePostsFromAppView(uris) : await hydrator(uris);
    final postsByUri = {for (final post in posts) post.uri.toString(): post};
    final moderated = <PostView>[];
    for (final uri in rankedUris) {
      final post = postsByUri[uri];
      if (post == null) continue;
      if (_moderationService?.shouldFilterPostInList(post) ?? false) continue;
      moderated.add(post);
    }
    return moderated;
  }

  Future<List<PostView>> _hydratePostsFromAppView(List<atcore.AtUri> uris) async {
    final headers = _appViewContext.appBskyHeadersForEndpoint(
      'app.bsky.feed.getPosts',
      await _moderationService?.headersForRequest(),
    );
    final response = await _authRecovery.run((client) => client.feed.getPosts(uris: uris, $headers: headers));
    return response.data.posts;
  }

  String _cacheKey(String postUri, String? cursor, int relationshipLimit, int hydrationLimit) =>
      '$postUri|${cursor ?? ''}|$relationshipLimit|$hydrationLimit';
}

class SimilarPostsPage {
  const SimilarPostsPage({required this.posts, this.cursor});

  final List<PostView> posts;
  final String? cursor;

  bool get hasMore => cursor != null && cursor!.isNotEmpty;
}

class _CachedSimilarPostsPage {
  const _CachedSimilarPostsPage(this.page, this.storedAt);

  final SimilarPostsPage page;
  final DateTime storedAt;
}
