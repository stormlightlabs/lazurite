import 'package:lazurite/features/notifications/domain/notification_local_models.dart';

typedef NotificationTapCallback = void Function(NotificationDeepLink deepLink);

abstract class LocalNotificationAdapter {
  Future<void> initialize({required NotificationTapCallback onTap});

  Future<void> requestPermissions();

  Future<void> show(LocalNotificationRequest request);
}
