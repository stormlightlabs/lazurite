// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dm_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppDmMessage _$AppDmMessageFromJson(Map<String, dynamic> json) => _AppDmMessage(
  messageId: json['messageId'] as String,
  convoId: json['convoId'] as String,
  sender: Author.fromJson(json['sender'] as Map<String, dynamic>),
  content: json['content'] as String,
  sentAt: DateTime.parse(json['sentAt'] as String),
  status: $enumDecode(_$MessageStatusEnumMap, json['status']),
);

Map<String, dynamic> _$AppDmMessageToJson(_AppDmMessage instance) => <String, dynamic>{
  'messageId': instance.messageId,
  'convoId': instance.convoId,
  'sender': instance.sender,
  'content': instance.content,
  'sentAt': instance.sentAt.toIso8601String(),
  'status': _$MessageStatusEnumMap[instance.status]!,
};

const _$MessageStatusEnumMap = {
  MessageStatus.pending: 'pending',
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.read: 'read',
  MessageStatus.failed: 'failed',
  MessageStatus.deleted: 'deleted',
};
