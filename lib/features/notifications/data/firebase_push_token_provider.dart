import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/notifications/domain/push_token_provider.dart';

class FirebasePushTokenProvider implements PushTokenProvider {
  FirebasePushTokenProvider({FirebaseMessaging? messaging}) : _messaging = messaging;

  FirebaseMessaging? _messaging;
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
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      _messaging ??= FirebaseMessaging.instance;
      final messaging = _messaging!;

      await messaging.setAutoInitEnabled(true);

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

  @override
  Future<void> dispose() async {
    await _refreshSubscription?.cancel();
    await _refreshController.close();
  }
}
