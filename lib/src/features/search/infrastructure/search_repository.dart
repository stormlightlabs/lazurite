import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/search_cache_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/search_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

/// Repository for search functionality.
class SearchRepository {
  SearchRepository(this._api, this._dao, this._cacheDao, this._logger);

  final XrpcClient _api;
  final SearchDao _dao;
  final SearchCacheDao _cacheDao;
  final Logger _logger;

  /// Normalizes a query string for use as a cache key.
  static String normalizeQuery(String query) {
    return query.trim().toLowerCase();
  }

  /// Searches posts with cursor pagination and caches results.
  Future<SearchPostsResult> searchPosts(String query, {String? cursor}) async {
    final queryKey = normalizeQuery(query);
    _logger.info('Searching posts', {'query': query, 'queryKey': queryKey, 'cursor': cursor});

    try {
      final response = await _api.call(
        'app.bsky.feed.searchPosts',
        params: {'q': query, 'limit': 25, if (cursor != null) 'cursor': cursor},
      );

      final rawPosts = response['posts'] as List? ?? [];
      final posts = rawPosts
          .map((e) => SearchPostItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final nextCursor = response['cursor'] as String?;

      _logger.debug('Found ${posts.length} posts');

      await _cacheSearchResults(queryKey, rawPosts, nextCursor, isLoadMore: cursor != null);

      return SearchPostsResult(posts: posts, cursor: nextCursor);
    } catch (e, stack) {
      _logger.error('Search failed', e, stack);
      rethrow;
    }
  }

  /// Caches search results in the database.
  Future<void> _cacheSearchResults(
    String queryKey,
    List<dynamic> rawPosts,
    String? cursor, {
    required bool isLoadMore,
  }) async {
    final postsCompanions = <PostsCompanion>[];
    final profilesCompanions = <ProfilesCompanion>[];
    final cacheItems = <SearchCacheItemsCompanion>[];

    int startIndex = 0;
    if (isLoadMore) {
      final existing = await _cacheDao.getSearchResults(queryKey);
      startIndex = existing.length;
    }

    for (var i = 0; i < rawPosts.length; i++) {
      final json = rawPosts[i] as Map<String, dynamic>;
      final author = json['author'] as Map<String, dynamic>;

      postsCompanions.add(
        PostsCompanion.insert(
          uri: json['uri'] as String,
          cid: json['cid'] as String,
          authorDid: author['did'] as String,
          record: jsonEncode(json['record']),
          embed: Value(json['embed'] != null ? jsonEncode(json['embed']) : null),
          indexedAt: Value(DateTime.tryParse(json['indexedAt'] as String? ?? '')),
          replyCount: Value(json['replyCount'] as int? ?? 0),
          repostCount: Value(json['repostCount'] as int? ?? 0),
          likeCount: Value(json['likeCount'] as int? ?? 0),
        ),
      );

      profilesCompanions.add(
        ProfilesCompanion.insert(
          did: author['did'] as String,
          handle: author['handle'] as String,
          displayName: Value(author['displayName'] as String?),
          description: Value(author['description'] as String?),
          avatar: Value(author['avatar'] as String?),
        ),
      );

      final sortKey = (startIndex + i).toString().padLeft(10, '0');
      cacheItems.add(
        SearchCacheItemsCompanion.insert(
          queryKey: queryKey,
          postUri: json['uri'] as String,
          sortKey: sortKey,
        ),
      );
    }

    await _cacheDao.insertSearchBatch(
      queryKey: queryKey,
      newPosts: postsCompanions,
      newProfiles: profilesCompanions,
      newItems: cacheItems,
      newCursor: cursor,
    );

    _logger.debug('Cached ${rawPosts.length} search results', {'queryKey': queryKey});
  }

  /// Gets cached search results for a query.
  Future<List<SearchPost>> getCachedResults(String query) {
    return _cacheDao.getSearchResults(normalizeQuery(query));
  }

  /// Watches cached search results for a query.
  Stream<List<SearchPost>> watchCachedResults(String query) {
    return _cacheDao.watchSearchResults(normalizeQuery(query));
  }

  /// Gets the cached cursor for a query.
  Future<String?> getCachedCursor(String query) {
    return _cacheDao.getCursor(normalizeQuery(query));
  }

  /// Clears cached results for a specific query.
  Future<void> clearCachedResults(String query) {
    return _cacheDao.clearSearchCache(normalizeQuery(query));
  }

  /// Cleans up stale search cache (not updated in 7 days).
  Future<void> cleanupSearchCache() async {
    final threshold = DateTime.now().subtract(const Duration(days: 7));
    final count = await _cacheDao.deleteStaleCacheItems(threshold);
    if (count > 0) {
      _logger.info('Cleaned up $count stale search cache items');
    }
  }

  /// Saves a search query to recent searches.
  Future<void> saveRecentSearch(String query) async {
    await _dao.addRecentSearch(query);
    _logger.debug('Saved recent search', {'query': query});
  }

  /// Gets recent searches.
  Future<List<RecentSearche>> getRecentSearches({int limit = 10}) {
    return _dao.getRecentSearches(limit: limit);
  }

  /// Watches recent searches.
  Stream<List<RecentSearche>> watchRecentSearches({int limit = 10}) {
    return _dao.watchRecentSearches(limit: limit);
  }

  /// Removes a single recent search.
  Future<void> removeRecentSearch(String query) async {
    await _dao.deleteRecentSearch(query);
    _logger.debug('Removed recent search', {'query': query});
  }

  /// Clears all recent searches.
  Future<void> clearAllRecentSearches() async {
    await _dao.clearAllRecentSearches();
    _logger.debug('Cleared all recent searches');
  }

  /// Searches actors (users) with cursor pagination.
  Future<SearchActorsResult> searchActors(String query, {String? cursor}) async {
    _logger.info('Searching actors', {'query': query, 'cursor': cursor});

    try {
      final response = await _api.call(
        'app.bsky.actor.searchActors',
        params: {'q': query, 'limit': 25, if (cursor != null) 'cursor': cursor},
      );

      final rawActors = response['actors'] as List? ?? [];
      final actors = rawActors
          .map((e) => SearchActorItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final nextCursor = response['cursor'] as String?;

      _logger.debug('Found ${actors.length} actors');

      return SearchActorsResult(actors: actors, cursor: nextCursor);
    } catch (e, stack) {
      _logger.error('Actor search failed', e, stack);
      rethrow;
    }
  }
}

/// Result of searching posts.
class SearchPostsResult {
  SearchPostsResult({required this.posts, this.cursor});

  final List<SearchPostItem> posts;
  final String? cursor;

  bool get hasMore => cursor != null;
}

/// A post from search results.
class SearchPostItem {
  factory SearchPostItem.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>;
    final record = json['record'] as Map<String, dynamic>;
    final embed = json['embed'] as Map<String, dynamic>?;

    return SearchPostItem(
      uri: json['uri'] as String,
      cid: json['cid'] as String,
      authorDid: author['did'] as String,
      authorHandle: author['handle'] as String,
      authorDisplayName: author['displayName'] as String?,
      authorAvatar: author['avatar'] as String?,
      text: record['text'] as String? ?? '',
      indexedAt: DateTime.tryParse(json['indexedAt'] as String? ?? ''),
      replyCount: json['replyCount'] as int? ?? 0,
      repostCount: json['repostCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      embed: embed,
      record: record,
    );
  }

  SearchPostItem({
    required this.uri,
    required this.cid,
    required this.authorDid,
    required this.authorHandle,
    this.authorDisplayName,
    this.authorAvatar,
    required this.text,
    this.indexedAt,
    this.replyCount = 0,
    this.repostCount = 0,
    this.likeCount = 0,
    this.embed,
    this.record,
  });

  final String uri;
  final String cid;
  final String authorDid;
  final String authorHandle;
  final String? authorDisplayName;
  final String? authorAvatar;
  final String text;
  final DateTime? indexedAt;
  final int replyCount;
  final int repostCount;
  final int likeCount;
  final Map<String, dynamic>? embed;
  final Map<String, dynamic>? record;
}

/// Result of searching actors.
class SearchActorsResult {
  SearchActorsResult({required this.actors, this.cursor});

  final List<SearchActorItem> actors;
  final String? cursor;

  bool get hasMore => cursor != null;
}

/// An actor (user) from search results.
class SearchActorItem {
  factory SearchActorItem.fromJson(Map<String, dynamic> json) {
    return SearchActorItem(
      did: json['did'] as String,
      handle: json['handle'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
      followersCount: json['followersCount'] as int? ?? 0,
      followsCount: json['followsCount'] as int? ?? 0,
      indexedAt: DateTime.tryParse(json['indexedAt'] as String? ?? ''),
    );
  }

  SearchActorItem({
    required this.did,
    required this.handle,
    this.displayName,
    this.description,
    this.avatar,
    this.followersCount = 0,
    this.followsCount = 0,
    this.indexedAt,
  });

  final String did;
  final String handle;
  final String? displayName;
  final String? description;
  final String? avatar;
  final int followersCount;
  final int followsCount;
  final DateTime? indexedAt;
}
