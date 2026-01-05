import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/app/theme.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/search/application/search_providers.dart';
import 'package:lazurite/src/features/search/infrastructure/search_repository.dart';
import 'package:lazurite/src/features/splash/presentation/splash_screen.dart';
import 'package:lazurite/src/features/timeline/application/timeline_notifier.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/timeline_dao.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

class MockSessionStorage extends Mock implements SessionStorage {}

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late MockSessionStorage mockSessionStorage;
  late MockSearchRepository mockSearchRepository;
  late AppDatabase testDatabase;
  late Session testSession;

  setUp(() {
    mockSessionStorage = MockSessionStorage();
    mockSearchRepository = MockSearchRepository();
    testDatabase = createTestDatabase();
    testSession = Session(
      did: 'did:web:test',
      handle: 'handle',
      pdsUrl: 'https://pds',
      accessJwt: 'access',
      refreshJwt: 'refresh',
      scope: 'scope',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      dpopKey: {},
    );
    when(() => mockSessionStorage.getSession()).thenAnswer((_) async => testSession);
    when(() => mockSearchRepository.watchRecentSearches()).thenAnswer((_) => Stream.value([]));
  });

  tearDown(() async {
    await testDatabase.close();
  });

  List<Override> getTestOverrides() {
    return [
      sessionStorageProvider.overrideWithValue(mockSessionStorage),
      appDatabaseProvider.overrideWithValue(testDatabase),
      authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
      timelineProvider.overrideWith(() => _TestTimelineNotifier()),
      searchRepositoryProvider.overrideWithValue(mockSearchRepository),
    ];
  }

  group('Router', () {
    testWidgets('shows splash screen when loading', (tester) async {
      final overrides = getTestOverrides()
          .where((override) => override.origin != authProvider)
          .toList();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...overrides,
            authProvider.overrideWith(
              () => _TestAuthNotifier(testSession, initialState: const AuthState.loading()),
            ),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final appRouter = ref.watch(goRouterProvider);
              return MaterialApp.router(theme: AppTheme.dark, routerConfig: appRouter);
            },
          ),
        ),
      );
      await tester.pump(); // Pump one frame to let the router process
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('navigates to home on initial load', (tester) async {
      await tester.pumpRouterApp(overrides: getTestOverrides());
      expect(find.text('No posts yet'), findsOneWidget);
    });

    testWidgets('navigates between tabs preserving state', (tester) async {
      await tester.pumpRouterApp(overrides: getTestOverrides());

      expect(find.text('No posts yet'), findsOneWidget);

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.text('Search'), findsWidgets);

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();
      expect(find.text('Your notifications will appear here'), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('No posts yet'), findsOneWidget);
    });

    testWidgets('navigates to DMs tab', (tester) async {
      await tester.pumpRouterApp(overrides: getTestOverrides());

      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();

      expect(find.text('Direct Messages'), findsOneWidget);
    });

    testWidgets('navigates to Profile tab', (tester) async {
      await tester.pumpRouterApp(overrides: getTestOverrides());

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsWidgets);
    });
  });

  group('AppRoutes', () {
    test('has correct home path', () {
      expect(AppRoutes.home, '/home');
    });

    test('has correct search path', () {
      expect(AppRoutes.search, '/search');
    });

    test('has correct notifications path', () {
      expect(AppRoutes.notifications, '/notifications');
    });

    test('has correct dms path', () {
      expect(AppRoutes.dms, '/dms');
    });

    test('has correct profile path', () {
      expect(AppRoutes.profile, '/profile');
    });

    test('has correct thread detail path', () {
      expect(AppRoutes.thread, 't/:uri');
    });

    test('has correct profile detail path', () {
      expect(AppRoutes.profileDetail, 'u/:did');
    });

    test('has correct convo path', () {
      expect(AppRoutes.convo, 'c/:convoId');
    });
  });

  group('AppRouteNames', () {
    test('has correct home name', () {
      expect(AppRouteNames.home, 'home');
    });

    test('has correct search name', () {
      expect(AppRouteNames.search, 'search');
    });

    test('has correct notifications name', () {
      expect(AppRouteNames.notifications, 'notifications');
    });

    test('has correct dms name', () {
      expect(AppRouteNames.dms, 'dms');
    });

    test('has correct profile name', () {
      expect(AppRouteNames.profile, 'profile');
    });
  });
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._session, {this.initialState});
  final Session _session;
  final AuthState? initialState;

  @override
  AuthState build() {
    return initialState ?? AuthState.authenticated(_session);
  }
}

class _TestTimelineNotifier extends TimelineNotifier {
  @override
  Stream<List<TimelineFeedItem>> build() {
    return Stream.value([]);
  }
}
