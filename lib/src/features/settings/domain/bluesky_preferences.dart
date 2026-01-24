import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'bluesky_preferences.freezed.dart';
part 'bluesky_preferences.g.dart';

/// Constants for preference type identifiers used in the $type field.
abstract final class BlueskyPreferenceTypes {
  static const String adultContent = 'app.bsky.actor.defs#adultContentPref';
  static const String contentLabel = 'app.bsky.actor.defs#contentLabelPref';
  static const String labelers = 'app.bsky.actor.defs#labelersPref';
  static const String feedView = 'app.bsky.actor.defs#feedViewPref';
  static const String threadView = 'app.bsky.actor.defs#threadViewPref';
  static const String mutedWords = 'app.bsky.actor.defs#mutedWordsPref';
  static const String contentLabels = 'app.bsky.actor.defs#contentLabelPrefs'; // Custom if needed
}

/// Adult content preference controlling visibility of adult content.
@freezed
abstract class AdultContentPref with _$AdultContentPref {
  const factory AdultContentPref({@Default(false) bool enabled}) = _AdultContentPref;

  const AdultContentPref._();

  factory AdultContentPref.fromJson(Map<String, dynamic> json) => _$AdultContentPrefFromJson(json);

  factory AdultContentPref.fromStoredJson(String jsonString) =>
      AdultContentPref.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  @override
  Map<String, dynamic> toJson() => {
    r'$type': BlueskyPreferenceTypes.adultContent,
    ..._$AdultContentPrefToJson(this as _AdultContentPref),
  };

  String toStoredJson() => jsonEncode(toJson());
}

/// Visibility options for content labels.
@JsonEnum()
enum LabelVisibility {
  /// No action taken, content appears normally.
  @JsonValue('ignore')
  ignore,

  /// Content shown with label badge.
  @JsonValue('show')
  show,

  /// Content hidden behind warning screen.
  @JsonValue('warn')
  warn,

  /// Content completely filtered from feeds.
  @JsonValue('hide')
  hide;

  /// Parses a visibility string from the API (for backwards compatibility).
  static LabelVisibility fromString(String? value) {
    return switch (value) {
      'ignore' => LabelVisibility.ignore,
      'show' => LabelVisibility.show,
      'warn' => LabelVisibility.warn,
      'hide' => LabelVisibility.hide,
      _ => LabelVisibility.warn,
    };
  }

  /// Converts to API string value.
  String toApiString() => name;
}

/// Content label preference controlling visibility of labeled content.
@freezed
abstract class ContentLabelPref with _$ContentLabelPref {
  const factory ContentLabelPref({
    required String label,
    @Default(LabelVisibility.warn) LabelVisibility visibility,
    @JsonKey(includeIfNull: false) String? labelerDid,
  }) = _ContentLabelPref;

  const ContentLabelPref._();

  factory ContentLabelPref.fromJson(Map<String, dynamic> json) => _$ContentLabelPrefFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
    r'$type': BlueskyPreferenceTypes.contentLabel,
    ..._$ContentLabelPrefToJson(this as _ContentLabelPref),
  };
}

/// Collection of content label preferences.
@freezed
abstract class ContentLabelPrefs with _$ContentLabelPrefs {
  factory ContentLabelPrefs.fromJson(Map<String, dynamic> json) =>
      _$ContentLabelPrefsFromJson(json);

  factory ContentLabelPrefs.fromJsonList(List<dynamic> jsonList) {
    return ContentLabelPrefs(
      items: jsonList.whereType<Map<String, dynamic>>().map(ContentLabelPref.fromJson).toList(),
    );
  }

  factory ContentLabelPrefs.fromStoredJson(String jsonString) =>
      ContentLabelPrefs.fromJsonList(jsonDecode(jsonString) as List<dynamic>);
  const factory ContentLabelPrefs({@Default([]) List<ContentLabelPref> items}) =
      _ContentLabelPrefs;

  const ContentLabelPrefs._();

  /// Empty collection.
  static const empty = ContentLabelPrefs(items: []);

  @override
  Map<String, dynamic> toJson() => _$ContentLabelPrefsToJson(this as _ContentLabelPrefs);

  String toStoredJson() => jsonEncode(items.map((i) => i.toJson()).toList());

  /// Gets the visibility for a specific label.
  LabelVisibility? getVisibility(String label, {String? labelerDid}) {
    for (final pref in items) {
      if (pref.label == label && pref.labelerDid == labelerDid) {
        return pref.visibility;
      }
    }
    return null;
  }
}

/// Reference to a labeler service.
@freezed
abstract class LabelerRef with _$LabelerRef {
  const factory LabelerRef({required String did}) = _LabelerRef;

  const LabelerRef._();

  factory LabelerRef.fromJson(Map<String, dynamic> json) => _$LabelerRefFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LabelerRefToJson(this as _LabelerRef);
}

/// Labelers preference for custom moderation services.
@freezed
abstract class LabelersPref with _$LabelersPref {
  factory LabelersPref.fromJson(Map<String, dynamic> json) => _$LabelersPrefFromJson(json);

  factory LabelersPref.fromStoredJson(String jsonString) =>
      LabelersPref.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  const factory LabelersPref({@Default([]) List<LabelerRef> labelers}) = _LabelersPref;

  const LabelersPref._();

  /// Empty preference with no labelers.
  static const empty = LabelersPref(labelers: []);

  @override
  Map<String, dynamic> toJson() => {
    r'$type': BlueskyPreferenceTypes.labelers,
    ..._$LabelersPrefToJson(this as _LabelersPref),
  };

  String toStoredJson() => jsonEncode(toJson());

  /// Gets the list of labeler DIDs.
  List<String> get labelerDids => labelers.map((l) => l.did).toList();
}

