/// Domain models for AT Protocol feed generator responses.
///
/// These models provide type-safe parsing of feed metadata from the
/// app.bsky.feed.getFeedGenerator and related endpoints, replacing
/// fragile dynamic JSON navigation with validated data structures.
library;

/// Represents a feed generator creator or basic actor profile.
///
/// This is a minimal profile representation used in feed metadata
/// and actor search results.
class ActorBasic {
  const ActorBasic({
    required this.did,
    required this.handle,
    this.displayName,
    this.avatar,
    this.description,
    this.indexedAt,
    this.followersCount,
    this.followsCount,
    this.postsCount,
  });

  /// Creates an ActorBasic from API JSON response with validation.
  ///
  /// Throws [FormatException] if required fields are missing or invalid.
  factory ActorBasic.fromJson(Map<String, dynamic> json) {
    final did = json['did'];
    final handle = json['handle'];

    if (did is! String || did.isEmpty) {
      throw FormatException('ActorBasic.did must be a non-empty string', json);
    }
    if (handle is! String || handle.isEmpty) {
      throw FormatException('ActorBasic.handle must be a non-empty string', json);
    }

    return ActorBasic(
      did: did,
      handle: handle,
      displayName: json['displayName'] as String?,
      avatar: json['avatar'] as String?,
      description: json['description'] as String?,
      indexedAt: _parseDateTime(json['indexedAt']),
      followersCount: json['followersCount'] as int?,
      followsCount: json['followsCount'] as int?,
      postsCount: json['postsCount'] as int?,
    );
  }

  /// The decentralized identifier (DID) of the actor.
  final String did;

  /// The handle (username) of the actor.
  final String handle;

  /// The display name (may be null).
  final String? displayName;

  /// URL to the actor's avatar image.
  final String? avatar;

  /// Profile description/bio.
  final String? description;

  /// When the actor was indexed by the AppView.
  final DateTime? indexedAt;

  /// Number of followers (present in search results).
  final int? followersCount;

  /// Number of follows (present in search results).
  final int? followsCount;

  /// Number of posts (present in search results).
  final int? postsCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActorBasic && runtimeType == other.runtimeType && did == other.did;

  @override
  int get hashCode => did.hashCode;
}

/// Represents feed generator metadata from app.bsky.feed.getFeedGenerator.
///
/// This model provides type-safe access to feed metadata, replacing
/// fragile patterns like `metadata['creator']['did']`.
class FeedGenerator {
  const FeedGenerator({
    required this.uri,
    required this.cid,
    required this.did,
    required this.creator,
    required this.displayName,
    this.description,
    this.avatar,
    this.likeCount,
    this.indexedAt,
  });

  /// Creates a FeedGenerator from API JSON response with validation.
  ///
  /// Throws [FormatException] if required fields are missing or invalid.
  factory FeedGenerator.fromJson(Map<String, dynamic> json) {
    final uri = json['uri'];
    final cid = json['cid'];
    final did = json['did'];
    final displayName = json['displayName'];

    if (uri is! String || uri.isEmpty) {
      throw FormatException('FeedGenerator.uri must be a non-empty string', json);
    }
    if (cid is! String || cid.isEmpty) {
      throw FormatException('FeedGenerator.cid must be a non-empty string', json);
    }
    if (did is! String || did.isEmpty) {
      throw FormatException('FeedGenerator.did must be a non-empty string', json);
    }
    if (displayName is! String || displayName.isEmpty) {
      throw FormatException('FeedGenerator.displayName must be a non-empty string', json);
    }

    final creatorJson = json['creator'];
    if (creatorJson is! Map<String, dynamic>) {
      throw FormatException('FeedGenerator.creator must be a Map', json);
    }

    return FeedGenerator(
      uri: uri,
      cid: cid,
      did: did,
      creator: ActorBasic.fromJson(creatorJson),
      displayName: displayName,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
      likeCount: json['likeCount'] as int?,
      indexedAt: _parseDateTime(json['indexedAt']),
    );
  }

  /// The AT URI of the feed generator (at://did:plc:xxx/app.bsky.feed.generator/yyy).
  final String uri;

  /// The CID (content identifier) of the feed generator record.
  final String cid;

  /// The DID of the feed generator service.
  final String did;

  /// The creator/author of the feed generator.
  final ActorBasic creator;

  /// The display name of the feed.
  final String displayName;

  /// Description of what the feed shows.
  final String? description;

  /// URL to the feed's avatar/icon image.
  final String? avatar;

  /// Number of likes on the feed generator.
  final int? likeCount;

  /// When the feed was indexed by the AppView.
  final DateTime? indexedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedGenerator && runtimeType == other.runtimeType && uri == other.uri;

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
