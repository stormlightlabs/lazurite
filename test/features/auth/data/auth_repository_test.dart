import 'dart:convert';

import 'package:atproto_oauth/atproto_oauth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_launcher/url_launcher.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class FakeAccountsCompanion extends Fake implements AccountsCompanion {}

void main() {
  late AuthRepository authRepository;
  late MockAppDatabase mockDatabase;

  setUpAll(() {
    registerFallbackValue(FakeAccountsCompanion());
  });

  setUp(() {
    mockDatabase = MockAppDatabase();
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
      test('should clear session', () async {
        when(() => mockDatabase.getActiveAccount()).thenAnswer((_) async => null);
        when(() => mockDatabase.deleteAllAccounts()).thenAnswer((_) async => 1);
        when(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).thenAnswer((_) async => 1);

        await authRepository.logout();

        verify(() => mockDatabase.getActiveAccount()).called(1);
        verify(() => mockDatabase.deleteAllAccounts()).called(1);
        verify(() => mockDatabase.deleteSetting(AppDatabase.activeAccountDidSettingKey)).called(1);
      });
    });

    group('callback server', () {
      test('builds a callback page that can return to the app', () {
        final html = authRepository.buildCallbackPageHtmlForTest();

        expect(html, contains('lazurite://auth-complete'));
        expect(html, contains('Return to Lazurite'));
        expect(html, contains('id="reopen-link"'));
        expect(html, contains('window.location.assign'));
        expect(html, contains('visibilitychange'));
      });

      test('can stop the callback server twice without throwing', () async {
        final redirectUri = await authRepository.startCallbackServerForTest(Uri.parse('http://127.0.0.1/callback'));

        expect(redirectUri.host, equals('127.0.0.1'));
        expect(authRepository.callbackPort, greaterThan(0));

        await authRepository.stopCallbackServerForTest();
        expect(authRepository.callbackPort, equals(0));

        await authRepository.stopCallbackServerForTest();
        expect(authRepository.callbackPort, equals(0));
      });
    });

    group('oauth browser launch mode', () {
      test('uses in-app browser view on mobile', () {
        expect(
          AuthRepository.oauthLaunchModeForTest(isWeb: false, platform: TargetPlatform.iOS),
          equals(LaunchMode.inAppBrowserView),
        );
        expect(
          AuthRepository.oauthLaunchModeForTest(isWeb: false, platform: TargetPlatform.android),
          equals(LaunchMode.inAppBrowserView),
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

OAuthClientMetadata _testClientMetadata() {
  return const OAuthClientMetadata(
    clientId: AuthRepository.kClientId,
    applicationType: 'native',
    clientName: 'Lazurite Test',
    clientUri: 'https://lazurite.stormlightlabs.org',
    redirectUris: ['http://127.0.0.1/callback'],
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
