import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lazurite/src/core/domain/author.dart';

import 'notification_type.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// Represents a notification from the Bluesky AT Protocol.
///
/// This domain model combines data from the Notifications table
/// with a Profile for the actor who triggered the notification.
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    /// Notification AT URI (unique identifier).
    required String uri,

    /// The user who triggered the notification.
    required Author actor,

    /// The type of notification.
    required NotificationType type,

    /// URI of the subject (post/profile) this notification is about.
    String? reasonSubjectUri,

    /// Associated record JSON (for displaying notification context).
    String? recordJson,

    /// When the notification was indexed on the server.
    required DateTime indexedAt,

    /// Whether the notification has been read.
    required bool isRead,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);
}
