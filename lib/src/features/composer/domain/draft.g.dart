// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Draft _$DraftFromJson(Map<String, dynamic> json) => _Draft(
  id: json['id'] as String,
  text: json['text'] as String,
  status: $enumDecode(_$DraftStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  media: (json['media'] as List<dynamic>)
      .map((e) => DraftMediaAttachment.fromJson(e as Map<String, dynamic>))
      .toList(),
  replyParentUri: json['replyParentUri'] as String?,
  replyParentCid: json['replyParentCid'] as String?,
  replyRootUri: json['replyRootUri'] as String?,
  replyRootCid: json['replyRootCid'] as String?,
  quoteUri: json['quoteUri'] as String?,
  quoteCid: json['quoteCid'] as String?,
  facetsJson: json['facetsJson'] as String?,
  externalUri: json['externalUri'] as String?,
  externalTitle: json['externalTitle'] as String?,
  externalDescription: json['externalDescription'] as String?,
  externalThumbBlobJson: json['externalThumbBlobJson'] as String?,
  errorMessage: json['errorMessage'] as String?,
  langs: (json['langs'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
  labels: (json['labels'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
  threadGateType: $enumDecodeNullable(_$ThreadGateTypeEnumMap, json['threadGateType']),
  quoteDisabled: json['quoteDisabled'] as bool? ?? false,
);

Map<String, dynamic> _$DraftToJson(_Draft instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'status': _$DraftStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'media': instance.media,
  'replyParentUri': instance.replyParentUri,
  'replyParentCid': instance.replyParentCid,
  'replyRootUri': instance.replyRootUri,
  'replyRootCid': instance.replyRootCid,
  'quoteUri': instance.quoteUri,
  'quoteCid': instance.quoteCid,
  'facetsJson': instance.facetsJson,
  'externalUri': instance.externalUri,
  'externalTitle': instance.externalTitle,
  'externalDescription': instance.externalDescription,
  'externalThumbBlobJson': instance.externalThumbBlobJson,
  'errorMessage': instance.errorMessage,
  'langs': instance.langs,
  'labels': instance.labels,
  'threadGateType': _$ThreadGateTypeEnumMap[instance.threadGateType],
  'quoteDisabled': instance.quoteDisabled,
};

const _$DraftStatusEnumMap = {
  DraftStatus.draft: 'draft',
  DraftStatus.publishing: 'publishing',
  DraftStatus.failed: 'failed',
  DraftStatus.posted: 'posted',
};

const _$ThreadGateTypeEnumMap = {
  ThreadGateType.mention: 'mention',
  ThreadGateType.following: 'following',
  ThreadGateType.mentionAndFollowing: 'mentionAndFollowing',
};

_DraftMediaAttachment _$DraftMediaAttachmentFromJson(Map<String, dynamic> json) =>
    _DraftMediaAttachment(
      id: (json['id'] as num).toInt(),
      draftId: json['draftId'] as String,
      localPath: json['localPath'] as String,
      mimeType: json['mimeType'] as String,
      status: $enumDecode(_$DraftMediaStatusEnumMap, json['status']),
      sortOrder: (json['sortOrder'] as num).toInt(),
      altText: json['altText'] as String?,
      uploadCid: json['uploadCid'] as String?,
      blobRefJson: json['blobRefJson'] as String?,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      aspectRatio: json['aspectRatio'] as String?,
    );

Map<String, dynamic> _$DraftMediaAttachmentToJson(_DraftMediaAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'draftId': instance.draftId,
      'localPath': instance.localPath,
      'mimeType': instance.mimeType,
      'status': _$DraftMediaStatusEnumMap[instance.status]!,
      'sortOrder': instance.sortOrder,
      'altText': instance.altText,
      'uploadCid': instance.uploadCid,
      'blobRefJson': instance.blobRefJson,
      'durationSeconds': instance.durationSeconds,
      'aspectRatio': instance.aspectRatio,
    };

const _$DraftMediaStatusEnumMap = {
  DraftMediaStatus.pending: 'pending',
  DraftMediaStatus.uploading: 'uploading',
  DraftMediaStatus.uploaded: 'uploaded',
  DraftMediaStatus.failed: 'failed',
};

_DraftMediaInput _$DraftMediaInputFromJson(Map<String, dynamic> json) => _DraftMediaInput(
  localPath: json['localPath'] as String,
  mimeType: json['mimeType'] as String,
  altText: json['altText'] as String?,
);

Map<String, dynamic> _$DraftMediaInputToJson(_DraftMediaInput instance) => <String, dynamic>{
  'localPath': instance.localPath,
  'mimeType': instance.mimeType,
  'altText': instance.altText,
};
