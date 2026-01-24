// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_generator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActorBasic _$ActorBasicFromJson(Map<String, dynamic> json) => _ActorBasic(
  did: json['did'] as String,
  handle: json['handle'] as String,
  displayName: json['displayName'] as String?,
  avatar: json['avatar'] as String?,
  description: json['description'] as String?,
  indexedAt: json['indexedAt'] == null ? null : DateTime.parse(json['indexedAt'] as String),
  followersCount: (json['followersCount'] as num?)?.toInt(),
  followsCount: (json['followsCount'] as num?)?.toInt(),
  postsCount: (json['postsCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$ActorBasicToJson(_ActorBasic instance) => <String, dynamic>{
  'did': instance.did,
  'handle': instance.handle,
  'displayName': instance.displayName,
  'avatar': instance.avatar,
  'description': instance.description,
  'indexedAt': instance.indexedAt?.toIso8601String(),
  'followersCount': instance.followersCount,
  'followsCount': instance.followsCount,
  'postsCount': instance.postsCount,
};

_FeedGenerator _$FeedGeneratorFromJson(Map<String, dynamic> json) => _FeedGenerator(
  uri: json['uri'] as String,
  cid: json['cid'] as String,
  did: json['did'] as String,
  creator: ActorBasic.fromJson(json['creator'] as Map<String, dynamic>),
  displayName: json['displayName'] as String,
  description: json['description'] as String?,
  avatar: json['avatar'] as String?,
  likeCount: (json['likeCount'] as num?)?.toInt(),
  indexedAt: json['indexedAt'] == null ? null : DateTime.parse(json['indexedAt'] as String),
);

Map<String, dynamic> _$FeedGeneratorToJson(_FeedGenerator instance) => <String, dynamic>{
  'uri': instance.uri,
  'cid': instance.cid,
  'did': instance.did,
  'creator': instance.creator,
  'displayName': instance.displayName,
  'description': instance.description,
  'avatar': instance.avatar,
  'likeCount': instance.likeCount,
  'indexedAt': instance.indexedAt?.toIso8601String(),
};
