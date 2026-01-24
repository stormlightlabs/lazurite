// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileData _$ProfileDataFromJson(Map<String, dynamic> json) => _ProfileData(
  did: json['did'] as String,
  handle: json['handle'] as String,
  displayName: json['displayName'] as String?,
  description: json['description'] as String?,
  avatar: json['avatar'] as String?,
  banner: json['banner'] as String?,
  followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
  followsCount: (json['followsCount'] as num?)?.toInt() ?? 0,
  postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
  indexedAt: json['indexedAt'] == null ? null : DateTime.parse(json['indexedAt'] as String),
  createdAt: json['createdAt'] == null ? null : DateTime.parse(json['createdAt'] as String),
  pronouns: json['pronouns'] as String?,
  website: json['website'] as String?,
  verificationStatus: _parseVerification(json['verification']),
  pinnedPostUri: _parsePinnedPost(json['pinnedPost']),
  viewer: json['viewer'] == null
      ? null
      : ActorViewer.fromJson(json['viewer'] as Map<String, dynamic>),
  labels: (json['labels'] as List<dynamic>?)
      ?.map((e) => ContentLabel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProfileDataToJson(_ProfileData instance) => <String, dynamic>{
  'did': instance.did,
  'handle': instance.handle,
  'displayName': instance.displayName,
  'description': instance.description,
  'avatar': instance.avatar,
  'banner': instance.banner,
  'followersCount': instance.followersCount,
  'followsCount': instance.followsCount,
  'postsCount': instance.postsCount,
  'indexedAt': instance.indexedAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'pronouns': instance.pronouns,
  'website': instance.website,
  'verification': instance.verificationStatus,
  'pinnedPost': instance.pinnedPostUri,
  'viewer': instance.viewer,
  'labels': instance.labels,
};

_AuthorFeedResult _$AuthorFeedResultFromJson(Map<String, dynamic> json) => _AuthorFeedResult(
  items: (json['items'] as List<dynamic>)
      .map((e) => Post.fromJson(e as Map<String, dynamic>))
      .toList(),
  cursor: json['cursor'] as String?,
);

Map<String, dynamic> _$AuthorFeedResultToJson(_AuthorFeedResult instance) => <String, dynamic>{
  'items': instance.items,
  'cursor': instance.cursor,
};

_FollowersResult _$FollowersResultFromJson(Map<String, dynamic> json) => _FollowersResult(
  followers: (json['followers'] as List<dynamic>)
      .map((e) => Author.fromJson(e as Map<String, dynamic>))
      .toList(),
  cursor: json['cursor'] as String?,
);

Map<String, dynamic> _$FollowersResultToJson(_FollowersResult instance) => <String, dynamic>{
  'followers': instance.followers,
  'cursor': instance.cursor,
};

_FollowsResult _$FollowsResultFromJson(Map<String, dynamic> json) => _FollowsResult(
  follows: (json['follows'] as List<dynamic>)
      .map((e) => Author.fromJson(e as Map<String, dynamic>))
      .toList(),
  cursor: json['cursor'] as String?,
);

Map<String, dynamic> _$FollowsResultToJson(_FollowsResult instance) => <String, dynamic>{
  'follows': instance.follows,
  'cursor': instance.cursor,
};