/// Feed view preference controlling what content appears in feeds.
@freezed
abstract class FeedViewPref with _$FeedViewPref {
  factory FeedViewPref.fromJson(Map<String, dynamic> json) => _$FeedViewPrefFromJson(json);

  factory FeedViewPref.fromStoredJson(String jsonString) =>
      FeedViewPref.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  const factory FeedViewPref({
    @Default(false) bool hideReplies,
    @Default(true) bool hideRepliesByUnfollowed,
    @JsonKey(includeIfNull: false) int? hideRepliesByLikeCount,
    @Default(false) bool hideReposts,
    @Default(false) bool hideQuotePosts,
    @JsonKey(includeIfNull: false) String? feed,
  }) = _FeedViewPref;

  const FeedViewPref._();

  /// Default preferences.
  static const defaultPref = FeedViewPref();

  @override
  Map<String, dynamic> toJson() => {
    r'$type': BlueskyPreferenceTypes.feedView,
    ..._$FeedViewPrefToJson(this as _FeedViewPref),
  };

  String toStoredJson() => jsonEncode(toJson());
}

/// Sort order options for thread views.
@JsonEnum()
enum ThreadSortOrder {
  @JsonValue('oldest')
  oldest,
  @JsonValue('newest')
  newest,
  @JsonValue('most-likes')
  mostLikes,
  @JsonValue('random')
  random,
  @JsonValue('hotness')
  hotness;

  /// Parses a sort order string from the API (for backwards compatibility).
  static ThreadSortOrder fromString(String? value) {
    return switch (value) {
      'oldest' => ThreadSortOrder.oldest,
      'newest' => ThreadSortOrder.newest,
      'most-likes' => ThreadSortOrder.mostLikes,
      'random' => ThreadSortOrder.random,
      'hotness' => ThreadSortOrder.hotness,
      _ => ThreadSortOrder.oldest,
    };
  }

  /// Converts to API string value.
  String toApiString() {
    return switch (this) {
      ThreadSortOrder.oldest => 'oldest',
      ThreadSortOrder.newest => 'newest',
      ThreadSortOrder.mostLikes => 'most-likes',
      ThreadSortOrder.random => 'random',
      ThreadSortOrder.hotness => 'hotness',
    };
  }
}

/// Thread view preference controlling thread display.
@freezed
abstract class ThreadViewPref with _$ThreadViewPref {
  factory ThreadViewPref.fromJson(Map<String, dynamic> json) => _$ThreadViewPrefFromJson(json);

  factory ThreadViewPref.fromStoredJson(String jsonString) =>
      ThreadViewPref.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  const factory ThreadViewPref({
    @Default(ThreadSortOrder.oldest) ThreadSortOrder sort,
    @Default(true) bool prioritizeFollowedUsers,
  }) = _ThreadViewPref;

  const ThreadViewPref._();

  /// Default preferences.
  static const defaultPref = ThreadViewPref();

  @override
  Map<String, dynamic> toJson() => {
    r'$type': BlueskyPreferenceTypes.threadView,
    ..._$ThreadViewPrefToJson(this as _ThreadViewPref),
  };

  String toStoredJson() => jsonEncode(toJson());
}

/// Target options for muted words.
@JsonEnum()
enum MutedWordTarget {
  @JsonValue('content')
  content,
  @JsonValue('tag')
  tags;

  static MutedWordTarget? fromString(String? value) {
    return switch (value) {
      'content' => MutedWordTarget.content,
      'tag' => MutedWordTarget.tags,
      _ => null,
    };
  }

  String toApiString() => name == 'tags' ? 'tag' : name;
}

/// Actor target options for muted words.
@JsonEnum()
enum MutedWordActorTarget {
  @JsonValue('all')
  all,
  @JsonValue('exclude-following')
  excludeFollowing;

  static MutedWordActorTarget fromString(String? value) {
    return switch (value) {
      'all' => MutedWordActorTarget.all,
      'exclude-following' => MutedWordActorTarget.excludeFollowing,
      _ => MutedWordActorTarget.all,
    };
  }

  String toApiString() {
    return switch (this) {
      MutedWordActorTarget.all => 'all',
      MutedWordActorTarget.excludeFollowing => 'exclude-following',
    };
  }
}

/// A single muted word entry.
@freezed
abstract class MutedWord with _$MutedWord {
  const factory MutedWord({
    required String id,
    required String value,
    required List<MutedWordTarget> targets,
    @Default(MutedWordActorTarget.all) MutedWordActorTarget actorTarget,
    @JsonKey(includeIfNull: false) DateTime? expiresAt,
  }) = _MutedWord;

  const MutedWord._();

  factory MutedWord.fromJson(Map<String, dynamic> json) => _$MutedWordFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MutedWordToJson(this as _MutedWord);

  /// Whether this muted word has expired.
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
}

/// Muted words preference for keyword filtering.
@freezed
abstract class MutedWordsPref with _$MutedWordsPref {
  factory MutedWordsPref.fromJson(Map<String, dynamic> json) => _$MutedWordsPrefFromJson(json);

  factory MutedWordsPref.fromStoredJson(String jsonString) =>
      MutedWordsPref.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  const factory MutedWordsPref({@Default([]) List<MutedWord> items}) = _MutedWordsPref;

  const MutedWordsPref._();

  /// Empty preference with no muted words.
  static const empty = MutedWordsPref(items: []);

  @override
  Map<String, dynamic> toJson() => {
    r'$type': BlueskyPreferenceTypes.mutedWords,
    ..._$MutedWordsPrefToJson(this as _MutedWordsPref),
  };

  String toStoredJson() => jsonEncode(toJson());

  /// Gets only non-expired muted words.
  List<MutedWord> get activeItems => items.where((i) => !i.isExpired).toList();
}
