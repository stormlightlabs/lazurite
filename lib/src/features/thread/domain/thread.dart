import 'dart:convert';

import 'package:drift/drift.dart' hide JsonKey;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lazurite/src/core/domain/author.dart' as core;
import 'package:lazurite/src/core/domain/content_label.dart';
import 'package:lazurite/src/core/domain/post.dart' as domain;
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';

part 'thread.freezed.dart';
part 'thread.g.dart';

@Freezed(unionKey: r'$type', unionValueCase: FreezedUnionCase.pascal)
sealed class ThreadViewPost with _$ThreadViewPost {
  const ThreadViewPost._();

  @FreezedUnionValue('app.bsky.feed.defs#threadViewPost')
  const factory ThreadViewPost.item({
    required ThreadPost post,
    ThreadViewPost? parent,
    @Default([]) List<ThreadViewPost> replies,
    Threadgate? threadgate,
  }) = _ThreadViewPostView;

  @FreezedUnionValue('app.bsky.feed.defs#blockedPost')
  const factory ThreadViewPost.blocked({
    required String uri,
    @Default(true) bool blocked,
    ThreadAuthor? author,
  }) = _ThreadViewPostBlocked;

  @FreezedUnionValue('app.bsky.feed.defs#notFoundPost')
  const factory ThreadViewPost.notFound({required String uri, @Default(true) bool notFound}) =
      _ThreadViewPostNotFound;

  factory ThreadViewPost({
    required ThreadPost post,
    ThreadViewPost? parent,
    List<ThreadViewPost> replies = const [],
    Threadgate? threadgate,
    bool isBlocked = false,
    bool isNotFound = false,
  }) {
    if (isBlocked) {
      return ThreadViewPost.blocked(uri: post.uri, blocked: true, author: post.author);
    }
    if (isNotFound) {
      return ThreadViewPost.notFound(uri: post.uri, notFound: true);
    }
    return ThreadViewPost.item(
      post: post,
      parent: parent,
      replies: replies,
      threadgate: threadgate,
    );
  }

  factory ThreadViewPost.fromJson(Map<String, dynamic> json) => _$ThreadViewPostFromJson(json);

  ThreadPost get post {
    return maybeWhen(
      item: (post, _, _, _) => post,
      blocked: (uri, _, _) =>
          ThreadPost.placeholder(uri: uri, reason: 'Post blocked', isBlocked: true),
      notFound: (uri, _) =>
          ThreadPost.placeholder(uri: uri, reason: 'Post not found', isNotFound: true),
      orElse: () => ThreadPost.placeholder(uri: 'unknown', reason: 'Unsupported thread item'),
    );
  }

  ThreadViewPost? get parent => maybeWhen(item: (_, parent, _, _) => parent, orElse: () => null);

  List<ThreadViewPost> get replies =>
      maybeWhen(item: (_, _, replies, _) => replies, orElse: () => const []);

  Threadgate? get threadgate =>
      maybeWhen(item: (_, _, _, threadgate) => threadgate, orElse: () => null);

  bool get isBlocked => maybeWhen(blocked: (_, _, _) => true, orElse: () => false);

  bool get isNotFound => maybeWhen(notFound: (_, _) => true, orElse: () => false);

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
  factory ThreadPost.fromJson(Map<String, dynamic> json) => _$ThreadPostFromJson(json);

  factory ThreadPost.placeholder({
    required String uri,
    required String reason,
    bool isBlocked = false,
    bool isNotFound = false,
  }) => ThreadPost(
    uri: uri,
    cid: uri,
    author: ThreadAuthor(did: 'placeholder:$uri', handle: 'unknown', displayName: reason),
    record: {'text': reason},
    placeholderReason: reason,
    indexedAt: DateTime.now(),
    isBlocked: isBlocked,
    isNotFound: isNotFound,
  );

