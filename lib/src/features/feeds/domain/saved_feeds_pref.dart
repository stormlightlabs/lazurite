import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_feeds_pref.freezed.dart';
part 'saved_feeds_pref.g.dart';

/// Represents a single feed item in SavedFeedsPrefV2.
@freezed
abstract class SavedFeedItem with _$SavedFeedItem {
  @JsonSerializable(explicitToJson: true)
  const factory SavedFeedItem({
    required String value,
    @Default(false) bool pinned,
    required String id,
  }) = _SavedFeedItem;

  factory SavedFeedItem.fromJson(Map<String, dynamic> json) => _$SavedFeedItemFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SavedFeedItemToJson(this as _SavedFeedItem);
}

/// Represents the V2 saved feeds preference (app.bsky.actor.defs#savedFeedsPrefV2).
@freezed
abstract class SavedFeedsPrefV2 with _$SavedFeedsPrefV2 {
  @JsonSerializable(explicitToJson: true)
  const factory SavedFeedsPrefV2({
    @JsonKey(name: r'$type') @Default('app.bsky.actor.defs#savedFeedsPrefV2') String type,
    required List<SavedFeedItem> items,
  }) = _SavedFeedsPrefV2;

  const SavedFeedsPrefV2._();

  factory SavedFeedsPrefV2.fromJson(Map<String, dynamic> json) => _$SavedFeedsPrefV2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SavedFeedsPrefV2ToJson(this as _SavedFeedsPrefV2);

  /// Returns a list of all saved feed URIs.
  List<String> get savedUris => items.map((item) => item.value).toList();

  /// Returns a list of pinned feed URIs.
  List<String> get pinnedUris =>
      items.where((item) => item.pinned).map((item) => item.value).toList();
}

/// Represents the V1 saved feeds preference (app.bsky.actor.defs#savedFeedsPref).
@freezed
abstract class SavedFeedsPref with _$SavedFeedsPref {
  @JsonSerializable(explicitToJson: true)
  const factory SavedFeedsPref({
    @JsonKey(name: r'$type') @Default('app.bsky.actor.defs#savedFeedsPref') String type,
    @Default([]) List<String> saved,
    @Default([]) List<String> pinned,
  }) = _SavedFeedsPref;

  const SavedFeedsPref._();

  factory SavedFeedsPref.fromJson(Map<String, dynamic> json) => _$SavedFeedsPrefFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SavedFeedsPrefToJson(this as _SavedFeedsPref);
}

/// Helper to parse preferences list and extract saved feeds preference.
class SavedFeedsPreferenceParser {
  /// Parses a preferences list from app.bsky.actor.getPreferences.
  static ({SavedFeedsPrefV2? v2, SavedFeedsPref? v1}) parse(List<dynamic> preferences) {
    SavedFeedsPrefV2? v2;
    SavedFeedsPref? v1;

    for (final pref in preferences) {
      if (pref is! Map<String, dynamic>) continue;

      final type = pref[r'$type'];
      if (type == 'app.bsky.actor.defs#savedFeedsPrefV2') {
        try {
          v2 = SavedFeedsPrefV2.fromJson(pref);
        } catch (_) {}
      } else if (type == 'app.bsky.actor.defs#savedFeedsPref') {
        try {
          v1 = SavedFeedsPref.fromJson(pref);
        } catch (_) {}
      }
    }

    return (v2: v2, v1: v1);
  }
}
