// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ThreadAuthor _$ThreadAuthorFromJson(Map<String, dynamic> json) => _ThreadAuthor(
  did: json['did'] as String,
  handle: json['handle'] as String,
  displayName: json['displayName'] as String?,
  description: json['description'] as String?,
  avatar: json['avatar'] as String?,
  viewer: json['viewer'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ThreadAuthorToJson(_ThreadAuthor instance) => <String, dynamic>{
  'did': instance.did,
  'handle': instance.handle,
  'displayName': instance.displayName,
  'description': instance.description,
  'avatar': instance.avatar,
  'viewer': instance.viewer,
};
