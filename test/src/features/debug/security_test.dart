import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/debug/infrastructure/debug_network_interceptor.dart';
import 'package:lazurite/src/features/debug/presentation/atproto_session_tab.dart';
import 'package:lazurite/src/features/debug/presentation/network_inspector_tab.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/dev_tools_dao.dart';
import 'package:mocktail/mocktail.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockDevToolsDao extends Mock implements DevToolsDao {}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._state);

  final AuthState _state;

  @override
  AuthState build() => _state;
}

void main() {
  group('Security: Token Protection', () {
    late Session testSession;

    setUp(() {
      testSession = Session(
        did: 'did:plc:test123',
        handle: 'test.bsky.social',
        pdsUrl: 'https://bsky.social',
        accessJwt: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.secret-access-token',
        refreshJwt: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.secret-refresh-token',
        scope: 'com.atproto.access',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        dpopKey: {
          'kty': 'EC',
          'crv': 'P-256',
          'x': 'secret-x-value',
          'y': 'secret-y-value',
          'd': 'secret-private-key',
        },
      );
    });

    group('ATProto Session Tab', () {
      testWidgets('never displays access token', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(
                () => _TestAuthNotifier(AuthState.authenticated(testSession)),
              ),
            ],
            child: const MaterialApp(home: Scaffold(body: AtprotoSessionTab())),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.secret-access-token'),
          findsNothing,
        );
        expect(find.textContaining('secret-access-token'), findsNothing);
        expect(find.textContaining('accessJwt'), findsNothing);
      });

      testWidgets('never displays refresh token', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(
                () => _TestAuthNotifier(AuthState.authenticated(testSession)),
              ),
            ],
            child: const MaterialApp(home: Scaffold(body: AtprotoSessionTab())),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.secret-refresh-token'),
          findsNothing,
        );
        expect(find.textContaining('secret-refresh-token'), findsNothing);
        expect(find.textContaining('refreshJwt'), findsNothing);
      });

      testWidgets('never displays DPoP key material', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(
                () => _TestAuthNotifier(AuthState.authenticated(testSession)),
              ),
            ],
            child: const MaterialApp(home: Scaffold(body: AtprotoSessionTab())),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('secret-x-value'), findsNothing);
        expect(find.textContaining('secret-y-value'), findsNothing);
        expect(find.textContaining('secret-private-key'), findsNothing);
        expect(find.textContaining('dpopKey'), findsNothing);
      });

      testWidgets('only displays safe session information', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(
                () => _TestAuthNotifier(AuthState.authenticated(testSession)),
              ),
            ],
            child: const MaterialApp(home: Scaffold(body: AtprotoSessionTab())),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('did:plc:test123'), findsOneWidget);
        expect(find.text('test.bsky.social'), findsOneWidget);
        expect(find.text('https://bsky.social'), findsOneWidget);
      });

      testWidgets('displays security note about token storage', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authProvider.overrideWith(
                () => _TestAuthNotifier(AuthState.authenticated(testSession)),
              ),
            ],
            child: const MaterialApp(home: Scaffold(body: AtprotoSessionTab())),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Tokens and keys are stored securely and never displayed.'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      });
    });

    group('Debug Network Interceptor', () {
      test('captures Authorization header in database logs', () async {
        final mockDao = MockDevToolsDao();
        final interceptor = DebugNetworkInterceptor(mockDao);
        final dio = Dio()..interceptors.add(interceptor);

        String? capturedRequestHeaders;
        when(
          () => mockDao.logRequest(
            uuid: any(named: 'uuid'),
            method: any(named: 'method'),
            url: any(named: 'url'),
            statusCode: any(named: 'statusCode'),
            durationMs: any(named: 'durationMs'),
            requestHeaders: any(named: 'requestHeaders'),
            responseHeaders: any(named: 'responseHeaders'),
            requestBody: any(named: 'requestBody'),
            responseBody: any(named: 'responseBody'),
            error: any(named: 'error'),
          ),
        ).thenAnswer((invocation) async {
          capturedRequestHeaders = invocation.namedArguments[#requestHeaders] as String;
        });

        dio.httpClientAdapter = _MockAdapter(
          (options) => ResponseBody.fromString(
            '{"success":true}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          ),
        );

        await dio.get(
          'https://bsky.social/xrpc/com.atproto.server.getSession',
          options: Options(headers: {'Authorization': 'Bearer ${testSession.accessJwt}'}),
        );

        final headers = jsonDecode(capturedRequestHeaders!) as Map<String, dynamic>;
        expect(headers['Authorization'], contains('Bearer'));
        expect(headers['Authorization'], contains(testSession.accessJwt));
      });

      test('captures DPoP header in database logs', () async {
        final mockDao = MockDevToolsDao();
        final interceptor = DebugNetworkInterceptor(mockDao);
        final dio = Dio()..interceptors.add(interceptor);

        String? capturedRequestHeaders;
        when(
          () => mockDao.logRequest(
            uuid: any(named: 'uuid'),
            method: any(named: 'method'),
            url: any(named: 'url'),
            statusCode: any(named: 'statusCode'),
            durationMs: any(named: 'durationMs'),
            requestHeaders: any(named: 'requestHeaders'),
            responseHeaders: any(named: 'responseHeaders'),
            requestBody: any(named: 'requestBody'),
            responseBody: any(named: 'responseBody'),
            error: any(named: 'error'),
          ),
        ).thenAnswer((invocation) async {
          capturedRequestHeaders = invocation.namedArguments[#requestHeaders] as String;
        });

        dio.httpClientAdapter = _MockAdapter(
          (options) => ResponseBody.fromString(
            '{"success":true}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          ),
        );

        const dpopProof = 'eyJhbGciOiJFUzI1NiIsInR5cCI6ImRwb3Arand0In0.secret-dpop-proof';
        await dio.post(
          'https://bsky.social/xrpc/com.atproto.repo.createRecord',
          options: Options(headers: {'DPoP': dpopProof}),
        );

        final headers = jsonDecode(capturedRequestHeaders!) as Map<String, dynamic>;
        expect(headers['DPoP'], equals(dpopProof));
      });

      test('captures request and response bodies in database logs', () async {
        final mockDao = MockDevToolsDao();
        final interceptor = DebugNetworkInterceptor(mockDao);
        final dio = Dio()..interceptors.add(interceptor);

        String? capturedRequestBody;
        String? capturedResponseBody;
        when(
          () => mockDao.logRequest(
            uuid: any(named: 'uuid'),
            method: any(named: 'method'),
            url: any(named: 'url'),
            statusCode: any(named: 'statusCode'),
            durationMs: any(named: 'durationMs'),
            requestHeaders: any(named: 'requestHeaders'),
            responseHeaders: any(named: 'responseHeaders'),
            requestBody: any(named: 'requestBody'),
            responseBody: any(named: 'responseBody'),
            error: any(named: 'error'),
          ),
        ).thenAnswer((invocation) async {
          capturedRequestBody = invocation.namedArguments[#requestBody] as String?;
          capturedResponseBody = invocation.namedArguments[#responseBody] as String?;
        });

        dio.httpClientAdapter = _MockAdapter(
          (options) => ResponseBody.fromString(
            '{"accessJwt":"${testSession.accessJwt}","refreshJwt":"${testSession.refreshJwt}"}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          ),
        );

        await dio.post(
          'https://bsky.social/xrpc/com.atproto.server.createSession',
          data: {'identifier': 'test.bsky.social', 'password': 'secret-password'},
        );

        final requestBody = jsonDecode(capturedRequestBody!) as Map<String, dynamic>;
        expect(requestBody['password'], equals('secret-password'));

        final responseBody = jsonDecode(capturedResponseBody!) as Map<String, dynamic>;
        expect(responseBody['accessJwt'], equals(testSession.accessJwt));
        expect(responseBody['refreshJwt'], equals(testSession.refreshJwt));
      });
    });

    group('Network Inspector UI', () {
      testWidgets('displays Authorization header from database logs', (tester) async {
        final mockDb = MockAppDatabase();
        final mockDao = MockDevToolsDao();
        when(() => mockDb.devToolsDao).thenReturn(mockDao);

        final logsWithAuthHeader = [
          DevNetworkLog(
            id: 1,
            uuid: 'uuid-1',
            method: 'GET',
            url: 'https://bsky.social/xrpc/com.atproto.server.getSession',
            statusCode: 200,
            requestHeaders: jsonEncode({'Authorization': 'Bearer ${testSession.accessJwt}'}),
            responseHeaders: '{}',
            timestamp: DateTime.now(),
            durationMs: 100,
            requestBody: null,
            responseBody: null,
            error: null,
          ),
        ];

        when(() => mockDao.watchLogs()).thenAnswer((_) => Stream.value(logsWithAuthHeader));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [appDatabaseProvider.overrideWithValue(mockDb)],
            child: const MaterialApp(home: Scaffold(body: NetworkInspectorTab())),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('GET'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Authorization'), findsAtLeastNWidgets(1));
      });

      testWidgets('displays DPoP header from database logs', (tester) async {
        final mockDb = MockAppDatabase();
        final mockDao = MockDevToolsDao();
        when(() => mockDb.devToolsDao).thenReturn(mockDao);

        const dpopProof = 'eyJhbGciOiJFUzI1NiIsInR5cCI6ImRwb3Arand0In0.secret-dpop-proof';
        final logsWithDpopHeader = [
          DevNetworkLog(
            id: 1,
            uuid: 'uuid-1',
            method: 'POST',
            url: 'https://bsky.social/xrpc/com.atproto.repo.createRecord',
            statusCode: 200,
            requestHeaders: jsonEncode({'DPoP': dpopProof}),
            responseHeaders: '{}',
            timestamp: DateTime.now(),
            durationMs: 150,
            requestBody: null,
            responseBody: null,
            error: null,
          ),
        ];

        when(() => mockDao.watchLogs()).thenAnswer((_) => Stream.value(logsWithDpopHeader));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [appDatabaseProvider.overrideWithValue(mockDb)],
            child: const MaterialApp(home: Scaffold(body: NetworkInspectorTab())),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('POST'));
        await tester.pumpAndSettle();

        expect(find.textContaining('DPoP'), findsAtLeastNWidgets(1));
      });

      test('database logs contain request/response bodies with tokens', () async {
        final logsWithTokensInBody = DevNetworkLog(
          id: 1,
          uuid: 'uuid-1',
          method: 'POST',
          url: 'https://bsky.social/xrpc/com.atproto.server.createSession',
          statusCode: 200,
          requestHeaders: '{}',
          responseHeaders: '{}',
          timestamp: DateTime.now(),
          durationMs: 200,
          requestBody: jsonEncode({
            'identifier': 'test.bsky.social',
            'password': 'secret-password',
          }),
          responseBody: jsonEncode({
            'accessJwt': testSession.accessJwt,
            'refreshJwt': testSession.refreshJwt,
            'did': testSession.did,
          }),
          error: null,
        );

        final requestBody = jsonDecode(logsWithTokensInBody.requestBody!) as Map<String, dynamic>;
        expect(requestBody['password'], equals('secret-password'));

        final responseBody =
            jsonDecode(logsWithTokensInBody.responseBody!) as Map<String, dynamic>;
        expect(responseBody['accessJwt'], equals(testSession.accessJwt));
        expect(responseBody['refreshJwt'], equals(testSession.refreshJwt));
      });
    });
  });
}

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter(this.handler);

  final dynamic Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final result = handler(options);
    if (result is ResponseBody) return result;
    throw result;
  }

  @override
  void close({bool force = false}) {}
}
