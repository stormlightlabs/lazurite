enum NotificationTapNavigationMode { go, push }

class NotificationDeepLink {
  const NotificationDeepLink({required this.route, required this.navigationMode});

  final String route;
  final NotificationTapNavigationMode navigationMode;
}

enum NotificationReasonFamily { mentions, replies, follows, likes, misc }

class LocalNotificationRequest {
  const LocalNotificationRequest({
    required this.notificationId,
    required this.title,
    required this.body,
    required this.reasonFamily,
    required this.deepLink,
  });

  final int notificationId;
  final String title;
  final String body;
  final NotificationReasonFamily reasonFamily;
  final NotificationDeepLink deepLink;
}
