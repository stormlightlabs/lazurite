import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:lazurite/src/infrastructure/network/interceptors/auth_interceptor.dart';

void main() {
  group('AuthInterceptor', () {
    group('token attachment', () {
      test('attaches Authorization header for authenticated requests', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        dio.interceptors.add(
          AuthInterceptor(
            getAccessToken: () async => 'test-token',
            refreshToken: () async => 'refreshed',
          ),
        );

        adapter.onGet('/test', (server) => server.reply(200, {'success': true}));

        final response = await dio.get(
          '/test',
          options: Options(extra: {AuthInterceptor.requiresAuthKey: true}),
        );

        expect(response.statusCode, equals(200));
      });

      test('does not attach token for non-authenticated requests', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        var tokenRequested = false;
        dio.interceptors.add(
          AuthInterceptor(
            getAccessToken: () async {
              tokenRequested = true;
              return 'test-token';
            },
            refreshToken: () async => 'refreshed',
          ),
        );

        adapter.onGet('/public', (server) => server.reply(200, {'public': true}));

        final response = await dio.get('/public');
        expect(response.statusCode, equals(200));
        expect(tokenRequested, isFalse);
      });

      test('handles null token gracefully', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        dio.interceptors.add(
          AuthInterceptor(getAccessToken: () async => null, refreshToken: () async => null),
        );

        adapter.onGet('/test', (server) => server.reply(200, {'success': true}));

        final response = await dio.get(
          '/test',
          options: Options(extra: {AuthInterceptor.requiresAuthKey: true}),
        );

        expect(response.statusCode, equals(200));
      });
    });

    group('onRequest behavior', () {
      test('adds Authorization header when token available', () async {
        final interceptor = AuthInterceptor(
          getAccessToken: () async => 'my-token',
          refreshToken: () async => 'refreshed',
        );

        final options = RequestOptions(
          path: '/test',
          extra: {AuthInterceptor.requiresAuthKey: true},
        );

        await interceptor.onRequest(options, _NoOpRequestHandler());

        expect(options.headers['Authorization'], equals('Bearer my-token'));
      });

      test('does not add Authorization header when token is null', () async {
        final interceptor = AuthInterceptor(
          getAccessToken: () async => null,
          refreshToken: () async => null,
        );

        final options = RequestOptions(
          path: '/test',
          extra: {AuthInterceptor.requiresAuthKey: true},
        );

        await interceptor.onRequest(options, _NoOpRequestHandler());

        expect(options.headers['Authorization'], isNull);
      });

      test('does not add Authorization header when requiresAuth is false', () async {
        final interceptor = AuthInterceptor(
          getAccessToken: () async => 'my-token',
          refreshToken: () async => 'refreshed',
        );

        final options = RequestOptions(
          path: '/test',
          extra: {AuthInterceptor.requiresAuthKey: false},
        );

        await interceptor.onRequest(options, _NoOpRequestHandler());

        expect(options.headers['Authorization'], isNull);
      });

      test('does not add Authorization header when requiresAuth is not set', () async {
        final interceptor = AuthInterceptor(
          getAccessToken: () async => 'my-token',
          refreshToken: () async => 'refreshed',
        );

        final options = RequestOptions(path: '/test');

        await interceptor.onRequest(options, _NoOpRequestHandler());

        expect(options.headers['Authorization'], isNull);
      });
    });

    group('401 handling', () {
      test('does not refresh for non-authenticated requests', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        var refreshCallCount = 0;
        dio.interceptors.add(
          AuthInterceptor(
            getAccessToken: () async => 'token',
            refreshToken: () async {
              refreshCallCount++;
              return 'refreshed';
            },
          ),
        );

        adapter.onGet('/public', (server) => server.reply(401, {'error': 'Unauthorized'}));

        expect(() => dio.get('/public'), throwsA(isA<DioException>()));

        await Future.delayed(const Duration(milliseconds: 50));
        expect(refreshCallCount, equals(0));
      });

      test('propagates error when refresh returns null', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        dio.interceptors.add(
          AuthInterceptor(getAccessToken: () async => 'token', refreshToken: () async => null),
        );

        adapter.onGet('/protected', (server) => server.reply(401, {'error': 'Unauthorized'}));

        expect(
          () => dio.get(
            '/protected',
            options: Options(extra: {AuthInterceptor.requiresAuthKey: true}),
          ),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('onError behavior', () {
      test('calls next for non-401 errors', () async {
        final interceptor = AuthInterceptor(
          getAccessToken: () async => 'token',
          refreshToken: () async => 'refreshed',
        );

        final error = DioException(
          requestOptions: RequestOptions(
            path: '/test',
            extra: {AuthInterceptor.requiresAuthKey: true},
          ),
          response: Response(requestOptions: RequestOptions(path: '/test'), statusCode: 500),
        );

        var nextCalled = false;
        final handler = _TestErrorHandler(onNext: () => nextCalled = true);

        await interceptor.onError(error, handler);

        expect(nextCalled, isTrue);
      });

      test('calls next for 401 on non-authenticated requests', () async {
        final interceptor = AuthInterceptor(
          getAccessToken: () async => 'token',
          refreshToken: () async => 'refreshed',
        );

        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(requestOptions: RequestOptions(path: '/test'), statusCode: 401),
        );

        var nextCalled = false;
        final handler = _TestErrorHandler(onNext: () => nextCalled = true);

        await interceptor.onError(error, handler);

        expect(nextCalled, isTrue);
      });
    });
  });

  group('AuthInterceptor constants', () {
    test('requiresAuthKey has expected value', () {
      expect(AuthInterceptor.requiresAuthKey, equals('requiresAuth'));
    });
  });
}

class _NoOpRequestHandler extends RequestInterceptorHandler {
  @override
  void next(RequestOptions requestOptions) {
    // No-op for testing
  }
}

class _TestErrorHandler extends ErrorInterceptorHandler {
  _TestErrorHandler({required this.onNext});
  final void Function() onNext;

  /// We don't call super to avoid async errors
  @override
  void next(DioException err) {
    onNext();
  }
}
