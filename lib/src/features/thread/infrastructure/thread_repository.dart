import 'dart:convert';

import 'package:lazurite/src/infrastructure/db/daos/timeline_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

class ThreadRepository {
  ThreadRepository(this._api, this._dao);

  final XrpcClient _api;
  final TimelineDao _dao;

  Future<ThreadViewPost> getPostThread(String uri) async {
    final response = await _api.call('app.bsky.feed.getPostThread', params: {'uri': uri});

    final thread = response['thread'] as Map<String, dynamic>;

    // TODO: Implement full thread structure caching.
    await _cacheThreadParticipants(thread);

    return ThreadViewPost.fromJson(thread);
  }

  Future<void> _cacheThreadParticipants(Map<String, dynamic> threadData) async {
    final posts = <PostInsert>[];
    final profiles = <ProfileInsert>[];

    void extract(Map<String, dynamic> data) {
      if (data[r'$type'] != 'app.bsky.feed.defs#threadViewPost') return;

      final post = data['post'] as Map<String, dynamic>;
      final author = post['author'] as Map<String, dynamic>;

      posts.add(
        PostInsert(
          uri: post['uri'],
          cid: post['cid'],
          authorDid: author['did'],
          record: jsonEncode(post['record']),
          indexedAt: DateTime.tryParse(post['indexedAt'] ?? ''),
        ),
      );

      profiles.add(
        ProfileInsert(
          did: author['did'],
          handle: author['handle'],
          displayName: author['displayName'],
          description: author['description'],
          avatar: author['avatar'],
        ),
      );

      final replies = data['replies'] as List?;
      if (replies != null) {
        for (final reply in replies) {
          extract(reply as Map<String, dynamic>);
        }
      }

      final parent = data['parent'];
      if (parent != null) {
        extract(parent as Map<String, dynamic>);
      }
    }

    extract(threadData);

    if (posts.isNotEmpty) {
      await _dao.insertTimeline(
        feedKey: 'thread_cache_temp',
        newPosts: posts,
        newProfiles: profiles,
        nextCursor: null,
      );
    }
  }
}

/// Domain model for a thread view post
class ThreadViewPost {
  factory ThreadViewPost.fromJson(Map<String, dynamic> json) {
    if (json[r'$type'] != 'app.bsky.feed.defs#threadViewPost') {
      // TODO: Handle blocked/not-found posts or other variants
      return ThreadViewPost(post: json['post'] ?? {}, parent: null, replies: []);
    }

    return ThreadViewPost(
      post: json['post'] as Map<String, dynamic>,
      parent: json['parent'] != null ? ThreadViewPost.fromJson(json['parent']) : null,
      replies:
          (json['replies'] as List?)
              ?.map((e) => ThreadViewPost.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
  ThreadViewPost({required this.post, this.parent, this.replies = const []});

  final Map<String, dynamic> post;
  final ThreadViewPost? parent;
  final List<ThreadViewPost> replies;
}