  const factory ThreadPost({
    required String uri,
    String? cid,
    required ThreadAuthor author,
    required Map<String, dynamic> record,
    @JsonKey(fromJson: _transformEmbed) String? embed,
    DateTime? indexedAt,
    @Default(0) int replyCount,
    @Default(0) int repostCount,
    @Default(0) int likeCount,
    @Default(0) int quoteCount,
    @Default(0) int bookmarkCount,
    List<ContentLabel>? labels,
    PostViewer? viewer,
    String? placeholderReason,
    @Default(false) bool isBlocked,
    @Default(false) bool isNotFound,
  }) = _ThreadPost;

  const ThreadPost._();

  String get effectiveCid => cid ?? uri;

  String? get viewerLikeUri => viewer?.like;
  String? get viewerRepostUri => viewer?.repost;
  bool get viewerBookmarked => viewer?.bookmarked ?? false;
  bool get viewerThreadMuted => viewer?.threadMuted ?? false;
  bool get viewerReplyDisabled => viewer?.replyDisabled ?? false;

  @override
  Map<String, dynamic> toJson() => _$ThreadPostToJson(this as _ThreadPost);

  PostsCompanion toPostsCompanion() => PostsCompanion.insert(
    uri: uri,
    cid: effectiveCid,
    authorDid: author.did,
    record: jsonEncode(record),
    embed: Value(embed),
    indexedAt: Value(indexedAt),
    replyCount: Value(replyCount),
    repostCount: Value(repostCount),
    likeCount: Value(likeCount),
    quoteCount: Value(quoteCount),
    bookmarkCount: Value(bookmarkCount),
    labels: Value(labels != null ? jsonEncode(labels) : null),
    viewerLikeUri: Value(viewer?.like),
    viewerRepostUri: Value(viewer?.repost),
    viewerBookmarked: Value(viewer?.bookmarked ?? false),
    viewerThreadMuted: Value(viewer?.threadMuted ?? false),
    viewerReplyDisabled: Value(viewer?.replyDisabled ?? false),
  );

  ProfilesCompanion toProfilesCompanion() => ProfilesCompanion.insert(
    did: author.did,
    handle: author.handle,
    displayName: Value(author.displayName ?? placeholderReason),
    description: Value(author.description),
    avatar: Value(author.avatar),
    indexedAt: Value(indexedAt),
  );

  ProfileRelationshipsCompanion? toRelationshipCompanion(String ownerDid) {
    final v = author.viewer;
    if (v == null) return null;

    return ProfileRelationshipsCompanion.insert(
      ownerDid: ownerDid,
      profileDid: author.did,
      following: Value(v.following != null),
      followingUri: Value(v.following),
      followedBy: Value(v.followedBy != null),
      muted: Value(v.muted),
      blocked: Value(v.blocking != null),
      blockingUri: Value(v.blocking),
      blockedBy: Value(v.blockedBy),
      mutedByList: Value(v.mutedByList),
      blockingByList: Value(v.blockingByList),
      updatedAt: DateTime.now(),
    );
  }

  domain.Post toPostModel() => domain.Post(
    uri: uri,
    cid: effectiveCid,
    author: author.toAuthorModel(),
    text: record['text'] as String? ?? '',
    embed: embed != null ? jsonDecode(embed!) as Map<String, dynamic> : null,
    record: record,
    indexedAt: indexedAt,
    replyCount: replyCount,
    repostCount: repostCount,
    likeCount: likeCount,
    viewerLikeUri: viewer?.like,
    viewerRepostUri: viewer?.repost,
    viewerBookmarked: viewer?.bookmarked ?? false,
  );

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

  FeedPost toFeedPost({String? reason}) => FeedPost(
    post: Post(
      uri: uri,
      cid: effectiveCid,
      authorDid: author.did,
      record: jsonEncode(record),
      embed: embed,
      indexedAt: indexedAt,
      replyCount: replyCount,
      repostCount: repostCount,
      likeCount: likeCount,
      quoteCount: quoteCount,
      bookmarkCount: bookmarkCount,
      labels: labels != null ? jsonEncode(labels) : null,
      viewerLikeUri: viewer?.like,
      viewerRepostUri: viewer?.repost,
      viewerBookmarked: viewer?.bookmarked ?? false,
      viewerThreadMuted: viewer?.threadMuted ?? false,
      viewerReplyDisabled: viewer?.replyDisabled ?? false,
    ),
    author: toProfileModel(),
    reason: reason,
  );
}

