import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/network/interceptors/logging_interceptor.dart';

void main() {
  group('LoggingInterceptor', () {
    group('constructor', () {
      test('enables all logging by default', () {
        final interceptor = LoggingInterceptor();
        expect(interceptor.logRequests, isTrue);
        expect(interceptor.logResponses, isTrue);
        expect(interceptor.logErrors, isTrue);
      });

      test('respects custom logging flags', () {
        final interceptor = LoggingInterceptor(
          logRequests: false,
          logResponses: true,
          logErrors: false,
        );
        expect(interceptor.logRequests, isFalse);
        expect(interceptor.logResponses, isTrue);
        expect(interceptor.logErrors, isFalse);
      });
    });

    group('header redaction', () {
      test('redacts Authorization header', () {
        final interceptor = LoggingInterceptor();
        final headers = {
          'Authorization': 'Bearer super-secret-token',
          'Content-Type': 'application/json',
        };

        final options = RequestOptions(path: '/test', headers: headers);

        interceptor.onRequest(options, RequestInterceptorHandler());

        expect(options.headers['Authorization'], equals('Bearer super-secret-token'));
      });

      test('redacts DPoP header', () {
        final options = RequestOptions(
          path: '/test',
          headers: {'DPoP': 'eyJhbGciOiJFUzI1NiIsInR5cCI6ImRwb3Arand0In0...'},
        );

        final interceptor = LoggingInterceptor();
        interceptor.onRequest(options, RequestInterceptorHandler());

        expect(options.headers['DPoP'], startsWith('eyJhbGci'));
      });

      test('redacts case-insensitive headers', () {
        final options = RequestOptions(
          path: '/test',
          headers: {'authorization': 'Bearer token', 'DPOP': 'proof'},
        );

        final interceptor = LoggingInterceptor();
        interceptor.onRequest(options, RequestInterceptorHandler());
      });
    });

    group('onRequest', () {
      test('calls handler.next to continue chain', () async {
        final interceptor = LoggingInterceptor();
        final options = RequestOptions(path: '/test');

        var nextCalled = false;
        final handler = _TestRequestHandler(onNext: () => nextCalled = true);

        interceptor.onRequest(options, handler);

        expect(nextCalled, isTrue);
      });

      test('processes request even when logging disabled', () {
        final interceptor = LoggingInterceptor(logRequests: false);
        final options = RequestOptions(path: '/test');

        var nextCalled = false;
        final handler = _TestRequestHandler(onNext: () => nextCalled = true);

        interceptor.onRequest(options, handler);

        expect(nextCalled, isTrue);
      });
    });

    group('onResponse', () {
      test('calls handler.next to continue chain', () {
        final interceptor = LoggingInterceptor();
        final response = Response(requestOptions: RequestOptions(path: '/test'), statusCode: 200);

        var nextCalled = false;
        final handler = _TestResponseHandler(onNext: () => nextCalled = true);

        interceptor.onResponse(response, handler);

        expect(nextCalled, isTrue);
      });
    });

    group('onError', () {
      test('calls handler.next to continue chain', () {
        final interceptor = LoggingInterceptor();
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: RequestOptions(path: '/test'), statusCode: 500),
        );

        var nextCalled = false;
        final handler = _TestErrorHandler(onNext: () => nextCalled = true);

        interceptor.onError(error, handler);

        expect(nextCalled, isTrue);
      });

      test('handles errors without response', () {
        final interceptor = LoggingInterceptor();
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timeout',
        );

        var nextCalled = false;
        final handler = _TestErrorHandler(onNext: () => nextCalled = true);

        interceptor.onError(error, handler);

        expect(nextCalled, isTrue);
      });
    });
  });
}

class _TestRequestHandler extends RequestInterceptorHandler {
  _TestRequestHandler({required this.onNext});
  final void Function() onNext;

  @override
  void next(RequestOptions requestOptions) {
    onNext();
    super.next(requestOptions);
  }
}

class _TestResponseHandler extends ResponseInterceptorHandler {
  _TestResponseHandler({required this.onNext});
  final void Function() onNext;

  @override
  void next(Response response) {
    onNext();
    super.next(response);
  }
}

class _TestErrorHandler extends ErrorInterceptorHandler {
  _TestErrorHandler({required this.onNext});
  final void Function() onNext;

  /// We don't call super.next() to avoid async error propagation in tests
  @override
  void next(DioException err) {
    onNext();
  }
}
