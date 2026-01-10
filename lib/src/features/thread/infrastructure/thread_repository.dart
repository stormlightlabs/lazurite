import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';
import 'package:lazurite/src/infrastructure/network/network_failure.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

import '../domain/thread.dart';

class ThreadRepository {
  ThreadRepository(this._api, this._dao, this._logger);

  final XrpcClient _api;
  final FeedContentDao _dao;
  final Logger _logger;

  Future<ThreadViewPost> getPostThread(String uri, String ownerDid) async {
    _logger.info('Fetching thread', {'uri': uri, 'ownerDid': ownerDid});
    try {
      final response = await _api.call('app.bsky.feed.getPostThread', params: {'uri': uri});

      final threadJson = response['thread'] as Map<String, dynamic>;
      final thread = ThreadViewPost.fromJson(threadJson);

      await _cacheThread(thread, ownerDid);
      _logger.debug('Cached thread posts and participants');

      return thread;
    } catch (e, stack) {
      if (e is AuthFailure && e.message?.contains('nonce') == true) {
        _logger.warning('Failed to fetch thread (recoverable auth error): ${e.message}');
      } else {
        _logger.error('Failed to fetch thread', e, stack);
      }
      rethrow;
    }
  }

  Future<void> _cacheThread(ThreadViewPost thread, String ownerDid) async {
    final posts = <PostsCompanion>[];
    final profiles = <ProfilesCompanion>[];
    final relationships = <ProfileRelationshipsCompanion>[];
    final feedContentItems = <FeedContentItemsCompanion>[];
    final seenPosts = <String>{};
    final seenProfiles = <String>{};

    final feedKey = 'thread:${thread.post.uri}';
    var order = 0;

    void visit(ThreadViewPost node) {
      final postCompanion = node.post.toPostsCompanion();
      final profileCompanion = node.post.toProfilesCompanion();
      final relationshipCompanion = node.post.toRelationshipCompanion(ownerDid);

      if (seenPosts.add(node.post.uri)) {
        posts.add(postCompanion);
      }
      if (seenProfiles.add(node.post.author.did)) {
        profiles.add(profileCompanion);
        if (relationshipCompanion != null) {
          relationships.add(relationshipCompanion);
        }
      }

      feedContentItems.add(
        FeedContentItemsCompanion.insert(
          feedKey: feedKey,
          postUri: node.post.uri,
          ownerDid: ownerDid,
          sortKey: order.toString().padLeft(6, '0'),
        ),
      );
      order += 1;

      for (final reply in node.replies) {
        visit(reply);
      }
    }

    for (final parent in thread.ancestorChain) {
      visit(parent);
    }
    visit(thread);

    if (posts.isNotEmpty) {
      await _dao.insertFeedContentBatch(
        feedKey: feedKey,
        ownerDid: ownerDid,
        newPosts: posts,
        newProfiles: profiles,
        newRelationships: relationships,
        newItems: feedContentItems,
      );
    }
  }
}
