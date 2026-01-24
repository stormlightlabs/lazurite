// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluesky_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdultContentPref _$AdultContentPrefFromJson(Map<String, dynamic> json) =>
    _AdultContentPref(enabled: json['enabled'] as bool? ?? false);

Map<String, dynamic> _$AdultContentPrefToJson(_AdultContentPref instance) => <String, dynamic>{
  'enabled': instance.enabled,
};

_ContentLabelPref _$ContentLabelPrefFromJson(Map<String, dynamic> json) => _ContentLabelPref(
  label: json['label'] as String,
  visibility:
      $enumDecodeNullable(_$LabelVisibilityEnumMap, json['visibility']) ?? LabelVisibility.warn,
  labelerDid: json['labelerDid'] as String?,
);

Map<String, dynamic> _$ContentLabelPrefToJson(_ContentLabelPref instance) => <String, dynamic>{
  'label': instance.label,
  'visibility': _$LabelVisibilityEnumMap[instance.visibility]!,
  'labelerDid': ?instance.labelerDid,
};

const _$LabelVisibilityEnumMap = {
  LabelVisibility.ignore: 'ignore',
  LabelVisibility.show: 'show',
  LabelVisibility.warn: 'warn',
  LabelVisibility.hide: 'hide',
};

_ContentLabelPrefs _$ContentLabelPrefsFromJson(Map<String, dynamic> json) => _ContentLabelPrefs(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ContentLabelPref.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ContentLabelPrefsToJson(_ContentLabelPrefs instance) => <String, dynamic>{
  'items': instance.items,
};

_LabelerRef _$LabelerRefFromJson(Map<String, dynamic> json) =>
    _LabelerRef(did: json['did'] as String);

Map<String, dynamic> _$LabelerRefToJson(_LabelerRef instance) => <String, dynamic>{
  'did': instance.did,
};

_LabelersPref _$LabelersPrefFromJson(Map<String, dynamic> json) => _LabelersPref(
  labelers:
      (json['labelers'] as List<dynamic>?)
          ?.map((e) => LabelerRef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$LabelersPrefToJson(_LabelersPref instance) => <String, dynamic>{
  'labelers': instance.labelers,
};

_FeedViewPref _$FeedViewPrefFromJson(Map<String, dynamic> json) => _FeedViewPref(
  hideReplies: json['hideReplies'] as bool? ?? false,
  hideRepliesByUnfollowed: json['hideRepliesByUnfollowed'] as bool? ?? true,
  hideRepliesByLikeCount: (json['hideRepliesByLikeCount'] as num?)?.toInt(),
  hideReposts: json['hideReposts'] as bool? ?? false,
  hideQuotePosts: json['hideQuotePosts'] as bool? ?? false,
  feed: json['feed'] as String?,
);

Map<String, dynamic> _$FeedViewPrefToJson(_FeedViewPref instance) => <String, dynamic>{
  'hideReplies': instance.hideReplies,
  'hideRepliesByUnfollowed': instance.hideRepliesByUnfollowed,
  'hideRepliesByLikeCount': ?instance.hideRepliesByLikeCount,
  'hideReposts': instance.hideReposts,
  'hideQuotePosts': instance.hideQuotePosts,
  'feed': ?instance.feed,
};

_ThreadViewPref _$ThreadViewPrefFromJson(Map<String, dynamic> json) => _ThreadViewPref(
  sort: $enumDecodeNullable(_$ThreadSortOrderEnumMap, json['sort']) ?? ThreadSortOrder.oldest,
  prioritizeFollowedUsers: json['prioritizeFollowedUsers'] as bool? ?? true,
);

Map<String, dynamic> _$ThreadViewPrefToJson(_ThreadViewPref instance) => <String, dynamic>{
  'sort': _$ThreadSortOrderEnumMap[instance.sort]!,
  'prioritizeFollowedUsers': instance.prioritizeFollowedUsers,
};

const _$ThreadSortOrderEnumMap = {
  ThreadSortOrder.oldest: 'oldest',
  ThreadSortOrder.newest: 'newest',
  ThreadSortOrder.mostLikes: 'most-likes',
  ThreadSortOrder.random: 'random',
  ThreadSortOrder.hotness: 'hotness',
};

_MutedWord _$MutedWordFromJson(Map<String, dynamic> json) => _MutedWord(
  id: json['id'] as String,
  value: json['value'] as String,
  targets: (json['targets'] as List<dynamic>)
      .map((e) => $enumDecode(_$MutedWordTargetEnumMap, e))
      .toList(),
  actorTarget:
      $enumDecodeNullable(_$MutedWordActorTargetEnumMap, json['actorTarget']) ??
      MutedWordActorTarget.all,
  expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$MutedWordToJson(_MutedWord instance) => <String, dynamic>{
  'id': instance.id,
  'value': instance.value,
  'targets': instance.targets.map((e) => _$MutedWordTargetEnumMap[e]!).toList(),
  'actorTarget': _$MutedWordActorTargetEnumMap[instance.actorTarget]!,
  'expiresAt': ?instance.expiresAt?.toIso8601String(),
};

const _$MutedWordTargetEnumMap = {MutedWordTarget.content: 'content', MutedWordTarget.tags: 'tag'};

const _$MutedWordActorTargetEnumMap = {
  MutedWordActorTarget.all: 'all',
  MutedWordActorTarget.excludeFollowing: 'exclude-following',
};

_MutedWordsPref _$MutedWordsPrefFromJson(Map<String, dynamic> json) => _MutedWordsPref(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => MutedWord.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$MutedWordsPrefToJson(_MutedWordsPref instance) => <String, dynamic>{
  'items': instance.items,
};
