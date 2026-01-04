import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jose/jose.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/infrastructure/auth/auth_repository.dart';
import 'package:lazurite/src/infrastructure/auth/dpop_utils.dart';
import 'package:lazurite/src/infrastructure/auth/oauth_client.dart';
import 'package:lazurite/src/infrastructure/auth/server_metadata.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:lazurite/src/infrastructure/identity/identity_repository.dart';
import 'package:mocktail/mocktail.dart';

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
    late IdentityRepository repo;

    setUp(() {
      dio = MockDio();
      repo = IdentityRepository(dio: dio);
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
    late AuthRepository authRepo;

    setUp(() {
      identityRepo = MockIdentityRepository();
      oauthClient = MockOAuthClient();
      sessionStorage = MockSessionStorage();
      secureStorage = MockFlutterSecureStorage();
      metadataRepo = MockServerMetadataRepository();

      authRepo = AuthRepository(
        identityRepository: identityRepo,
        oauthClient: oauthClient,
        sessionStorage: sessionStorage,
        metadataRepository: metadataRepo,
        secureStorage: secureStorage,
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
  });
}
