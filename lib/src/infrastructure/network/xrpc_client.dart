import 'package:dio/dio.dart';
import 'package:lazurite/src/core/utils/logger.dart';

import 'endpoint_meta.dart';
import 'endpoint_registry.dart';
import 'host_kind.dart';
import 'http_method.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/proxy_interceptor.dart';
import 'network_failure.dart';

/// High-level XRPC client that routes requests to the correct host.
///
/// This is the main entry point for making XRPC requests. It:
/// - Looks up endpoint metadata from the registry
/// - Routes requests to the correct Dio client (public vs PDS)
/// - Handles response parsing and error conversion
class XrpcClient {
  XrpcClient({
    required Dio publicDio,
    required Dio? pdsDio,
    required Logger logger,
    EndpointRegistry? registry,
  }) : _publicDio = publicDio,
       _pdsDio = pdsDio,
       _logger = logger,
       _registry = registry ?? EndpointRegistry.instance;

  final Dio _publicDio;
  final Dio? _pdsDio;
  final Logger _logger;
  final EndpointRegistry _registry;

  /// Whether the client has a PDS configured for authenticated requests.
  bool get isAuthenticated => _pdsDio != null;

  /// Makes an XRPC request.
  ///
  /// The [nsid] is used to look up routing information from the registry.
  /// Query parameters are provided via [params] for GET requests.
  /// Request body is provided via [body] for POST requests.
  ///
  /// Returns the parsed response data, or throws a [NetworkFailure].
  Future<Map<String, dynamic>> call(
    String nsid, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? body,
  }) async {
    final meta = _registry.lookup(nsid);
    if (meta == null) {
      throw ArgumentError.value(nsid, 'nsid', 'Unknown endpoint');
    }

    final dio = _selectDio(meta);
    final options = _buildOptions(meta);

    try {
      final Response<dynamic> response;

      switch (meta.method) {
        case HttpMethod.get:
          response = await dio.get<dynamic>(meta.path, queryParameters: params, options: options);
        case HttpMethod.post:
          response = await dio.post<dynamic>(
            meta.path,
            data: body,
            queryParameters: params,
            options: options,
          );
      }

      return _parseResponse(response);
    } on DioException catch (e) {
      final failure = _convertError(e);
      _logger.error('XRPC call failed: $nsid', failure, e.stackTrace);
      throw failure;
    }
  }

  /// Makes a raw request without parsing the response.
  ///
  /// Useful for endpoints that return non-JSON responses (e.g., blobs).
  Future<Response<T>> callRaw<T>(
    String nsid, {
    Map<String, dynamic>? params,
    Object? body,
    ResponseType? responseType,
  }) async {
    final meta = _registry.lookup(nsid);
    if (meta == null) {
      throw ArgumentError.value(nsid, 'nsid', 'Unknown endpoint');
    }

    final dio = _selectDio(meta);
    final options = _buildOptions(meta);
    if (responseType != null) {
      options.responseType = responseType;
    }

    try {
      switch (meta.method) {
        case HttpMethod.get:
          return await dio.get<T>(meta.path, queryParameters: params, options: options);
        case HttpMethod.post:
          return await dio.post<T>(
            meta.path,
            data: body,
            queryParameters: params,
            options: options,
          );
      }
    } on DioException catch (e) {
      final failure = _convertError(e);
      _logger.error('XRPC raw call failed: $nsid', failure, e.stackTrace);
      throw failure;
    }
  }

  /// Selects the appropriate Dio client based on endpoint metadata.
  Dio _selectDio(EndpointMeta meta) {
    switch (meta.hostKind) {
      case HostKind.publicApi:
        return _publicDio;
      case HostKind.pds:
        if (_pdsDio == null) {
          throw StateError(
            'Cannot make authenticated request: PDS client not configured. '
            'Ensure user is logged in.',
          );
        }
        return _pdsDio;
    }
  }

  /// Builds request options with metadata for interceptors.
  Options _buildOptions(EndpointMeta meta) {
    return Options(
      extra: {
        AuthInterceptor.requiresAuthKey: meta.requiresAuth,
        ProxyInterceptor.proxyKindKey: meta.proxyKind,
      },
    );
  }

  /// Parses the response data.
  Map<String, dynamic> _parseResponse(Response<dynamic> response) {
    final data = response.data;

    if (data == null) {
      return {};
    }

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw DecodeFailure(message: 'Unexpected response type: ${data.runtimeType}');
  }

  /// Converts Dio exceptions to standardized [NetworkFailure] types.
  NetworkFailure _convertError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ConnectionFailure(message: 'Request timeout: ${e.message}', cause: e);
      case DioExceptionType.connectionError:
        return ConnectionFailure(message: 'Connection failed: ${e.message}', cause: e);
      case DioExceptionType.badCertificate:
        return ConnectionFailure(message: 'Certificate error: ${e.message}', cause: e);
      case DioExceptionType.cancel:
        return ConnectionFailure(message: 'Request cancelled', cause: e);
      case DioExceptionType.badResponse:
        return _convertResponseError(e);
      case DioExceptionType.unknown:
        return ConnectionFailure(message: e.message ?? 'Unknown network error', cause: e);
    }
  }

  /// Converts response errors to appropriate failure types.
  NetworkFailure _convertResponseError(DioException e) {
    final statusCode = e.response?.statusCode ?? 0;
    final data = e.response?.data;

    String? errorMessage;
    String? errorCode;

    if (data is Map<String, dynamic>) {
      errorMessage = data['message'] as String?;
      errorCode = data['error'] as String?;
    }

    switch (statusCode) {
      case 401:
        return AuthFailure(message: errorMessage ?? 'Authentication required', cause: e);
      case 429:
        Duration? retryAfter;
        final retryHeader = e.response?.headers.value('retry-after');
        if (retryHeader != null) {
          final seconds = int.tryParse(retryHeader);
          if (seconds != null) {
            retryAfter = Duration(seconds: seconds);
          }
        }
        return RateLimitFailure(
          message: errorMessage ?? 'Rate limit exceeded',
          cause: e,
          retryAfter: retryAfter,
        );
      case >= 400 && < 500:
        return ClientFailure(
          statusCode: statusCode,
          message: errorMessage ?? 'Client error',
          errorCode: errorCode,
          cause: e,
        );
      case >= 500:
        return ServerFailure(
          statusCode: statusCode,
          message: errorMessage ?? 'Server error',
          cause: e,
        );
      default:
        return ServerFailure(
          statusCode: statusCode,
          message: errorMessage ?? 'Unexpected error',
          cause: e,
        );
    }
  }
}
