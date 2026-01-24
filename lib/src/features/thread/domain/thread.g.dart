// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ThreadViewPostView _$ThreadViewPostViewFromJson(Map<String, dynamic> json) => _ThreadViewPostView(
  post: ThreadPost.fromJson(json['post'] as Map<String, dynamic>),
  parent: json['parent'] == null
      ? null
      : ThreadViewPost.fromJson(json['parent'] as Map<String, dynamic>),
  replies:
      (json['replies'] as List<dynamic>?)
          ?.map((e) => ThreadViewPost.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  threadgate: json['threadgate'] == null
      ? null
      : Threadgate.fromJson(json['threadgate'] as Map<String, dynamic>),
  $type: json[r'$type'] as String?,
);

Map<String, dynamic> _$ThreadViewPostViewToJson(_ThreadViewPostView instance) => <String, dynamic>{
  'post': instance.post,
  'parent': instance.parent,
  'replies': instance.replies,
  'threadgate': instance.threadgate,
  r'$type': instance.$type,
};

_ThreadViewPostBlocked _$ThreadViewPostBlockedFromJson(Map<String, dynamic> json) =>
    _ThreadViewPostBlocked(
      uri: json['uri'] as String,
      blocked: json['blocked'] as bool? ?? true,
      author: json['author'] == null
          ? null
          : ThreadAuthor.fromJson(json['author'] as Map<String, dynamic>),
      $type: json[r'$type'] as String?,
    );

Map<String, dynamic> _$ThreadViewPostBlockedToJson(_ThreadViewPostBlocked instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'blocked': instance.blocked,
      'author': instance.author,
      r'$type': instance.$type,
    };

_ThreadViewPostNotFound _$ThreadViewPostNotFoundFromJson(Map<String, dynamic> json) =>
    _ThreadViewPostNotFound(
      uri: json['uri'] as String,
      notFound: json['notFound'] as bool? ?? true,
      $type: json[r'$type'] as String?,
    );

Map<String, dynamic> _$ThreadViewPostNotFoundToJson(_ThreadViewPostNotFound instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'notFound': instance.notFound,
      r'$type': instance.$type,
    };

_ThreadPost _$ThreadPostFromJson(Map<String, dynamic> json) => _ThreadPost(
  uri: json['uri'] as String,
  cid: json['cid'] as String?,
  author: ThreadAuthor.fromJson(json['author'] as Map<String, dynamic>),
  record: json['record'] as Map<String, dynamic>,
  embed: _transformEmbed(json['embed']),
  indexedAt: json['indexedAt'] == null ? null : DateTime.parse(json['indexedAt'] as String),
  replyCount: (json['replyCount'] as num?)?.toInt() ?? 0,
  repostCount: (json['repostCount'] as num?)?.toInt() ?? 0,
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  quoteCount: (json['quoteCount'] as num?)?.toInt() ?? 0,
  bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
  labels: (json['labels'] as List<dynamic>?)
      ?.map((e) => ContentLabel.fromJson(e as Map<String, dynamic>))
      .toList(),
  viewer: json['viewer'] == null
      ? null
      : PostViewer.fromJson(json['viewer'] as Map<String, dynamic>),
  placeholderReason: json['placeholderReason'] as String?,
  isBlocked: json['isBlocked'] as bool? ?? false,
  isNotFound: json['isNotFound'] as bool? ?? false,
);

Map<String, dynamic> _$ThreadPostToJson(_ThreadPost instance) => <String, dynamic>{
  'uri': instance.uri,
  'cid': instance.cid,
  'author': instance.author,
  'record': instance.record,
  'embed': instance.embed,
  'indexedAt': instance.indexedAt?.toIso8601String(),
  'replyCount': instance.replyCount,
  'repostCount': instance.repostCount,
  'likeCount': instance.likeCount,
  'quoteCount': instance.quoteCount,
  'bookmarkCount': instance.bookmarkCount,
  'labels': instance.labels,
  'viewer': instance.viewer,
  'placeholderReason': instance.placeholderReason,
  'isBlocked': instance.isBlocked,
  'isNotFound': instance.isNotFound,
};

