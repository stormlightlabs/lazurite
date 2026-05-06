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
  static int _forcedUnauthorizedResponses = 0;

  static void debugForceUnauthorizedOnce() {
    if (!kDebugMode) {
      return;
    }
    _forcedUnauthorizedResponses += 1;
    log.w('XRPC Debug Hook: next $_forcedUnauthorizedResponses request(s) will return 401 Unauthorized');
  }

  @visibleForTesting
  static void debugResetForcedUnauthorized() {
    _forcedUnauthorizedResponses = 0;
  }

  static atp_core.GetClient wrapGetClient([atp_core.GetClient? baseClient]) {
    final delegate = baseClient ?? http.get;
    return (Uri url, {Map<String, String>? headers}) async {
      final normalizedHeaders = normalizeOutgoingHeaders(headers);
      final metadata = metadataFor(url, headers: normalizedHeaders);
      final stopwatch = Stopwatch()..start();
      _trace(_requestLogLine(httpMethod: 'GET', metadata: metadata));
      final forced = _takeForcedUnauthorized(method: 'GET', url: url, metadata: metadata);
      if (forced != null) {
        _logResponse(httpMethod: 'GET', metadata: metadata, statusCode: forced.statusCode, elapsed: stopwatch.elapsed);
        return forced;
      }
      try {
        final response = await delegate(url, headers: normalizedHeaders);
        _logResponse(
          httpMethod: 'GET',
          metadata: metadata,
          statusCode: response.statusCode,
          elapsed: stopwatch.elapsed,
        );
        return response;
      } catch (error, stackTrace) {
        _error(
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
      final normalizedHeaders = normalizeOutgoingHeaders(headers);
      final metadata = metadataFor(url, headers: normalizedHeaders);
      final stopwatch = Stopwatch()..start();
      _trace(_requestLogLine(httpMethod: 'POST', metadata: metadata));
      final forced = _takeForcedUnauthorized(method: 'POST', url: url, metadata: metadata);
      if (forced != null) {
        _logResponse(httpMethod: 'POST', metadata: metadata, statusCode: forced.statusCode, elapsed: stopwatch.elapsed);
        return forced;
      }
      try {
        final response = await delegate(url, headers: normalizedHeaders, body: body, encoding: encoding);
        _logResponse(
          httpMethod: 'POST',
          metadata: metadata,
          statusCode: response.statusCode,
          elapsed: stopwatch.elapsed,
        );
        return response;
      } catch (error, stackTrace) {
        _error(
          _failureLogLine(httpMethod: 'POST', metadata: metadata, elapsed: stopwatch.elapsed),
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    };
  }

  @visibleForTesting
  static Map<String, String>? normalizeOutgoingHeaders(Map<String, String>? headers) {
    if (headers == null || headers.isEmpty) {
      return headers;
    }

    var dpopKey = '';
    var dpopValue = '';
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == 'dpop') {
        dpopKey = entry.key;
        dpopValue = entry.value;
        break;
      }
    }
    if (dpopKey.isEmpty) {
      return headers;
    }

    final normalizedDpop = _normalizeDpopProof(dpopValue);
    if (normalizedDpop == dpopValue) {
      return headers;
    }

    final normalized = Map<String, String>.from(headers);
    normalized[dpopKey] = normalizedDpop;
    _trace('XRPC Request: normalized DPoP proof encoding to base64url');
    return normalized;
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

  static String _normalizeDpopProof(String proof) {
    final trimmed = proof.trim();
    if (trimmed.isEmpty) {
      return proof;
    }

    final segments = trimmed.split('.');
    if (segments.length != 3) {
      return proof;
    }

    final decodedSignature = _decodeJwtSegment(segments[2]);
    if (decodedSignature == null) {
      return proof;
    }

    final normalizedSignature = base64UrlEncode(decodedSignature).replaceAll('=', '');
    if (normalizedSignature == segments[2]) {
      return proof;
    }

    segments[2] = normalizedSignature;
    return segments.join('.');
  }

  static List<int>? _decodeJwtSegment(String segment) {
    final normalizedSegment = segment.trim();
    if (normalizedSegment.isEmpty) {
      return null;
    }

    try {
      return base64Url.decode(base64Url.normalize(normalizedSegment));
    } catch (_) {}

    try {
      return base64.decode(base64.normalize(normalizedSegment));
    } catch (_) {}

    return null;
  }

  static http.Response? _takeForcedUnauthorized({
    required String method,
    required Uri url,
    required XrpcRequestMetadata metadata,
  }) {
    if (!kDebugMode || _forcedUnauthorizedResponses < 1) {
      return null;
    }

    _forcedUnauthorizedResponses -= 1;
    _warn(
      'XRPC Debug Hook: forcing 401 for method=$method, PDS=${metadata.pdsHost}, '
      'AppView=${metadata.appView}, XRPC method=${metadata.xrpcMethod}',
    );
    return http.Response(
      '{"error":"Unauthorized","message":"Forced debug Unauthorized response"}',
      401,
      headers: const {'content-type': 'application/json'},
      request: http.Request(method, url),
    );
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
      _warn(message);
      return;
    }
    _trace(message);
  }

  static void _trace(String message) {
    if (!kDebugMode) {
      return;
    }
    log.t(message);
  }

  static void _warn(String message, {Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) {
      return;
    }
    log.w(message, error: error, stackTrace: stackTrace);
  }

  static void _error(String message, {Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) {
      return;
    }
    log.e(message, error: error, stackTrace: stackTrace);
  }
}
