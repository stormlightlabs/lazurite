import 'dart:convert';

import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:drift/drift.dart' show Value;
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/features/search/data/semantic_indexer.dart';

class LikedPostsRepository {
  LikedPostsRepository({
    required dynamic bluesky,
    required AppDatabase database,
    SemanticIndexer? semanticIndexer,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
  }) : _bluesky = bluesky,
       _database = database,
       _semanticIndexer = semanticIndexer,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       );

  final dynamic _bluesky;
  final AppDatabase _database;
  final SemanticIndexer? _semanticIndexer;
  final AppViewRequestContext _appViewContext;

  static const int _maxLikes = 1000;
  static const int _pageSize = 100;

  /// Syncs liked posts for [accountDid].
  ///
  /// Paginates through [bluesky.feed.getActorLikes] until it encounters an
  /// already-known URI or has fetched [_maxLikes] posts, whichever comes first.
  /// Upserts new entries and evicts oldest entries when count exceeds [_maxLikes].
  Future<void> syncLikes(String accountDid) async {
    String? cursor;
    var fetched = 0;
    var hitKnown = false;

    while (!hitKnown && fetched < _maxLikes) {
      final response = await _bluesky.feed.getActorLikes(
        actor: accountDid,
        limit: _pageSize,
        cursor: cursor,
        $headers: _appViewContext.appBskyHeaders(),
      );

      final data = response.data;
      final posts = data.feed;

      if (posts.isEmpty) break;

      for (final FeedViewPost feedViewPost in posts) {
        final postUri = feedViewPost.post.uri.toString();

        final existing = await _database.getLikedPost(accountDid, postUri);
        if (existing != null) {
          hitKnown = true;
          break;
        }

        final likedAt = feedViewPost.reason == null
            ? DateTime.now()
            : _extractLikedAt(feedViewPost.reason!, DateTime.now());

        final postJson = jsonEncode(feedViewPost.toJson());
        await _database.upsertLikedPost(
          LikedPostsCompanion(
            accountDid: Value(accountDid),
            postUri: Value(postUri),
            postJson: Value(postJson),
            likedAt: Value(likedAt),
          ),
        );
        _semanticIndexer?.queueIndexPost(postUri, postJson, accountDid, 'liked');
        fetched++;
      }

      if (hitKnown || data.cursor == null) break;
      cursor = data.cursor;
    }

    await _database.evictOldestLikedPosts(accountDid, _maxLikes);
  }

  /// Returns a paginated list of liked posts for [accountDid].
  Future<List<LikedPostEntry>> getLikedPosts(String accountDid, {int limit = 50, int offset = 0}) =>
      _database.getLikedPosts(accountDid, limit: limit, offset: offset);

  /// Removes a single liked post from local storage and the embedding index.
  Future<int> removeLike(String accountDid, String postUri) async {
    final result = await _database.removeLikedPost(accountDid, postUri);
    _semanticIndexer?.removePost(postUri);
    return result;
  }

  DateTime _extractLikedAt(dynamic reason, DateTime fallback) {
    try {
      final map = reason is Map ? reason : (reason as dynamic).toJson();
      final indexedAt = map['indexedAt'] as String?;
      if (indexedAt != null) {
        return DateTime.parse(indexedAt);
      }
    } catch (_) {}
    return fallback;
  }
}
