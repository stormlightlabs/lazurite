/// Domain models for AT Protocol saved feeds preferences.
///
/// These models provide type-safe parsing of preferences from
/// app.bsky.actor.getPreferences and putPreferences endpoints.
library;

/// Represents a single feed item in SavedFeedsPrefV2.
class SavedFeedItem {
  const SavedFeedItem({required this.value, required this.pinned, required this.id});

  /// Creates a SavedFeedItem from API JSON response with validation.
  ///
  /// Throws [FormatException] if required fields are missing or invalid.
  factory SavedFeedItem.fromJson(Map<String, dynamic> json) {
    final value = json['value'];
    final id = json['id'];

    if (value is! String || value.isEmpty) {
      throw FormatException('SavedFeedItem.value must be a non-empty string', json);
    }
    if (id is! String || id.isEmpty) {
      throw FormatException('SavedFeedItem.id must be a non-empty string', json);
    }

    return SavedFeedItem(value: value, pinned: json['pinned'] as bool? ?? false, id: id);
  }

  /// Converts this SavedFeedItem to a JSON map.
  Map<String, dynamic> toJson() {
    return {'value': value, 'pinned': pinned, 'id': id};
  }

  /// The AT URI of the feed.
  final String value;

  /// Whether this feed is pinned.
  final bool pinned;

  /// Unique identifier for this item.
  final String id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedFeedItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents the V2 saved feeds preference (app.bsky.actor.defs#savedFeedsPrefV2).
///
/// V2 uses an ordered list of items with individual pinned states.
class SavedFeedsPrefV2 {
  const SavedFeedsPrefV2({required this.items});

  /// Creates a SavedFeedsPrefV2 from API JSON response with validation.
  ///
  /// Throws [FormatException] if the structure is invalid.
  factory SavedFeedsPrefV2.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];

    if (itemsJson is! List) {
      throw FormatException('SavedFeedsPrefV2.items must be a List', json);
    }

    final items = itemsJson.map((item) {
      if (item is! Map<String, dynamic>) {
        throw FormatException('SavedFeedsPrefV2 items must be Maps', item);
      }
      return SavedFeedItem.fromJson(item);
    }).toList();

    return SavedFeedsPrefV2(items: items);
  }

  /// Converts this SavedFeedsPrefV2 to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      '\$type': 'app.bsky.actor.defs#savedFeedsPrefV2',
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  /// The list of saved feed items.
  final List<SavedFeedItem> items;

  /// Returns a list of all saved feed URIs.
  List<String> get savedUris => items.map((item) => item.value).toList();

  /// Returns a list of pinned feed URIs.
  List<String> get pinnedUris =>
      items.where((item) => item.pinned).map((item) => item.value).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedFeedsPrefV2 && runtimeType == other.runtimeType && items == other.items;

  @override
  int get hashCode => Object.hashAll(items);
}

/// Represents the V1 saved feeds preference (app.bsky.actor.defs#savedFeedsPref).
///
/// V1 uses separate lists for saved and pinned feeds (deprecated).
class SavedFeedsPref {
  const SavedFeedsPref({required this.saved, required this.pinned});

  /// Creates a SavedFeedsPref from API JSON response with validation.
  factory SavedFeedsPref.fromJson(Map<String, dynamic> json) {
    final savedJson = json['saved'];
    final pinnedJson = json['pinned'];

    List<String> saved = [];
    if (savedJson != null) {
      if (savedJson is! List) {
        throw FormatException('SavedFeedsPref.saved must be a List', json);
      }
      saved = savedJson.cast<String>();
    }

    List<String> pinned = [];
    if (pinnedJson != null) {
      if (pinnedJson is! List) {
        throw FormatException('SavedFeedsPref.pinned must be a List', json);
      }
      pinned = pinnedJson.cast<String>();
    }

    return SavedFeedsPref(saved: saved, pinned: pinned);
  }

  /// Converts this SavedFeedsPref to a JSON map.
  Map<String, dynamic> toJson() {
    return {'\$type': 'app.bsky.actor.defs#savedFeedsPref', 'saved': saved, 'pinned': pinned};
  }

  /// List of saved feed URIs.
  final List<String> saved;

  /// List of pinned feed URIs.
  final List<String> pinned;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedFeedsPref &&
          runtimeType == other.runtimeType &&
          saved == other.saved &&
          pinned == other.pinned;

  @override
  int get hashCode => Object.hash(saved, pinned);
}

/// Helper to parse preferences list and extract saved feeds preference.
///
/// Returns either a SavedFeedsPrefV2 or SavedFeedsPref depending on what's found.
/// Returns null if neither format is present.
class SavedFeedsPreferenceParser {
  /// Parses a preferences list from app.bsky.actor.getPreferences.
  ///
  /// Returns a record with either v2 or v1 populated, or both null if not found.
  static ({SavedFeedsPrefV2? v2, SavedFeedsPref? v1}) parse(List<dynamic> preferences) {
    SavedFeedsPrefV2? v2;
    SavedFeedsPref? v1;

    for (final pref in preferences) {
      if (pref is! Map<String, dynamic>) continue;

      final type = pref['\$type'];
      if (type == 'app.bsky.actor.defs#savedFeedsPrefV2') {
        try {
          v2 = SavedFeedsPrefV2.fromJson(pref);
        } catch (e) {
          continue;
        }
      } else if (type == 'app.bsky.actor.defs#savedFeedsPref') {
        try {
          v1 = SavedFeedsPref.fromJson(pref);
        } catch (e) {
          continue;
        }
      }
    }

    return (v2: v2, v1: v1);
  }
}
