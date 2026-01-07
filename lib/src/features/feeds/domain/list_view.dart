/// Domain models for AT Protocol list responses.
///
/// These models provide type-safe parsing of list metadata from the
/// app.bsky.graph.getList endpoint.
library;

import 'package:lazurite/src/features/feeds/domain/feed_generator.dart';

/// Represents list metadata from app.bsky.graph.getList.
///
/// Lists in Bluesky can be used as feeds to view posts from list members.
class ListView {
  const ListView({
    required this.uri,
    required this.cid,
    required this.creator,
    required this.name,
    required this.purpose,
    this.description,
    this.avatar,
    this.listItemCount,
    this.indexedAt,
  });

  /// Creates a ListView from API JSON response with validation.
  ///
  /// Throws [FormatException] if required fields are missing or invalid.
  factory ListView.fromJson(Map<String, dynamic> json) {
    final uri = json['uri'];
    final cid = json['cid'];
    final name = json['name'];
    final purpose = json['purpose'];

    if (uri is! String || uri.isEmpty) {
      throw FormatException('ListView.uri must be a non-empty string', json);
    }
    if (cid is! String || cid.isEmpty) {
      throw FormatException('ListView.cid must be a non-empty string', json);
    }
    if (name is! String || name.isEmpty) {
      throw FormatException('ListView.name must be a non-empty string', json);
    }
    if (purpose is! String || purpose.isEmpty) {
      throw FormatException('ListView.purpose must be a non-empty string', json);
    }

    final creatorJson = json['creator'];
    if (creatorJson is! Map<String, dynamic>) {
      throw FormatException('ListView.creator must be a Map', json);
    }

    return ListView(
      uri: uri,
      cid: cid,
      creator: ActorBasic.fromJson(creatorJson),
      name: name,
      purpose: purpose,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
      listItemCount: json['listItemCount'] as int?,
      indexedAt: _parseDateTime(json['indexedAt']),
    );
  }

  /// The AT URI of the list (at://did:plc:xxx/app.bsky.graph.list/yyy).
  final String uri;

  /// The CID (content identifier) of the list record.
  final String cid;

  /// The creator/owner of the list.
  final ActorBasic creator;

  /// The name of the list.
  final String name;

  /// The purpose of the list (e.g., "app.bsky.graph.defs#curatelist", "app.bsky.graph.defs#modlist").
  final String purpose;

  /// Description of the list.
  final String? description;

  /// URL to the list's avatar/icon image.
  final String? avatar;

  /// Number of items in the list.
  final int? listItemCount;

  /// When the list was indexed by the AppView.
  final DateTime? indexedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListView && runtimeType == other.runtimeType && uri == other.uri;

  @override
  int get hashCode => uri.hashCode;
}

/// Helper function to safely parse DateTime from dynamic JSON value.
DateTime? _parseDateTime(dynamic value) {
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
