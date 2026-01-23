// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Session _$SessionFromJson(Map<String, dynamic> json) => _Session(
  did: json['did'] as String,
  handle: json['handle'] as String,
  pdsUrl: json['pdsUrl'] as String,
  accessJwt: json['accessJwt'] as String,
  refreshJwt: json['refreshJwt'] as String,
  scope: json['scope'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  dpopKey: json['dpopKey'] as Map<String, dynamic>,
);

Map<String, dynamic> _$SessionToJson(_Session instance) => <String, dynamic>{
  'did': instance.did,
  'handle': instance.handle,
  'pdsUrl': instance.pdsUrl,
  'accessJwt': instance.accessJwt,
  'refreshJwt': instance.refreshJwt,
  'scope': instance.scope,
  'expiresAt': instance.expiresAt.toIso8601String(),
  'dpopKey': instance.dpopKey,
};
