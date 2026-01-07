/// Domain models for AT Protocol Bluesky account preferences.
///
/// These models provide type-safe parsing of preferences from
/// app.bsky.actor.getPreferences and putPreferences endpoints.
library;

import 'dart:convert';

/// Constants for preference type identifiers used in the $type field.
abstract final class BlueskyPreferenceTypes {
  static const String adultContent = 'app.bsky.actor.defs#adultContentPref';
  static const String contentLabel = 'app.bsky.actor.defs#contentLabelPref';
  static const String labelers = 'app.bsky.actor.defs#labelersPref';
  static const String feedView = 'app.bsky.actor.defs#feedViewPref';
  static const String threadView = 'app.bsky.actor.defs#threadViewPref';
  static const String mutedWords = 'app.bsky.actor.defs#mutedWordsPref';
}

/// Adult content preference controlling visibility of adult content.
///
/// AT Protocol type: app.bsky.actor.defs#adultContentPref
class AdultContentPref {
  const AdultContentPref({required this.enabled});

  /// Creates an AdultContentPref from API JSON response.
  factory AdultContentPref.fromJson(Map<String, dynamic> json) {
    return AdultContentPref(enabled: json['enabled'] as bool? ?? false);
  }

  /// Deserializes from stored JSON string.
  factory AdultContentPref.fromStoredJson(String jsonString) {
    return AdultContentPref.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Whether adult content is enabled.
  final bool enabled;

  /// Converts to JSON map for storage.
  Map<String, dynamic> toJson() => {'enabled': enabled};

  /// Serializes to JSON string for storage.
  String toStoredJson() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AdultContentPref && enabled == other.enabled;

  @override
  int get hashCode => enabled.hashCode;

  @override
  String toString() => 'AdultContentPref(enabled: $enabled)';
}

/// Visibility options for content labels.
enum LabelVisibility {
  /// No action taken, content appears normally.
  ignore,

  /// Content shown with label badge.
  show,

  /// Content hidden behind warning screen.
  warn,

  /// Content completely filtered from feeds.
  hide;

  /// Parses a visibility string from the API.
  static LabelVisibility fromString(String? value) {
    return switch (value) {
      'ignore' => LabelVisibility.ignore,
      'show' => LabelVisibility.show,
      'warn' => LabelVisibility.warn,
      'hide' => LabelVisibility.hide,
      _ => LabelVisibility.warn, // Default to warn for unknown values
    };
  }

  /// Converts to API string value.
  String toApiString() => name;
}

/// Content label preference controlling visibility of labeled content.
///
/// AT Protocol type: app.bsky.actor.defs#contentLabelPref
class ContentLabelPref {
  const ContentLabelPref({required this.label, required this.visibility, this.labelerDid});

  /// Creates a ContentLabelPref from API JSON response.
  factory ContentLabelPref.fromJson(Map<String, dynamic> json) {
    return ContentLabelPref(
      label: json['label'] as String? ?? '',
      labelerDid: json['labelerDid'] as String?,
      visibility: LabelVisibility.fromString(json['visibility'] as String?),
    );
  }

  /// The label identifier (e.g., "sexual", "graphic-media", "nudity").
  final String label;

  /// Optional DID of the labeler that defines this label.
  final String? labelerDid;

  /// The visibility setting for this label.
  final LabelVisibility visibility;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
    'label': label,
    if (labelerDid != null) 'labelerDid': labelerDid,
    'visibility': visibility.toApiString(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentLabelPref &&
          label == other.label &&
          labelerDid == other.labelerDid &&
          visibility == other.visibility;

  @override
  int get hashCode => Object.hash(label, labelerDid, visibility);

  @override
  String toString() =>
      'ContentLabelPref(label: $label, labelerDid: $labelerDid, visibility: $visibility)';
}

/// Collection of content label preferences.
///
/// Stored as a single JSON array in the database for efficiency.
class ContentLabelPrefs {
  const ContentLabelPrefs({required this.items});

  /// Creates from a list of preference JSON objects.
  factory ContentLabelPrefs.fromJsonList(List<dynamic> jsonList) {
    final items = <ContentLabelPref>[];
    for (final item in jsonList) {
      if (item is Map<String, dynamic>) {
        items.add(ContentLabelPref.fromJson(item));
      }
    }
    return ContentLabelPrefs(items: items);
  }

  /// Deserializes from stored JSON string.
  factory ContentLabelPrefs.fromStoredJson(String jsonString) {
    final list = jsonDecode(jsonString) as List<dynamic>;
    return ContentLabelPrefs.fromJsonList(list);
  }

  /// Empty collection.
  static const empty = ContentLabelPrefs(items: []);

  final List<ContentLabelPref> items;

  /// Converts to JSON list.
  List<Map<String, dynamic>> toJson() => items.map((item) => item.toJson()).toList();

  /// Serializes to JSON string for storage.
  String toStoredJson() => jsonEncode(toJson());

