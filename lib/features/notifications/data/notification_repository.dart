import 'package:bluesky/app_bsky_notification_listnotifications.dart';
import 'package:bluesky/bluesky.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';

class NotificationRepository {
  NotificationRepository({
    required Bluesky bluesky,
    ModerationService? moderationService,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
  }) : _bluesky = bluesky,
       _moderationService = moderationService,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       );

  final Bluesky _bluesky;
  final ModerationService? _moderationService;
  final AppViewRequestContext _appViewContext;

  Future<NotificationListResult> listNotifications({String? cursor, int limit = 50}) async {
    final response = await _bluesky.notification.listNotifications(
      cursor: cursor,
      limit: limit,
      $headers: _appViewContext.appBskyHeaders(await _moderationService?.headersForRequest()),
    );

    return NotificationListResult(
      notifications: _filterNotifications(response.data.notifications),
      cursor: response.data.cursor,
      seenAt: response.data.seenAt,
    );
  }

  Future<int> getUnreadCount() async {
    final response = await _bluesky.notification.getUnreadCount(
      $headers: _appViewContext.appBskyHeaders(await _moderationService?.headersForRequest()),
    );
    return response.data.count;
  }

  Future<void> updateSeen() async {
    await _bluesky.notification.updateSeen(
      seenAt: DateTime.now(),
      $headers: _appViewContext.appBskyHeaders(await _moderationService?.headersForRequest()),
    );
  }

  List<Notification> _filterNotifications(List<Notification> notifications) {
    final moderationService = _moderationService;
    if (moderationService == null) {
      return notifications;
    }

    return notifications
        .where((notification) => !moderationService.shouldFilterNotificationInList(notification))
        .toList();
  }
}

class NotificationListResult {
  NotificationListResult({required this.notifications, this.cursor, this.seenAt});

  final List<Notification> notifications;
  final String? cursor;
  final DateTime? seenAt;
}
