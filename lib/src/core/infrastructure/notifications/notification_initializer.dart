import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Service for initializing and configuring local notifications.
///
/// This singleton handles:
/// - Initializing the timezone database
/// - Configuring Android notification channels
/// - Configuring iOS notification permissions
/// - Requesting notification permissions from the user
class NotificationInitializer {
  NotificationInitializer._();

  static final _instance = NotificationInitializer._();
  static NotificationInitializer get instance => _instance;

  FlutterLocalNotificationsPlugin? _plugin;
  void Function(NotificationResponse)? _onNotificationTap;

  /// Returns the initialized FlutterLocalNotificationsPlugin instance.
  FlutterLocalNotificationsPlugin get plugin {
    if (_plugin == null) {
      throw StateError('NotificationInitializer not initialized. Call initialize() first.');
    }
    return _plugin!;
  }

  /// Initializes the notification system.
  ///
  /// This must be called before using any notification functionality.
  /// It initializes the timezone database and configures platform-specific
  /// notification settings.
  Future<FlutterLocalNotificationsPlugin> initialize({
    void Function(NotificationResponse)? onNotificationTap,
  }) async {
    if (_plugin != null) {
      _onNotificationTap = onNotificationTap;
      return _plugin!;
    }

    _onNotificationTap = onNotificationTap;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(tz.local.name));

    const androidChannel = AndroidNotificationChannel(
      'scheduled_posts',
      'Scheduled Posts',
      description: 'Notifications for scheduled posts',
      importance: Importance.high,
    );

    const androidInit = AndroidInitializationSettings('@mipmap/launcher');

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    _plugin = FlutterLocalNotificationsPlugin();

    await _plugin!.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
    await _plugin!
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    return _plugin!;
  }

  /// Sets or updates the notification tap handler.
  void setOnNotificationTapCallback(void Function(NotificationResponse) callback) {
    _onNotificationTap = callback;
  }

  void _handleNotificationTap(NotificationResponse response) {
    if (_onNotificationTap != null) {
      _onNotificationTap!(response);
    } else {
      debugPrint('Notification tapped: ${response.payload}');
    }
  }

  /// Requests notification permissions from the user.
  ///
  /// On iOS, this will show the permission dialog if not already requested.
  /// On Android, permissions are granted at install time.
  Future<bool> requestPermissions() async {
    final androidPlugin = _plugin
        ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final iosPlugin = _plugin
        ?.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    final androidGranted = await androidPlugin?.requestNotificationsPermission() ?? true;
    final iosGranted =
        await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true) ?? true;

    return androidGranted || iosGranted;
  }

  /// Checks if notifications are permitted.
  Future<bool> areNotificationsPermitted() async {
    final androidPlugin = _plugin
        ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final iosPlugin = _plugin
        ?.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    final androidPermitted = await androidPlugin?.areNotificationsEnabled() ?? true;
    final iosPermitted = await iosPlugin?.checkPermissions() != null;
    return androidPermitted || iosPermitted;
  }
}
