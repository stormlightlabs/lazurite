import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../infrastructure/db/daos/dev_tools_dao.dart';

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

    // TODO: add pending status & log pending requests, updated on completion
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

      final requestHeaders = jsonEncode(options.headers);
      final responseHeaders = response != null ? jsonEncode(response.headers.map) : '{}';

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
}
