import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/network/interceptors/retry_interceptor.dart';

void main() {
  group('RetryInterceptor', () {
    group('configuration', () {
      test('respects custom maxRetries setting', () {
        final interceptor = RetryInterceptor(maxRetries: 5);
        expect(interceptor.maxRetries, equals(5));
      });

      test('defaults to 3 retries', () {
        final interceptor = RetryInterceptor();
        expect(interceptor.maxRetries, equals(3));
      });

      test('respects custom initialDelay', () {
        final interceptor = RetryInterceptor(initialDelay: const Duration(seconds: 2));
        expect(interceptor.initialDelay, equals(const Duration(seconds: 2)));
      });

      test('respects custom maxDelay', () {
        final interceptor = RetryInterceptor(maxDelay: const Duration(seconds: 30));
        expect(interceptor.maxDelay, equals(const Duration(seconds: 30)));
      });

      test('defaults to 500ms initial delay', () {
        final interceptor = RetryInterceptor();
        expect(interceptor.initialDelay, equals(const Duration(milliseconds: 500)));
      });

      test('defaults to 10s max delay', () {
        final interceptor = RetryInterceptor();
        expect(interceptor.maxDelay, equals(const Duration(seconds: 10)));
      });

      test('respects custom retryableStatusCodes', () {
        final interceptor = RetryInterceptor(retryableStatusCodes: {418, 500});
        expect(interceptor.retryableStatusCodes, equals({418, 500}));
      });

      test('defaults to 502, 503, 504, 429', () {
        final interceptor = RetryInterceptor();
        expect(interceptor.retryableStatusCodes, equals({502, 503, 504, 429}));
      });
    });

    group('does not retry non-GET requests', () {
      late RetryInterceptor interceptor;

      setUp(() {
        interceptor = RetryInterceptor(
          maxRetries: 3,
          initialDelay: const Duration(milliseconds: 10),
        );
      });

      test('does not retry POST requests', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test', method: 'POST'),
          type: DioExceptionType.connectionError,
        );

        var nextCalledSynchronously = false;
        final handler = _SyncTrackingErrorHandler(
          onNextSync: () => nextCalledSynchronously = true,
        );

        interceptor.onError(error, handler);

        expect(nextCalledSynchronously, isTrue);
      });

      test('does not retry PUT requests', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test', method: 'PUT'),
          type: DioExceptionType.connectionError,
        );

        var nextCalledSynchronously = false;
        final handler = _SyncTrackingErrorHandler(
          onNextSync: () => nextCalledSynchronously = true,
        );

        interceptor.onError(error, handler);

        expect(nextCalledSynchronously, isTrue);
      });

      test('does not retry DELETE requests', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test', method: 'DELETE'),
          type: DioExceptionType.connectionError,
        );

        var nextCalledSynchronously = false;
        final handler = _SyncTrackingErrorHandler(
          onNextSync: () => nextCalledSynchronously = true,
        );

        interceptor.onError(error, handler);

        expect(nextCalledSynchronously, isTrue);
      });

      test('does not retry PATCH requests', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test', method: 'PATCH'),
          type: DioExceptionType.connectionError,
        );

        var nextCalledSynchronously = false;
        final handler = _SyncTrackingErrorHandler(
          onNextSync: () => nextCalledSynchronously = true,
        );

        interceptor.onError(error, handler);

        expect(nextCalledSynchronously, isTrue);
      });
    });

    group('does not retry non-retryable status codes', () {
      late RetryInterceptor interceptor;

      setUp(() {
        interceptor = RetryInterceptor(
          maxRetries: 3,
          initialDelay: const Duration(milliseconds: 10),
        );
      });

      test('does not retry on 400 Bad Request (GET)', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test', method: 'GET'),
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: RequestOptions(path: '/test'), statusCode: 400),
        );

        var nextCalledSynchronously = false;
        final handler = _SyncTrackingErrorHandler(
          onNextSync: () => nextCalledSynchronously = true,
        );

        interceptor.onError(error, handler);

        expect(nextCalledSynchronously, isTrue);
      });

      test('does not retry on 401 Unauthorized (GET)', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test', method: 'GET'),
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: RequestOptions(path: '/test'), statusCode: 401),
        );

        var nextCalledSynchronously = false;
        final handler = _SyncTrackingErrorHandler(
          onNextSync: () => nextCalledSynchronously = true,
        );

        interceptor.onError(error, handler);

        expect(nextCalledSynchronously, isTrue);
      });

      test('does not retry on 403 Forbidden (GET)', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test', method: 'GET'),
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: RequestOptions(path: '/test'), statusCode: 403),
        );

        var nextCalledSynchronously = false;
        final handler = _SyncTrackingErrorHandler(
          onNextSync: () => nextCalledSynchronously = true,
        );

        interceptor.onError(error, handler);

        expect(nextCalledSynchronously, isTrue);
      });

      test('does not retry on 404 Not Found (GET)', () {
        final error = DioException(
          requestOptions: RequestOptions(path: '/test', method: 'GET'),
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: RequestOptions(path: '/test'), statusCode: 404),
        );

        var nextCalledSynchronously = false;
        final handler = _SyncTrackingErrorHandler(
          onNextSync: () => nextCalledSynchronously = true,
        );

        interceptor.onError(error, handler);

        expect(nextCalledSynchronously, isTrue);
      });
    });

    group('retries GET requests on retryable errors', () {
      test('attempts retry on 503 for GET (does not call next synchronously)', () {
        final interceptor = RetryInterceptor(
          maxRetries: 1,
          initialDelay: const Duration(milliseconds: 10),
        );

        final error = DioException(
          requestOptions: RequestOptions(
            path: '/test',
            method: 'GET',
            baseUrl: 'https://example.com',
          ),
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: RequestOptions(path: '/test'), statusCode: 503),
        );

        var nextCalledSynchronously = false;
        final handler = _SyncTrackingErrorHandler(
          onNextSync: () => nextCalledSynchronously = true,
        );

        interceptor.onError(error, handler);

        expect(nextCalledSynchronously, isFalse);
      });

      test('attempts retry on connection timeout for GET', () {
        final interceptor = RetryInterceptor(
          maxRetries: 1,
          initialDelay: const Duration(milliseconds: 10),
        );

        final error = DioException(
          requestOptions: RequestOptions(
            path: '/test',
            method: 'GET',
            baseUrl: 'https://example.com',
          ),
          type: DioExceptionType.connectionTimeout,
        );

        var nextCalledSynchronously = false;
        final handler = _SyncTrackingErrorHandler(
          onNextSync: () => nextCalledSynchronously = true,
        );

        interceptor.onError(error, handler);

        expect(nextCalledSynchronously, isFalse);
      });

      test('attempts retry on connection error for GET', () {
        final interceptor = RetryInterceptor(
          maxRetries: 1,
          initialDelay: const Duration(milliseconds: 10),
        );

        final error = DioException(
          requestOptions: RequestOptions(
            path: '/test',
            method: 'GET',
            baseUrl: 'https://example.com',
          ),
          type: DioExceptionType.connectionError,
        );

        var nextCalledSynchronously = false;
        final handler = _SyncTrackingErrorHandler(
          onNextSync: () => nextCalledSynchronously = true,
        );

        interceptor.onError(error, handler);

        expect(nextCalledSynchronously, isFalse);
      });
    });

    group('retry count limit', () {
      test('stops retrying after max retries exceeded', () {
        final interceptor = RetryInterceptor(
          maxRetries: 2,
          initialDelay: const Duration(milliseconds: 10),
        );

        final options = RequestOptions(
          path: '/test',
          method: 'GET',
          baseUrl: 'https://example.com',
        );
        options.extra['_retryCount'] = 2;

        final error = DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );

        var nextCalledSynchronously = false;
        final handler = _SyncTrackingErrorHandler(
          onNextSync: () => nextCalledSynchronously = true,
        );

        interceptor.onError(error, handler);

        expect(nextCalledSynchronously, isTrue);
      });
    });
  });
}

/// A test handler that tracks whether next() was called synchronously
class _SyncTrackingErrorHandler extends ErrorInterceptorHandler {
  _SyncTrackingErrorHandler({required this.onNextSync});
  final void Function() onNextSync;

  @override
  void next(DioException err) {
    onNextSync();
  }
}
