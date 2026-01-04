import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Interceptor that logs HTTP requests and responses.
///
/// Automatically redacts sensitive headers like Authorization and DPoP to prevent accidental token
/// leakage in logs.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({this.logRequests = true, this.logResponses = true, this.logErrors = true});

  /// Whether to log outgoing requests.
  final bool logRequests;

  /// Whether to log successful responses.
  final bool logResponses;

  /// Whether to log error responses.
  final bool logErrors;

  /// Headers that should have their values redacted in logs.
  static const _sensitiveHeaders = {'authorization', 'dpop', 'x-access-token', 'x-refresh-token'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (logRequests) {
      final method = options.method;
      final uri = options.uri.toString();
      final headers = _redactHeaders(options.headers);

      developer.log('→ $method $uri', name: 'HTTP');
      if (headers.isNotEmpty) {
        developer.log('  Headers: $headers', name: 'HTTP');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (logResponses) {
      final method = response.requestOptions.method;
      final uri = response.requestOptions.uri.toString();
      final statusCode = response.statusCode;

      developer.log('← $statusCode $method $uri', name: 'HTTP');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (logErrors) {
      final method = err.requestOptions.method;
      final uri = err.requestOptions.uri.toString();
      final statusCode = err.response?.statusCode ?? 'N/A';
      final type = err.type.name;

      developer.log(
        '✕ $statusCode $method $uri ($type)',
        name: 'HTTP',
        level: 900, // Warning level
      );
      if (err.message != null) {
        developer.log('  Error: ${err.message}', name: 'HTTP', level: 900);
      }
    }
    handler.next(err);
  }

  /// Redacts sensitive header values.
  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      if (_sensitiveHeaders.contains(key.toLowerCase())) {
        return MapEntry(key, '[REDACTED]');
      }
      return MapEntry(key, value);
    });
  }
}
