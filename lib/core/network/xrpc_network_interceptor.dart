import 'dart:convert';

import 'package:atproto_core/atproto_core.dart' as atp_core;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/core/logging/app_logger.dart';

class XrpcRequestMetadata {
  const XrpcRequestMetadata({required this.pdsHost, required this.appView, required this.xrpcMethod});

  final String pdsHost;
  final String appView;
  final String xrpcMethod;
}

abstract final class XrpcNetworkInterceptor {
  static atp_core.GetClient wrapGetClient([atp_core.GetClient? baseClient]) {
    final delegate = baseClient ?? http.get;
    return (Uri url, {Map<String, String>? headers}) async {
      final metadata = metadataFor(url, headers: headers);
      final stopwatch = Stopwatch()..start();
      log.t(_requestLogLine(httpMethod: 'GET', metadata: metadata));
      try {
        final response = await delegate(url, headers: headers);
        _logResponse(
          httpMethod: 'GET',
          metadata: metadata,
          statusCode: response.statusCode,
          elapsed: stopwatch.elapsed,
        );
        return response;
      } catch (error, stackTrace) {
        log.e(
          _failureLogLine(httpMethod: 'GET', metadata: metadata, elapsed: stopwatch.elapsed),
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    };
  }

  static atp_core.PostClient wrapPostClient([atp_core.PostClient? baseClient]) {
    final delegate = baseClient ?? http.post;
    return (Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
      final metadata = metadataFor(url, headers: headers);
      final stopwatch = Stopwatch()..start();
      log.t(_requestLogLine(httpMethod: 'POST', metadata: metadata));
      try {
        final response = await delegate(url, headers: headers, body: body, encoding: encoding);
        _logResponse(
          httpMethod: 'POST',
          metadata: metadata,
          statusCode: response.statusCode,
          elapsed: stopwatch.elapsed,
        );
        return response;
      } catch (error, stackTrace) {
        log.e(
          _failureLogLine(httpMethod: 'POST', metadata: metadata, elapsed: stopwatch.elapsed),
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    };
  }

  @visibleForTesting
  static XrpcRequestMetadata metadataFor(Uri url, {Map<String, String>? headers}) {
    final pdsHost = url.host.isEmpty ? '<unknown>' : url.host;
    final xrpcMethod = _extractXrpcMethod(url);
    final appView = _headerValue(headers, 'atproto-proxy') ?? 'none';
    return XrpcRequestMetadata(pdsHost: pdsHost, appView: appView, xrpcMethod: xrpcMethod);
  }

  static String _extractXrpcMethod(Uri url) {
    final segments = url.pathSegments.where((segment) => segment.isNotEmpty).toList(growable: false);
    final xrpcIndex = segments.indexOf('xrpc');
    if (xrpcIndex >= 0 && xrpcIndex + 1 < segments.length) {
      return segments[xrpcIndex + 1];
    }
    return '<unknown>';
  }

  static String? _headerValue(Map<String, String>? headers, String key) {
    if (headers == null) {
      return null;
    }

    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == key.toLowerCase()) {
        return entry.value;
      }
    }
    return null;
  }

  static String _requestLogLine({required String httpMethod, required XrpcRequestMetadata metadata}) {
    return 'XRPC Request: method=$httpMethod, PDS=${metadata.pdsHost}, AppView=${metadata.appView}, '
        'XRPC method=${metadata.xrpcMethod}';
  }

  static String _responseLogLine({
    required String httpMethod,
    required XrpcRequestMetadata metadata,
    required int statusCode,
    required Duration elapsed,
  }) {
    return 'XRPC Response: method=$httpMethod, status=$statusCode, durationMs=${elapsed.inMilliseconds}, '
        'PDS=${metadata.pdsHost}, AppView=${metadata.appView}, XRPC method=${metadata.xrpcMethod}';
  }

  static String _failureLogLine({
    required String httpMethod,
    required XrpcRequestMetadata metadata,
    required Duration elapsed,
  }) {
    return 'XRPC Failure: method=$httpMethod, durationMs=${elapsed.inMilliseconds}, PDS=${metadata.pdsHost}, '
        'AppView=${metadata.appView}, XRPC method=${metadata.xrpcMethod}';
  }

  static void _logResponse({
    required String httpMethod,
    required XrpcRequestMetadata metadata,
    required int statusCode,
    required Duration elapsed,
  }) {
    final message = _responseLogLine(
      httpMethod: httpMethod,
      metadata: metadata,
      statusCode: statusCode,
      elapsed: elapsed,
    );
    if (statusCode >= 400) {
      log.w(message);
      return;
    }
    log.t(message);
  }
}
