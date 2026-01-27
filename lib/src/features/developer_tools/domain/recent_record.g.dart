// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecentRecord _$RecentRecordFromJson(Map<String, dynamic> json) => _RecentRecord(
  uri: json['uri'] as String,
  did: json['did'] as String,
  collection: json['collection'] as String,
  rkey: json['rkey'] as String,
  cid: json['cid'] as String?,
  indexedAt: json['indexedAt'] == null ? null : DateTime.parse(json['indexedAt'] as String),
  viewedAt: DateTime.parse(json['viewedAt'] as String),
);

Map<String, dynamic> _$RecentRecordToJson(_RecentRecord instance) => <String, dynamic>{
  'uri': instance.uri,
  'did': instance.did,
  'collection': instance.collection,
  'rkey': instance.rkey,
  'cid': instance.cid,
  'indexedAt': instance.indexedAt?.toIso8601String(),
  'viewedAt': instance.viewedAt.toIso8601String(),
};
