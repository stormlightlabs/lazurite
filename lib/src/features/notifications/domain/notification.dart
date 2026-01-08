import '../../../infrastructure/db/app_database.dart';
import 'notification_type.dart';

/// Represents a notification from the Bluesky AT Protocol.
///
/// This domain model combines data from the Notifications table
/// with a Profile for the actor who triggered the notification.
class AppNotification {
  AppNotification({
    required this.uri,
    required this.actor,
    required this.type,
    this.reasonSubjectUri,
    this.recordJson,
    required this.indexedAt,
    required this.isRead,
  });

  /// Notification AT URI (unique identifier).
  final String uri;

  /// The user who triggered the notification.
  final Profile actor;

  /// The type of notification.
  final NotificationType type;

  /// URI of the subject (post/profile) this notification is about.
  final String? reasonSubjectUri;

  /// Associated record JSON (for displaying notification context).
  final String? recordJson;

  /// When the notification was indexed on the server.
  final DateTime indexedAt;

  /// Whether the notification has been read.
  final bool isRead;

  /// Returns a copy with updated fields.
  AppNotification copyWith({
    String? uri,
    Profile? actor,
    NotificationType? type,
    String? reasonSubjectUri,
    String? recordJson,
    DateTime? indexedAt,
    bool? isRead,
  }) {
    return AppNotification(
      uri: uri ?? this.uri,
      actor: actor ?? this.actor,
      type: type ?? this.type,
      reasonSubjectUri: reasonSubjectUri ?? this.reasonSubjectUri,
      recordJson: recordJson ?? this.recordJson,
      indexedAt: indexedAt ?? this.indexedAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