  /// Gets the visibility for a specific label.
  LabelVisibility? getVisibility(String label, {String? labelerDid}) {
    for (final pref in items) {
      if (pref.label == label && pref.labelerDid == labelerDid) {
        return pref.visibility;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ContentLabelPrefs && _listEquals(items, other.items);

  @override
  int get hashCode => Object.hashAll(items);

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Reference to a labeler service.
class LabelerRef {
  const LabelerRef({required this.did});

  factory LabelerRef.fromJson(Map<String, dynamic> json) {
    return LabelerRef(did: json['did'] as String? ?? '');
  }

  final String did;

  Map<String, dynamic> toJson() => {'did': did};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LabelerRef && did == other.did;

  @override
  int get hashCode => did.hashCode;
}

/// Labelers preference for custom moderation services.
///
/// AT Protocol type: app.bsky.actor.defs#labelersPref
class LabelersPref {
  const LabelersPref({required this.labelers});

  /// Creates a LabelersPref from API JSON response.
  factory LabelersPref.fromJson(Map<String, dynamic> json) {
    final labelersJson = json['labelers'] as List<dynamic>? ?? [];
    final labelers = labelersJson
        .whereType<Map<String, dynamic>>()
        .map(LabelerRef.fromJson)
        .toList();
    return LabelersPref(labelers: labelers);
  }

  /// Deserializes from stored JSON string.
  factory LabelersPref.fromStoredJson(String jsonString) {
    return LabelersPref.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Empty preference with no labelers.
  static const empty = LabelersPref(labelers: []);

  final List<LabelerRef> labelers;

  /// Gets the list of labeler DIDs.
  List<String> get labelerDids => labelers.map((l) => l.did).toList();

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {'labelers': labelers.map((l) => l.toJson()).toList()};

  /// Serializes to JSON string for storage.
  String toStoredJson() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelersPref && ContentLabelPrefs._listEquals(labelers, other.labelers);

  @override
  int get hashCode => Object.hashAll(labelers);

  @override
  String toString() => 'LabelersPref(labelers: ${labelers.length})';
}

/// Feed view preference controlling what content appears in feeds.
///
/// AT Protocol type: app.bsky.actor.defs#feedViewPref
class FeedViewPref {
  const FeedViewPref({
    this.hideReplies = false,
    this.hideRepliesByUnfollowed = true,
    this.hideRepliesByLikeCount,
    this.hideReposts = false,
    this.hideQuotePosts = false,
    this.feed,
  });

  /// Creates a FeedViewPref from API JSON response.
  factory FeedViewPref.fromJson(Map<String, dynamic> json) {
    return FeedViewPref(
      hideReplies: json['hideReplies'] as bool? ?? false,
      hideRepliesByUnfollowed: json['hideRepliesByUnfollowed'] as bool? ?? true,
      hideRepliesByLikeCount: json['hideRepliesByLikeCount'] as int?,
      hideReposts: json['hideReposts'] as bool? ?? false,
      hideQuotePosts: json['hideQuotePosts'] as bool? ?? false,
      feed: json['feed'] as String?,
    );
  }

  /// Deserializes from stored JSON string.
  factory FeedViewPref.fromStoredJson(String jsonString) {
    return FeedViewPref.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Default preferences.
  static const defaultPref = FeedViewPref();

  /// Whether to hide replies in feeds.
  final bool hideReplies;

  /// Whether to hide replies from accounts you don't follow.
  final bool hideRepliesByUnfollowed;

  /// Hide replies with less than this many likes (optional).
  final int? hideRepliesByLikeCount;

  /// Whether to hide reposts in feeds.
  final bool hideReposts;

  /// Whether to hide quote posts in feeds.
  final bool hideQuotePosts;

  /// Optional feed URI this preference applies to.
  final String? feed;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
    'hideReplies': hideReplies,
    'hideRepliesByUnfollowed': hideRepliesByUnfollowed,
    if (hideRepliesByLikeCount != null) 'hideRepliesByLikeCount': hideRepliesByLikeCount,
    'hideReposts': hideReposts,
    'hideQuotePosts': hideQuotePosts,
    if (feed != null) 'feed': feed,
  };

  /// Serializes to JSON string for storage.
  String toStoredJson() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedViewPref &&
          hideReplies == other.hideReplies &&
          hideRepliesByUnfollowed == other.hideRepliesByUnfollowed &&
          hideRepliesByLikeCount == other.hideRepliesByLikeCount &&
          hideReposts == other.hideReposts &&
          hideQuotePosts == other.hideQuotePosts &&
          feed == other.feed;

  @override
  int get hashCode => Object.hash(
    hideReplies,
    hideRepliesByUnfollowed,
    hideRepliesByLikeCount,
    hideReposts,
    hideQuotePosts,
    feed,
  );

  @override
  String toString() => 'FeedViewPref(hideReplies: $hideReplies, hideReposts: $hideReposts)';
}

/// Sort order options for thread views.
enum ThreadSortOrder {
  oldest,
  newest,
  mostLikes,
  random,
  hotness;

  /// Parses a sort order string from the API.
  static ThreadSortOrder fromString(String? value) {
    return switch (value) {
      'oldest' => ThreadSortOrder.oldest,
      'newest' => ThreadSortOrder.newest,
      'most-likes' => ThreadSortOrder.mostLikes,
      'random' => ThreadSortOrder.random,
      'hotness' => ThreadSortOrder.hotness,
      _ => ThreadSortOrder.oldest, // Default
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
///
/// AT Protocol type: app.bsky.actor.defs#threadViewPref
class ThreadViewPref {
  const ThreadViewPref({this.sort = ThreadSortOrder.oldest, this.prioritizeFollowedUsers = true});

  /// Creates a ThreadViewPref from API JSON response.
  factory ThreadViewPref.fromJson(Map<String, dynamic> json) {
    return ThreadViewPref(
      sort: ThreadSortOrder.fromString(json['sort'] as String?),
      prioritizeFollowedUsers: json['prioritizeFollowedUsers'] as bool? ?? true,
    );
  }

  /// Deserializes from stored JSON string.
  factory ThreadViewPref.fromStoredJson(String jsonString) {
    return ThreadViewPref.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Default preferences.
  static const defaultPref = ThreadViewPref();

  /// The sort order for thread replies.
  final ThreadSortOrder sort;

  /// Whether to show replies from followed users first.
  final bool prioritizeFollowedUsers;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
    'sort': sort.toApiString(),
    'prioritizeFollowedUsers': prioritizeFollowedUsers,
  };

  /// Serializes to JSON string for storage.
  String toStoredJson() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThreadViewPref &&
          sort == other.sort &&
          prioritizeFollowedUsers == other.prioritizeFollowedUsers;

  @override
  int get hashCode => Object.hash(sort, prioritizeFollowedUsers);

  @override
  String toString() =>
      'ThreadViewPref(sort: $sort, prioritizeFollowedUsers: $prioritizeFollowedUsers)';
}

/// Target options for muted words.
enum MutedWordTarget {
  content,
  tags;

  static MutedWordTarget? fromString(String? value) {
    return switch (value) {
      'content' => MutedWordTarget.content,
      'tag' => MutedWordTarget.tags,
      _ => null,
    };
  }

  String toApiString() {
    return switch (this) {
      MutedWordTarget.content => 'content',
      MutedWordTarget.tags => 'tag',
    };
  }
}

/// Actor target options for muted words.
enum MutedWordActorTarget {
  all,
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
class MutedWord {
  const MutedWord({
    required this.id,
    required this.value,
    required this.targets,
    this.actorTarget = MutedWordActorTarget.all,
    this.expiresAt,
  });

  factory MutedWord.fromJson(Map<String, dynamic> json) {
    final targetsJson = json['targets'] as List<dynamic>? ?? [];
    final targets = targetsJson
        .map((t) => MutedWordTarget.fromString(t as String?))
        .whereType<MutedWordTarget>()
        .toList();

    DateTime? expiresAt;
    final expiresAtStr = json['expiresAt'] as String?;
    if (expiresAtStr != null) {
      expiresAt = DateTime.tryParse(expiresAtStr);
    }

    return MutedWord(
      id: json['id'] as String? ?? '',
      value: json['value'] as String? ?? '',
      targets: targets,
      actorTarget: MutedWordActorTarget.fromString(json['actorTarget'] as String?),
      expiresAt: expiresAt,
    );
  }

  final String id;
  final String value;
  final List<MutedWordTarget> targets;
  final MutedWordActorTarget actorTarget;
  final DateTime? expiresAt;

  /// Whether this muted word has expired.
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  Map<String, dynamic> toJson() => {
    'id': id,
    'value': value,
    'targets': targets.map((t) => t.toApiString()).toList(),
    'actorTarget': actorTarget.toApiString(),
    if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
  };

  @override
  bool operator ==(Object other) => identical(this, other) || other is MutedWord && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MutedWord(id: $id, value: $value)';
}

/// Muted words preference for keyword filtering.
///
/// AT Protocol type: app.bsky.actor.defs#mutedWordsPref
class MutedWordsPref {
  const MutedWordsPref({required this.items});

  /// Creates a MutedWordsPref from API JSON response.
  factory MutedWordsPref.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson.whereType<Map<String, dynamic>>().map(MutedWord.fromJson).toList();
    return MutedWordsPref(items: items);
  }

  /// Deserializes from stored JSON string.
  factory MutedWordsPref.fromStoredJson(String jsonString) {
    return MutedWordsPref.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Empty preference with no muted words.
  static const empty = MutedWordsPref(items: []);

  final List<MutedWord> items;

  /// Gets only non-expired muted words.
  List<MutedWord> get activeItems => items.where((i) => !i.isExpired).toList();

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {'items': items.map((i) => i.toJson()).toList()};

  /// Serializes to JSON string for storage.
  String toStoredJson() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MutedWordsPref && ContentLabelPrefs._listEquals(items, other.items);

  @override
  int get hashCode => Object.hashAll(items);

  @override
  String toString() => 'MutedWordsPref(items: ${items.length})';
}
