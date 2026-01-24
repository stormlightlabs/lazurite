// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OutboxItem _$OutboxItemFromJson(Map<String, dynamic> json) => _OutboxItem(
  outboxId: json['outboxId'] as String,
  convoId: json['convoId'] as String,
  messageText: json['messageText'] as String,
  status: $enumDecode(_$OutboxStatusEnumMap, json['status']),
  retryCount: (json['retryCount'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastAttemptAt: json['lastAttemptAt'] == null
      ? null
      : DateTime.parse(json['lastAttemptAt'] as String),
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$OutboxItemToJson(_OutboxItem instance) => <String, dynamic>{
  'outboxId': instance.outboxId,
  'convoId': instance.convoId,
  'messageText': instance.messageText,
  'status': _$OutboxStatusEnumMap[instance.status]!,
  'retryCount': instance.retryCount,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastAttemptAt': instance.lastAttemptAt?.toIso8601String(),
  'errorMessage': instance.errorMessage,
};

const _$OutboxStatusEnumMap = {
  OutboxStatus.pending: 'pending',
  OutboxStatus.sending: 'sending',
  OutboxStatus.failed: 'failed',
};
