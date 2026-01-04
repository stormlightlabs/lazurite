import 'package:dio/dio.dart';

/// Callback type for getting the current access token.
typedef TokenGetter = Future<String?> Function();

/// Callback type for refreshing the access token.
typedef TokenRefresher = Future<String?> Function();

/// Interceptor that handles authentication for XRPC requests.
///
/// Attaches the access token to requests that require authentication,
/// and handles 401 responses by attempting to refresh the token once.
///
/// Note: DPoP proof generation will be added in Milestone C when OAuth
/// is implemented.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.getAccessToken, required this.refreshToken});

  /// Callback to get the current access token.
  final TokenGetter getAccessToken;

  /// Callback to refresh the access token.
  final TokenRefresher refreshToken;

  /// Lock to prevent concurrent refresh attempts.
  bool _isRefreshing = false;

  /// Key used to mark requests as requiring auth in options.extra.
  static const requiresAuthKey = 'requiresAuth';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final requiresAuth = options.extra[requiresAuthKey] == true;

    if (requiresAuth) {
      final token = await getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        // TODO: Add DPoP proof header here
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final requiresAuth = err.requestOptions.extra[requiresAuthKey] == true;
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
      final newToken = await refreshToken();

      if (newToken == null) {
        return handler.next(err);
      }

      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newToken';
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
