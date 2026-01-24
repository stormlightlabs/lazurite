// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Post _$PostFromJson(Map<String, dynamic> json) => _Post(
  uri: json['uri'] as String,
  cid: json['cid'] as String,
  author: Author.fromJson(json['author'] as Map<String, dynamic>),
  text: json['text'] as String,
  indexedAt: json['indexedAt'] == null ? null : DateTime.parse(json['indexedAt'] as String),
  replyCount: (json['replyCount'] as num?)?.toInt() ?? 0,
  repostCount: (json['repostCount'] as num?)?.toInt() ?? 0,
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  embed: json['embed'] as Map<String, dynamic>?,
  record: json['record'] as Map<String, dynamic>?,
  facets: json['facets'] as List<dynamic>?,
  viewerLikeUri: json['viewerLikeUri'] as String?,
  viewerRepostUri: json['viewerRepostUri'] as String?,
  viewerBookmarked: json['viewerBookmarked'] as bool? ?? false,
  isReply: json['isReply'] as bool? ?? false,
  isRepost: json['isRepost'] as bool? ?? false,
  isQuote: json['isQuote'] as bool? ?? false,
  hasImages: json['hasImages'] as bool? ?? false,
  hasVideo: json['hasVideo'] as bool? ?? false,
  embedType: json['embedType'] as String?,
);

Map<String, dynamic> _$PostToJson(_Post instance) => <String, dynamic>{
  'uri': instance.uri,
  'cid': instance.cid,
  'author': instance.author,
  'text': instance.text,
  'indexedAt': instance.indexedAt?.toIso8601String(),
  'replyCount': instance.replyCount,
  'repostCount': instance.repostCount,
  'likeCount': instance.likeCount,
  'embed': instance.embed,
  'record': instance.record,
  'facets': instance.facets,
  'viewerLikeUri': instance.viewerLikeUri,
  'viewerRepostUri': instance.viewerRepostUri,
  'viewerBookmarked': instance.viewerBookmarked,
  'isReply': instance.isReply,
  'isRepost': instance.isRepost,
  'isQuote': instance.isQuote,
  'hasImages': instance.hasImages,
  'hasVideo': instance.hasVideo,
  'embedType': instance.embedType,
};
