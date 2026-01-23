// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) => _AppNotification(
  uri: json['uri'] as String,
  actor: Author.fromJson(json['actor'] as Map<String, dynamic>),
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  reasonSubjectUri: json['reasonSubjectUri'] as String?,
  recordJson: json['recordJson'] as String?,
  indexedAt: DateTime.parse(json['indexedAt'] as String),
  isRead: json['isRead'] as bool,
);

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) => <String, dynamic>{
  'uri': instance.uri,
  'actor': instance.actor,
  'type': _$NotificationTypeEnumMap[instance.type]!,
  'reasonSubjectUri': instance.reasonSubjectUri,
  'recordJson': instance.recordJson,
  'indexedAt': instance.indexedAt.toIso8601String(),
  'isRead': instance.isRead,
};

const _$NotificationTypeEnumMap = {
  NotificationType.like: 'like',
  NotificationType.repost: 'repost',
  NotificationType.follow: 'follow',
  NotificationType.mention: 'mention',
  NotificationType.reply: 'reply',
  NotificationType.quote: 'quote',
  NotificationType.starterpackJoined: 'starterpackJoined',
};