_PostViewer _$PostViewerFromJson(Map<String, dynamic> json) => _PostViewer(
  like: json['like'] as String?,
  repost: json['repost'] as String?,
  bookmarked: json['bookmarked'] as bool? ?? false,
  threadMuted: json['threadMuted'] as bool? ?? false,
  replyDisabled: json['replyDisabled'] as bool? ?? false,
  embedding: json['embedding'] as String?,
);

Map<String, dynamic> _$PostViewerToJson(_PostViewer instance) => <String, dynamic>{
  'like': instance.like,
  'repost': instance.repost,
  'bookmarked': instance.bookmarked,
  'threadMuted': instance.threadMuted,
  'replyDisabled': instance.replyDisabled,
  'embedding': instance.embedding,
};

_ThreadAuthor _$ThreadAuthorFromJson(Map<String, dynamic> json) => _ThreadAuthor(
  did: json['did'] as String,
  handle: json['handle'] as String,
  displayName: json['displayName'] as String?,
  description: json['description'] as String?,
  avatar: json['avatar'] as String?,
  viewer: json['viewer'] == null
      ? null
      : ActorViewer.fromJson(json['viewer'] as Map<String, dynamic>),
  labels: (json['labels'] as List<dynamic>?)
      ?.map((e) => ContentLabel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ThreadAuthorToJson(_ThreadAuthor instance) => <String, dynamic>{
  'did': instance.did,
  'handle': instance.handle,
  'displayName': instance.displayName,
  'description': instance.description,
  'avatar': instance.avatar,
  'viewer': instance.viewer,
  'labels': instance.labels,
};

_ActorViewer _$ActorViewerFromJson(Map<String, dynamic> json) => _ActorViewer(
  following: json['following'] as String?,
  followedBy: json['followedBy'] as String?,
  muted: json['muted'] as bool? ?? false,
  blocking: json['blocking'] as String?,
  blockedBy: json['blockedBy'] as bool? ?? false,
  mutedByList: json['mutedByList'] as String?,
  blockingByList: json['blockingByList'] as String?,
  knownFollowers: json['knownFollowers'] as bool? ?? false,
);

Map<String, dynamic> _$ActorViewerToJson(_ActorViewer instance) => <String, dynamic>{
  'following': instance.following,
  'followedBy': instance.followedBy,
  'muted': instance.muted,
  'blocking': instance.blocking,
  'blockedBy': instance.blockedBy,
  'mutedByList': instance.mutedByList,
  'blockingByList': instance.blockingByList,
  'knownFollowers': instance.knownFollowers,
};

_Threadgate _$ThreadgateFromJson(Map<String, dynamic> json) => _Threadgate(
  uri: json['uri'] as String,
  cid: json['cid'] as String?,
  record: json['record'] == null
      ? null
      : ThreadgateRecord.fromJson(json['record'] as Map<String, dynamic>),
  lists:
      (json['lists'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ??
      const [],
);

Map<String, dynamic> _$ThreadgateToJson(_Threadgate instance) => <String, dynamic>{
  'uri': instance.uri,
  'cid': instance.cid,
  'record': instance.record,
  'lists': instance.lists,
};

_ThreadgateRecord _$ThreadgateRecordFromJson(Map<String, dynamic> json) => _ThreadgateRecord(
  post: json['post'] as String,
  allow:
      (json['allow'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ??
      const [],
  createdAt: json['createdAt'] == null ? null : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ThreadgateRecordToJson(_ThreadgateRecord instance) => <String, dynamic>{
  'post': instance.post,
  'allow': instance.allow,
  'createdAt': instance.createdAt?.toIso8601String(),
};
