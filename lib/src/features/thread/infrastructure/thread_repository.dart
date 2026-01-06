import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

class ThreadRepository {
  ThreadRepository(this._api, this._dao, this._logger);

  final XrpcClient _api;
  final FeedContentDao _dao;
  final Logger _logger;

  Future<ThreadViewPost> getPostThread(String uri) async {
    _logger.info('Fetching thread', {'uri': uri});
    try {
      final response = await _api.call('app.bsky.feed.getPostThread', params: {'uri': uri});

      final threadJson = response['thread'] as Map<String, dynamic>;
      final thread = ThreadViewPost.fromJson(threadJson);

      await _cacheThread(thread);
      _logger.debug('Cached thread posts and participants');

      return thread;
    } catch (e, stack) {
      _logger.error('Failed to fetch thread', e, stack);
      rethrow;
    }
  }

  Future<void> _cacheThread(ThreadViewPost thread) async {
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
      final relationshipCompanion = node.post.toRelationshipCompanion();

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
        newPosts: posts,
        newProfiles: profiles,
        newRelationships: relationships,
        newItems: feedContentItems,
      );
    }
  }
}

/// Domain model for a thread view post
class ThreadViewPost {
  factory ThreadViewPost.fromJson(Map<String, dynamic> json) {
    final type = json[r'$type'];
    switch (type) {
      case 'app.bsky.feed.defs#threadViewPost':
        return ThreadViewPost(
          post: ThreadPost.fromJson(json['post'] as Map<String, dynamic>),
          parent: json['parent'] != null ? ThreadViewPost.fromJson(json['parent']) : null,
          replies:
              (json['replies'] as List?)
                  ?.map((e) => ThreadViewPost.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [],
        );
      case 'app.bsky.feed.defs#blockedPost':
        return ThreadViewPost(
          post: ThreadPost.placeholder(
            uri: json['uri'] as String? ?? 'unknown',
            reason: 'Post blocked',
          ),
        );
      case 'app.bsky.feed.defs#notFoundPost':
        return ThreadViewPost(
          post: ThreadPost.placeholder(
            uri: json['uri'] as String? ?? 'unknown',
            reason: 'Post not found',
          ),
        );
      default:
        return ThreadViewPost(
          post: ThreadPost.placeholder(
            uri: json['uri'] as String? ?? 'unknown',
            reason: 'Unsupported thread item',
          ),
        );
    }
  }

  ThreadViewPost({required this.post, this.parent, this.replies = const []});

  final ThreadPost post;
  final ThreadViewPost? parent;
  final List<ThreadViewPost> replies;

  List<ThreadViewPost> get ancestorChain {
    final chain = <ThreadViewPost>[];
    var current = parent;
    while (current != null) {
      chain.add(current);
      current = current.parent;
    }
    return chain.reversed.toList();
  }
}

class ThreadPost {
  ThreadPost({
    required this.uri,
    required this.cid,
    required this.author,
    required this.record,
    this.embed,
    this.indexedAt,
    this.replyCount = 0,
    this.repostCount = 0,
    this.likeCount = 0,
    this.placeholderReason,
  });

  factory ThreadPost.fromJson(Map<String, dynamic> json) {
    final author = ThreadAuthor.fromJson(json['author'] as Map<String, dynamic>);
    return ThreadPost(
      uri: json['uri'] as String,
      cid: json['cid'] as String? ?? json['uri'] as String,
      author: author,
      record: (json['record'] as Map<String, dynamic>?) ?? const {},
      embed: json['embed'] != null ? jsonEncode(json['embed']) : null,
      indexedAt: DateTime.tryParse(json['indexedAt'] ?? ''),
      replyCount: json['replyCount'] as int? ?? 0,
      repostCount: json['repostCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
    );
  }

  factory ThreadPost.placeholder({required String uri, required String reason}) {
    return ThreadPost(
      uri: uri,
      cid: uri,
      author: ThreadAuthor(did: 'placeholder:$uri', handle: 'unknown', displayName: reason),
      record: {'text': reason},
      placeholderReason: reason,
      indexedAt: DateTime.now(),
    );
  }

  final String uri;
  final String cid;
  final ThreadAuthor author;
  final Map<String, dynamic> record;
  final String? embed;
  final DateTime? indexedAt;
  final int replyCount;
  final int repostCount;
  final int likeCount;
  final String? placeholderReason;

  PostsCompanion toPostsCompanion() {
    return PostsCompanion.insert(
      uri: uri,
      cid: cid,
      authorDid: author.did,
      record: jsonEncode(record),
      embed: Value(embed),
      indexedAt: Value(indexedAt),
      replyCount: Value(replyCount),
      repostCount: Value(repostCount),
      likeCount: Value(likeCount),
    );
  }

  ProfilesCompanion toProfilesCompanion() {
    return ProfilesCompanion.insert(
      did: author.did,
      handle: author.handle,
      displayName: Value(author.displayName ?? placeholderReason),
      description: Value(author.description),
      avatar: Value(author.avatar),
      indexedAt: Value(indexedAt),
    );
  }

  ProfileRelationshipsCompanion? toRelationshipCompanion() {
    final viewer = author.viewer;
    if (viewer == null) return null;

    return ProfileRelationshipsCompanion.insert(
      profileDid: author.did,
      following: Value(viewer['following'] != null),
      followingUri: Value(viewer['following'] as String?),
      followedBy: Value(viewer['followedBy'] != null),
      muted: Value(viewer['muted'] as bool? ?? false),
      blocked: Value(viewer['blocking'] != null),
      blockingUri: Value(viewer['blocking'] as String?),
      blockedBy: Value(viewer['blockedBy'] as bool? ?? false),
      mutedByList: Value(viewer['mutedByList']?['uri'] as String?),
      blockingByList: Value(viewer['blockingByList']?['uri'] as String?),
      updatedAt: DateTime.now(),
    );
  }

  Post toPostModel() {
    return Post(
      uri: uri,
      cid: cid,
      authorDid: author.did,
      record: jsonEncode(record),
      embed: embed,
      indexedAt: indexedAt,
      replyCount: replyCount,
      repostCount: repostCount,
      likeCount: likeCount,
    );
  }

  Profile toProfileModel() {
    return Profile(
      did: author.did,
      handle: author.handle,
      displayName: author.displayName ?? placeholderReason,
      description: author.description,
      avatar: author.avatar,
      indexedAt: indexedAt,
    );
  }

  FeedPost toFeedPost({String? reason}) {
    return FeedPost(post: toPostModel(), author: toProfileModel(), reason: reason);
  }
}

class ThreadAuthor {
  ThreadAuthor({
    required this.did,
    required this.handle,
    this.displayName,
    this.description,
    this.avatar,
    this.viewer,
  });

  factory ThreadAuthor.fromJson(Map<String, dynamic> json) {
    return ThreadAuthor(
      did: json['did'] as String,
      handle: json['handle'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
      viewer: json['viewer'] as Map<String, dynamic>?,
    );
  }

  final String did;
  final String handle;
  final String? displayName;
  final String? description;
  final String? avatar;
  final Map<String, dynamic>? viewer;
}
