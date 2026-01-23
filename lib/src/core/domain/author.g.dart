// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Author _$AuthorFromJson(Map<String, dynamic> json) => _Author(
  did: json['did'] as String,
  handle: json['handle'] as String,
  displayName: json['displayName'] as String?,
  avatar: json['avatar'] as String?,
);

Map<String, dynamic> _$AuthorToJson(_Author instance) => <String, dynamic>{
  'did': instance.did,
  'handle': instance.handle,
  'displayName': instance.displayName,
  'avatar': instance.avatar,
};
