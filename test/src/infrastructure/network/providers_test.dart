import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';
import 'package:lazurite/src/infrastructure/network/interceptors/auth_interceptor.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

class MockFeedContentDao extends Mock implements FeedContentDao {}

class TestAuthNotifier extends AuthNotifier {
  TestAuthNotifier(this._initialState, {this.refreshedSession});

  final AuthState _initialState;
  Session? refreshedSession;
  bool refreshInvoked = false;
  bool logoutInvoked = false;

  @override
  AuthState build() => _initialState;

  @override
  Future<Session?> refreshActiveSession() async {
    refreshInvoked = true;
    return refreshedSession;
  }

  @override
  Future<void> logout() async {
    logoutInvoked = true;
    state = const AuthState.unauthenticated();
  }
}

Session buildSession() {
  return Session(
    did: 'did:web:tester',
    handle: 'tester.bsky.social',
    pdsUrl: 'https://pds.bsky.social',
    accessJwt: 'access',
    refreshJwt: 'refresh',
    scope: 'scope',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
    dpopKey: const {'kty': 'EC', 'crv': 'P-256', 'x': 'x', 'y': 'y'},
  );
}

void main() {
  group('dioPublicProvider', () {
    test('creates Dio configured for public API', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final dio = container.read(dioPublicProvider);
      expect(dio.options.baseUrl, 'https://public.api.bsky.app');
    });
  });

  group('dioPdsProvider', () {
    late MockSessionStorage mockSessionStorage;
    late MockAppDatabase mockDatabase;
    late MockFeedContentDao mockFeedContentDao;

    setUp(() {
      mockSessionStorage = MockSessionStorage();
      mockDatabase = MockAppDatabase();
      mockFeedContentDao = MockFeedContentDao();

      when(() => mockSessionStorage.getSession()).thenAnswer((_) async => null);
      when(() => mockSessionStorage.clearSession()).thenAnswer((_) async {});
      when(() => mockDatabase.feedContentDao).thenReturn(mockFeedContentDao);
      when(() => mockFeedContentDao.clearFeedContent(any())).thenAnswer((_) async {});
    });

    test('returns null when user is not authenticated', () {
      final container = ProviderContainer(
        overrides: [
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
          authProvider.overrideWith(() => TestAuthNotifier(const AuthState.unauthenticated())),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(dioPdsProvider), isNull);
    });

    test('creates Dio bound to session PDS when authenticated', () async {
      final session = buildSession();
      final notifier = TestAuthNotifier(AuthState.authenticated(session));
      final container = ProviderContainer(
        overrides: [
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
          authProvider.overrideWith(() => notifier),
        ],
      );
      addTearDown(container.dispose);

      final dio = container.read(dioPdsProvider);
      expect(dio, isNotNull);
      expect(dio!.options.baseUrl, session.pdsUrl);

      final authInterceptor = dio.interceptors.whereType<AuthInterceptor>().single;
      expect(await authInterceptor.getSession(), equals(session));

      final refreshed = session.copyWith(accessJwt: 'new-token');
      notifier.refreshedSession = refreshed;

      final refreshedSession = await authInterceptor.refreshSession();
      expect(refreshedSession, equals(refreshed));
      expect(notifier.refreshInvoked, isTrue);
    });

    test('wires onSessionInvalidated to trigger logout and clear cache', () async {
      final session = buildSession();
      final notifier = TestAuthNotifier(AuthState.authenticated(session));
      final container = ProviderContainer(
        overrides: [
          sessionStorageProvider.overrideWithValue(mockSessionStorage),
          authProvider.overrideWith(() => notifier),
          appDatabaseProvider.overrideWithValue(mockDatabase),
        ],
      );
      addTearDown(container.dispose);

      final dio = container.read(dioPdsProvider);
      expect(dio, isNotNull);

      final authInterceptor = dio!.interceptors.whereType<AuthInterceptor>().single;

      authInterceptor.onSessionInvalidated?.call();

      await Future<void>.delayed(Duration.zero);

      expect(notifier.logoutInvoked, isTrue);
      verify(() => mockFeedContentDao.clearFeedContent('home')).called(1);
    });
  });
}
