import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/core/infrastructure/notifications/notification_initializer.dart';

/// Service for handling notification interactions and deep linking.
///
/// This singleton manages:
/// - Notification tap handling with deep linking to scheduled posts
/// - Integration with the app's router for navigation
class NotificationController {
  NotificationController._();

  static final _instance = NotificationController._();
  static NotificationController get instance => _instance;

  GlobalKey<NavigatorState>? _navigatorKey;

  /// Initializes the notification controller with the app's navigator key.
  ///
  /// This must be called after the router is initialized.
  void initialize({GlobalKey<NavigatorState>? navigatorKey}) {
    _navigatorKey = navigatorKey;
    NotificationInitializer.instance.setOnNotificationTapCallback(_onNotificationTap);
    debugPrint('NotificationController initialized');
  }

  /// Handles notification tap events.
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;

    if (payload == null) {
      debugPrint('Notification tapped with no payload');
      return;
    }

    debugPrint('Notification tapped with payload: $payload');

    if (payload.startsWith('draft:')) {
      final draftId = payload.substring(6);
      _navigateToScheduledPost(draftId);
    }
  }

  /// Navigates to the scheduled post detail screen.
  void _navigateToScheduledPost(String draftId) {
    if (_navigatorKey == null) {
      debugPrint('No navigator key available for scheduled post: $draftId');
      return;
    }

    final context = _navigatorKey!.currentContext;

    if (context == null) {
      debugPrint('No navigation context available for scheduled post: $draftId');
      return;
    }

    try {
      context.go('/scheduled/$draftId');
    } catch (e) {
      debugPrint('Failed to navigate to scheduled post: $e');
    }
  }
}
