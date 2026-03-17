import 'package:bluesky/app_bsky_notification_listnotifications.dart';
import 'package:bluesky/bluesky.dart';

class NotificationRepository {
  NotificationRepository({required Bluesky bluesky}) : _bluesky = bluesky;

  final Bluesky _bluesky;

  Future<NotificationListResult> listNotifications({String? cursor, int limit = 50}) async {
    final response = await _bluesky.notification.listNotifications(cursor: cursor, limit: limit);

    return NotificationListResult(
      notifications: response.data.notifications,
      cursor: response.data.cursor,
      seenAt: response.data.seenAt,
    );
  }

  Future<int> getUnreadCount() async {
    final response = await _bluesky.notification.getUnreadCount();
    return response.data.count;
  }

  Future<void> updateSeen() async {
    await _bluesky.notification.updateSeen(seenAt: DateTime.now());
  }
}

class NotificationListResult {
  NotificationListResult({required this.notifications, this.cursor, this.seenAt});

  final List<Notification> notifications;
  final String? cursor;
  final DateTime? seenAt;
}
