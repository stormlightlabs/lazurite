import 'package:dio/dio.dart';
import 'package:jose/jose.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/infrastructure/auth/dpop_nonce_store.dart';
import 'package:lazurite/src/infrastructure/auth/dpop_utils.dart';

/// Callback type for getting the current session.
typedef SessionGetter = Future<Session?> Function();

/// Callback type for refreshing the session.
typedef SessionRefresher = Future<Session?> Function();

/// Interceptor that handles authentication for XRPC requests.
///
/// Attaches the access token and DPoP proof to requests that require authentication,
/// and handles 401 responses by attempting to refresh the token once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.getSession,
    required this.refreshSession,
    DPoPNonceStore? nonceStore,
  }) : _nonceStore = nonceStore ?? DPoPNonceStore();

  /// Callback to get the current session.
  final SessionGetter getSession;

  /// Callback to refresh the session.
  final SessionRefresher refreshSession;

  /// Store for DPoP nonces.
  final DPoPNonceStore _nonceStore;

  /// Lock to prevent concurrent refresh attempts.
  bool _isRefreshing = false;

  /// Key used to mark requests as requiring auth in options.extra.
  static const requiresAuthKey = 'requiresAuth';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final requiresAuth = options.extra[requiresAuthKey] == true;

    if (requiresAuth) {
      final session = await getSession();
      if (session != null) {
        final token = session.accessJwt;
        options.headers['Authorization'] = 'Bearer $token';

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
          // TODO: Log error for debugging: $e
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
    }

    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }
    if (!requiresAuth) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      return handler.next(err);
    }
    final hasRetried = err.requestOptions.extra['_authRetried'] == true;
    if (hasRetried) {
      return handler.next(err);
    }

    _isRefreshing = true;

    try {
      final newSession = await refreshSession();

      if (newSession == null) {
        return handler.next(err);
      }

      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer ${newSession.accessJwt}';

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
        // TODO: Log error for debugging: $e
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

      final response = await retryDio.fetch(options);
      return handler.resolve(response);
    } catch (e) {
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
