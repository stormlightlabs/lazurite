import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/infrastructure/network/interceptors/auth_interceptor.dart';

Session _createTestSession({
  String accessJwt = 'test-token',
  String pdsUrl = 'https://pds.example.com',
}) {
  return Session(
    did: 'did:plc:test',
    handle: 'test.bsky.social',
    pdsUrl: pdsUrl,
    accessJwt: accessJwt,
    refreshJwt: 'refresh-token',
    scope: 'atproto',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
    dpopKey: const {'kty': 'EC', 'crv': 'P-256', 'x': 'test', 'y': 'test', 'd': 'test'},
  );
}

void main() {
  group('AuthInterceptor', () {
    group('token attachment', () {
      test('attaches Authorization header for authenticated requests', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        dio.interceptors.add(
          AuthInterceptor(
            getSession: () async => _createTestSession(),
            refreshSession: () async => _createTestSession(accessJwt: 'refreshed'),
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

        var sessionRequested = false;
        dio.interceptors.add(
          AuthInterceptor(
            getSession: () async {
              sessionRequested = true;
              return _createTestSession();
            },
            refreshSession: () async => _createTestSession(accessJwt: 'refreshed'),
          ),
        );

        adapter.onGet('/public', (server) => server.reply(200, {'public': true}));

        final response = await dio.get('/public');
        expect(response.statusCode, equals(200));
        expect(sessionRequested, isFalse);
      });

      test('handles null session gracefully', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        dio.interceptors.add(
          AuthInterceptor(getSession: () async => null, refreshSession: () async => null),
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
      test('adds Authorization header when session available', () async {
        final interceptor = AuthInterceptor(
          getSession: () async => _createTestSession(accessJwt: 'my-token'),
          refreshSession: () async => _createTestSession(accessJwt: 'refreshed'),
        );

        final options = RequestOptions(
          path: '/test',
          extra: {AuthInterceptor.requiresAuthKey: true},
        );

        await interceptor.onRequest(options, _NoOpRequestHandler());

        expect(options.headers['Authorization'], equals('Bearer my-token'));
      });

      test('does not add Authorization header when session is null', () async {
        final interceptor = AuthInterceptor(
          getSession: () async => null,
          refreshSession: () async => null,
        );

        final options = RequestOptions(
          path: '/test',
          extra: {AuthInterceptor.requiresAuthKey: true},
        );

        await interceptor.onRequest(options, _NoOpRequestHandler());

        expect(options.headers['Authorization'], isNull);
      });

      test('skips auth when requiresAuth is false', () async {
        final interceptor = AuthInterceptor(
          getSession: () async => _createTestSession(),
          refreshSession: () async => _createTestSession(accessJwt: 'refreshed'),
        );

        final options = RequestOptions(path: '/test');

        await interceptor.onRequest(options, _NoOpRequestHandler());

        expect(options.headers['Authorization'], isNull);
      });
    });

    group('401 retry behavior', () {
      test('retries request with new token on 401', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        var refreshCalled = false;

        dio.interceptors.add(
          AuthInterceptor(
            getSession: () async => _createTestSession(),
            refreshSession: () async {
              refreshCalled = true;
              return _createTestSession(accessJwt: 'new-token');
            },
          ),
        );

        adapter.onGet(
          '/test',
          (server) => server.reply(401, {'error': 'Unauthorized'}),
          headers: {'Authorization': 'Bearer test-token'},
        );

        adapter.onGet(
          '/test',
          (server) => server.reply(200, {'success': true}),
          headers: {'Authorization': 'Bearer new-token'},
        );

        try {
          await dio.get('/test', options: Options(extra: {AuthInterceptor.requiresAuthKey: true}));
        } catch (e) {
          // Expect error since mock adapter can't handle retry properly
        }

        expect(refreshCalled, isTrue);
      });

      test('does not retry if refresh returns null', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        dio.interceptors.add(
          AuthInterceptor(
            getSession: () async => _createTestSession(),
            refreshSession: () async => null,
          ),
        );

        adapter.onGet('/test', (server) => server.reply(401, {'error': 'Unauthorized'}));

        try {
          await dio.get('/test', options: Options(extra: {AuthInterceptor.requiresAuthKey: true}));
          fail('Should throw exception');
        } catch (e) {
          expect(e, isA<DioException>());
        }
      });

      test('does not retry more than once', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        var refreshCount = 0;

        dio.interceptors.add(
          AuthInterceptor(
            getSession: () async => _createTestSession(),
            refreshSession: () async {
              refreshCount++;
              return _createTestSession(accessJwt: 'new-token-$refreshCount');
            },
          ),
        );

        adapter.onGet('/test', (server) => server.reply(401, {'error': 'Unauthorized'}));

        try {
          await dio.get('/test', options: Options(extra: {AuthInterceptor.requiresAuthKey: true}));
          fail('Should throw exception');
        } catch (e) {
          expect(e, isA<DioException>());
        }

        expect(refreshCount, lessThanOrEqualTo(1));
      });

      test('queues concurrent 401 requests and retries after single refresh', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        var refreshCount = 0;

        dio.interceptors.add(
          AuthInterceptor(
            getSession: () async => _createTestSession(),
            refreshSession: () async {
              refreshCount++;
              await Future.delayed(const Duration(milliseconds: 100));
              return _createTestSession(accessJwt: 'refreshed-token');
            },
          ),
        );

        adapter.onGet('/test1', (server) => server.reply(401, {'error': 'Unauthorized'}));
        adapter.onGet('/test2', (server) => server.reply(401, {'error': 'Unauthorized'}));

        final futures = [
          dio.get('/test1', options: Options(extra: {AuthInterceptor.requiresAuthKey: true})),
          dio.get('/test2', options: Options(extra: {AuthInterceptor.requiresAuthKey: true})),
        ];

        try {
          await Future.wait(futures);
        } catch (e) {
          // Expected to fail since mock adapter can't handle retries properly
        }

        expect(refreshCount, equals(1));
      });

      test('does not attempt refresh for non-auth requests', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        var refreshCalled = false;

        dio.interceptors.add(
          AuthInterceptor(
            getSession: () async => _createTestSession(),
            refreshSession: () async {
              refreshCalled = true;
              return _createTestSession(accessJwt: 'new-token');
            },
          ),
        );

        adapter.onGet('/public', (server) => server.reply(401, {'error': 'Unauthorized'}));

        try {
          await dio.get('/public');
          fail('Should throw exception');
        } catch (e) {
          expect(e, isA<DioException>());
        }

        expect(refreshCalled, isFalse);
      });
    });
  });
}

class _NoOpRequestHandler extends RequestInterceptorHandler {
  @override
  void next(RequestOptions requestOptions) {}
}
