// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListView _$ListViewFromJson(Map<String, dynamic> json) => _ListView(
  uri: json['uri'] as String,
  cid: json['cid'] as String,
  creator: ActorBasic.fromJson(json['creator'] as Map<String, dynamic>),
  name: json['name'] as String,
  purpose: json['purpose'] as String,
  description: json['description'] as String?,
  avatar: json['avatar'] as String?,
  listItemCount: (json['listItemCount'] as num?)?.toInt(),
  indexedAt: json['indexedAt'] == null ? null : DateTime.parse(json['indexedAt'] as String),
);

Map<String, dynamic> _$ListViewToJson(_ListView instance) => <String, dynamic>{
  'uri': instance.uri,
  'cid': instance.cid,
  'creator': instance.creator,
  'name': instance.name,
  'purpose': instance.purpose,
  'description': instance.description,
  'avatar': instance.avatar,
  'listItemCount': instance.listItemCount,
  'indexedAt': instance.indexedAt?.toIso8601String(),
};
