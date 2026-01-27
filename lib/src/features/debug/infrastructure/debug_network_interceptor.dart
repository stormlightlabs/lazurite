import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:lazurite/src/infrastructure/db/daos/dev_tools_dao.dart';
import 'package:uuid/uuid.dart';

/// Interceptor that logs network requests to the [DevToolsDao].
class DebugNetworkInterceptor extends Interceptor {
  DebugNetworkInterceptor(this._dao);

  final DevToolsDao _dao;
  final _uuid = const Uuid();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final uuid = _uuid.v4();
    options.extra['debug_uuid'] = uuid;
    options.extra['debug_start_time'] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logCompletion(response.requestOptions, response: response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logCompletion(err.requestOptions, error: err);
    handler.next(err);
  }

  Future<void> _logCompletion(
    RequestOptions options, {
    Response? response,
    DioException? error,
  }) async {
    try {
      final uuid = options.extra['debug_uuid'] as String? ?? _uuid.v4();
      final startTime =
          options.extra['debug_start_time'] as int? ?? DateTime.now().millisecondsSinceEpoch;
      final endTime = DateTime.now().millisecondsSinceEpoch;
      final duration = endTime - startTime;

      final requestHeadersMap = Map<String, dynamic>.from(options.headers);
      _redactHeaders(requestHeadersMap);
      final requestHeaders = jsonEncode(requestHeadersMap);

      final responseHeadersMap = response != null
          ? Map<String, dynamic>.from(response.headers.map)
          : <String, dynamic>{};
      _redactHeaders(responseHeadersMap);
      final responseHeaders = jsonEncode(responseHeadersMap);

      String? requestBody;
      try {
        if (options.data != null) {
          requestBody = options.data is String ? options.data : jsonEncode(options.data);
        }
      } catch (e) {
        requestBody = '<Unserializable Body: $e>';
      }

      String? responseBody;
      try {
        if (response?.data != null) {
          responseBody = response!.data is String ? response.data : jsonEncode(response.data);
        }
      } catch (e) {
        responseBody = '<Unserializable Body: $e>';
      }

      await _dao.logRequest(
        uuid: uuid,
        method: options.method,
        url: options.uri.toString(),
        statusCode: response?.statusCode ?? error?.response?.statusCode ?? 0,
        durationMs: duration,
        requestHeaders: requestHeaders,
        responseHeaders: responseHeaders,
        requestBody: requestBody,
        responseBody: responseBody,
        error: error?.message,
      );
    } catch (e, stack) {
      developer.log(
        'Failed to log network request',
        name: 'DebugNetworkInterceptor',
        error: e,
        stackTrace: stack,
      );
    }
  }

  void _redactHeaders(Map<String, dynamic> headers) {
    const sensitiveHeaders = ['authorization', 'dpop'];
    final keys = headers.keys.toList();
    for (final key in keys) {
      final lowercaseKey = key.toLowerCase();
      if (sensitiveHeaders.contains(lowercaseKey)) {
        final value = headers[key];
        String redactValue(String v) {
          final parts = v.split(' ');
          if (parts.length > 1) {
            return '${parts[0]} ***';
          }
          if (lowercaseKey == 'authorization') return 'Bearer ***';
          if (lowercaseKey == 'dpop') return 'DPoP ***';
          return '***';
        }

        if (value is String) {
          headers[key] = redactValue(value);
        } else if (value is List) {
          headers[key] = value.map((v) {
            if (v is String) return redactValue(v);
            return '***';
          }).toList();
        } else {
          headers[key] = '***';
        }
      }
    }
  }
}
