import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lazurite/src/core/domain/post.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/core/utils/pagination.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart' hide Post;
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/search_cache_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/search_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

/// Repository for search functionality.
class SearchRepository {
  SearchRepository(this._api, this._dao, this._cacheDao, this._sessionStorage, this._logger);

  final XrpcClient _api;
  final SearchDao _dao;
  final SearchCacheDao _cacheDao;
  final SessionStorage _sessionStorage;
  final Logger _logger;

  /// Normalizes a query string for use as a cache key.
  static String normalizeQuery(String query) {
    return query.trim().toLowerCase();
  }

  /// Gets the current user's DID from session storage.
  Future<String> _getOwnerDid() async {
    final session = await _sessionStorage.getSession();
    return session!.did;
  }

  /// Searches posts with cursor pagination and caches results.
  Future<PaginatedResult<Post>> searchPosts(String query, {String? cursor}) async {
    final queryKey = normalizeQuery(query);
    final ownerDid = await _getOwnerDid();
    _logger.info('Searching posts', {'query': query, 'queryKey': queryKey, 'cursor': cursor});

    try {
      final response = await _api.call(
        'app.bsky.feed.searchPosts',
        params: {'q': query, 'limit': 25, if (cursor != null) 'cursor': cursor},
      );

      final postsJson = response['posts'];
      if (postsJson is! List?) {
        throw FormatException('posts must be a List', response);
      }
      final rawPosts = postsJson ?? [];
      final posts = <Post>[];
      for (final postJson in rawPosts) {
        if (postJson is! Map<String, dynamic>) {
          throw FormatException('Each post must be a Map', postJson);
        }
        posts.add(Post.fromJson(postJson));
      }
      final nextCursor = response['cursor'] as String?;

      _logger.debug('Found ${posts.length} posts');

      await _cacheSearchResults(
        queryKey,
        ownerDid,
        rawPosts,
        nextCursor,
        isLoadMore: cursor != null,
      );

      return PaginatedResult(items: posts, cursor: nextCursor);
    } catch (e, stack) {
      _logger.error('Search failed', e, stack);
      if (cursor == null) {
        final cachedResults = await _cacheDao.getSearchResults(queryKey, ownerDid);
        if (cachedResults.isNotEmpty) {
          final cachedPosts = _mapCachedResults(cachedResults);
          _logger.warning('Serving cached search results due to offline failure', {
            'query': queryKey,
            'count': cachedPosts.length,
          });
          return PaginatedResult(items: cachedPosts, cursor: null);
        }
      }
      rethrow;
    }
  }

  /// Caches search results in the database.
  Future<void> _cacheSearchResults(
    String queryKey,
    String ownerDid,
    List<dynamic> rawPosts,
    String? cursor, {
    required bool isLoadMore,
  }) async {
    final postsCompanions = <PostsCompanion>[];
    final profilesCompanions = <ProfilesCompanion>[];
    final cacheItems = <SearchCacheItemsCompanion>[];

    int startIndex = 0;
    if (isLoadMore) {
      final existing = await _cacheDao.getSearchResults(queryKey, ownerDid);
      startIndex = existing.length;
    }

    for (var i = 0; i < rawPosts.length; i++) {
      final postJson = rawPosts[i];
      if (postJson is! Map<String, dynamic>) {
        throw FormatException('Each post must be a Map', postJson);
      }

      final authorJson = postJson['author'];
      if (authorJson is! Map<String, dynamic>) {
        throw FormatException('Post author must be a Map', postJson);
      }

      final uri = postJson['uri'];
      final cid = postJson['cid'];
      final authorDid = authorJson['did'];
      final authorHandle = authorJson['handle'];

      if (uri is! String || uri.isEmpty) {
        throw FormatException('Post uri must be a non-empty string', postJson);
      }
      if (cid is! String || cid.isEmpty) {
        throw FormatException('Post cid must be a non-empty string', postJson);
      }
      if (authorDid is! String || authorDid.isEmpty) {
        throw FormatException('Author did must be a non-empty string', authorJson);
      }
      if (authorHandle is! String || authorHandle.isEmpty) {
        throw FormatException('Author handle must be a non-empty string', authorJson);
      }

      postsCompanions.add(
        PostsCompanion.insert(
          uri: uri,
          cid: cid,
          authorDid: authorDid,
          record: jsonEncode(postJson['record']),
          embed: Value(postJson['embed'] != null ? jsonEncode(postJson['embed']) : null),
          indexedAt: Value(DateTime.tryParse(postJson['indexedAt'] as String? ?? '')),
          replyCount: Value(postJson['replyCount'] as int? ?? 0),
          repostCount: Value(postJson['repostCount'] as int? ?? 0),
          likeCount: Value(postJson['likeCount'] as int? ?? 0),
        ),
      );

      profilesCompanions.add(
        ProfilesCompanion.insert(
          did: authorDid,
          handle: authorHandle,
          displayName: Value(authorJson['displayName'] as String?),
          description: Value(authorJson['description'] as String?),
          avatar: Value(authorJson['avatar'] as String?),
        ),
      );

      final sortKey = (startIndex + i).toString().padLeft(10, '0');
      cacheItems.add(
        SearchCacheItemsCompanion.insert(
          queryKey: queryKey,
          ownerDid: ownerDid,
          postUri: uri,
          sortKey: sortKey,
        ),
      );
    }

    await _cacheDao.insertSearchBatch(
      queryKey: queryKey,
      ownerDid: ownerDid,
      newPosts: postsCompanions,
      newProfiles: profilesCompanions,
      newItems: cacheItems,
      newCursor: cursor,
    );

    _logger.debug('Cached ${rawPosts.length} search results', {'queryKey': queryKey});
  }

