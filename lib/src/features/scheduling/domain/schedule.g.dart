// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Schedule _$ScheduleFromJson(Map<String, dynamic> json) => _Schedule(
  draftId: json['draftId'] as String,
  ownerDid: json['ownerDid'] as String,
  scheduledAtUtc: DateTime.parse(json['scheduledAtUtc'] as String),
  status: $enumDecode(_$ScheduleStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  attempts: (json['attempts'] as num?)?.toInt() ?? 0,
  lastError: json['lastError'] as String?,
  postedUri: json['postedUri'] as String?,
  postedCid: json['postedCid'] as String?,
);

Map<String, dynamic> _$ScheduleToJson(_Schedule instance) => <String, dynamic>{
  'draftId': instance.draftId,
  'ownerDid': instance.ownerDid,
  'scheduledAtUtc': instance.scheduledAtUtc.toIso8601String(),
  'status': _$ScheduleStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'attempts': instance.attempts,
  'lastError': instance.lastError,
  'postedUri': instance.postedUri,
  'postedCid': instance.postedCid,
};

const _$ScheduleStatusEnumMap = {
  ScheduleStatus.scheduled: 'scheduled',
  ScheduleStatus.posting: 'posting',
  ScheduleStatus.posted: 'posted',
  ScheduleStatus.failed: 'failed',
};