String? _transformEmbed(Object? embed) {
  if (embed == null) return null;
  if (embed is String) return embed;
  return jsonEncode(embed);
}

@freezed
abstract class PostViewer with _$PostViewer {
  const factory PostViewer({
    String? like,
    String? repost,
    @Default(false) bool bookmarked,
    @Default(false) bool threadMuted,
    @Default(false) bool replyDisabled,
    String? embedding,
  }) = _PostViewer;

  factory PostViewer.fromJson(Map<String, dynamic> json) => _$PostViewerFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PostViewerToJson(this as _PostViewer);
}

@freezed
abstract class ThreadAuthor with _$ThreadAuthor {
  const factory ThreadAuthor({
    required String did,
    required String handle,
    String? displayName,
    String? description,
    String? avatar,
    ActorViewer? viewer,
    List<ContentLabel>? labels,
  }) = _ThreadAuthor;

  const ThreadAuthor._();

  factory ThreadAuthor.fromJson(Map<String, dynamic> json) => _$ThreadAuthorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ThreadAuthorToJson(this as _ThreadAuthor);

  core.Author toAuthorModel() {
    return core.Author(did: did, handle: handle, displayName: displayName, avatar: avatar);
  }

  ProfilesCompanion toProfilesCompanion() {
    return ProfilesCompanion.insert(
      did: did,
      handle: handle,
      displayName: Value(displayName),
      description: Value(description),
      avatar: Value(avatar),
    );
  }

  ProfileRelationshipsCompanion? toRelationshipCompanion(String ownerDid) {
    final v = viewer;
    if (v == null) return null;

    return ProfileRelationshipsCompanion.insert(
      ownerDid: ownerDid,
      profileDid: did,
      following: Value(v.following != null),
      followingUri: Value(v.following),
      followedBy: Value(v.followedBy != null),
      muted: Value(v.muted),
      blocked: Value(v.blocking != null),
      blockingUri: Value(v.blocking),
      blockedBy: Value(v.blockedBy),
      mutedByList: Value(v.mutedByList),
      blockingByList: Value(v.blockingByList),
      updatedAt: DateTime.now(),
    );
  }
}

@freezed
abstract class ActorViewer with _$ActorViewer {
  const factory ActorViewer({
    String? following,
    String? followedBy,
    @Default(false) bool muted,
    String? blocking,
    @Default(false) bool blockedBy,
    String? mutedByList,
    String? blockingByList,
    @Default(false) bool knownFollowers,
  }) = _ActorViewer;

  factory ActorViewer.fromJson(Map<String, dynamic> json) => _$ActorViewerFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ActorViewerToJson(this as _ActorViewer);
}

@freezed
abstract class Threadgate with _$Threadgate {
  const factory Threadgate({
    required String uri,
    String? cid,
    ThreadgateRecord? record,
    @Default([]) List<Map<String, dynamic>> lists,
  }) = _Threadgate;

  const Threadgate._();

  factory Threadgate.fromJson(Map<String, dynamic> json) => _$ThreadgateFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ThreadgateToJson(this as _Threadgate);

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

@freezed
abstract class ThreadgateRecord with _$ThreadgateRecord {
  const factory ThreadgateRecord({
    required String post,
    @Default([]) List<Map<String, dynamic>> allow,
    DateTime? createdAt,
  }) = _ThreadgateRecord;

  const ThreadgateRecord._();

  factory ThreadgateRecord.fromJson(Map<String, dynamic> json) => _$ThreadgateRecordFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ThreadgateRecordToJson(this as _ThreadgateRecord);
}
