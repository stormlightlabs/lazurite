import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/network/slingshot_client.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/shared/utils/test_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poptart_core/poptart_core.dart' as atcore;
import 'package:poptart_oauth/poptart_oauth.dart';
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

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  setUp(() {
    mockDatabase = MockAppDatabase();
    mockSlingshotClient = MockSlingshotClient();
    when(() => mockDatabase.getAccount(any())).thenAnswer((_) async => null);
    when(
      () => mockDatabase.acquireAuthRefreshLock(
        any(),
        owner: any(named: 'owner'),
        expiresAt: any(named: 'expiresAt'),
      ),
    ).thenAnswer((_) async => true);
    when(() => mockDatabase.isAuthRefreshLockActive(any())).thenAnswer((_) async => false);
    when(() => mockDatabase.releaseAuthRefreshLock(any(), owner: any(named: 'owner'))).thenAnswer((_) async => 1);
    when(
      () => mockDatabase.updateAccountSessionIfRefreshTokenMatches(
        any(),
        expectedRefreshToken: any(named: 'expectedRefreshToken'),
        handle: any(named: 'handle'),
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
        expiresAt: any(named: 'expiresAt'),
        displayName: any(named: 'displayName'),
        service: any(named: 'service'),
        oauthService: any(named: 'oauthService'),
        oauthClientId: any(named: 'oauthClientId'),
        dpopNonce: any(named: 'dpopNonce'),
        dpopPublicKey: any(named: 'dpopPublicKey'),
        dpopPrivateKey: any(named: 'dpopPrivateKey'),
      ),
    ).thenAnswer((_) async => false);
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
      test('coalesces concurrent refreshes for the same DID', () async {
        final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final refreshedAccessToken = buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds + 3600,
          iatEpochSeconds: nowEpochSeconds,
        );
        final refreshStarted = Completer<void>();
        final allowRefreshToComplete = Completer<void>();
        var refreshCalls = 0;
        authRepository = AuthRepository(
          database: mockDatabase,
          appPasswordRefreshSession: ({required String refreshJwt, String? service}) async {
            refreshCalls += 1;
            refreshStarted.complete();
            await allowRefreshToComplete.future;
            return _appPasswordRefreshResponse(
              did: 'did:plc:abc123',
              handle: 'user.bsky.social',
              accessJwt: refreshedAccessToken,
              refreshJwt: 'new-refresh-token',
            );
          },
        );

        const currentSession = AuthTokens(
          accessToken: 'expired-access-token',
          refreshToken: 'refresh-token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'bsky.social',
          authMethod: AuthMethod.appPassword,
        );

        when(
          () => mockDatabase.getAccount(currentSession.did),
        ).thenAnswer((_) async => _accountForTokens(currentSession));
        when(
          () => mockDatabase.getSetting(AppDatabase.activeAccountDidSettingKey),
        ).thenAnswer((_) async => currentSession.did);
        when(
          () => mockDatabase.updateAccountSessionIfRefreshTokenMatches(
            currentSession.did,
            expectedRefreshToken: currentSession.refreshToken!,
            handle: 'user.bsky.social',
            accessToken: refreshedAccessToken,
            refreshToken: 'new-refresh-token',
            expiresAt: any(named: 'expiresAt'),
            displayName: null,
            service: 'bsky.social',
            oauthService: null,
            oauthClientId: null,
            dpopNonce: null,
            dpopPublicKey: null,
            dpopPrivateKey: null,
          ),
        ).thenAnswer((_) async => true);

        final firstRefresh = authRepository.refreshSession(currentSession);
        await refreshStarted.future;
        final secondRefresh = authRepository.refreshSession(currentSession);
        allowRefreshToComplete.complete();

        final refreshed = await Future.wait([firstRefresh, secondRefresh]);

        expect(refreshCalls, equals(1));
        expect(refreshed.map((tokens) => tokens?.refreshToken), everyElement('new-refresh-token'));
      });

      test('returns newer stored session when caller holds stale refresh token', () async {
        authRepository = AuthRepository(
          database: mockDatabase,
          appPasswordRefreshSession: ({required String refreshJwt, String? service}) async =>
              throw StateError('stale refresh token should not be used'),
        );

        const currentSession = AuthTokens(
          accessToken: 'expired-access-token',
          refreshToken: 'stale-refresh-token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'bsky.social',
          authMethod: AuthMethod.appPassword,
        );
        final newerSession = AuthTokens(
          accessToken: 'new-access-token',
          refreshToken: 'new-refresh-token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'bsky.social',
          authMethod: AuthMethod.appPassword,
        );

        when(
          () => mockDatabase.getAccount(currentSession.did),
        ).thenAnswer((_) async => _accountForTokens(newerSession));

        final refreshed = await authRepository.refreshSession(currentSession);

        expect(refreshed, isNotNull);
        expect(refreshed!.refreshToken, equals('new-refresh-token'));
        verifyNever(
          () => mockDatabase.updateAccountSessionIfRefreshTokenMatches(
            any(),
            expectedRefreshToken: any(named: 'expectedRefreshToken'),
            handle: any(named: 'handle'),
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
            expiresAt: any(named: 'expiresAt'),
            displayName: any(named: 'displayName'),
            service: any(named: 'service'),
            oauthService: any(named: 'oauthService'),
            oauthClientId: any(named: 'oauthClientId'),
            dpopNonce: any(named: 'dpopNonce'),
            dpopPublicKey: any(named: 'dpopPublicKey'),
            dpopPrivateKey: any(named: 'dpopPrivateKey'),
          ),
        );
      });

      test('uses newer stored session when compare-and-swap persistence loses a token race', () async {
        final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final refreshedAccessToken = buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds + 3600,
          iatEpochSeconds: nowEpochSeconds,
        );
        authRepository = AuthRepository(
          database: mockDatabase,
          appPasswordRefreshSession: ({required String refreshJwt, String? service}) async {
            return _appPasswordRefreshResponse(
              did: 'did:plc:abc123',
              handle: 'user.bsky.social',
              accessJwt: refreshedAccessToken,
              refreshJwt: 'refresh-from-this-call',
            );
          },
        );

        const currentSession = AuthTokens(
          accessToken: 'expired-access-token',
          refreshToken: 'old-refresh-token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'bsky.social',
          authMethod: AuthMethod.appPassword,
        );
        final newerSession = AuthTokens(
          accessToken: 'newer-access-token',
          refreshToken: 'newer-refresh-token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'bsky.social',
          authMethod: AuthMethod.appPassword,
        );
        var getAccountCalls = 0;
        when(() => mockDatabase.getAccount(currentSession.did)).thenAnswer((_) async {
          getAccountCalls += 1;
          return getAccountCalls == 1 ? _accountForTokens(currentSession) : _accountForTokens(newerSession);
        });
        when(
          () => mockDatabase.getSetting(AppDatabase.activeAccountDidSettingKey),
        ).thenAnswer((_) async => currentSession.did);
        when(
          () => mockDatabase.updateAccountSessionIfRefreshTokenMatches(
            any(),
            expectedRefreshToken: any(named: 'expectedRefreshToken'),
            handle: any(named: 'handle'),
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
            expiresAt: any(named: 'expiresAt'),
            displayName: any(named: 'displayName'),
            service: any(named: 'service'),
            oauthService: any(named: 'oauthService'),
            oauthClientId: any(named: 'oauthClientId'),
            dpopNonce: any(named: 'dpopNonce'),
            dpopPublicKey: any(named: 'dpopPublicKey'),
            dpopPrivateKey: any(named: 'dpopPrivateKey'),
          ),
        ).thenAnswer((_) async => false);

        final refreshed = await authRepository.refreshSession(currentSession);

        expect(refreshed, isNotNull);
        expect(refreshed!.refreshToken, equals('newer-refresh-token'));
        verifyNever(() => mockDatabase.insertAccount(any()));
      });

      test('does not resurrect account when it is removed before refreshed tokens are persisted', () async {
        final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final refreshedAccessToken = buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds + 3600,
          iatEpochSeconds: nowEpochSeconds,
        );
        authRepository = AuthRepository(
          database: mockDatabase,
          appPasswordRefreshSession: ({required String refreshJwt, String? service}) async {
            return _appPasswordRefreshResponse(
              did: 'did:plc:abc123',
              handle: 'user.bsky.social',
              accessJwt: refreshedAccessToken,
              refreshJwt: 'new-refresh-token',
            );
          },
        );

        const currentSession = AuthTokens(
          accessToken: 'expired-access-token',
          refreshToken: 'old-refresh-token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'bsky.social',
          authMethod: AuthMethod.appPassword,
        );
        var getAccountCalls = 0;
        when(() => mockDatabase.getAccount(currentSession.did)).thenAnswer((_) async {
          getAccountCalls += 1;
          return getAccountCalls == 1 ? _accountForTokens(currentSession) : null;
        });
        when(
          () => mockDatabase.getSetting(AppDatabase.activeAccountDidSettingKey),
        ).thenAnswer((_) async => currentSession.did);
        when(
          () => mockDatabase.updateAccountSessionIfRefreshTokenMatches(
            any(),
            expectedRefreshToken: any(named: 'expectedRefreshToken'),
            handle: any(named: 'handle'),
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
            expiresAt: any(named: 'expiresAt'),
            displayName: any(named: 'displayName'),
            service: any(named: 'service'),
            oauthService: any(named: 'oauthService'),
            oauthClientId: any(named: 'oauthClientId'),
            dpopNonce: any(named: 'dpopNonce'),
            dpopPublicKey: any(named: 'dpopPublicKey'),
            dpopPrivateKey: any(named: 'dpopPrivateKey'),
          ),
        ).thenAnswer((_) async => false);

        await expectLater(authRepository.refreshSession(currentSession), throwsA(isA<Exception>()));

        verifyNever(() => mockDatabase.insertAccount(any()));
        verifyNever(() => mockDatabase.setSetting(AppDatabase.activeAccountDidSettingKey, any()));
      });

      test('uses tokens refreshed by another worker while persistent refresh lock is held', () async {
        authRepository = AuthRepository(
          database: mockDatabase,
          appPasswordRefreshSession: ({required String refreshJwt, String? service}) async =>
              throw StateError('refresh should be handled by the lock holder'),
        );

        const currentSession = AuthTokens(
          accessToken: 'expired-access-token',
          refreshToken: 'old-refresh-token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'bsky.social',
          authMethod: AuthMethod.appPassword,
        );

        final newerSession = AuthTokens(
          accessToken: 'new-access-token',
          refreshToken: 'new-refresh-token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'bsky.social',
          authMethod: AuthMethod.appPassword,
        );
        when(
          () => mockDatabase.acquireAuthRefreshLock(
            any(),
            owner: any(named: 'owner'),
            expiresAt: any(named: 'expiresAt'),
          ),
        ).thenAnswer((_) async => false);
        when(
          () => mockDatabase.getAccount(currentSession.did),
        ).thenAnswer((_) async => _accountForTokens(newerSession));

        final refreshed = await authRepository.refreshSession(currentSession);

        expect(refreshed, isNotNull);
        expect(refreshed!.refreshToken, 'new-refresh-token');
        verifyNever(
          () => mockDatabase.updateAccountSessionIfRefreshTokenMatches(
            any(),
            expectedRefreshToken: any(named: 'expectedRefreshToken'),
            handle: any(named: 'handle'),
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
            expiresAt: any(named: 'expiresAt'),
            displayName: any(named: 'displayName'),
            service: any(named: 'service'),
            oauthService: any(named: 'oauthService'),
            oauthClientId: any(named: 'oauthClientId'),
            dpopNonce: any(named: 'dpopNonce'),
            dpopPublicKey: any(named: 'dpopPublicKey'),
            dpopPrivateKey: any(named: 'dpopPrivateKey'),
          ),
        );
      });

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

        when(
          () => mockDatabase.getAccount(currentSession.did),
        ).thenAnswer((_) async => _accountForTokens(currentSession));
        when(() => mockDatabase.deleteAccount(currentSession.did)).thenAnswer((_) async => 1);
        when(
          () => mockDatabase.getSetting(AppDatabase.activeAccountDidSettingKey),
        ).thenAnswer((_) async => currentSession.did);
        when(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).thenAnswer((_) async => 1);

        await expectLater(authRepository.refreshSession(currentSession), throwsA(isA<Exception>()));

        verify(() => mockDatabase.deleteAccount(currentSession.did)).called(1);
        verify(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).called(1);
      });

      test('does not invalidate account when rejected refresh token is already stale', () async {
        authRepository = AuthRepository(
          database: mockDatabase,
          appPasswordRefreshSession: ({required String refreshJwt, String? service}) async =>
              throw _unauthorizedRefreshException(),
        );

        const currentSession = AuthTokens(
          accessToken: 'expired-access-token',
          refreshToken: 'stale-refresh-token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'bsky.social',
          authMethod: AuthMethod.appPassword,
        );
        const newerSession = AuthTokens(
          accessToken: 'new-access-token',
          refreshToken: 'new-refresh-token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          service: 'bsky.social',
          authMethod: AuthMethod.appPassword,
        );

        when(
          () => mockDatabase.getAccount(currentSession.did),
        ).thenAnswer((_) async => _accountForTokens(newerSession));

        final refreshed = await authRepository.refreshSession(currentSession);

        expect(refreshed, isNotNull);
        expect(refreshed!.refreshToken, equals('new-refresh-token'));
        verifyNever(() => mockDatabase.deleteAccount(any()));
        verifyNever(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey));
      });
    });

    group('oauth refresh', () {
      test('orders issuer host before stored auth host and deduplicates candidates', () {
        final candidates = AuthRepository.oauthRefreshServiceCandidates(
          storedAuthService: 'https://bsky.social',
          issuer: 'https://bsky.social',
        );

        expect(candidates, equals(['bsky.social']));
      });

      test('uses stored oauth auth host when issuer is unavailable', () {
        final candidates = AuthRepository.oauthRefreshServiceCandidates(
          storedAuthService: 'https://oauth.custom.example',
          issuer: null,
        );

        expect(candidates, equals(['oauth.custom.example', 'bsky.social']));
      });

      test('retries OAuth refresh against fallback auth service hosts', () async {
        final attemptedServices = <String>[];
        final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final expiredAccessToken = buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds - 3600,
          iatEpochSeconds: nowEpochSeconds - 7200,
          aud: 'did:web:porcini.us-east.host.bsky.network',
        );
        final refreshedAccessToken = buildJwt(
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
        when(
          () => mockDatabase.updateAccountSessionIfRefreshTokenMatches(
            any(),
            expectedRefreshToken: any(named: 'expectedRefreshToken'),
            handle: any(named: 'handle'),
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
            expiresAt: any(named: 'expiresAt'),
            displayName: any(named: 'displayName'),
            service: any(named: 'service'),
            oauthService: any(named: 'oauthService'),
            oauthClientId: any(named: 'oauthClientId'),
            dpopNonce: any(named: 'dpopNonce'),
            dpopPublicKey: any(named: 'dpopPublicKey'),
            dpopPrivateKey: any(named: 'dpopPrivateKey'),
          ),
        ).thenAnswer((_) async => true);

        final refreshed = await authRepository.refreshSession(sessionWithJwt);

        expect(refreshed, isNotNull);
        expect(refreshed!.did, equals(currentSession.did));
        expect(attemptedServices, equals(['porcini.us-east.host.bsky.network', 'bsky.social']));
        expect(refreshed.oauthService, equals('bsky.social'));
        verifyNever(() => mockDatabase.deleteAccount(any()));
        verifyNever(() => mockDatabase.insertAccount(any()));
      });

      test('preserves stored nullable OAuth fields when refresh does not re-fetch them', () async {
        final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final expiredAccessToken = buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds - 3600,
          iatEpochSeconds: nowEpochSeconds - 7200,
          aud: 'did:web:porcini.us-east.host.bsky.network',
          iss: 'https://bsky.social',
        );
        final refreshedAccessToken = buildJwt(
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

        final currentSession = AuthTokens(
          accessToken: expiredAccessToken,
          refreshToken: 'refresh-token',
          did: 'did:plc:abc123',
          handle: 'user.bsky.social',
          displayName: 'Stored User',
          service: 'porcini.us-east.host.bsky.network',
          oauthService: 'bsky.social',
          oauthClientId: AuthRepository.kClientId,
          dpopNonce: 'old-nonce',
          dpopPublicKey: 'public-key',
          dpopPrivateKey: 'private-key',
          authMethod: AuthMethod.oauth,
        );

        when(
          () => mockDatabase.getSetting(AppDatabase.activeAccountDidSettingKey),
        ).thenAnswer((_) async => currentSession.did);
        when(
          () => mockDatabase.updateAccountSessionIfRefreshTokenMatches(
            currentSession.did,
            expectedRefreshToken: currentSession.refreshToken!,
            handle: currentSession.handle,
            accessToken: refreshedAccessToken,
            refreshToken: currentSession.refreshToken!,
            expiresAt: any(named: 'expiresAt'),
            displayName: currentSession.displayName,
            service: currentSession.service,
            oauthService: currentSession.oauthService,
            oauthClientId: currentSession.oauthClientId,
            dpopNonce: 'new-nonce',
            dpopPublicKey: currentSession.dpopPublicKey,
            dpopPrivateKey: currentSession.dpopPrivateKey,
          ),
        ).thenAnswer((_) async => true);

        final refreshed = await authRepository.refreshSession(currentSession);

        expect(refreshed, isNotNull);
        expect(refreshed!.refreshToken, equals('refresh-token'));
        expect(refreshed.displayName, equals('Stored User'));
        expect(refreshed.service, equals('porcini.us-east.host.bsky.network'));
        expect(refreshed.oauthClientId, equals(AuthRepository.kClientId));
        expect(refreshed.dpopNonce, equals('new-nonce'));
        verifyNever(() => mockDatabase.insertAccount(any()));
      });

      test('loads OAuth refresh metadata using stored oauthClientId', () async {
        final requestedClientIds = <String>[];
        final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final expiredAccessToken = buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds - 3600,
          iatEpochSeconds: nowEpochSeconds - 7200,
          aud: 'did:web:porcini.us-east.host.bsky.network',
          iss: 'https://northsky.social',
        );
        final refreshedAccessToken = buildJwt(
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
        when(
          () => mockDatabase.updateAccountSessionIfRefreshTokenMatches(
            any(),
            expectedRefreshToken: any(named: 'expectedRefreshToken'),
            handle: any(named: 'handle'),
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
            expiresAt: any(named: 'expiresAt'),
            displayName: any(named: 'displayName'),
            service: any(named: 'service'),
            oauthService: any(named: 'oauthService'),
            oauthClientId: any(named: 'oauthClientId'),
            dpopNonce: any(named: 'dpopNonce'),
            dpopPublicKey: any(named: 'dpopPublicKey'),
            dpopPrivateKey: any(named: 'dpopPrivateKey'),
          ),
        ).thenAnswer((_) async => true);

        final refreshed = await authRepository.refreshSession(sessionWithJwt);

        expect(refreshed, isNotNull);
        expect(requestedClientIds, equals(['https://northsky.social/oauth/client-metadata.json']));
      });

      test('falls back to default client id when stored oauthClientId is blank', () async {
        final requestedClientIds = <String>[];
        final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final expiredAccessToken = buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds - 3600,
          iatEpochSeconds: nowEpochSeconds - 7200,
          aud: 'did:web:porcini.us-east.host.bsky.network',
          iss: 'https://northsky.social',
        );
        final refreshedAccessToken = buildJwt(
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
        when(
          () => mockDatabase.updateAccountSessionIfRefreshTokenMatches(
            any(),
            expectedRefreshToken: any(named: 'expectedRefreshToken'),
            handle: any(named: 'handle'),
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
            expiresAt: any(named: 'expiresAt'),
            displayName: any(named: 'displayName'),
            service: any(named: 'service'),
            oauthService: any(named: 'oauthService'),
            oauthClientId: any(named: 'oauthClientId'),
            dpopNonce: any(named: 'dpopNonce'),
            dpopPublicKey: any(named: 'dpopPublicKey'),
            dpopPrivateKey: any(named: 'dpopPrivateKey'),
          ),
        ).thenAnswer((_) async => true);

        final refreshed = await authRepository.refreshSession(sessionWithJwt);

        expect(refreshed, isNotNull);
        expect(requestedClientIds, equals([AuthRepository.kClientId]));
      });

      test('preserves account when OAuth refresh fails transiently', () async {
        final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final expiredAccessToken = buildJwt(
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
        final expiredAccessToken = buildJwt(
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

        when(
          () => mockDatabase.getAccount(currentSession.did),
        ).thenAnswer((_) async => _accountForTokens(currentSession));
        when(() => mockDatabase.deleteAccount(currentSession.did)).thenAnswer((_) async => 1);
        when(
          () => mockDatabase.getSetting(AppDatabase.activeAccountDidSettingKey),
        ).thenAnswer((_) async => currentSession.did);
        when(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).thenAnswer((_) async => 1);

        await expectLater(authRepository.refreshSession(currentSession), throwsA(isA<Exception>()));

        verify(() => mockDatabase.deleteAccount(currentSession.did)).called(1);
        verify(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).called(1);
      });

      test('does not invalidate OAuth account when rejected refresh token is already stale', () async {
        final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final expiredAccessToken = buildJwt(
          sub: 'did:plc:abc123',
          expEpochSeconds: nowEpochSeconds - 3600,
          iatEpochSeconds: nowEpochSeconds - 7200,
          aud: 'did:web:porcini.us-east.host.bsky.network',
          iss: 'https://bsky.social',
        );
        final newerAccessToken = buildJwt(
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
                throw const OAuthException('{"error":"invalid_grant"}');
              },
        );

        final currentSession = AuthTokens(
          accessToken: expiredAccessToken,
          refreshToken: 'stale-refresh-token',
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
        final newerSession = currentSession.copyWith(
          accessToken: newerAccessToken,
          refreshToken: 'new-refresh-token',
          dpopNonce: 'new-nonce',
        );

        when(
          () => mockDatabase.getAccount(currentSession.did),
        ).thenAnswer((_) async => _accountForTokens(newerSession));

        final refreshed = await authRepository.refreshSession(currentSession);

        expect(refreshed, isNotNull);
        expect(refreshed!.refreshToken, equals('new-refresh-token'));
        verifyNever(() => mockDatabase.deleteAccount(any()));
        verifyNever(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey));
      });

      test('does not invalidate when only fallback OAuth candidates reject credentials', () async {
        final attemptedServices = <String>[];
        final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final expiredAccessToken = buildJwt(
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
      test('prioritizes resolved auth service, then preferred auth hosts, before PDS fallback', () {
        final candidates = AuthRepository.oauthAuthorizeServiceCandidates(
          preferredAuthService: 'blacksky.community',
          resolvedPdsHost: 'https://porcini.us-east.host.bsky.network',
          resolvedAuthService: 'https://bsky.social',
        );

        expect(candidates, equals(['bsky.social', 'blacksky.community', 'porcini.us-east.host.bsky.network']));
      });

      test('deduplicates when preferred and resolved hosts match defaults', () {
        final candidates = AuthRepository.oauthAuthorizeServiceCandidates(
          preferredAuthService: 'https://bsky.social',
          resolvedPdsHost: 'bsky.social',
          resolvedAuthService: 'bsky.social',
        );

        expect(candidates, equals(['bsky.social']));
      });
    });

    group('oauth callback exchange service', () {
      test('uses callback issuer when present', () {
        final service = AuthRepository.oauthCallbackExchangeService(
          pendingService: 'porcini.us-east.host.bsky.network',
          callbackUri: Uri.parse(
            'https://lazurite.stormlightlabs.org/oauth/callback?code=abc&state=xyz&iss=https%3A%2F%2Fbsky.social',
          ),
        );

        expect(service, equals('bsky.social'));
      });

      test('falls back to pending auth service when callback has no issuer', () {
        final service = AuthRepository.oauthCallbackExchangeService(
          pendingService: 'https://auth.example.com',
          callbackUri: Uri.parse('org.stormlightlabs.lazurite:/oauth/callback?code=abc&state=xyz'),
        );

        expect(service, equals('auth.example.com'));
      });

      test('redeems callback with issuer host when it differs from launched auth service', () async {
        final authorizeServices = <String>[];
        final callbackServices = <String>[];
        final launchedUrls = <Uri>[];

        authRepository = AuthRepository(
          database: mockDatabase,
          loadClientMetadata: (_) async => _testClientMetadata(),
          oauthServiceResolver: () => 'pending-auth.example',
          resolveHandleDid: (_) async => 'did:plc:alice',
          resolveDidDocument: (_) async => const {
            'service': [
              {
                'id': '#atproto_pds',
                'type': 'AtprotoPersonalDataServer',
                'serviceEndpoint': 'https://porcini.us-east.host.bsky.network',
              },
            ],
          },
          resolveAuthorizationServiceForPdsHost: (_) async => null,
          launchUrlWithMode: (url, _) async {
            launchedUrls.add(url);
            return true;
          },
          oauthAuthorizeSession: (client, identity) async {
            authorizeServices.add(client.service);
            expect(identity, equals('alice.bsky.social'));
            return (
              Uri.https(client.service, '/oauth/authorize', const {'request_uri': 'urn:request'}),
              const OAuthContext(codeVerifier: 'verifier', state: 'state', dpopNonce: 'nonce'),
            );
          },
          oauthCallbackSession: (client, callbackUrl, context) async {
            callbackServices.add(client.service);
            expect(context.state, equals('state'));
            expect(Uri.parse(callbackUrl).queryParameters['code'], equals('abc'));
            return OAuthSession(
              accessToken: 'access',
              refreshToken: 'refresh',
              tokenType: 'DPoP',
              scope: 'atproto',
              expiresAt: DateTime.now().add(const Duration(hours: 1)),
              sub: 'did:plc:alice',
              $dPoPNonce: 'next-nonce',
              $publicKey: 'public-key',
              $privateKey: 'private-key',
            );
          },
          oauthTokenBuilder:
              (
                session, {
                required fallbackHandle,
                required fallbackPdsHost,
                required oauthService,
                oauthClientId,
              }) async => AuthTokens(
                accessToken: session.accessToken,
                refreshToken: session.refreshToken,
                expiresAt: session.expiresAt,
                did: session.sub,
                handle: fallbackHandle,
                service: fallbackPdsHost,
                oauthService: oauthService,
                oauthClientId: oauthClientId,
                dpopNonce: session.$dPoPNonce,
                dpopPublicKey: session.$publicKey,
                dpopPrivateKey: session.$privateKey,
                authMethod: AuthMethod.oauth,
              ),
        );
        when(() => mockDatabase.insertAccount(any())).thenAnswer((_) async => 1);
        when(
          () => mockDatabase.setSetting(AppDatabase.activeAccountDidSettingKey, 'did:plc:alice'),
        ).thenAnswer((_) async => 1);

        final loginFuture = authRepository.loginWithOAuth('alice.bsky.social');
        await Future<void>.delayed(Duration.zero);

        expect(authorizeServices, equals(['pending-auth.example']));
        expect(launchedUrls, hasLength(1));

        final handled = await authRepository.completeOAuthCallbackFromUri(
          Uri.parse(
            'https://lazurite.stormlightlabs.org/oauth/callback?code=abc&state=state&iss=https%3A%2F%2Fbsky.social',
          ),
        );

        expect(handled, isTrue);
        final tokens = await loginFuture;

        expect(callbackServices, equals(['bsky.social']));
        expect(tokens, isNotNull);
        expect(tokens!.oauthService, equals('bsky.social'));
        verify(() => mockDatabase.insertAccount(any())).called(1);
        verify(() => mockDatabase.setSetting(AppDatabase.activeAccountDidSettingKey, 'did:plc:alice')).called(1);
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

        expect(() => authRepository.resolveServiceForIdentifier('alice.bsky.social'), throwsA(isA<Exception>()));
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

        final service = await authRepository.resolveServiceForIdentifier('alice.bsky.social');

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
              contains('Enter a full handle like username.bsky.social'),
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

        final service = await authRepository.resolveServiceForIdentifier('DID:PLC:ABC123');
        expect(service, equals('pds.example'));
      });

      test('fails fast for incomplete did identifiers', () async {
        await expectLater(
          authRepository.loginWithOAuth('did:web:'),
          throwsA(
            isA<AuthIdentifierResolutionException>().having(
              (error) => error.toString(),
              'message',
              contains('Enter a complete DID like did:plc:... or did:web:...'),
            ),
          ),
        );
      });
    });

    group('oauth callback normalization', () {
      test('accepts canonical custom scheme callback URI', () {
        final normalized = authRepository.normalizeOAuthCallbackUri(
          Uri.parse('org.stormlightlabs.lazurite:/oauth/callback?code=abc&state=xyz'),
        );

        expect(normalized, isNotNull);
        expect(normalized!.scheme, equals('org.stormlightlabs.lazurite'));
        expect(normalized.path, equals('/oauth/callback'));
      });

      test('normalizes path-only callback URI to canonical custom scheme', () {
        final normalized = authRepository.normalizeOAuthCallbackUri(Uri.parse('/oauth/callback?code=abc&state=xyz'));

        expect(normalized, isNotNull);
        expect(normalized!.toString(), equals('org.stormlightlabs.lazurite:/oauth/callback?code=abc&state=xyz'));
      });

      test('normalizes authority-style custom scheme callback URI to canonical custom scheme', () {
        final normalized = authRepository.normalizeOAuthCallbackUri(
          Uri.parse('org.stormlightlabs.lazurite://oauth/callback?code=abc&state=xyz'),
        );

        expect(normalized, isNotNull);
        expect(normalized!.toString(), equals('org.stormlightlabs.lazurite:/oauth/callback?code=abc&state=xyz'));
      });

      test('normalizes compatibility callback path to canonical custom scheme', () {
        final normalized = authRepository.normalizeOAuthCallbackUri(Uri.parse('/callback?code=abc&state=xyz'));

        expect(normalized, isNotNull);
        expect(normalized!.toString(), equals('org.stormlightlabs.lazurite:/oauth/callback?code=abc&state=xyz'));
      });

      test('rejects path-only callback without oauth response parameters', () {
        final normalized = authRepository.normalizeOAuthCallbackUri(Uri.parse('/callback?foo=bar'));

        expect(normalized, isNull);
      });

      test('accepts exact HTTPS callback URI with oauth query parameters', () {
        final normalized = authRepository.normalizeOAuthCallbackUri(
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

      test('accepts hosted HTTPS callback URI after static host trailing slash redirect', () {
        final normalized = authRepository.normalizeOAuthCallbackUri(
          Uri.parse(
            'https://lazurite.stormlightlabs.org/oauth/callback/?code=abc&state=xyz&iss=https%3A%2F%2Fbsky.social',
          ),
        );

        expect(normalized, isNotNull);
        expect(normalized!.scheme, equals('https'));
        expect(normalized.host, equals('lazurite.stormlightlabs.org'));
        expect(normalized.path, equals('/oauth/callback/'));
        expect(normalized.queryParameters['code'], equals('abc'));
        expect(normalized.queryParameters['state'], equals('xyz'));
      });

      test('rejects HTTPS callback URI with unexpected host', () {
        final normalized = authRepository.normalizeOAuthCallbackUri(
          Uri.parse('https://example.com/oauth/callback?code=abc&state=xyz'),
        );

        expect(normalized, isNull);
      });

      test('rejects HTTPS callback URI with unexpected path', () {
        final normalized = authRepository.normalizeOAuthCallbackUri(
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

        final firstResult = authRepository.runOAuthCallbackExchangeOnce(
          Uri.parse('org.stormlightlabs.lazurite:/oauth/callback?code=abc&state=xyz'),
          exchange,
        );
        final secondResult = authRepository.runOAuthCallbackExchangeOnce(
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
      test('uses custom scheme callback by default on Android login', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        var sawAuthorize = false;
        authRepository = AuthRepository(
          database: mockDatabase,
          loadClientMetadata: (_) async => _testClientMetadata(),
          oauthServiceResolver: () => 'bsky.social',
          resolveHandleDid: (_) async => 'did:plc:alice',
          resolveDidDocument: (_) async => const {
            'service': [
              {
                'id': '#atproto_pds',
                'type': 'AtprotoPersonalDataServer',
                'serviceEndpoint': 'https://bsky.social',
              },
            ],
          },
          resolveAuthorizationServiceForPdsHost: (_) async => null,
          oauthAuthorizeSession: (client, identity) async {
            sawAuthorize = true;
            expect(client.metadata.redirectUris, equals(['org.stormlightlabs.lazurite:/oauth/callback']));
            throw const OAuthException('stop after redirect assertion');
          },
        );

        await expectLater(authRepository.loginWithOAuth('alice.bsky.social'), throwsA(isA<Exception>()));
        expect(sawAuthorize, isTrue);
      });

      test('prefers HTTPS callback on Android when flag is enabled', () {
        final selected = authRepository.selectOAuthRedirectUriTemplate(
          const ['org.stormlightlabs.lazurite:/oauth/callback', 'https://lazurite.stormlightlabs.org/oauth/callback'],
          isAndroid: true,
          httpsAndroidCallbackEnabled: true,
          isIos: false,
          httpsIosCallbackEnabled: true,
        );

        expect(selected.toString(), equals('https://lazurite.stormlightlabs.org/oauth/callback'));
      });

      test('uses custom scheme callback on Android when HTTPS flag is disabled', () {
        final selected = authRepository.selectOAuthRedirectUriTemplate(
          const ['org.stormlightlabs.lazurite:/oauth/callback', 'https://lazurite.stormlightlabs.org/oauth/callback'],
          isAndroid: true,
          httpsAndroidCallbackEnabled: false,
          isIos: false,
          httpsIosCallbackEnabled: true,
        );

        expect(selected.toString(), equals('org.stormlightlabs.lazurite:/oauth/callback'));
      });

      test('uses custom scheme callback when HTTPS callback is unavailable', () {
        final selected = authRepository.selectOAuthRedirectUriTemplate(
          const ['org.stormlightlabs.lazurite:/oauth/callback'],
          isAndroid: true,
          httpsAndroidCallbackEnabled: true,
          isIos: false,
          httpsIosCallbackEnabled: true,
        );

        expect(selected.toString(), equals('org.stormlightlabs.lazurite:/oauth/callback'));
      });

      test('uses HTTPS callback when custom scheme callback is unavailable', () {
        final selected = authRepository.selectOAuthRedirectUriTemplate(
          const ['https://lazurite.stormlightlabs.org/oauth/callback'],
          isAndroid: true,
          httpsAndroidCallbackEnabled: true,
          isIos: false,
          httpsIosCallbackEnabled: true,
        );

        expect(selected.toString(), equals('https://lazurite.stormlightlabs.org/oauth/callback'));
      });

      test('prefers HTTPS callback on iOS when flag is enabled', () {
        final selected = authRepository.selectOAuthRedirectUriTemplate(
          const ['org.stormlightlabs.lazurite:/oauth/callback', 'https://lazurite.stormlightlabs.org/oauth/callback'],
          isAndroid: false,
          httpsAndroidCallbackEnabled: true,
          isIos: true,
          httpsIosCallbackEnabled: true,
        );

        expect(selected.toString(), equals('https://lazurite.stormlightlabs.org/oauth/callback'));
      });

      test('uses custom scheme callback on iOS when HTTPS flag is disabled', () {
        final selected = authRepository.selectOAuthRedirectUriTemplate(
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
          () => authRepository.selectOAuthRedirectUriTemplate(
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
      test('clears the active account marker without deleting saved accounts', () async {
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
        verify(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).called(1);
        verifyNever(() => mockDatabase.deleteAccount(any()));
        verifyNever(() => mockDatabase.deleteAllAccounts());
      });

      test('clears the active account marker when no active account exists', () async {
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
          AuthRepository.oauthLaunchModeForPlatform(isWeb: false, platform: TargetPlatform.iOS),
          equals(LaunchMode.externalApplication),
        );
      });

      test('uses external application on Android', () {
        expect(
          AuthRepository.oauthLaunchModeForPlatform(isWeb: false, platform: TargetPlatform.android),
          equals(LaunchMode.externalApplication),
        );
      });

      test('uses external application on non-mobile native platforms', () {
        expect(
          AuthRepository.oauthLaunchModeForPlatform(isWeb: false, platform: TargetPlatform.macOS),
          equals(LaunchMode.externalApplication),
        );
        expect(
          AuthRepository.oauthLaunchModeForPlatform(isWeb: false, platform: TargetPlatform.windows),
          equals(LaunchMode.externalApplication),
        );
      });

      test('uses platform default mode on web', () {
        expect(
          AuthRepository.oauthLaunchModeForPlatform(isWeb: true, platform: TargetPlatform.iOS),
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

        await authRepository.dismissOAuthBrowserForLaunchMode(LaunchMode.inAppBrowserView);

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

        await authRepository.dismissOAuthBrowserForLaunchMode(LaunchMode.externalApplication);

        expect(supportChecks, equals(0));
        expect(closeCalls, equals(0));
      });
    });
  });
}

atcore.InvalidRequestException _invalidResolveHandleRequestException() => atcore.InvalidRequestException(
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

atcore.UnauthorizedException _unauthorizedRefreshException() => atcore.UnauthorizedException(
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

atcore.XRPCResponse<atcore.Session> _appPasswordRefreshResponse({
  required String did,
  required String handle,
  required String accessJwt,
  required String refreshJwt,
}) => atcore.XRPCResponse(
  headers: const {},
  status: atcore.HttpStatus.ok,
  request: atcore.XRPCRequest(
    method: atcore.HttpMethod.post,
    url: Uri.https('bsky.social', '/xrpc/com.atproto.server.refreshSession'),
  ),
  rateLimit: atcore.RateLimit.unlimited(),
  data: atcore.Session(did: did, handle: handle, accessJwt: accessJwt, refreshJwt: refreshJwt),
);

OAuthClientMetadata _testClientMetadata() => const OAuthClientMetadata(
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

Account _accountForTokens(AuthTokens tokens) => Account(
  did: tokens.did,
  handle: tokens.handle,
  service: tokens.service,
  oauthService: tokens.oauthService,
  oauthClientId: tokens.oauthClientId,
  accessToken: tokens.accessToken,
  refreshToken: tokens.refreshToken,
  dpopPublicKey: tokens.dpopPublicKey,
  dpopPrivateKey: tokens.dpopPrivateKey,
  dpopNonce: tokens.dpopNonce,
  displayName: tokens.displayName,
  expiresAt: tokens.expiresAt,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
