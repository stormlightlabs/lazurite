import 'package:go_router/go_router.dart';
import 'package:lazurite/features/notifications/domain/notification_local_models.dart';

class NotificationDeepLinkNavigator {
  static void navigate(GoRouter router, NotificationDeepLink deepLink) {
    switch (deepLink.navigationMode) {
      case NotificationTapNavigationMode.go:
        router.go(deepLink.route);
        break;
      case NotificationTapNavigationMode.push:
        router.push(deepLink.route);
        break;
    }
  }
}