  List<Post> _mapCachedResults(List<SearchPost> cachedResults) {
    return cachedResults
        .map((cached) => Post.fromFeedPost(FeedPost(post: cached.post, author: cached.author)))
        .toList();
  }

  /// Gets cached search results for a query.
  Future<List<SearchPost>> getCachedResults(String query) async {
    final ownerDid = await _getOwnerDid();
    return _cacheDao.getSearchResults(normalizeQuery(query), ownerDid);
  }

  /// Watches cached search results for a query.
  Stream<List<SearchPost>> watchCachedResults(String query) async* {
    final ownerDid = await _getOwnerDid();
    yield* _cacheDao.watchSearchResults(normalizeQuery(query), ownerDid);
  }

  /// Gets the cached cursor for a query.
  Future<String?> getCachedCursor(String query) async {
    final ownerDid = await _getOwnerDid();
    return _cacheDao.getCursor(normalizeQuery(query), ownerDid);
  }

  /// Clears cached results for a specific query.
  Future<void> clearCachedResults(String query) async {
    final ownerDid = await _getOwnerDid();
    return _cacheDao.clearSearchCache(normalizeQuery(query), ownerDid);
  }

  /// Cleans up stale search cache (not updated in 7 days).
  Future<void> cleanupSearchCache() async {
    final ownerDid = await _getOwnerDid();
    final threshold = DateTime.now().subtract(const Duration(days: 7));
    final count = await _cacheDao.deleteStaleCacheItems(threshold, ownerDid);
    if (count > 0) {
      _logger.info('Cleaned up $count stale search cache items');
    }
  }

  /// Saves a search query to recent searches.
  Future<void> saveRecentSearch(String query) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    await _dao.addRecentSearch(query, ownerDid);
    _logger.debug('Saved recent search', {'query': query});
  }

  /// Gets recent searches.
  Future<List<RecentSearche>> getRecentSearches({int limit = 10}) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    return _dao.getRecentSearches(ownerDid, limit: limit);
  }

  /// Watches recent searches.
  Stream<List<RecentSearche>> watchRecentSearches({int limit = 10}) async* {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    yield* _dao.watchRecentSearches(ownerDid, limit: limit);
  }

  /// Removes a single recent search.
  Future<void> removeRecentSearch(String query) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    await _dao.deleteRecentSearch(query, ownerDid);
    _logger.debug('Removed recent search', {'query': query});
  }

  /// Clears all recent searches.
  Future<void> clearAllRecentSearches() async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    await _dao.clearAllRecentSearches(ownerDid);
    _logger.debug('Cleared all recent searches');
  }

  /// Searches actors (users) with cursor pagination.
  Future<PaginatedResult<SearchActorItem>> searchActors(String query, {String? cursor}) async {
    _logger.info('Searching actors', {'query': query, 'cursor': cursor});

    try {
      final response = await _api.call(
        'app.bsky.actor.searchActors',
        params: {'q': query, 'limit': 25, if (cursor != null) 'cursor': cursor},
      );

      final actorsJson = response['actors'];
      if (actorsJson is! List?) {
        throw FormatException('actors must be a List', response);
      }
      final rawActors = actorsJson ?? [];
      final actors = <SearchActorItem>[];
      for (final actorJson in rawActors) {
        if (actorJson is! Map<String, dynamic>) {
          throw FormatException('Each actor must be a Map', actorJson);
        }
        actors.add(SearchActorItem.fromJson(actorJson));
      }
      final nextCursor = response['cursor'] as String?;

      _logger.debug('Found ${actors.length} actors');

      return PaginatedResult(items: actors, cursor: nextCursor);
    } catch (e, stack) {
      _logger.error('Actor search failed', e, stack);
      rethrow;
    }
  }
}

/// An actor (user) from search results.
class SearchActorItem {
  SearchActorItem({
    required this.did,
    required this.handle,
    this.displayName,
    this.description,
    this.avatar,
    this.followersCount = 0,
    this.followsCount = 0,
    this.indexedAt,
    this.allowIncoming,
  });
  factory SearchActorItem.fromJson(Map<String, dynamic> json) {
    final did = json['did'];
    final handle = json['handle'];

    if (did is! String || did.isEmpty) {
      throw FormatException('SearchActorItem.did must be a non-empty string', json);
    }
    if (handle is! String || handle.isEmpty) {
      throw FormatException('SearchActorItem.handle must be a non-empty string', json);
    }

    return SearchActorItem(
      did: did,
      handle: handle,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
      followersCount: json['followersCount'] as int? ?? 0,
      followsCount: json['followsCount'] as int? ?? 0,
      indexedAt: DateTime.tryParse(json['indexedAt'] as String? ?? ''),
      allowIncoming: _parseAllowIncoming(json),
    );
  }

  static String? _parseAllowIncoming(Map<String, dynamic> json) {
    final associated = json['associated'];
    if (associated is Map<String, dynamic>) {
      final chat = associated['chat'];
      if (chat is Map<String, dynamic>) {
        return chat['allowIncoming'] as String?;
      }
    }
    return null;
  }

  final String did;
  final String handle;
  final String? displayName;
  final String? description;
  final String? avatar;
  final int followersCount;
  final int followsCount;
  final DateTime? indexedAt;
  final String? allowIncoming;
}
