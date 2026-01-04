import 'dart:math';

import 'package:dio/dio.dart';

/// Interceptor that retries failed GET requests with exponential backoff.
///
/// Retry policy:
/// - Only retries GET requests (safe, idempotent methods)
/// - Retries on connection errors and server errors (502, 503, 504)
/// - Does NOT retry on client errors (4xx except rate limits)
/// - Uses bounded exponential backoff with jitter
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 10),
    this.retryableStatusCodes = const {502, 503, 504, 429},
  });

  /// Maximum number of retry attempts.
  final int maxRetries;

  /// Initial delay before first retry.
  final Duration initialDelay;

  /// Maximum delay between retries.
  final Duration maxDelay;

  /// HTTP status codes that should trigger a retry.
  final Set<int> retryableStatusCodes;

  /// Key used to track retry count in request options.
  static const _retryCountKey = '_retryCount';

  /// Random instance for jitter calculation.
  static final _random = Random();

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.method.toUpperCase() != 'GET') {
      return handler.next(err);
    }

    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final retryCount = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;

    if (retryCount >= maxRetries) {
      return handler.next(err);
    }

    final delay = _calculateDelay(retryCount);

    await Future.delayed(delay);

    final options = err.requestOptions;
    options.extra[_retryCountKey] = retryCount + 1;

    try {
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
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  /// Determines if the error should trigger a retry.
  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    final statusCode = err.response?.statusCode;
    if (statusCode != null && retryableStatusCodes.contains(statusCode)) {
      return true;
    }

    return false;
  }

  /// Calculates delay with exponential backoff and jitter.
  Duration _calculateDelay(int retryCount) {
    final exponentialMs = initialDelay.inMilliseconds * pow(2, retryCount);
    final jitterMs = (_random.nextDouble() * 0.25 * exponentialMs).toInt();
    final totalMs = min(exponentialMs.toInt() + jitterMs, maxDelay.inMilliseconds);
    return Duration(milliseconds: totalMs);
  }
}
