import 'package:drift/drift.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/post_interactions_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

/// Repository for managing post interactions (like, repost, bookmark).
///
/// Handles both remote API calls and local state persistence with optimistic updates.
class PostInteractionRepository {
  PostInteractionRepository(this._api, this._dao, this._logger);

  final XrpcClient _api;
  final PostInteractionsDao _dao;
  final Logger _logger;

  /// Likes a post.
  Future<void> like(String postUri, String postCid, String ownerDid) async {
    _logger.info('Liking post', {'uri': postUri, 'owner': ownerDid});

    final tempUri = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    await _dao.upsertInteraction(
      PostInteractionsCompanion.insert(
        postUri: postUri,
        ownerDid: ownerDid,
        likeUri: Value(tempUri),
        updatedAt: DateTime.now(),
      ),
    );

    try {
      final response = await _api.call(
        'com.atproto.repo.createRecord',
        body: {
          'repo': ownerDid,
          'collection': 'app.bsky.feed.like',
          'record': {
            r'$type': 'app.bsky.feed.like',
            'subject': {'uri': postUri, 'cid': postCid},
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          },
        },
      );

      final realUri = response['uri'] as String;
      await _dao.upsertInteraction(
        PostInteractionsCompanion.insert(
          postUri: postUri,
          ownerDid: ownerDid,
          likeUri: Value(realUri),
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e, stack) {
      _logger.error('Failed to like post', e, stack);

      await _dao.upsertInteraction(
        PostInteractionsCompanion.insert(
          postUri: postUri,
          ownerDid: ownerDid,
          likeUri: const Value(null),
          updatedAt: DateTime.now(),
        ),
      );
      rethrow;
    }
  }

  /// Unlikes a post.
  Future<void> unlike(String postUri, String likeUri, String ownerDid) async {
    _logger.info('Unliking post', {'uri': postUri, 'likeUri': likeUri});

    await _dao.upsertInteraction(
      PostInteractionsCompanion.insert(
        postUri: postUri,
        ownerDid: ownerDid,
        likeUri: const Value(null),
        updatedAt: DateTime.now(),
      ),
    );

    try {
      final parts = likeUri.split('/');
      final rkey = parts.last;

      await _api.call(
        'com.atproto.repo.deleteRecord',
        body: {'repo': ownerDid, 'collection': 'app.bsky.feed.like', 'rkey': rkey},
      );
    } catch (e, stack) {
      _logger.error('Failed to unlike post', e, stack);

      await _dao.upsertInteraction(
        PostInteractionsCompanion.insert(
          postUri: postUri,
          ownerDid: ownerDid,
          likeUri: Value(likeUri),
          updatedAt: DateTime.now(),
        ),
      );
      rethrow;
    }
  }

  /// Reposts a post.
  Future<void> repost(String postUri, String postCid, String ownerDid) async {
    _logger.info('Reposting post', {'uri': postUri, 'owner': ownerDid});

    final tempUri = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    await _dao.upsertInteraction(
      PostInteractionsCompanion.insert(
        postUri: postUri,
        ownerDid: ownerDid,
        repostUri: Value(tempUri),
        updatedAt: DateTime.now(),
      ),
    );

    try {
      final response = await _api.call(
        'com.atproto.repo.createRecord',
        body: {
          'repo': ownerDid,
          'collection': 'app.bsky.feed.repost',
          'record': {
            r'$type': 'app.bsky.feed.repost',
            'subject': {'uri': postUri, 'cid': postCid},
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          },
        },
      );

      final realUri = response['uri'] as String;
      await _dao.upsertInteraction(
        PostInteractionsCompanion.insert(
          postUri: postUri,
          ownerDid: ownerDid,
          repostUri: Value(realUri),
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e, stack) {
      _logger.error('Failed to repost post', e, stack);

      await _dao.upsertInteraction(
        PostInteractionsCompanion.insert(
          postUri: postUri,
          ownerDid: ownerDid,
          repostUri: const Value(null),
          updatedAt: DateTime.now(),
        ),
      );
      rethrow;
    }
  }

  /// Unreposts a post.
  Future<void> unrepost(String postUri, String repostUri, String ownerDid) async {
    _logger.info('Unreposting post', {'uri': postUri, 'repostUri': repostUri});

    await _dao.upsertInteraction(
      PostInteractionsCompanion.insert(
        postUri: postUri,
        ownerDid: ownerDid,
        repostUri: const Value(null),
        updatedAt: DateTime.now(),
      ),
    );

    try {
      final parts = repostUri.split('/');
      final rkey = parts.last;

      await _api.call(
        'com.atproto.repo.deleteRecord',
        body: {'repo': ownerDid, 'collection': 'app.bsky.feed.repost', 'rkey': rkey},
      );
    } catch (e, stack) {
      _logger.error('Failed to unrepost post', e, stack);

      await _dao.upsertInteraction(
        PostInteractionsCompanion.insert(
          postUri: postUri,
          ownerDid: ownerDid,
          repostUri: Value(repostUri),
          updatedAt: DateTime.now(),
        ),
      );
      rethrow;
    }
  }

  /// Bookmarks a post.
  Future<void> bookmark(String postUri, String postCid, String ownerDid) async {
    _logger.info('Bookmarking post', {'uri': postUri});

    await _dao.upsertInteraction(
      PostInteractionsCompanion.insert(
        postUri: postUri,
        ownerDid: ownerDid,
        bookmarked: const Value(true),
        bookmarkUri: const Value('temp-bookmark'),
        updatedAt: DateTime.now(),
      ),
    );

    try {
      final response = await _api.call(
        'app.bsky.bookmark.createBookmark',
        body: {
          'subject': {'uri': postUri, 'cid': postCid},
        },
      );

      final uri = response['uri'] as String;
      await _dao.upsertInteraction(
        PostInteractionsCompanion.insert(
          postUri: postUri,
          ownerDid: ownerDid,
          bookmarked: const Value(true),
          bookmarkUri: Value(uri),
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e, stack) {
      _logger.error('Failed to bookmark post', e, stack);

      await _dao.upsertInteraction(
        PostInteractionsCompanion.insert(
          postUri: postUri,
          ownerDid: ownerDid,
          bookmarked: const Value(false),
          bookmarkUri: const Value(null),
          updatedAt: DateTime.now(),
        ),
      );
      rethrow;
    }
  }

  /// Unbookmarks a post.
  Future<void> unbookmark(String postUri, String bookmarkUri, String ownerDid) async {
    _logger.info('Unbookmarking post', {'uri': postUri, 'bookmarkUri': bookmarkUri});

    await _dao.upsertInteraction(
      PostInteractionsCompanion.insert(
        postUri: postUri,
        ownerDid: ownerDid,
        bookmarked: const Value(false),
        bookmarkUri: const Value(null),
        updatedAt: DateTime.now(),
      ),
    );

    try {
      await _api.call('app.bsky.bookmark.deleteBookmark', body: {'uri': postUri});
    } catch (e, stack) {
      _logger.error('Failed to unbookmark post', e, stack);
      await _dao.upsertInteraction(
        PostInteractionsCompanion.insert(
          postUri: postUri,
          ownerDid: ownerDid,
          bookmarked: const Value(true),
          bookmarkUri: Value(bookmarkUri),
          updatedAt: DateTime.now(),
        ),
      );
      rethrow;
    }
  }
}
