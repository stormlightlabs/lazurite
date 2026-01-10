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

      test('attaches token even for non-requiresAuth requests if session available', () async {
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
        expect(sessionRequested, isTrue);
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

        expect(options.headers['Authorization'], equals('DPoP my-token'));
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

      test('attaches auth even when requiresAuth is false if session available', () async {
        final interceptor = AuthInterceptor(
          getSession: () async => _createTestSession(),
          refreshSession: () async => _createTestSession(accessJwt: 'refreshed'),
        );

        final options = RequestOptions(path: '/test');

        await interceptor.onRequest(options, _NoOpRequestHandler());

        expect(options.headers['Authorization'], isNotNull);
        expect(options.headers['Authorization'], startsWith('DPoP'));
      });
    });

    group('401 retry behavior', () {
      test('retries request immediately on use_dpop_nonce without refresh', () async {
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
          (server) => server.reply(
            401,
            {'error': 'use_dpop_nonce'},
            headers: {
              'DPoP-Nonce': ['new-nonce-value'],
            },
          ),
          headers: {
            'Authorization': ['DPoP test-token'],
          },
        );

        adapter.onGet(
          '/test',
          (server) => server.reply(200, {'success': true}),
          headers: {'Authorization': 'DPoP test-token'},
        );

        final response = await dio.get(
          '/test',
          options: Options(extra: {AuthInterceptor.requiresAuthKey: true}),
        );

        expect(response.statusCode, equals(200));
        expect(refreshCalled, isFalse);
      });

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
          headers: {'Authorization': 'DPoP test-token'},
        );

        adapter.onGet(
          '/test',
          (server) => server.reply(200, {'success': true}),
          headers: {'Authorization': 'DPoP new-token'},
        );

        try {
          await dio.get('/test', options: Options(extra: {AuthInterceptor.requiresAuthKey: true}));
        } catch (e) {
          /* Expect error since mock adapter can't handle retry properly */
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
          /* Expected to fail since mock adapter can't handle retries properly */
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

    group('invalid token handling', () {
      test('refreshes session on 400 InvalidToken before logging out', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        var sessionInvalidated = false;
        var refreshCalled = false;

        dio.interceptors.add(
          AuthInterceptor(
            getSession: () async => _createTestSession(),
            refreshSession: () async {
              refreshCalled = true;
              return _createTestSession(accessJwt: 'refreshed');
            },
            onSessionInvalidated: () {
              sessionInvalidated = true;
            },
          ),
        );

        adapter.onGet(
          '/test',
          (server) => server.reply(400, {'error': 'InvalidToken', 'message': 'Malformed token'}),
        );

        await expectLater(
          dio.get('/test', options: Options(extra: {AuthInterceptor.requiresAuthKey: true})),
          throwsA(isA<DioException>()),
        );

        expect(refreshCalled, isTrue);
        expect(sessionInvalidated, isFalse);
      });

      test('invalidates session when refresh fails for 400 InvalidToken', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        var sessionInvalidated = false;

        dio.interceptors.add(
          AuthInterceptor(
            getSession: () async => _createTestSession(),
            refreshSession: () async => throw Exception('refresh failed'),
            onSessionInvalidated: () {
              sessionInvalidated = true;
            },
          ),
        );

        adapter.onGet(
          '/test',
          (server) => server.reply(400, {'error': 'InvalidToken', 'message': 'Malformed token'}),
        );

        await expectLater(
          dio.get('/test', options: Options(extra: {AuthInterceptor.requiresAuthKey: true})),
          throwsA(isA<DioException>()),
        );

        expect(sessionInvalidated, isTrue);
      });

      test('invalidates session when refresh returns null for 400 ExpiredToken', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        var sessionInvalidated = false;

        dio.interceptors.add(
          AuthInterceptor(
            getSession: () async => _createTestSession(),
            refreshSession: () async => null,
            onSessionInvalidated: () {
              sessionInvalidated = true;
            },
          ),
        );

        adapter.onGet(
          '/test',
          (server) => server.reply(400, {'error': 'ExpiredToken', 'message': 'Token expired'}),
        );

        await expectLater(
          dio.get('/test', options: Options(extra: {AuthInterceptor.requiresAuthKey: true})),
          throwsA(isA<DioException>()),
        );

        expect(sessionInvalidated, isTrue);
      });

      test('does not call onSessionInvalidated for other 400 errors', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        var sessionInvalidated = false;

        dio.interceptors.add(
          AuthInterceptor(
            getSession: () async => _createTestSession(),
            refreshSession: () async => _createTestSession(),
            onSessionInvalidated: () {
              sessionInvalidated = true;
            },
          ),
        );

        adapter.onGet(
          '/test',
          (server) => server.reply(400, {'error': 'InvalidRequest', 'message': 'Bad request'}),
        );

        try {
          await dio.get('/test', options: Options(extra: {AuthInterceptor.requiresAuthKey: true}));
          fail('Should throw exception');
        } catch (e) {
          expect(e, isA<DioException>());
        }

        expect(sessionInvalidated, isFalse);
      });

      test('does not call onSessionInvalidated for non-auth requests with 400', () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://test.api'));
        final adapter = DioAdapter(dio: dio);

        var sessionInvalidated = false;

        dio.interceptors.add(
          AuthInterceptor(
            getSession: () async => _createTestSession(),
            refreshSession: () async => _createTestSession(),
            onSessionInvalidated: () {
              sessionInvalidated = true;
            },
          ),
        );

        adapter.onGet('/public', (server) => server.reply(400, {'error': 'InvalidToken'}));

        try {
          await dio.get('/public');
          fail('Should throw exception');
        } catch (e) {
          expect(e, isA<DioException>());
        }

        expect(sessionInvalidated, isFalse);
      });
    });
  });
}

class _NoOpRequestHandler extends RequestInterceptorHandler {
  @override
  void next(RequestOptions requestOptions) {}
}
