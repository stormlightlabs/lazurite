import 'package:collection/collection.dart';

/// Types of notifications supported by Bluesky.
enum NotificationType {
  like,
  repost,
  follow,
  mention,
  reply,
  quote,
  starterpackJoined;

  /// Parses a notification reason string from the API into a NotificationType.
  ///
  /// Handles both camelCase and kebab-case formats (e.g., 'starterpack-joined').
  static NotificationType? fromString(String value) {
    final normalized = value.replaceAll('-', '').toLowerCase();
    return NotificationType.values.firstWhereOrNull((e) => e.name.toLowerCase() == normalized);
  }

  /// Returns a human-readable description for this notification type.
  String get displayText {
    switch (this) {
      case NotificationType.like:
        return 'liked your post';
      case NotificationType.repost:
        return 'reposted your post';
      case NotificationType.follow:
        return 'followed you';
      case NotificationType.mention:
        return 'mentioned you';
      case NotificationType.reply:
        return 'replied to your post';
      case NotificationType.quote:
        return 'quoted your post';
      case NotificationType.starterpackJoined:
        return 'joined via your starter pack';
    }
  }
}
