import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/notifications/domain/push_token_provider.dart';

class FirebasePushTokenProvider implements PushTokenProvider {
  FirebasePushTokenProvider({
    FirebaseMessaging? messaging,
    bool Function()? isApplePlatform,
    Future<void> Function(Duration)? delayFn,
    int apnsTokenRetryAttempts = 15,
    Duration apnsTokenRetryDelay = const Duration(milliseconds: 400),
  }) : _messaging = messaging,
       _isApplePlatform = isApplePlatform ?? (() => Platform.isIOS || Platform.isMacOS),
       _delayFn = delayFn ?? Future.delayed,
       _apnsTokenRetryAttempts = apnsTokenRetryAttempts,
       _apnsTokenRetryDelay = apnsTokenRetryDelay;

  FirebaseMessaging? _messaging;
  final bool Function() _isApplePlatform;
  final Future<void> Function(Duration) _delayFn;
  final int _apnsTokenRetryAttempts;
  final Duration _apnsTokenRetryDelay;
  final _refreshController = StreamController<String>.broadcast();
  StreamSubscription<String>? _refreshSubscription;
  var _initialized = false;

  @override
  Stream<String> get onTokenRefresh => _refreshController.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      if (_messaging == null) {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp();
        }
        _messaging = FirebaseMessaging.instance;
      }

      final messaging = _messaging!;

      final notificationSettings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      log.i('Notification permission status: ${notificationSettings.authorizationStatus.name}');

      await messaging.setAutoInitEnabled(true);
      await _waitForApnsToken(messaging);

      _refreshSubscription = messaging.onTokenRefresh.listen(
        (token) {
          if (token.trim().isEmpty) {
            return;
          }
          _refreshController.add(token);
        },
        onError: (Object error, StackTrace stackTrace) {
          log.w('Push token refresh listener failed', error: error, stackTrace: stackTrace);
        },
      );

      _initialized = true;
    } catch (error, stackTrace) {
      log.w(
        'Push token provider initialization failed; push registration is disabled until Firebase is configured',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<String?> getToken() async {
    await initialize();
    if (!_initialized) {
      return null;
    }

    try {
      await _waitForApnsToken(_messaging!);
      final token = await _messaging!.getToken();
      final trimmed = token?.trim();
      if (trimmed == null || trimmed.isEmpty) {
        return null;
      }
      return trimmed;
    } catch (error, stackTrace) {
      log.w('Failed to acquire push token', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> _waitForApnsToken(FirebaseMessaging messaging) async {
    if (!_isApplePlatform()) {
      return;
    }

    for (var attempt = 1; attempt <= _apnsTokenRetryAttempts; attempt++) {
      final apnsToken = await messaging.getAPNSToken();
      final normalized = apnsToken?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        if (attempt > 1) {
          log.i('APNs token became available after retry (attempt $attempt/$_apnsTokenRetryAttempts)');
        }
        return;
      }
      await _delayFn(_apnsTokenRetryDelay);
    }

    log.w(
      'APNs token unavailable after retries; FCM token registration may be delayed '
      'until APNs registration completes',
    );
  }

  @override
  Future<void> dispose() async {
    await _refreshSubscription?.cancel();
    await _refreshController.close();
  }
}
