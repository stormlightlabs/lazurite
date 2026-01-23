// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dm_conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DmConversation _$DmConversationFromJson(Map<String, dynamic> json) => _DmConversation(
  convoId: json['convoId'] as String,
  members: (json['members'] as List<dynamic>)
      .map((e) => Author.fromJson(e as Map<String, dynamic>))
      .toList(),
  lastMessageText: json['lastMessageText'] as String?,
  lastMessageAt: json['lastMessageAt'] == null
      ? null
      : DateTime.parse(json['lastMessageAt'] as String),
  lastReadMessageId: json['lastReadMessageId'] as String?,
  unreadCount: (json['unreadCount'] as num).toInt(),
  isMuted: json['isMuted'] as bool,
  isAccepted: json['isAccepted'] as bool,
);

Map<String, dynamic> _$DmConversationToJson(_DmConversation instance) => <String, dynamic>{
  'convoId': instance.convoId,
  'members': instance.members,
  'lastMessageText': instance.lastMessageText,
  'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
  'lastReadMessageId': instance.lastReadMessageId,
  'unreadCount': instance.unreadCount,
  'isMuted': instance.isMuted,
  'isAccepted': instance.isAccepted,
};
