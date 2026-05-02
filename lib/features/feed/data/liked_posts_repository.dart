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
  /// Uses `app.bsky.feed.getActorLikes` for the signed-in account.
  /// Stops when the cursor is exhausted or [_maxLikes] posts are scanned.
  Future<void> syncLikes(String accountDid) async {
    String? cursor;
    var scanned = 0;

    while (scanned < _maxLikes) {
      final response = await _bluesky.feed.getActorLikes(
        actor: accountDid,
        limit: _pageSize,
        cursor: cursor,
        $headers: _appViewContext.appBskyHeadersWithoutProxy(),
      );

      final data = response.data;
      final posts = (data.feed as List<dynamic>).whereType<FeedViewPost>().toList(growable: false);

      if (posts.isEmpty) break;
      scanned += posts.length;

      for (final FeedViewPost feedViewPost in posts) {
        final postUri = feedViewPost.post.uri.toString();
        final likedAt = _resolveLikedAt(feedViewPost);
        final postJson = jsonEncode(feedViewPost.toJson());

        final existing = await _database.getLikedPost(accountDid, postUri);
        if (existing != null) {
          if (likedAt.isAfter(existing.likedAt)) {
            await _database.updateLikedPost(existing.id, postJson: postJson, likedAt: likedAt);
            _semanticIndexer?.queueIndexPost(postUri, postJson, accountDid, 'liked');
          }
          continue;
        }

        await _database.upsertLikedPost(
          LikedPostsCompanion(
            accountDid: Value(accountDid),
            postUri: Value(postUri),
            postJson: Value(postJson),
            likedAt: Value(likedAt),
          ),
        );
        _semanticIndexer?.queueIndexPost(postUri, postJson, accountDid, 'liked');
      }

      if (data.cursor == null) break;
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

  DateTime _resolveLikedAt(FeedViewPost feedViewPost) {
    final fromReason = _extractReasonIndexedAt(feedViewPost.reason);
    if (fromReason != null) {
      return fromReason;
    }

    final indexedAt = (feedViewPost.post as dynamic).indexedAt;
    if (indexedAt is DateTime) {
      return indexedAt.toUtc();
    }

    final createdAtRaw = feedViewPost.post.record['createdAt'];
    if (createdAtRaw is String) {
      final parsed = DateTime.tryParse(createdAtRaw);
      if (parsed != null) {
        return parsed.toUtc();
      }
    }

    // Deterministic fallback for malformed/missing timestamps.
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  DateTime? _extractReasonIndexedAt(dynamic reason) {
    if (reason == null) {
      return null;
    }
    try {
      final map = reason is Map ? reason : (reason as dynamic).toJson();
      final indexedAt = map['indexedAt'] as String?;
      if (indexedAt != null) {
        return DateTime.parse(indexedAt).toUtc();
      }
    } catch (_) {}
    return null;
  }
}
