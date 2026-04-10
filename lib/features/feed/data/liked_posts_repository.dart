import 'dart:convert';

import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:drift/drift.dart' show Value;
import 'package:lazurite/core/database/app_database.dart';

class LikedPostsRepository {
  LikedPostsRepository({required dynamic bluesky, required AppDatabase database})
    : _bluesky = bluesky,
      _database = database;

  final dynamic _bluesky;
  final AppDatabase _database;

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
      final response = await _bluesky.feed.getActorLikes(actor: accountDid, limit: _pageSize, cursor: cursor);

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

        await _database.upsertLikedPost(
          LikedPostsCompanion(
            accountDid: Value(accountDid),
            postUri: Value(postUri),
            postJson: Value(jsonEncode(feedViewPost.toJson())),
            likedAt: Value(likedAt),
          ),
        );
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

  /// Removes a single liked post from local storage.
  Future<int> removeLike(String accountDid, String postUri) => _database.removeLikedPost(accountDid, postUri);

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
