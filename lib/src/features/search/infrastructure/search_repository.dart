import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/search_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

/// Repository for search functionality.
class SearchRepository {
  SearchRepository(this._api, this._dao, this._logger);

  final XrpcClient _api;
  final SearchDao _dao;
  final Logger _logger;

  /// Searches posts with cursor pagination.
  Future<SearchPostsResult> searchPosts(String query, {String? cursor}) async {
    _logger.info('Searching posts', {'query': query, 'cursor': cursor});
    try {
      final response = await _api.call(
        'app.bsky.feed.searchPosts',
        params: {'q': query, 'limit': 25, if (cursor != null) 'cursor': cursor},
      );

      final posts =
          (response['posts'] as List?)
              ?.map((e) => SearchPostItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      final nextCursor = response['cursor'] as String?;

      _logger.debug('Found ${posts.length} posts');
      return SearchPostsResult(posts: posts, cursor: nextCursor);
    } catch (e, stack) {
      _logger.error('Search failed', e, stack);
      rethrow;
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
}
