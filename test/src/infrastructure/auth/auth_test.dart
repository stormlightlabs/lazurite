import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jose/jose.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/core/identity/did_document.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/auth/auth_repository.dart';
import 'package:lazurite/src/infrastructure/auth/dpop_utils.dart';
import 'package:lazurite/src/infrastructure/auth/oauth_client.dart';
import 'package:lazurite/src/infrastructure/auth/server_metadata.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:lazurite/src/infrastructure/identity/identity_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockLogger extends Mock implements Logger {}

class MockDio extends Mock implements Dio {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockSessionStorage extends Mock implements SessionStorage {}

class MockOAuthClient extends Mock implements OAuthClient {}

class MockIdentityRepository extends Mock implements IdentityRepository {}

class MockServerMetadataRepository extends Mock implements ServerMetadataRepository {}

/// Fake JsonWebKey for testing
class FakeJsonWebKey extends Fake implements JsonWebKey {
  @override
  Map<String, dynamic> toJson() => {'kty': 'EC', 'crv': 'P-256', 'x': 'x', 'y': 'y', 'd': 'd'};
}

class FakeSession extends Fake implements Session {}

class FakeServerMetadata extends Fake implements ServerMetadata {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeJsonWebKey());
    registerFallbackValue(FakeSession());
    registerFallbackValue(FakeServerMetadata());
  });

  group('IdentityRepository', () {
    late MockDio dio;
    late MockLogger logger;
    late IdentityRepository repo;

    setUp(() {
      dio = MockDio();
      logger = MockLogger();
      when(() => logger.debug(any())).thenReturn(null);
      when(() => logger.info(any())).thenReturn(null);
      when(() => logger.warning(any())).thenReturn(null);
      when(() => logger.error(any(), any(), any<StackTrace?>())).thenReturn(null);
      repo = IdentityRepository(dio: dio, logger: logger);
    });

    test('resolveHandle returns DID on success', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: 'did:plc:123',
        ),
      );

      final result = await repo.resolveHandle('alice.bsky.social');
      expect(result, 'did:plc:123');
    });

    test('resolveDidDocument returns valid doc', () async {
      final json = {
        'id': 'did:plc:123',
        'alsoKnownAs': ['at://alice.bsky.social'],
        'service': [
          {
            'id': '#atproto_pds',
            'type': 'AtprotoPersonalDataServer',
            'serviceEndpoint': 'https://bsky.social',
          },
        ],
      };

      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: json,
        ),
      );

      final doc = await repo.resolveDidDocument('did:plc:123');
      expect(doc, isNotNull);
      expect(doc!.id, 'did:plc:123');
      expect(doc.pdsEndpoint, 'https://bsky.social');
    });
  });

  group('OAuthClient', () {
    late MockDio dio;
    late MockLogger logger;
    late OAuthClient client;

    setUp(() {
      dio = MockDio();
      logger = MockLogger();
      client = OAuthClient(dio: dio, logger: logger);
    });

    test('pushedAuthorizationRequest validates request_uri format', () async {
      const metadata = ServerMetadata(
        issuer: 'https://pds.com',
        authorizationEndpoint: 'https://pds.com/oauth/authorize',
        tokenEndpoint: 'https://pds.com/oauth/token',
        pushedAuthorizationRequestEndpoint: 'https://pds.com/oauth/par',
      );

      when(
        () => dio.post<Map<String, dynamic>>(
          any(),
          options: any(named: 'options'),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 201,
          data: {'request_uri': 'invalid-format', 'expires_in': 60},
        ),
      );

      final key = await DPoPUtils.generateKey();

      await expectLater(
        () => client.pushedAuthorizationRequest(
          metadata: metadata,
          key: key,
          state: 'state',
          codeChallenge: 'challenge',
          redirectUri: 'http://127.0.0.1/callback',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid request_uri format'),
          ),
        ),
      );
    });

    test('pushedAuthorizationRequest throws on missing expires_in', () async {
      const metadata = ServerMetadata(
        issuer: 'https://pds.com',
        authorizationEndpoint: 'https://pds.com/oauth/authorize',
        tokenEndpoint: 'https://pds.com/oauth/token',
        pushedAuthorizationRequestEndpoint: 'https://pds.com/oauth/par',
      );

      when(
        () => dio.post<Map<String, dynamic>>(
          any(),
          options: any(named: 'options'),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 201,
          data: {'request_uri': 'urn:ietf:params:oauth:request_uri:test'},
        ),
      );

      final key = await DPoPUtils.generateKey();

      await expectLater(
        () => client.pushedAuthorizationRequest(
          metadata: metadata,
          key: key,
          state: 'state',
          codeChallenge: 'challenge',
          redirectUri: 'http://127.0.0.1/callback',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('PAR response missing expires_in'),
          ),
        ),
      );
    });

    test('pushedAuthorizationRequest logs warning for short expires_in', () async {
      const metadata = ServerMetadata(
        issuer: 'https://pds.com',
        authorizationEndpoint: 'https://pds.com/oauth/authorize',
        tokenEndpoint: 'https://pds.com/oauth/token',
        pushedAuthorizationRequestEndpoint: 'https://pds.com/oauth/par',
      );

      when(
        () => dio.post<Map<String, dynamic>>(
          any(),
          options: any(named: 'options'),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 201,
          data: {
            'request_uri': 'urn:ietf:params:oauth:request_uri:test',
            'expires_in': 15, // Less than 30 seconds
          },
        ),
      );
      when(() => logger.warning(any())).thenReturn(null);

      final key = await DPoPUtils.generateKey();

      final requestUri = await client.pushedAuthorizationRequest(
        metadata: metadata,
        key: key,
        state: 'state',
        codeChallenge: 'challenge',
        redirectUri: 'http://localhost/callback',
      );

      expect(requestUri, 'urn:ietf:params:oauth:request_uri:test');
      verify(() => logger.warning(any(that: contains('very short')))).called(1);
    });

    test('pushedAuthorizationRequest succeeds with valid response', () async {
      const metadata = ServerMetadata(
        issuer: 'https://pds.com',
        authorizationEndpoint: 'https://pds.com/oauth/authorize',
        tokenEndpoint: 'https://pds.com/oauth/token',
        pushedAuthorizationRequestEndpoint: 'https://pds.com/oauth/par',
      );

      when(
        () => dio.post<Map<String, dynamic>>(
          any(),
          options: any(named: 'options'),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 201,
          data: {
            'request_uri': 'urn:ietf:params:oauth:request_uri:6esc_11ACC5bwc014ltc14eY',
            'expires_in': 60,
          },
        ),
      );

      final key = await DPoPUtils.generateKey();

      final requestUri = await client.pushedAuthorizationRequest(
        metadata: metadata,
        key: key,
        state: 'state',
        codeChallenge: 'challenge',
        redirectUri: 'http://localhost/callback',
      );

      expect(requestUri, 'urn:ietf:params:oauth:request_uri:6esc_11ACC5bwc014ltc14eY');
    });
  });

  group('DPoPUtils', () {
    test('generateKey returns ES256 key', () async {
      final key = await DPoPUtils.generateKey();
      expect(key.algorithm, 'ES256');
    });

    test('createProof returns valid JWT', () async {
      final key = await DPoPUtils.generateKey();
      final proof = await DPoPUtils.createProof(
        url: 'https://example.com',
        method: 'POST',
        privateKey: key,
        nonce: 'test-nonce',
      );

      final jws = JsonWebSignature.fromCompactSerialization(proof);
      expect(jws.unverifiedPayload.jsonContent['htu'], 'https://example.com');
      expect(jws.unverifiedPayload.jsonContent['nonce'], 'test-nonce');
    });

    test('createProof adds ath claim when accessToken provided', () async {
      final key = await DPoPUtils.generateKey();
      final proof = await DPoPUtils.createProof(
        url: 'https://example.com',
        method: 'POST',
        privateKey: key,
        accessToken: 'access-token',
      );

      final jws = JsonWebSignature.fromCompactSerialization(proof);
      final digest = sha256.convert(utf8.encode('access-token'));
      final expectedAth = base64Url.encode(digest.bytes).replaceAll('=', '');

      expect(jws.unverifiedPayload.jsonContent['ath'], expectedAth);
    });
  });

  group('AuthRepository', () {
    late MockIdentityRepository identityRepo;
    late MockOAuthClient oauthClient;
    late MockSessionStorage sessionStorage;
    late MockFlutterSecureStorage secureStorage;
    late MockServerMetadataRepository metadataRepo;
    late MockLogger logger;
    late AuthRepository authRepo;

    setUp(() {
      identityRepo = MockIdentityRepository();
      oauthClient = MockOAuthClient();
      sessionStorage = MockSessionStorage();
      secureStorage = MockFlutterSecureStorage();
      metadataRepo = MockServerMetadataRepository();
      logger = MockLogger();

      authRepo = AuthRepository(
        identityRepository: identityRepo,
        oauthClient: oauthClient,
        sessionStorage: sessionStorage,
        metadataRepository: metadataRepo,
        secureStorage: secureStorage,
        logger: logger,
      );
    });

    test('completeLogin success', () async {
      final uri = Uri.parse('org.stormlightlabs.lazurite://callback?code=abc&state=xyz');
      final key = await DPoPUtils.generateKey();
      final pendingState = {
        'did': 'did:plc:user',
        'handle': 'user.bsky.social',
        'pdsUrl': 'https://pds.com',
        'verifier': 'verifier123',
        'state': 'xyz',
        'redirectUri': 'http://127.0.0.1:12345/callback',
        'dpopKey': key.toJson(),
      };

      const testMetadata = ServerMetadata(
        issuer: 'https://pds.com',
        authorizationEndpoint: 'https://pds.com/oauth/authorize',
        tokenEndpoint: 'https://pds.com/oauth/token',
      );

      when(
        () => secureStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => jsonEncode(pendingState));

      when(() => secureStorage.delete(key: any(named: 'key'))).thenAnswer((_) async {});

      when(() => metadataRepo.discover(any())).thenAnswer((_) async => testMetadata);

      when(
        () => oauthClient.exchangeCodeForToken(
          metadata: any(named: 'metadata'),
          code: any(named: 'code'),
          codeVerifier: any(named: 'codeVerifier'),
          redirectUri: any(named: 'redirectUri'),
          key: any(named: 'key'),
          nonce: any(named: 'nonce'),
        ),
      ).thenAnswer(
        (_) async => TokenResponse(
          accessToken: 'access',
          tokenType: 'Bearer',
          refreshToken: 'refresh',
          scope: 'scope',
          expiresIn: 3600,
        ),
      );

      when(() => sessionStorage.saveSession(any())).thenAnswer((_) async {});

      final session = await authRepo.completeLogin(uri);

      expect(session.did, 'did:plc:user');
      expect(session.accessJwt, 'access');
      verify(() => sessionStorage.saveSession(any())).called(1);
    });

    test('loginWithAppPassword success', () async {
      final mockBootstrapDio = MockDio();

      authRepo = AuthRepository(
        identityRepository: identityRepo,
        oauthClient: oauthClient,
        sessionStorage: sessionStorage,
        metadataRepository: metadataRepo,
        secureStorage: secureStorage,
        bootstrapDio: mockBootstrapDio,
        logger: logger,
      );

      when(() => identityRepo.resolveHandle(any())).thenAnswer((_) async => 'did:plc:user');
      when(() => identityRepo.resolveDidDocument(any())).thenAnswer(
        (_) async => const DidDocument(
          id: 'did:plc:user',
          alsoKnownAs: [],
          service: [
            DidService(
              id: '#atproto_pds',
              type: 'AtprotoPersonalDataServer',
              serviceEndpoint: 'https://pds.com',
            ),
          ],
        ),
      );

      when(() => mockBootstrapDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: {
            'accessJwt': 'access',
            'refreshJwt': 'refresh',
            'did': 'did:plc:user',
            'handle': 'user.bsky.social',
          },
        ),
      );

      when(() => sessionStorage.saveSession(any())).thenAnswer((_) async {});

      final session = await authRepo.loginWithAppPassword('user.bsky.social', 'password');

      expect(session.did, 'did:plc:user');
      expect(session.accessJwt, 'access');
      expect(session.refreshJwt, 'refresh');
      verify(
        () => mockBootstrapDio.post(
          '/xrpc/com.atproto.server.createSession',
          data: {'identifier': 'user.bsky.social', 'password': 'password'},
        ),
      ).called(1);
      verify(() => sessionStorage.saveSession(any())).called(1);
    });

    test('completeLogin validates scopes and logs warning on mismatch', () async {
      final uri = Uri.parse('org.stormlightlabs.lazurite://callback?code=abc&state=xyz');
      final key = await DPoPUtils.generateKey();
      final pendingState = {
        'did': 'did:plc:user',
        'handle': 'user.bsky.social',
        'pdsUrl': 'https://pds.com',
        'verifier': 'verifier123',
        'state': 'xyz',
        'redirectUri': 'http://127.0.0.1:12345/callback',
        'dpopKey': key.toJson(),
      };

      const testMetadata = ServerMetadata(
        issuer: 'https://pds.com',
        authorizationEndpoint: 'https://pds.com/oauth/authorize',
        tokenEndpoint: 'https://pds.com/oauth/token',
      );

      when(
        () => secureStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => jsonEncode(pendingState));
      when(() => secureStorage.delete(key: any(named: 'key'))).thenAnswer((_) async {});
      when(() => metadataRepo.discover(any())).thenAnswer((_) async => testMetadata);
      when(
        () => oauthClient.exchangeCodeForToken(
          metadata: any(named: 'metadata'),
          code: any(named: 'code'),
          codeVerifier: any(named: 'codeVerifier'),
          redirectUri: any(named: 'redirectUri'),
          key: any(named: 'key'),
          nonce: any(named: 'nonce'),
        ),
      ).thenAnswer(
        (_) async => TokenResponse(
          accessToken: 'access',
          tokenType: 'Bearer',
          refreshToken: 'refresh',
          scope: 'atproto', // Missing 'transition:generic'
          expiresIn: 3600,
        ),
      );
      when(() => sessionStorage.saveSession(any())).thenAnswer((_) async {});
      when(() => logger.warning(any())).thenReturn(null);

      await authRepo.completeLogin(uri);

      verify(() => logger.warning(any(that: contains('reduced scopes')))).called(1);
    });

    test('completeLogin validates JWT claims and logs warning on mismatch', () async {
      final uri = Uri.parse('org.stormlightlabs.lazurite://callback?code=abc&state=xyz');
      final key = await DPoPUtils.generateKey();

      final jwtKey = await DPoPUtils.generateKey();
      final builder = JsonWebSignatureBuilder()
        ..jsonContent = {
          'sub': 'did:plc:wrong-user',
          'iss': 'https://pds.com',
          'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'exp': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
        }
        ..addRecipient(jwtKey, algorithm: 'ES256');
      final jws = builder.build();
      final accessToken = jws.toCompactSerialization();

      final pendingState = {
        'did': 'did:plc:user',
        'handle': 'user.bsky.social',
        'pdsUrl': 'https://pds.com',
        'verifier': 'verifier123',
        'state': 'xyz',
        'redirectUri': 'http://127.0.0.1:12345/callback',
        'dpopKey': key.toJson(),
      };

      const testMetadata = ServerMetadata(
        issuer: 'https://pds.com',
        authorizationEndpoint: 'https://pds.com/oauth/authorize',
        tokenEndpoint: 'https://pds.com/oauth/token',
      );

      when(
        () => secureStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => jsonEncode(pendingState));
      when(() => secureStorage.delete(key: any(named: 'key'))).thenAnswer((_) async {});
      when(() => metadataRepo.discover(any())).thenAnswer((_) async => testMetadata);
      when(
        () => oauthClient.exchangeCodeForToken(
          metadata: any(named: 'metadata'),
          code: any(named: 'code'),
          codeVerifier: any(named: 'codeVerifier'),
          redirectUri: any(named: 'redirectUri'),
          key: any(named: 'key'),
          nonce: any(named: 'nonce'),
        ),
      ).thenAnswer(
        (_) async => TokenResponse(
          accessToken: accessToken,
          tokenType: 'Bearer',
          refreshToken: 'refresh',
          scope: 'atproto transition:generic',
          expiresIn: 3600,
        ),
      );
      when(() => sessionStorage.saveSession(any())).thenAnswer((_) async {});
      when(() => logger.warning(any(), any())).thenReturn(null);

      await authRepo.completeLogin(uri);

      verify(() => logger.warning(any(that: contains('sub claim mismatch')), any())).called(1);
    });

    test('loginWithAppPassword failure', () async {
      final mockBootstrapDio = MockDio();

      authRepo = AuthRepository(
        identityRepository: identityRepo,
        oauthClient: oauthClient,
        sessionStorage: sessionStorage,
        metadataRepository: metadataRepo,
        secureStorage: secureStorage,
        bootstrapDio: mockBootstrapDio,
        logger: logger,
      );

      when(() => identityRepo.resolveHandle(any())).thenAnswer((_) async => 'did:plc:user');
      when(() => identityRepo.resolveDidDocument(any())).thenAnswer(
        (_) async => const DidDocument(
          id: 'did:plc:user',
          alsoKnownAs: [],
          service: [
            DidService(
              id: '#atproto_pds',
              type: 'AtprotoPersonalDataServer',
              serviceEndpoint: 'https://pds.com',
            ),
          ],
        ),
      );

      when(() => mockBootstrapDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
            data: {'message': 'Invalid credentials'},
          ),
        ),
      );

      await expectLater(
        () => authRepo.loginWithAppPassword('user.bsky.social', 'badpass'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Login failed'))),
      );
    });
  });
}
