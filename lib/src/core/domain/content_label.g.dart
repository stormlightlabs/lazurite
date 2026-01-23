// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_label.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContentLabel _$ContentLabelFromJson(Map<String, dynamic> json) => _ContentLabel(
  src: json['src'] as String,
  uri: json['uri'] as String,
  val: json['val'] as String,
  cts: DateTime.parse(json['cts'] as String),
  cid: json['cid'] as String?,
  neg: json['neg'] as bool?,
  ver: (json['ver'] as num?)?.toInt(),
);

Map<String, dynamic> _$ContentLabelToJson(_ContentLabel instance) => <String, dynamic>{
  'src': instance.src,
  'uri': instance.uri,
  'val': instance.val,
  'cts': instance.cts.toIso8601String(),
  'cid': ?instance.cid,
  'neg': ?instance.neg,
  'ver': ?instance.ver,
};
