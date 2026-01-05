import 'dart:async';

import 'package:dio/dio.dart';
import 'package:jose/jose.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/auth/dpop_nonce_store.dart';
import 'package:lazurite/src/infrastructure/auth/dpop_utils.dart';

/// Callback type for getting the current session.
typedef SessionGetter = Future<Session?> Function();

/// Callback type for refreshing the session.
typedef SessionRefresher = Future<Session?> Function();

/// Callback type for notifying when session is invalidated.
typedef SessionInvalidatedCallback = void Function();

/// Interceptor that handles authentication for XRPC requests.
///
/// Attaches the access token and DPoP proof to requests that require authentication,
/// and handles 401 responses by attempting to refresh the token once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.getSession,
    required this.refreshSession,
    this.onSessionInvalidated,
    DPoPNonceStore? nonceStore,
    Logger? logger,
  }) : _nonceStore = nonceStore ?? DPoPNonceStore(),
       _logger = logger ?? const Logger('AuthInterceptor');

  /// Callback to get the current session.
  final SessionGetter getSession;

  /// Callback to refresh the session.
  final SessionRefresher refreshSession;

  /// Callback invoked when the session is invalidated (e.g., InvalidToken).
  final SessionInvalidatedCallback? onSessionInvalidated;

  /// ATProto error codes that indicate an invalid/expired token.
  static const _invalidTokenErrorCodes = {'InvalidToken', 'ExpiredToken'};

  /// Store for DPoP nonces.
  final DPoPNonceStore _nonceStore;

  /// Logger instance.
  final Logger _logger;

  /// Completer used to queue requests during token refresh.
  ///
  /// When null, no refresh is in progress. When non-null, a refresh is in progress
  /// and concurrent requests should wait for the completer to complete.
  Completer<Session?>? _refreshCompleter;

  /// Key used to mark requests as requiring auth in options.extra.
  static const requiresAuthKey = 'requiresAuth';

  /// Key used to ensure invalid token retries only happen once.
  static const _invalidTokenRetriedKey = '_invalidTokenRetried';

  /// Retries a request with a new session.
  Future<void> _retryRequestWithSession(
    DioException err,
    Session newSession,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    // Use DPoP scheme for Authorization header as per RFC 9449
    options.headers['Authorization'] = 'DPoP ${newSession.accessJwt}';

    try {
      final dpopKey = JsonWebKey.fromJson(newSession.dpopKey);
      final url = options.uri.toString();
      final method = options.method;
      final nonce = _nonceStore.get(newSession.pdsUrl);

      final proof = await DPoPUtils.createProof(
        url: url,
        method: method,
        privateKey: dpopKey,
        accessToken: newSession.accessJwt,
        nonce: nonce,
      );

      options.headers['DPoP'] = proof;
    } catch (e) {
      _logger.warning('Failed to create DPoP proof for retry', e);
    }

    options.extra['_authRetried'] = true;
    final retryDio = Dio(
      BaseOptions(
        baseUrl: options.baseUrl,
        connectTimeout: options.connectTimeout,
        receiveTimeout: options.receiveTimeout,
        sendTimeout: options.sendTimeout,
      ),
    );

    try {
      final response = await retryDio.fetch(options);
      handler.resolve(response);
    } catch (e) {
      handler.next(err);
    }
  }

  /// Performs a token refresh with completer-based coordination.
  ///
  /// If a refresh is already in progress, waits for it to complete.
  /// Otherwise, initiates a new refresh.
  Future<Session?> _performRefresh() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<Session?>();

    try {
      final newSession = await refreshSession();
      _refreshCompleter!.complete(newSession);
      return newSession;
    } catch (e, st) {
      _logger.warning('Session refresh failed', e, st);
      _refreshCompleter!.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final requiresAuth = options.extra[requiresAuthKey] == true;

    if (requiresAuth) {
      var session = await getSession();

      // Proactively refresh if token is near expiration
      if (session != null && session.isNearExpiration && !session.isExpired) {
        _logger.debug('Token near expiration, proactively refreshing');
        final refreshed = await _performRefresh();
        if (refreshed != null) {
          session = refreshed;
        } else {
          _logger.warning('Proactive refresh failed, continuing with existing token');
        }
      }

      if (session != null) {
        final token = session.accessJwt;
        // Use DPoP scheme for Authorization header as per RFC 9449
        options.headers['Authorization'] = 'DPoP $token';

        try {
          final dpopKey = JsonWebKey.fromJson(session.dpopKey);
          final url = options.uri.toString();
          final method = options.method;
          final nonce = _nonceStore.get(session.pdsUrl);

          final proof = await DPoPUtils.createProof(
            url: url,
            method: method,
            privateKey: dpopKey,
            accessToken: token,
            nonce: nonce,
          );

          options.headers['DPoP'] = proof;
        } catch (e) {
          _logger.warning('Failed to create DPoP proof for request', e);
        }
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    final requiresAuth = response.requestOptions.extra[requiresAuthKey] == true;
    if (requiresAuth) {
      final session = await getSession();
      if (session != null) {
        final nonce = DPoPNonceStore.extractFromHeaders(response.headers.map);
        if (nonce != null) {
          _nonceStore.store(session.pdsUrl, nonce);
        }
      }
    }

    handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final requiresAuth = err.requestOptions.extra[requiresAuthKey] == true;

    if (requiresAuth) {
      final session = await getSession();
      if (session != null && err.response != null) {
        final nonce = DPoPNonceStore.extractFromHeaders(err.response!.headers.map);
        if (nonce != null) {
          _nonceStore.store(session.pdsUrl, nonce);
        }
      }

      if (await _tryRefreshAfterInvalidToken(err, handler)) {
        return;
      }
    }

    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }
    if (!requiresAuth) {
      return handler.next(err);
    }

    final hasRetried = err.requestOptions.extra['_authRetried'] == true;
    if (hasRetried) {
      return handler.next(err);
    }

    if (_refreshCompleter != null) {
      try {
        final newSession = await _refreshCompleter!.future;
        if (newSession == null) {
          return handler.next(err);
        }

        return _retryRequestWithSession(err, newSession, handler);
      } catch (e) {
        return handler.next(err);
      }
    }

    _refreshCompleter = Completer<Session?>();

    try {
      final newSession = await refreshSession();
      _refreshCompleter!.complete(newSession);

      if (newSession == null) {
        return handler.next(err);
      }

      return _retryRequestWithSession(err, newSession, handler);
    } catch (e) {
      _refreshCompleter!.completeError(e);
      return handler.next(err);
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<bool> _tryRefreshAfterInvalidToken(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 400) {
      return false;
    }

    final errorCode = _extractErrorCode(err.response);
    final isInvalidTokenError = errorCode != null && _invalidTokenErrorCodes.contains(errorCode);
    if (!isInvalidTokenError) {
      return false;
    }

    final hasRetried = err.requestOptions.extra[_invalidTokenRetriedKey] == true;
    if (!hasRetried) {
      err.requestOptions.extra[_invalidTokenRetriedKey] = true;
      final newSession = await _performRefresh();
      if (newSession != null) {
        await _retryRequestWithSession(err, newSession, handler);
        return true;
      }
    }

    _logger.warning('Session invalidated due to $errorCode');
    onSessionInvalidated?.call();
    handler.next(err);
    return true;
  }

  /// Extracts the ATProto error code from a response.
  String? _extractErrorCode(Response<dynamic>? response) {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      return data['error'] as String?;
    }
    return null;
  }
}
