import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/timeline/application/timeline_notifier.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/timeline_dao.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

class MockSessionStorage extends Mock implements SessionStorage {}

void main() {
  late MockSessionStorage mockSessionStorage;
  late AppDatabase testDatabase;
  late Session testSession;

  setUp(() {
    mockSessionStorage = MockSessionStorage();
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
  });

  tearDown(() async {
    await testDatabase.close();
  });

  List<Override> getTestOverrides() {
    return [
      sessionStorageProvider.overrideWithValue(mockSessionStorage),
      appDatabaseProvider.overrideWithValue(testDatabase),
      authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
      // Override timeline to return empty list immediately
      timelineProvider.overrideWith(() => _TestTimelineNotifier()),
    ];
  }

  group('Router', () {
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

      expect(find.text('Your Profile'), findsOneWidget);
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
  _TestAuthNotifier(this._session);
  final Session _session;

  @override
  AuthState build() {
    return AuthState.authenticated(_session);
  }
}

class _TestTimelineNotifier extends TimelineNotifier {
  @override
  Stream<List<TimelineFeedItem>> build() {
    return Stream.value([]);
  }
}
