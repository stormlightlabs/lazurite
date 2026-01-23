import 'dart:convert';

import 'package:drift/drift.dart' hide JsonKey;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lazurite/src/core/domain/author.dart' as core;
import 'package:lazurite/src/core/domain/post.dart' as domain;
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';

part 'thread.freezed.dart';
part 'thread.g.dart';

/// Domain model for a thread view post.
@freezed
abstract class ThreadViewPost with _$ThreadViewPost {
  const factory ThreadViewPost({
    required ThreadPost post,
    ThreadViewPost? parent,
    @Default([]) List<ThreadViewPost> replies,
    Threadgate? threadgate,
    @Default(false) bool isBlocked,
    @Default(false) bool isNotFound,
  }) = _ThreadViewPost;

  const ThreadViewPost._();

  factory ThreadViewPost.fromJson(Map<String, dynamic> json) {
    final type = json[r'$type'] as String?;
    switch (type) {
      case 'app.bsky.feed.defs#threadViewPost':
        return ThreadViewPost(
          post: ThreadPost.fromJson(json['post'] as Map<String, dynamic>),
          parent: json['parent'] != null
              ? ThreadViewPost.fromJson(json['parent'] as Map<String, dynamic>)
              : null,
          replies:
              (json['replies'] as List?)
                  ?.map((e) => ThreadViewPost.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const [],
          threadgate: json['threadgate'] != null
              ? Threadgate.fromJson(json['threadgate'] as Map<String, dynamic>)
              : null,
        );
      case 'app.bsky.feed.defs#blockedPost':
        return ThreadViewPost(
          post: ThreadPost.placeholder(
            uri: json['uri'] as String? ?? 'unknown',
            reason: 'Post blocked',
            isBlocked: true,
          ),
          isBlocked: true,
        );
      case 'app.bsky.feed.defs#notFoundPost':
        return ThreadViewPost(
          post: ThreadPost.placeholder(
            uri: json['uri'] as String? ?? 'unknown',
            reason: 'Post not found',
            isNotFound: true,
          ),
          isNotFound: true,
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

/// Domain model for a thread post.
@freezed
abstract class ThreadPost with _$ThreadPost {
  const factory ThreadPost({
    required String uri,
    required String cid,
    required ThreadAuthor author,
    required Map<String, dynamic> record,
    String? embed,
    DateTime? indexedAt,
    @Default(0) int replyCount,
    @Default(0) int repostCount,
    @Default(0) int likeCount,
    @Default(0) int quoteCount,
    @Default(0) int bookmarkCount,
    String? labels,
    String? viewerLikeUri,
    String? viewerRepostUri,
    @Default(false) bool viewerBookmarked,
    @Default(false) bool viewerThreadMuted,
    @Default(false) bool viewerReplyDisabled,
    String? placeholderReason,
    @Default(false) bool isBlocked,
    @Default(false) bool isNotFound,
  }) = _ThreadPost;

  const ThreadPost._();

  factory ThreadPost.fromJson(Map<String, dynamic> json) {
    final viewer = json['viewer'] as Map<String, dynamic>?;
    final labelsJson = json['labels'] as List?;

    return ThreadPost(
      uri: json['uri'] as String,
      cid: json['cid'] as String? ?? json['uri'] as String,
      author: ThreadAuthor.fromJson(json['author'] as Map<String, dynamic>),
      record: (json['record'] as Map<String, dynamic>?) ?? const {},
      embed: json['embed'] != null ? jsonEncode(json['embed']) : null,
      indexedAt: DateTime.tryParse(json['indexedAt'] as String? ?? ''),
      replyCount: json['replyCount'] as int? ?? 0,
      repostCount: json['repostCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      quoteCount: json['quoteCount'] as int? ?? 0,
      bookmarkCount: json['bookmarkCount'] as int? ?? 0,
      labels: labelsJson != null ? jsonEncode(labelsJson) : null,
      viewerLikeUri: viewer?['like'] as String?,
      viewerRepostUri: viewer?['repost'] as String?,
      viewerBookmarked: viewer?['bookmarked'] as bool? ?? false,
      viewerThreadMuted: viewer?['threadMuted'] as bool? ?? false,
      viewerReplyDisabled: viewer?['replyDisabled'] as bool? ?? false,
    );
  }

  factory ThreadPost.placeholder({
    required String uri,
    required String reason,
    bool isBlocked = false,
    bool isNotFound = false,
  }) {
    return ThreadPost(
      uri: uri,
      cid: uri,
      author: ThreadAuthor(did: 'placeholder:$uri', handle: 'unknown', displayName: reason),
      record: {'text': reason},
      placeholderReason: reason,
      indexedAt: DateTime.now(),
      isBlocked: isBlocked,
      isNotFound: isNotFound,
    );
  }

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
      quoteCount: Value(quoteCount),
      bookmarkCount: Value(bookmarkCount),
      labels: Value(labels),
      viewerLikeUri: Value(viewerLikeUri),
      viewerRepostUri: Value(viewerRepostUri),
      viewerBookmarked: Value(viewerBookmarked),
      viewerThreadMuted: Value(viewerThreadMuted),
      viewerReplyDisabled: Value(viewerReplyDisabled),
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

  ProfileRelationshipsCompanion? toRelationshipCompanion(String ownerDid) {
    final viewer = author.viewer;
    if (viewer == null) return null;

    return ProfileRelationshipsCompanion.insert(
      ownerDid: ownerDid,
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

  domain.Post toPostModel() {
    return domain.Post(
      uri: uri,
      cid: cid,
      author: author.toAuthorModel(),
      text: record['text'] as String? ?? '',
      embed: embed != null ? jsonDecode(embed!) as Map<String, dynamic> : null,
      record: record,
      indexedAt: indexedAt,
      replyCount: replyCount,
      repostCount: repostCount,
      likeCount: likeCount,
      viewerLikeUri: viewerLikeUri,
      viewerRepostUri: viewerRepostUri,
      viewerBookmarked: viewerBookmarked,
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
    final driftPost = Post(
      uri: uri,
      cid: cid,
      authorDid: author.did,
      record: jsonEncode(record),
      embed: embed,
      indexedAt: indexedAt,
      replyCount: replyCount,
      repostCount: repostCount,
      likeCount: likeCount,
      quoteCount: quoteCount,
      bookmarkCount: bookmarkCount,
      labels: labels,
      viewerLikeUri: viewerLikeUri,
      viewerRepostUri: viewerRepostUri,
      viewerBookmarked: viewerBookmarked,
      viewerThreadMuted: viewerThreadMuted,
      viewerReplyDisabled: viewerReplyDisabled,
    );
    return FeedPost(post: driftPost, author: toProfileModel(), reason: reason);
  }
}

/// Domain model for a thread author.
@freezed
abstract class ThreadAuthor with _$ThreadAuthor {
  const factory ThreadAuthor({
    required String did,
    required String handle,
    String? displayName,
    String? description,
    String? avatar,
    Map<String, dynamic>? viewer,
  }) = _ThreadAuthor;

  const ThreadAuthor._();

  factory ThreadAuthor.fromJson(Map<String, dynamic> json) => _$ThreadAuthorFromJson(json);

  core.Author toAuthorModel() {
    return core.Author(did: did, handle: handle, displayName: displayName, avatar: avatar);
  }
}

/// Threadgate represents reply restrictions on a post.
@freezed
abstract class Threadgate with _$Threadgate {
  const factory Threadgate({
    required String uri,
    String? cid,
    ThreadgateRecord? record,
    @Default([]) List<Map<String, dynamic>> lists,
  }) = _Threadgate;

  const Threadgate._();

  factory Threadgate.fromJson(Map<String, dynamic> json) {
    final recordJson = json['record'] as Map<String, dynamic>?;
    final listsJson = json['lists'] as List?;

    return Threadgate(
      uri: json['uri'] as String? ?? '',
      cid: json['cid'] as String?,
      record: recordJson != null ? ThreadgateRecord.fromJson(recordJson) : null,
      lists: listsJson?.map((e) => e as Map<String, dynamic>).toList() ?? const [],
    );
  }

  /// Returns readable description of reply restriction.
  String get restrictionDescription {
    if (record == null) return 'Replies restricted';
    final allowRules = record!.allow;
    if (allowRules.isEmpty) return 'Replies disabled';

    final descriptions = <String>[];
    for (final rule in allowRules) {
      final type = rule[r'$type'] as String?;
      switch (type) {
        case 'app.bsky.feed.threadgate#mentionRule':
          descriptions.add('mentioned users');
        case 'app.bsky.feed.threadgate#followingRule':
          descriptions.add('accounts the author follows');
        case 'app.bsky.feed.threadgate#listRule':
          descriptions.add('list members');
        default:
          descriptions.add('specific users');
      }
    }
    return 'Replies limited to ${descriptions.join(', ')}';
  }
}

/// Threadgate record with allow rules.
@freezed
abstract class ThreadgateRecord with _$ThreadgateRecord {
  const factory ThreadgateRecord({
    required String post,
    @Default([]) List<Map<String, dynamic>> allow,
    DateTime? createdAt,
  }) = _ThreadgateRecord;

  const ThreadgateRecord._();

  factory ThreadgateRecord.fromJson(Map<String, dynamic> json) {
    final allowJson = json['allow'] as List?;
    return ThreadgateRecord(
      post: json['post'] as String? ?? '',
      allow: allowJson?.map((e) => e as Map<String, dynamic>).toList() ?? const [],
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}
