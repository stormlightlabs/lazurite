// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_feeds_pref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavedFeedItem _$SavedFeedItemFromJson(Map<String, dynamic> json) => _SavedFeedItem(
  value: json['value'] as String,
  pinned: json['pinned'] as bool? ?? false,
  id: json['id'] as String,
);

Map<String, dynamic> _$SavedFeedItemToJson(_SavedFeedItem instance) => <String, dynamic>{
  'value': instance.value,
  'pinned': instance.pinned,
  'id': instance.id,
};

_SavedFeedsPrefV2 _$SavedFeedsPrefV2FromJson(Map<String, dynamic> json) => _SavedFeedsPrefV2(
  type: json[r'$type'] as String? ?? 'app.bsky.actor.defs#savedFeedsPrefV2',
  items: (json['items'] as List<dynamic>)
      .map((e) => SavedFeedItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SavedFeedsPrefV2ToJson(_SavedFeedsPrefV2 instance) => <String, dynamic>{
  r'$type': instance.type,
  'items': instance.items.map((e) => e.toJson()).toList(),
};

_SavedFeedsPref _$SavedFeedsPrefFromJson(Map<String, dynamic> json) => _SavedFeedsPref(
  type: json[r'$type'] as String? ?? 'app.bsky.actor.defs#savedFeedsPref',
  saved: (json['saved'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
  pinned: (json['pinned'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
);

Map<String, dynamic> _$SavedFeedsPrefToJson(_SavedFeedsPref instance) => <String, dynamic>{
  r'$type': instance.type,
  'saved': instance.saved,
  'pinned': instance.pinned,
};
