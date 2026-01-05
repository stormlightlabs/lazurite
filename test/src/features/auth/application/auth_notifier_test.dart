import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/infrastructure/auth/auth_repository.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionStorage extends Mock implements SessionStorage {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSessionStorage mockSessionStorage;

  setUpAll(() {
    registerFallbackValue(
      Session(
        did: 'did:web:fallback',
        handle: 'fallback',
        pdsUrl: 'https://fallback.com',
        accessJwt: 'access',
        refreshJwt: 'refresh',
        scope: 'scope',
        expiresAt: DateTime.now(),
        dpopKey: {},
      ),
    );
    registerFallbackValue(Uri.parse('lazurite://callback'));
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSessionStorage = MockSessionStorage();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        sessionStorageProvider.overrideWithValue(mockSessionStorage),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AuthNotifier', () {
    test('initial state is loading then unauthenticated when no session', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);

      final container = createContainer();
      container.listen(authProvider, (previous, next) {});

      expect(container.read(authProvider), const AuthState.loading());

      await Future<void>.delayed(Duration.zero);

      expect(container.read(authProvider), const AuthState.unauthenticated());
    });

    test('initial state is authenticated when session exists', () async {
      final session = Session(
        did: 'did:web:example.com',
        handle: 'example.com',
        pdsUrl: 'https://example.com',
        accessJwt: 'access',
        refreshJwt: 'refresh',
        scope: 'scope',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        dpopKey: {},
      );

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => session);

      final container = createContainer();
      container.listen(authProvider, (previous, next) {});

      await Future<void>.delayed(Duration.zero);

      expect(container.read(authProvider), AuthState.authenticated(session));
    });

    test('login triggers repo login', () async {
      final testSession = Session(
        did: 'did:web:test.com',
        handle: 'test.com',
        pdsUrl: 'https://test.com',
        accessJwt: 'access',
        refreshJwt: 'refresh',
        scope: 'scope',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        dpopKey: {},
      );

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);
      when(() => mockAuthRepository.login(any())).thenAnswer((_) async => testSession);

      final container = createContainer();
      container.listen(authProvider, (previous, next) {});
      await Future<void>.delayed(Duration.zero);

      await container.read(authProvider.notifier).login('handle');

      await Future<void>.delayed(Duration.zero);
      expect(container.read(authProvider), AuthState.authenticated(testSession));
      verify(() => mockAuthRepository.login('handle')).called(1);
    });

    test('completeLogin updates state after OAuth callback', () async {
      final completedSession = Session(
        did: 'did:web:auth-callback',
        handle: 'auth-callback',
        pdsUrl: 'https://auth-callback',
        accessJwt: 'access',
        refreshJwt: 'refresh',
        scope: 'scope',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        dpopKey: {},
      );

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);
      when(
        () => mockAuthRepository.completeLogin(any()),
      ).thenAnswer((_) async => completedSession);

      final container = createContainer();
      container.listen(authProvider, (previous, next) {});
      await Future<void>.delayed(Duration.zero);

      final callbackUri = Uri.parse('app://callback?code=1234');
      await container.read(authProvider.notifier).completeLogin(callbackUri);

      await Future<void>.delayed(Duration.zero);
      expect(container.read(authProvider), AuthState.authenticated(completedSession));
      verify(() => mockAuthRepository.completeLogin(callbackUri)).called(1);
    });

    test('expired session triggers refresh', () async {
      final expiredSession = Session(
        did: 'did:web:expired',
        handle: 'expired.com',
        pdsUrl: 'https://expired.com',
        accessJwt: 'expired_access',
        refreshJwt: 'refresh_token',
        scope: 'scope',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 10)),
        dpopKey: {},
      );

      final refreshedSession = expiredSession.copyWith(
        accessJwt: 'new_access',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => expiredSession);
      when(
        () => mockAuthRepository.refreshSession(any()),
      ).thenAnswer((_) async => refreshedSession);

      final container = createContainer();
      container.listen(authProvider, (previous, next) {});

      await Future<void>.delayed(Duration.zero);

      verify(() => mockAuthRepository.refreshSession(expiredSession)).called(1);
      expect(container.read(authProvider), AuthState.authenticated(refreshedSession));
    });

    test('failed refresh clears session', () async {
      final expiredSession = Session(
        did: 'did:web:expired',
        handle: 'expired.com',
        pdsUrl: 'https://expired.com',
        accessJwt: 'expired_access',
        refreshJwt: 'refresh_token',
        scope: 'scope',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 10)),
        dpopKey: {},
      );

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => expiredSession);
      when(() => mockAuthRepository.refreshSession(any())).thenThrow(Exception('Refresh failed'));
      when(() => mockSessionStorage.clearSession()).thenAnswer((_) async {});

      final container = createContainer();
      container.listen(authProvider, (previous, next) {});

      await Future<void>.delayed(Duration.zero);

      verify(() => mockAuthRepository.refreshSession(expiredSession)).called(1);
      verify(() => mockSessionStorage.clearSession()).called(1);
      expect(container.read(authProvider), const AuthState.unauthenticated());
    });

    test('loginWithAppPassword triggers repo login', () async {
      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);
      when(() => mockAuthRepository.loginWithAppPassword(any(), any())).thenAnswer(
        (_) async => Session(
          did: 'did:web:example.com',
          handle: 'example.com',
          pdsUrl: 'https://example.com',
          accessJwt: 'access',
          refreshJwt: 'refresh',
          scope: 'scope',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          dpopKey: {},
        ),
      );

      final container = createContainer();
      container.listen(authProvider, (previous, next) {});
      await Future<void>.delayed(Duration.zero);

      await container.read(authProvider.notifier).loginWithAppPassword('handle', 'pass');

      expect(container.read(authProvider), isA<AuthStateAuthenticated>());
      await Future<void>.delayed(Duration.zero);
      verify(() => mockAuthRepository.loginWithAppPassword('handle', 'pass')).called(1);
    });

    test('logout revokes session and clears storage', () async {
      final session = Session(
        did: 'did:web:authed',
        handle: 'authed.com',
        pdsUrl: 'https://authed.com',
        accessJwt: 'access',
        refreshJwt: 'refresh',
        scope: 'scope',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        dpopKey: {},
      );

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => session);
      when(() => mockAuthRepository.revokeSession(any())).thenAnswer((_) async {});
      when(() => mockSessionStorage.clearSession()).thenAnswer((_) async {});

      final container = createContainer();
      container.listen(authProvider, (previous, next) {});
      await Future<void>.delayed(Duration.zero);

      expect(container.read(authProvider), AuthState.authenticated(session));

      await container.read(authProvider.notifier).logout();
      await Future<void>.delayed(Duration.zero);

      verify(() => mockAuthRepository.revokeSession(session)).called(1);
      verify(() => mockSessionStorage.clearSession()).called(1);
      expect(container.read(authProvider), const AuthState.unauthenticated());
    });
  });
}
