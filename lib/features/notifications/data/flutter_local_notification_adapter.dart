import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lazurite/features/notifications/domain/local_notification_adapter.dart';
import 'package:lazurite/features/notifications/domain/notification_local_mappers.dart';
import 'package:lazurite/features/notifications/domain/notification_local_models.dart';

class FlutterLocalNotificationAdapter implements LocalNotificationAdapter {
  FlutterLocalNotificationAdapter({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  var _initialized = false;

  @override
  Future<void> initialize({required NotificationTapCallback onTap}) async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final categories = NotificationReasonFamily.values
        .map((family) => DarwinNotificationCategory(family.iosCategoryIdentifier))
        .toList(growable: false);
    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: categories,
    );

    await _plugin.initialize(
      InitializationSettings(android: androidSettings, iOS: darwinSettings),
      onDidReceiveNotificationResponse: (response) {
        final deepLink = NotificationPayloadCodec.decode(response.payload);
        if (deepLink != null) {
          onTap(deepLink);
        }
      },
    );

    await _createAndroidChannels();

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final deepLink = NotificationPayloadCodec.decode(launchDetails?.notificationResponse?.payload);
      if (deepLink != null) {
        onTap(deepLink);
      }
    }

    _initialized = true;
  }

  @override
  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  @override
  Future<void> show(LocalNotificationRequest request) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        request.reasonFamily.androidChannelId,
        request.reasonFamily.androidChannelName,
        channelDescription: '${request.reasonFamily.androidChannelName} notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(categoryIdentifier: request.reasonFamily.iosCategoryIdentifier),
    );

    await _plugin.show(
      request.notificationId,
      request.title,
      request.body,
      details,
      payload: NotificationPayloadCodec.encode(request.deepLink),
    );
  }

  Future<void> _createAndroidChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) {
      return;
    }

    for (final family in NotificationReasonFamily.values) {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          family.androidChannelId,
          family.androidChannelName,
          description: '${family.androidChannelName} notifications',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }
}
