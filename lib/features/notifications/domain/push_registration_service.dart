import 'dart:async';
import 'dart:io';

import 'package:poptart_core/poptart_core.dart' as atcore show UnauthorizedException;
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/notifications/domain/push_token_provider.dart';

typedef NotificationRepositoryFactory = NotificationRepository Function(AuthTokens tokens);
typedef DelayFn = Future<void> Function(Duration delay);
typedef PushAuthRecoveryCallback = Future<AuthTokens?> Function();

class PushRegistrationService {
  PushRegistrationService({
    required PushTokenProvider tokenProvider,
    required NotificationRepositoryFactory notificationRepositoryFactory,
    this.appId = 'org.stormlightlabs.lazurite',
    Duration initialBackoff = const Duration(seconds: 1),
    int maxAttempts = 4,
    DelayFn delayFn = Future.delayed,
    bool Function()? isPushPlatformSupported,
    PushAuthRecoveryCallback? authRecovery,
  }) : _tokenProvider = tokenProvider,
       _notificationRepositoryFactory = notificationRepositoryFactory,
       _initialBackoff = initialBackoff,
       _maxAttempts = maxAttempts,
       _delayFn = delayFn,
       _isPushPlatformSupported = isPushPlatformSupported ?? (() => Platform.isAndroid || Platform.isIOS),
       _authRecovery = authRecovery;

  final PushTokenProvider _tokenProvider;
  final NotificationRepositoryFactory _notificationRepositoryFactory;
  final String appId;
  final Duration _initialBackoff;
  final int _maxAttempts;
  final DelayFn _delayFn;
  final bool Function() _isPushPlatformSupported;
  PushAuthRecoveryCallback? _authRecovery;

  StreamSubscription<String>? _tokenRefreshSubscription;
  AuthTokens? _activeTokens;
  String? _registeredDid;
  String? _registeredToken;
  var _started = false;

  bool get _supportsPushPlatform => _isPushPlatformSupported();

  void configureAuthRecovery(PushAuthRecoveryCallback? authRecovery) {
    _authRecovery = authRecovery;
  }

  Future<void> start({required AuthTokens? initialTokens}) async {
    if (_started || !_supportsPushPlatform) {
      _activeTokens = initialTokens;
      return;
    }

    _started = true;
    _activeTokens = initialTokens;

    await _tokenProvider.initialize();
    _tokenRefreshSubscription = _tokenProvider.onTokenRefresh.listen(
      (token) {
        unawaited(_handleTokenRefresh(token));
      },
      onError: (Object error, StackTrace stackTrace) {
        log.w('Push token refresh stream failed', error: error, stackTrace: stackTrace);
      },
    );

    try {
      await _syncCurrentSession();
    } catch (error, stackTrace) {
      log.w('Initial push registration sync failed', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> updateSession(AuthTokens? tokens) async {
    if (!_supportsPushPlatform) {
      _activeTokens = tokens;
      return;
    }

    final previousTokens = _activeTokens;
    _activeTokens = tokens;

    if (previousTokens != null && (tokens == null || tokens.did != previousTokens.did)) {
      try {
        await _unregisterWithCurrentToken(previousTokens);
      } catch (error, stackTrace) {
        log.w('Push unregistration during session transition failed', error: error, stackTrace: stackTrace);
      }
    }

    if (tokens == null) {
      return;
    }

    try {
      await _syncCurrentSession();
    } catch (error, stackTrace) {
      log.w('Push registration sync failed', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _handleTokenRefresh(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final tokens = _activeTokens;
    if (tokens == null) {
      return;
    }

    final previousToken = _registeredToken;
    final previousDid = _registeredDid;
    _registeredToken = null;

    if (previousToken != null && previousDid == tokens.did && previousToken != trimmed) {
      try {
        await _retry(
          operation: 'push unregister refresh',
          action: () async {
            await _notificationRepositoryFactory(
              tokens,
            ).unregisterPush(token: previousToken, appId: appId, platform: _platform);
          },
        );
      } catch (error, stackTrace) {
        log.w('Push refresh unregistration failed', error: error, stackTrace: stackTrace);
      }
    }

    try {
      await _register(tokens: tokens, token: trimmed);
    } catch (error, stackTrace) {
      log.w('Push refresh registration failed', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _syncCurrentSession() async {
    final tokens = _activeTokens;
    if (tokens == null) {
      return;
    }

    final token = await _tokenProvider.getToken();
    if (token == null || token.trim().isEmpty) {
      log.w('Push token unavailable; skipping push registration for ${tokens.did}');
      return;
    }

    if (_registeredDid == tokens.did && _registeredToken == token) {
      return;
    }

    await _register(tokens: tokens, token: token);
  }

  Future<void> _register({required AuthTokens tokens, required String token}) async {
    var operationTokens = tokens;
    await _retry(
      operation: 'push register',
      action: () async {
        await _notificationRepositoryFactory(
          operationTokens,
        ).registerPush(token: token, appId: appId, platform: _platform);
      },
      recoverUnauthorized: () async {
        final recovered = await _recoverActiveSession(expectedDid: tokens.did);
        if (recovered == null) {
          return false;
        }
        operationTokens = recovered;
        return true;
      },
    );

    _registeredDid = operationTokens.did;
    _registeredToken = token;
  }

  Future<void> _unregisterWithCurrentToken(AuthTokens tokens) async {
    final registeredToken = _registeredToken;
    if (registeredToken == null || _registeredDid != tokens.did) {
      return;
    }

    await _retry(
      operation: 'push unregister',
      action: () async {
        await _notificationRepositoryFactory(
          tokens,
        ).unregisterPush(token: registeredToken, appId: appId, platform: _platform);
      },
    );

    _registeredDid = null;
    _registeredToken = null;
  }

  Future<void> _retry({
    required String operation,
    required Future<void> Function() action,
    Future<bool> Function()? recoverUnauthorized,
  }) async {
    var backoff = Duration.zero;
    Object? lastError;
    StackTrace? lastStackTrace;

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      if (backoff > Duration.zero) {
        await _delayFn(backoff);
      }

      try {
        await action();
        return;
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;

        if (error is atcore.UnauthorizedException && recoverUnauthorized != null) {
          final recovered = await recoverUnauthorized();
          if (recovered) {
            backoff = Duration.zero;
            log.w('Push lifecycle operation recovered auth session: $operation');
            continue;
          }
        }

        if (attempt >= _maxAttempts) {
          log.e('Push lifecycle operation failed: $operation', error: error, stackTrace: stackTrace);
          Error.throwWithStackTrace(error, stackTrace);
        }

        backoff = backoff == Duration.zero ? _initialBackoff : backoff * 2;
        log.w(
          'Push lifecycle operation retrying: $operation attempt=$attempt/${_maxAttempts - 1}',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (lastError != null) {
      Error.throwWithStackTrace(lastError, lastStackTrace ?? StackTrace.current);
    }
  }

  Future<AuthTokens?> _recoverActiveSession({required String expectedDid}) async {
    final recovery = _authRecovery;
    if (recovery == null) {
      return null;
    }

    final recovered = await recovery();
    if (recovered == null || recovered.did != expectedDid) {
      return null;
    }

    _activeTokens = recovered;
    return recovered;
  }

  NotificationPushPlatform get _platform =>
      Platform.isIOS ? NotificationPushPlatform.ios : NotificationPushPlatform.android;

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _tokenProvider.dispose();
  }
}
