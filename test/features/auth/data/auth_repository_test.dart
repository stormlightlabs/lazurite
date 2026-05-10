import 'dart:async';
import 'dart:convert';

import 'package:poptart_core/poptart_core.dart' as atcore;
import 'package:poptart_oauth/poptart_oauth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/network/slingshot_client.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_launcher/url_launcher.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSlingshotClient extends Mock implements SlingshotClient {}

class FakeAccountsCompanion extends Fake implements AccountsCompanion {}

void main() {
  late AuthRepository authRepository;
  late MockAppDatabase mockDatabase;
  late MockSlingshotClient mockSlingshotClient;

  setUpAll(() {
    registerFallbackValue(FakeAccountsCompanion());
  });

  setUp(() {
    mockDatabase = MockAppDatabase();
    mockSlingshotClient = MockSlingshotClient();
    authRepository = AuthRepository(database: mockDatabase);
  });

  group('AuthRepository', () {
    group('getStoredSession', () {
      test('should return null when no account exists', () async {
        when(() => mockDatabase.getActiveAccount()).thenAnswer((_) async => null);

        final result = await authRepository.getStoredSession();

        expect(result, isNull);
        verify(() => mockDatabase.getActiveAccount()).called(1);
      });

      test('should return AuthTokens when account exists', () async {
        final account = Account(
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'bsky.social',
          oauthService: null,
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
          dpopPublicKey: null,
          dpopPrivateKey: null,
          dpopNonce: null,
          displayName: 'User Name',
          expiresAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockDatabase.getActiveAccount()).thenAnswer((_) async => account);

        final result = await authRepository.getStoredSession();

        expect(result, isNotNull);
        expect(result!.did, equals('did:plc:abc123'));
        expect(result.handle, equals('user.bsky.social'));
        expect(result.accessToken, equals('access_token'));
        expect(result.refreshToken, equals('refresh_token'));
        expect(result.displayName, equals('User Name'));
        expect(result.service, equals('bsky.social'));
        expect(result.authMethod, AuthMethod.appPassword);
      });

      test('should read oauthService for oauth-backed account', () async {
        final account = Account(
          did: 'did:plc:oauth123',
          handle: 'oauth-user.bsky.social',
          service: 'porcini.us-east.host.bsky.network',
          oauthService: 'bsky.social',
          oauthClientId: 'https://lazurite.stormlightlabs.org/client-metadata.json',
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
          dpopPublicKey: 'public-key',
          dpopPrivateKey: 'private-key',
          dpopNonce: 'nonce',
          displayName: 'OAuth User',
          expiresAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockDatabase.getActiveAccount()).thenAnswer((_) async => account);

        final result = await authRepository.getStoredSession();

        expect(result, isNotNull);
        expect(result!.usesOAuth, isTrue);
        expect(result.oauthService, equals('bsky.social'));
        expect(result.oauthClientId, equals('https://lazurite.stormlightlabs.org/client-metadata.json'));
      });
    });

    group('saveSession', () {
      test('should save session to database', () async {
        const tokens = AuthTokens(
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          displayName: 'User Name',
          service: 'bsky.social',
          oauthClientId: 'https://lazurite.stormlightlabs.org/client-metadata.json',
        );

        when(() => mockDatabase.insertAccount(any())).thenAnswer((_) async => 1);

        await authRepository.saveSession(tokens);

        verify(() => mockDatabase.insertAccount(any())).called(1);
      });

      test('should mark the saved session active when requested', () async {
        const tokens = AuthTokens(accessToken: 'access_token', did: 'did:plc:abc123', handle: 'user.bsky.social');

        when(() => mockDatabase.insertAccount(any())).thenAnswer((_) async => 1);
        when(
          () => mockDatabase.setSetting(AppDatabase.activeAccountDidSettingKey, tokens.did),
        ).thenAnswer((_) async => 1);

        await authRepository.saveSession(tokens, makeActive: true);

        verify(() => mockDatabase.insertAccount(any())).called(1);
        verify(() => mockDatabase.setSetting(AppDatabase.activeAccountDidSettingKey, tokens.did)).called(1);
      });
    });

    group('restoreSession', () {
      test('should return stored session when it is still valid', () async {
        final futureExpiry = DateTime.now().add(const Duration(hours: 1));
        final account = Account(
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'bsky.social',
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
          dpopPublicKey: null,
          dpopPrivateKey: null,
          dpopNonce: null,
          displayName: 'User Name',
          expiresAt: futureExpiry,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockDatabase.getActiveAccount()).thenAnswer((_) async => account);

        final restored = await authRepository.restoreSession();

        expect(restored, isNotNull);
        expect(restored!.handle, equals('user.bsky.social'));
      });

      test('preserves expired stored session when refresh failure is transient', () async {
        final expiredAt = DateTime.now().subtract(const Duration(hours: 1));
        final account = Account(
          did: 'did:plc:oauth123',
          handle: 'oauth-user.bsky.social',
          service: 'porcini.us-east.host.bsky.network',
          oauthService: 'bsky.social',
          oauthClientId: AuthRepository.kClientId,
          accessToken: 'expired-access-token',
          refreshToken: 'refresh-token',
          dpopPublicKey: 'public-key',
          dpopPrivateKey: 'private-key',
          dpopNonce: 'nonce',
          displayName: 'OAuth User',
          expiresAt: expiredAt,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        authRepository = AuthRepository(
          database: mockDatabase,
          loadClientMetadata: (_) async => throw Exception('metadata unavailable'),
        );
        when(() => mockDatabase.getActiveAccount()).thenAnswer((_) async => account);

        final restored = await authRepository.restoreSession();

        expect(restored, isNotNull);
        expect(restored!.did, equals(account.did));
        expect(restored.isExpired, isTrue);
        verifyNever(() => mockDatabase.deleteAccount(any()));
        verifyNever(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey));
      });
    });

    group('app password refresh', () {
      test('preserves account when refresh fails transiently', () async {
        authRepository = AuthRepository(
          database: mockDatabase,
          appPasswordRefreshSession: ({required String refreshJwt, String? service}) async =>
              throw Exception('refresh service unavailable'),
        );

        const currentSession = AuthTokens(
          accessToken: 'expired-access-token',
          refreshToken: 'refresh-token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'bsky.social',
          authMethod: AuthMethod.appPassword,
        );

        await expectLater(authRepository.refreshSession(currentSession), throwsA(isA<Exception>()));

        verifyNever(() => mockDatabase.deleteAccount(any()));
        verifyNever(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey));
      });

      test('invalidates account when refresh token is rejected', () async {
        authRepository = AuthRepository(
          database: mockDatabase,
          appPasswordRefreshSession: ({required String refreshJwt, String? service}) async =>
              throw _unauthorizedRefreshException(),
        );

        const currentSession = AuthTokens(
          accessToken: 'expired-access-token',
          refreshToken: 'refresh-token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'bsky.social',
          authMethod: AuthMethod.appPassword,
        );

        when(() => mockDatabase.deleteAccount(currentSession.did)).thenAnswer((_) async => 1);
        when(
          () => mockDatabase.getSetting(AppDatabase.activeAccountDidSettingKey),
        ).thenAnswer((_) async => currentSession.did);
        when(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).thenAnswer((_) async => 1);

        await expectLater(authRepository.refreshSession(currentSession), throwsA(isA<Exception>()));

        verify(() => mockDatabase.deleteAccount(currentSession.did)).called(1);
        verify(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).called(1);
      });
    });

    group('oauth refresh', () {
      test('orders issuer host before stored auth host and deduplicates candidates', () {
        final candidates = AuthRepository.oauthRefreshServiceCandidatesForTest(
          storedAuthService: 'https://bsky.social',
          issuer: 'https://bsky.social',
        );

        expect(candidates, equals(['bsky.social']));
      });

      test('uses stored oauth auth host when issuer is unavailable', () {
        final candidates = AuthRepository.oauthRefreshServiceCandidatesForTest(
          storedAuthService: 'https://oauth.custom.example',
          issuer: null,
        );

        expect(candidates, equals(['oauth.custom.example', 'bsky.social']));
      });

      test('retries OAuth refresh against fallback auth service hosts', () async {
        final attemptedServices = <String>[];
        final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final expiredAccessToken = _buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds - 3600,
          iatEpochSeconds: nowEpochSeconds - 7200,
          aud: 'did:web:porcini.us-east.host.bsky.network',
        );
        final refreshedAccessToken = _buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds + 3600,
          iatEpochSeconds: nowEpochSeconds,
          aud: 'did:web:porcini.us-east.host.bsky.network',
          iss: 'https://bsky.social',
        );

        authRepository = AuthRepository(
          database: mockDatabase,
          loadClientMetadata: (_) async => _testClientMetadata(),
          oauthRefreshSession:
              ({required OAuthClientMetadata metadata, required String service, required OAuthSession session}) async {
                attemptedServices.add(service);
                if (service == 'porcini.us-east.host.bsky.network') {
                  throw const FormatException('Unexpected character (at character 1)');
                }

                expect(service, equals('bsky.social'));
                return OAuthSession(
                  accessToken: refreshedAccessToken,
                  refreshToken: session.refreshToken,
                  tokenType: 'DPoP',
                  scope: 'atproto',
                  expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
                  sub: session.sub,
                  $dPoPNonce: 'new-nonce',
                  $publicKey: session.$publicKey,
                  $privateKey: session.$privateKey,
                );
              },
        );

        const currentSession = AuthTokens(
          accessToken: 'REPLACE_ME',
          refreshToken: 'refresh-token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'porcini.us-east.host.bsky.network',
          oauthService: 'porcini.us-east.host.bsky.network',
          dpopNonce: 'nonce',
          dpopPublicKey: 'public-key',
          dpopPrivateKey: 'private-key',
          authMethod: AuthMethod.oauth,
        );
        final sessionWithJwt = currentSession.copyWith(accessToken: expiredAccessToken);

        when(
          () => mockDatabase.getSetting(AppDatabase.activeAccountDidSettingKey),
        ).thenAnswer((_) async => currentSession.did);
        when(() => mockDatabase.insertAccount(any())).thenAnswer((_) async => 1);
        when(
          () => mockDatabase.setSetting(AppDatabase.activeAccountDidSettingKey, currentSession.did),
        ).thenAnswer((_) async => 1);

        final refreshed = await authRepository.refreshSession(sessionWithJwt);

        expect(refreshed, isNotNull);
        expect(refreshed!.did, equals(currentSession.did));
        expect(attemptedServices, equals(['porcini.us-east.host.bsky.network', 'bsky.social']));
        expect(refreshed.oauthService, equals('bsky.social'));
        verifyNever(() => mockDatabase.deleteAccount(any()));
        verify(() => mockDatabase.insertAccount(any())).called(1);
      });

      test('loads OAuth refresh metadata using stored oauthClientId', () async {
        final requestedClientIds = <String>[];
        final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final expiredAccessToken = _buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds - 3600,
          iatEpochSeconds: nowEpochSeconds - 7200,
          aud: 'did:web:porcini.us-east.host.bsky.network',
          iss: 'https://northsky.social',
        );
        final refreshedAccessToken = _buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds + 3600,
          iatEpochSeconds: nowEpochSeconds,
          aud: 'did:web:porcini.us-east.host.bsky.network',
          iss: 'https://northsky.social',
        );

        authRepository = AuthRepository(
          database: mockDatabase,
          loadClientMetadata: (clientId) async {
            requestedClientIds.add(clientId);
            return _testClientMetadata();
          },
          oauthRefreshSession:
              ({required OAuthClientMetadata metadata, required String service, required OAuthSession session}) async {
                return OAuthSession(
                  accessToken: refreshedAccessToken,
                  refreshToken: session.refreshToken,
                  tokenType: 'DPoP',
                  scope: 'atproto',
                  expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
                  sub: session.sub,
                  $dPoPNonce: 'new-nonce',
                  $publicKey: session.$publicKey,
                  $privateKey: session.$privateKey,
                );
              },
        );

        const currentSession = AuthTokens(
          accessToken: 'REPLACE_ME',
          refreshToken: 'refresh-token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'porcini.us-east.host.bsky.network',
          oauthService: 'northsky.social',
          oauthClientId: 'https://northsky.social/oauth/client-metadata.json',
          dpopNonce: 'nonce',
          dpopPublicKey: 'public-key',
          dpopPrivateKey: 'private-key',
          authMethod: AuthMethod.oauth,
        );
        final sessionWithJwt = currentSession.copyWith(accessToken: expiredAccessToken);

        when(
          () => mockDatabase.getSetting(AppDatabase.activeAccountDidSettingKey),
        ).thenAnswer((_) async => currentSession.did);
        when(() => mockDatabase.insertAccount(any())).thenAnswer((_) async => 1);
        when(
          () => mockDatabase.setSetting(AppDatabase.activeAccountDidSettingKey, currentSession.did),
        ).thenAnswer((_) async => 1);

        final refreshed = await authRepository.refreshSession(sessionWithJwt);

        expect(refreshed, isNotNull);
        expect(requestedClientIds, equals(['https://northsky.social/oauth/client-metadata.json']));
      });

      test('falls back to default client id when stored oauthClientId is blank', () async {
        final requestedClientIds = <String>[];
        final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final expiredAccessToken = _buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds - 3600,
          iatEpochSeconds: nowEpochSeconds - 7200,
          aud: 'did:web:porcini.us-east.host.bsky.network',
          iss: 'https://northsky.social',
        );
        final refreshedAccessToken = _buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds + 3600,
          iatEpochSeconds: nowEpochSeconds,
          aud: 'did:web:porcini.us-east.host.bsky.network',
          iss: 'https://northsky.social',
        );

        authRepository = AuthRepository(
          database: mockDatabase,
          loadClientMetadata: (clientId) async {
            requestedClientIds.add(clientId);
            return _testClientMetadata();
          },
          oauthRefreshSession:
              ({required OAuthClientMetadata metadata, required String service, required OAuthSession session}) async {
                return OAuthSession(
                  accessToken: refreshedAccessToken,
                  refreshToken: session.refreshToken,
                  tokenType: 'DPoP',
                  scope: 'atproto',
                  expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
                  sub: session.sub,
                  $dPoPNonce: 'new-nonce',
                  $publicKey: session.$publicKey,
                  $privateKey: session.$privateKey,
                );
              },
        );

        const currentSession = AuthTokens(
          accessToken: 'REPLACE_ME',
          refreshToken: 'refresh-token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'porcini.us-east.host.bsky.network',
          oauthService: 'northsky.social',
          oauthClientId: '   ',
          dpopNonce: 'nonce',
          dpopPublicKey: 'public-key',
          dpopPrivateKey: 'private-key',
          authMethod: AuthMethod.oauth,
        );
        final sessionWithJwt = currentSession.copyWith(accessToken: expiredAccessToken);

        when(
          () => mockDatabase.getSetting(AppDatabase.activeAccountDidSettingKey),
        ).thenAnswer((_) async => currentSession.did);
        when(() => mockDatabase.insertAccount(any())).thenAnswer((_) async => 1);
        when(
          () => mockDatabase.setSetting(AppDatabase.activeAccountDidSettingKey, currentSession.did),
        ).thenAnswer((_) async => 1);

        final refreshed = await authRepository.refreshSession(sessionWithJwt);

        expect(refreshed, isNotNull);
        expect(requestedClientIds, equals([AuthRepository.kClientId]));
      });

      test('preserves account when OAuth refresh fails transiently', () async {
        final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final expiredAccessToken = _buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds - 3600,
          iatEpochSeconds: nowEpochSeconds - 7200,
          aud: 'did:web:porcini.us-east.host.bsky.network',
          iss: 'https://bsky.social',
        );

        authRepository = AuthRepository(
          database: mockDatabase,
          loadClientMetadata: (_) async => _testClientMetadata(),
          oauthRefreshSession:
              ({required OAuthClientMetadata metadata, required String service, required OAuthSession session}) async {
                throw const OAuthException('{"error":"temporarily_unavailable"}');
              },
        );

        final currentSession = AuthTokens(
          accessToken: expiredAccessToken,
          refreshToken: 'refresh-token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'porcini.us-east.host.bsky.network',
          oauthService: 'bsky.social',
          oauthClientId: AuthRepository.kClientId,
          dpopNonce: 'nonce',
          dpopPublicKey: 'public-key',
          dpopPrivateKey: 'private-key',
          authMethod: AuthMethod.oauth,
        );

        await expectLater(authRepository.refreshSession(currentSession), throwsA(isA<Exception>()));

        verifyNever(() => mockDatabase.deleteAccount(any()));
        verifyNever(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey));
      });

      test('invalidates account when OAuth refresh token is rejected', () async {
        final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final expiredAccessToken = _buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds - 3600,
          iatEpochSeconds: nowEpochSeconds - 7200,
          aud: 'did:web:porcini.us-east.host.bsky.network',
          iss: 'https://bsky.social',
        );

        authRepository = AuthRepository(
          database: mockDatabase,
          loadClientMetadata: (_) async => _testClientMetadata(),
          oauthRefreshSession:
              ({required OAuthClientMetadata metadata, required String service, required OAuthSession session}) async {
                throw const OAuthException('{"error":"invalid_grant"}');
              },
        );

        final currentSession = AuthTokens(
          accessToken: expiredAccessToken,
          refreshToken: 'refresh-token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'porcini.us-east.host.bsky.network',
          oauthService: 'bsky.social',
          oauthClientId: AuthRepository.kClientId,
          dpopNonce: 'nonce',
          dpopPublicKey: 'public-key',
          dpopPrivateKey: 'private-key',
          authMethod: AuthMethod.oauth,
        );

        when(() => mockDatabase.deleteAccount(currentSession.did)).thenAnswer((_) async => 1);
        when(
          () => mockDatabase.getSetting(AppDatabase.activeAccountDidSettingKey),
        ).thenAnswer((_) async => currentSession.did);
        when(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).thenAnswer((_) async => 1);

        await expectLater(authRepository.refreshSession(currentSession), throwsA(isA<Exception>()));

        verify(() => mockDatabase.deleteAccount(currentSession.did)).called(1);
        verify(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).called(1);
      });

      test('does not invalidate when only fallback OAuth candidates reject credentials', () async {
        final attemptedServices = <String>[];
        final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final expiredAccessToken = _buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds - 3600,
          iatEpochSeconds: nowEpochSeconds - 7200,
          aud: 'did:web:porcini.us-east.host.bsky.network',
          iss: 'https://issuer.example',
        );

        authRepository = AuthRepository(
          database: mockDatabase,
          loadClientMetadata: (_) async => _testClientMetadata(),
          oauthRefreshSession:
              ({required OAuthClientMetadata metadata, required String service, required OAuthSession session}) async {
                attemptedServices.add(service);
                if (service == 'issuer.example') {
                  throw const OAuthException('{"error":"temporarily_unavailable"}');
                }
                throw const OAuthException('{"error":"invalid_grant"}');
              },
        );

        final currentSession = AuthTokens(
          accessToken: expiredAccessToken,
          refreshToken: 'refresh-token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'porcini.us-east.host.bsky.network',
          oauthService: 'stale-auth.example',
          oauthClientId: AuthRepository.kClientId,
          dpopNonce: 'nonce',
          dpopPublicKey: 'public-key',
          dpopPrivateKey: 'private-key',
          authMethod: AuthMethod.oauth,
        );

        await expectLater(authRepository.refreshSession(currentSession), throwsA(isA<Exception>()));

        expect(attemptedServices, equals(['issuer.example', 'stale-auth.example', 'bsky.social']));
        verifyNever(() => mockDatabase.deleteAccount(any()));
        verifyNever(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey));
      });
    });

    group('oauth authorize candidates', () {
      test('prioritizes resolved auth service before provider preference', () {
        final candidates = AuthRepository.oauthAuthorizeServiceCandidatesForTest(
          preferredAuthService: 'blacksky.community',
          resolvedPdsHost: 'https://porcini.us-east.host.bsky.network',
          resolvedAuthService: 'https://bsky.social',
        );

        expect(candidates, equals(['bsky.social', 'porcini.us-east.host.bsky.network', 'blacksky.community']));
      });

      test('deduplicates when preferred and resolved hosts match defaults', () {
        final candidates = AuthRepository.oauthAuthorizeServiceCandidatesForTest(
          preferredAuthService: 'https://bsky.social',
          resolvedPdsHost: 'bsky.social',
          resolvedAuthService: 'bsky.social',
        );

        expect(candidates, equals(['bsky.social']));
      });
    });

    group('slingshot identity fallback', () {
      test('does not use slingshot fallback when disabled', () async {
        authRepository = AuthRepository(
          database: mockDatabase,
          slingshotClient: mockSlingshotClient,
          slingshotIdentityFallbackEnabledResolver: () => false,
          resolveHandleDid: (_) async => throw Exception('resolveHandle down'),
        );

        expect(() => authRepository.resolveServiceForIdentifierForTest('alice.bsky.social'), throwsA(isA<Exception>()));
        verifyNever(() => mockSlingshotClient.resolveMiniDoc(any()));
      });

      test('uses slingshot mini doc when handle resolution is degraded and fallback is enabled', () async {
        when(() => mockSlingshotClient.resolveMiniDoc('alice.bsky.social')).thenAnswer(
          (_) async => const SlingshotMiniDoc(
            did: 'did:plc:alice',
            handle: 'alice.bsky.social',
            pds: 'https://pds.alice.example',
          ),
        );

        authRepository = AuthRepository(
          database: mockDatabase,
          slingshotClient: mockSlingshotClient,
          slingshotIdentityFallbackEnabledResolver: () => true,
          resolveHandleDid: (_) async => throw Exception('resolveHandle down'),
          resolveDidDocument: (_) async {
            throw Exception('DID doc should not be fetched when mini doc includes pds');
          },
        );

        final service = await authRepository.resolveServiceForIdentifierForTest('alice.bsky.social');

        expect(service, equals('pds.alice.example'));
        verify(() => mockSlingshotClient.resolveMiniDoc('alice.bsky.social')).called(1);
      });
    });

    group('oauth identifier validation', () {
      test('fails fast for malformed handle input', () async {
        await expectLater(
          authRepository.loginWithOAuth('not-a-handle'),
          throwsA(
            isA<AuthIdentifierResolutionException>().having(
              (error) => error.toString(),
              'message',
              contains('Invalid handle format'),
            ),
          ),
        );
      });

      test('throws identifier resolution error for unresolvable handle', () async {
        authRepository = AuthRepository(
          database: mockDatabase,
          resolveHandleDid: (_) async => throw _invalidResolveHandleRequestException(),
        );

        await expectLater(
          authRepository.loginWithOAuth('nobody.bsky.social'),
          throwsA(
            isA<AuthIdentifierResolutionException>().having(
              (error) => error.toString(),
              'message',
              allOf(contains('Unable to resolve'), contains('nobody.bsky.social')),
            ),
          ),
        );
      });

      test('normalizes uppercase did input before identity handling', () async {
        authRepository = AuthRepository(
          database: mockDatabase,
          resolveDidDocument: (_) async => {
            'service': [
              {'id': '#atproto_pds', 'type': 'AtprotoPersonalDataServer', 'serviceEndpoint': 'https://pds.example'},
            ],
          },
        );

        final service = await authRepository.resolveServiceForIdentifierForTest('DID:PLC:ABC123');
        expect(service, equals('pds.example'));
      });

      test('fails fast for incomplete did identifiers', () async {
        await expectLater(
          authRepository.loginWithOAuth('did:web:'),
          throwsA(
            isA<AuthIdentifierResolutionException>().having(
              (error) => error.toString(),
              'message',
              contains('Invalid DID format'),
            ),
          ),
        );
      });
    });

    group('oauth callback normalization', () {
      test('accepts canonical custom scheme callback URI', () {
        final normalized = authRepository.normalizeOAuthCallbackUriForTest(
          Uri.parse('org.stormlightlabs.lazurite:/oauth/callback?code=abc&state=xyz'),
        );

        expect(normalized, isNotNull);
        expect(normalized!.scheme, equals('org.stormlightlabs.lazurite'));
        expect(normalized.path, equals('/oauth/callback'));
      });

      test('normalizes path-only callback URI to canonical custom scheme', () {
        final normalized = authRepository.normalizeOAuthCallbackUriForTest(
          Uri.parse('/oauth/callback?code=abc&state=xyz'),
        );

        expect(normalized, isNotNull);
        expect(normalized!.toString(), equals('org.stormlightlabs.lazurite:/oauth/callback?code=abc&state=xyz'));
      });

      test('normalizes authority-style custom scheme callback URI to canonical custom scheme', () {
        final normalized = authRepository.normalizeOAuthCallbackUriForTest(
          Uri.parse('org.stormlightlabs.lazurite://oauth/callback?code=abc&state=xyz'),
        );

        expect(normalized, isNotNull);
        expect(normalized!.toString(), equals('org.stormlightlabs.lazurite:/oauth/callback?code=abc&state=xyz'));
      });

      test('normalizes compatibility callback path to canonical custom scheme', () {
        final normalized = authRepository.normalizeOAuthCallbackUriForTest(Uri.parse('/callback?code=abc&state=xyz'));

        expect(normalized, isNotNull);
        expect(normalized!.toString(), equals('org.stormlightlabs.lazurite:/oauth/callback?code=abc&state=xyz'));
      });

      test('rejects path-only callback without oauth response parameters', () {
        final normalized = authRepository.normalizeOAuthCallbackUriForTest(Uri.parse('/callback?foo=bar'));

        expect(normalized, isNull);
      });

      test('accepts exact HTTPS callback URI with oauth query parameters', () {
        final normalized = authRepository.normalizeOAuthCallbackUriForTest(
          Uri.parse(
            'https://lazurite.stormlightlabs.org/oauth/callback?code=abc&state=xyz&iss=https%3A%2F%2Fbsky.social',
          ),
        );

        expect(normalized, isNotNull);
        expect(normalized!.scheme, equals('https'));
        expect(normalized.host, equals('lazurite.stormlightlabs.org'));
        expect(normalized.path, equals('/oauth/callback'));
        expect(normalized.queryParameters['code'], equals('abc'));
        expect(normalized.queryParameters['state'], equals('xyz'));
      });

      test('rejects HTTPS callback URI with unexpected host', () {
        final normalized = authRepository.normalizeOAuthCallbackUriForTest(
          Uri.parse('https://example.com/oauth/callback?code=abc&state=xyz'),
        );

        expect(normalized, isNull);
      });

      test('rejects HTTPS callback URI with unexpected path', () {
        final normalized = authRepository.normalizeOAuthCallbackUriForTest(
          Uri.parse('https://lazurite.stormlightlabs.org/callback?code=abc&state=xyz'),
        );

        expect(normalized, isNull);
      });
    });

    group('oauth callback exchange coordination', () {
      test('joins duplicate callback deliveries to one token exchange', () async {
        const tokens = AuthTokens(accessToken: 'access', did: 'did:plc:abc123', handle: 'user.bsky.social');
        final exchangeCompleter = Completer<AuthTokens>();
        var exchangeCalls = 0;

        Future<AuthTokens> exchange(String callbackUrl) {
          exchangeCalls += 1;
          expect(callbackUrl, equals('org.stormlightlabs.lazurite:/oauth/callback?code=abc&state=xyz'));
          return exchangeCompleter.future;
        }

        final firstResult = authRepository.runOAuthCallbackExchangeOnceForTest(
          Uri.parse('org.stormlightlabs.lazurite:/oauth/callback?code=abc&state=xyz'),
          exchange,
        );
        final secondResult = authRepository.runOAuthCallbackExchangeOnceForTest(
          Uri.parse('org.stormlightlabs.lazurite:/oauth/callback?code=abc&state=xyz'),
          exchange,
        );

        await Future<void>.delayed(Duration.zero);
        expect(exchangeCalls, equals(1));

        exchangeCompleter.complete(tokens);

        expect(await firstResult, equals(tokens));
        expect(await secondResult, equals(tokens));
        expect(exchangeCalls, equals(1));
      });
    });

    group('oauth redirect URI selection', () {
      test('prefers HTTPS callback on Android when flag is enabled', () {
        final selected = authRepository.selectOAuthRedirectUriTemplateForTest(
          const ['org.stormlightlabs.lazurite:/oauth/callback', 'https://lazurite.stormlightlabs.org/oauth/callback'],
          isAndroid: true,
          httpsAndroidCallbackEnabled: true,
          isIos: false,
          httpsIosCallbackEnabled: true,
        );

        expect(selected.toString(), equals('https://lazurite.stormlightlabs.org/oauth/callback'));
      });

      test('uses custom scheme callback on Android when HTTPS flag is disabled', () {
        final selected = authRepository.selectOAuthRedirectUriTemplateForTest(
          const ['org.stormlightlabs.lazurite:/oauth/callback', 'https://lazurite.stormlightlabs.org/oauth/callback'],
          isAndroid: true,
          httpsAndroidCallbackEnabled: false,
          isIos: false,
          httpsIosCallbackEnabled: true,
        );

        expect(selected.toString(), equals('org.stormlightlabs.lazurite:/oauth/callback'));
      });

      test('uses custom scheme callback when HTTPS callback is unavailable', () {
        final selected = authRepository.selectOAuthRedirectUriTemplateForTest(
          const ['org.stormlightlabs.lazurite:/oauth/callback'],
          isAndroid: true,
          httpsAndroidCallbackEnabled: true,
          isIos: false,
          httpsIosCallbackEnabled: true,
        );

        expect(selected.toString(), equals('org.stormlightlabs.lazurite:/oauth/callback'));
      });

      test('uses HTTPS callback when custom scheme callback is unavailable', () {
        final selected = authRepository.selectOAuthRedirectUriTemplateForTest(
          const ['https://lazurite.stormlightlabs.org/oauth/callback'],
          isAndroid: true,
          httpsAndroidCallbackEnabled: true,
          isIos: false,
          httpsIosCallbackEnabled: true,
        );

        expect(selected.toString(), equals('https://lazurite.stormlightlabs.org/oauth/callback'));
      });

      test('prefers HTTPS callback on iOS when flag is enabled', () {
        final selected = authRepository.selectOAuthRedirectUriTemplateForTest(
          const ['org.stormlightlabs.lazurite:/oauth/callback', 'https://lazurite.stormlightlabs.org/oauth/callback'],
          isAndroid: false,
          httpsAndroidCallbackEnabled: true,
          isIos: true,
          httpsIosCallbackEnabled: true,
        );

        expect(selected.toString(), equals('https://lazurite.stormlightlabs.org/oauth/callback'));
      });

      test('uses custom scheme callback on iOS when HTTPS flag is disabled', () {
        final selected = authRepository.selectOAuthRedirectUriTemplateForTest(
          const ['org.stormlightlabs.lazurite:/oauth/callback', 'https://lazurite.stormlightlabs.org/oauth/callback'],
          isAndroid: false,
          httpsAndroidCallbackEnabled: true,
          isIos: true,
          httpsIosCallbackEnabled: false,
        );

        expect(selected.toString(), equals('org.stormlightlabs.lazurite:/oauth/callback'));
      });

      test('throws when no supported callback URI is present', () {
        expect(
          () => authRepository.selectOAuthRedirectUriTemplateForTest(
            const ['https://example.com/oauth/callback'],
            isAndroid: true,
            httpsAndroidCallbackEnabled: true,
            isIos: false,
            httpsIosCallbackEnabled: true,
          ),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('clearSession', () {
      test('should delete all accounts', () async {
        when(() => mockDatabase.deleteAllAccounts()).thenAnswer((_) async => 1);
        when(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).thenAnswer((_) async => 1);

        await authRepository.clearSession();

        verify(() => mockDatabase.deleteAllAccounts()).called(1);
        verify(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).called(1);
      });
    });

    group('logout', () {
      test('removes only the active account session', () async {
        final account = Account(
          did: 'did:plc:active',
          handle: 'active.bsky.social',
          service: null,
          oauthService: null,
          accessToken: 'access_token',
          refreshToken: null,
          dpopPublicKey: null,
          dpopPrivateKey: null,
          dpopNonce: null,
          displayName: 'Active User',
          expiresAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockDatabase.getActiveAccount()).thenAnswer((_) async => account);
        when(() => mockDatabase.deleteAccount(account.did)).thenAnswer((_) async => 1);
        when(
          () => mockDatabase.getSetting(AppDatabase.activeAccountDidSettingKey),
        ).thenAnswer((_) async => account.did);
        when(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).thenAnswer((_) async => 1);

        await authRepository.logout();

        verify(() => mockDatabase.getActiveAccount()).called(1);
        verify(() => mockDatabase.deleteAccount(account.did)).called(1);
        verify(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).called(1);
        verifyNever(() => mockDatabase.deleteAllAccounts());
      });

      test('clears stale active account setting when no active account exists', () async {
        when(() => mockDatabase.getActiveAccount()).thenAnswer((_) async => null);
        when(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).thenAnswer((_) async => 1);

        await authRepository.logout();

        verify(() => mockDatabase.getActiveAccount()).called(1);
        verify(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).called(1);
        verifyNever(() => mockDatabase.deleteAllAccounts());
        verifyNever(() => mockDatabase.deleteAccount(any()));
      });
    });

    group('oauth browser launch mode', () {
      test('uses external application on iOS', () {
        expect(
          AuthRepository.oauthLaunchModeForTest(isWeb: false, platform: TargetPlatform.iOS),
          equals(LaunchMode.externalApplication),
        );
      });

      test('uses external application on Android', () {
        expect(
          AuthRepository.oauthLaunchModeForTest(isWeb: false, platform: TargetPlatform.android),
          equals(LaunchMode.externalApplication),
        );
      });

      test('uses external application on non-mobile native platforms', () {
        expect(
          AuthRepository.oauthLaunchModeForTest(isWeb: false, platform: TargetPlatform.macOS),
          equals(LaunchMode.externalApplication),
        );
        expect(
          AuthRepository.oauthLaunchModeForTest(isWeb: false, platform: TargetPlatform.windows),
          equals(LaunchMode.externalApplication),
        );
      });

      test('uses platform default mode on web', () {
        expect(
          AuthRepository.oauthLaunchModeForTest(isWeb: true, platform: TargetPlatform.iOS),
          equals(LaunchMode.platformDefault),
        );
      });
    });

    group('oauth browser dismissal', () {
      test('dismisses in-app browser when close is supported', () async {
        var closeCalls = 0;
        var supportChecks = 0;
        authRepository = AuthRepository(
          database: mockDatabase,
          launchUrlWithMode: (_, _) async => true,
          supportsCloseForMode: (_) async {
            supportChecks += 1;
            return true;
          },
          closeInAppBrowser: () async {
            closeCalls += 1;
          },
        );

        await authRepository.dismissOAuthBrowserForTest(LaunchMode.inAppBrowserView);

        expect(supportChecks, equals(1));
        expect(closeCalls, equals(1));
      });

      test('does not attempt close for non in-app browser launch modes', () async {
        var closeCalls = 0;
        var supportChecks = 0;
        authRepository = AuthRepository(
          database: mockDatabase,
          launchUrlWithMode: (_, _) async => true,
          supportsCloseForMode: (_) async {
            supportChecks += 1;
            return true;
          },
          closeInAppBrowser: () async {
            closeCalls += 1;
          },
        );

        await authRepository.dismissOAuthBrowserForTest(LaunchMode.externalApplication);

        expect(supportChecks, equals(0));
        expect(closeCalls, equals(0));
      });
    });
  });
}

atcore.InvalidRequestException _invalidResolveHandleRequestException() {
  return atcore.InvalidRequestException(
    atcore.XRPCResponse(
      headers: const {},
      status: atcore.HttpStatus.badRequest,
      request: atcore.XRPCRequest(
        method: atcore.HttpMethod.get,
        url: Uri.https('bsky.social', '/xrpc/com.atproto.identity.resolveHandle'),
      ),
      rateLimit: atcore.RateLimit.unlimited(),
      data: const atcore.XRPCError(error: 'InvalidRequest', message: 'Could not resolve handle'),
    ),
  );
}

atcore.UnauthorizedException _unauthorizedRefreshException() {
  return atcore.UnauthorizedException(
    atcore.XRPCResponse(
      headers: const {},
      status: atcore.HttpStatus.unauthorized,
      request: atcore.XRPCRequest(
        method: atcore.HttpMethod.post,
        url: Uri.https('bsky.social', '/xrpc/com.atproto.server.refreshSession'),
      ),
      rateLimit: atcore.RateLimit.unlimited(),
      data: const atcore.XRPCError(error: 'ExpiredToken', message: 'Refresh token rejected'),
    ),
  );
}

OAuthClientMetadata _testClientMetadata() {
  return const OAuthClientMetadata(
    clientId: AuthRepository.kClientId,
    applicationType: 'native',
    clientName: 'Lazurite Test',
    clientUri: 'https://lazurite.stormlightlabs.org',
    redirectUris: ['https://lazurite.stormlightlabs.org/oauth/callback', 'org.stormlightlabs.lazurite:/oauth/callback'],
    responseTypes: ['code'],
    grantTypes: ['authorization_code', 'refresh_token'],
    scope: 'atproto',
    tokenEndpointAuthMethod: 'none',
  );
}

String _buildJwt({
  required String sub,
  required int expEpochSeconds,
  required int iatEpochSeconds,
  String? aud,
  String? iss,
}) {
  String encodePart(Map<String, Object?> value) {
    return base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  }

  final header = encodePart(const {'alg': 'none', 'typ': 'JWT'});
  final payload = encodePart({
    'sub': sub,
    'exp': expEpochSeconds,
    'iat': iatEpochSeconds,
    'aud': ?aud,
    'iss': ?iss,
    'scope': 'atproto',
  });

  return '$header.$payload.signature';
}
