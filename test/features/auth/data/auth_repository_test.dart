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
          launchUrlWithMode: (_, __) async => true,
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
          launchUrlWithMode: (_, __) async => true,
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
