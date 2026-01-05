import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/app.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/application/feed_sync_controller.dart';
import 'package:lazurite/src/features/search/application/search_providers.dart';
import 'package:lazurite/src/features/search/infrastructure/search_repository.dart';
import 'package:lazurite/src/features/timeline/application/timeline_notifier.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/timeline_dao.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      feedSyncControllerProvider.overrideWith((ref) {}),
      pinnedFeedsProvider.overrideWith(() => MockPinnedFeedsNotifier()),
      activeFeedProvider.overrideWith(() => MockActiveFeed()),
    ];
  }

  group('App', () {
    testWidgets('boots and renders root scaffold', (tester) async {
      await tester.pumpWidget(ProviderScope(overrides: getTestOverrides(), child: const App()));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('displays all 5 navigation destinations', (tester) async {
      await tester.pumpWidget(ProviderScope(overrides: getTestOverrides(), child: const App()));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationDestination), findsNWidgets(5));

      expect(
        find.descendant(of: find.byType(NavigationBar), matching: find.text('Home')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(NavigationBar), matching: find.text('Search')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(NavigationBar), matching: find.text('Notifications')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(NavigationBar), matching: find.text('Messages')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(NavigationBar), matching: find.text('Profile')),
        findsOneWidget,
      );
    });

    testWidgets('starts on home screen', (tester) async {
      await tester.pumpWidget(ProviderScope(overrides: getTestOverrides(), child: const App()));
      await tester.pumpAndSettle();
      expect(find.text('No posts yet'), findsOneWidget);
    });

    testWidgets('uses dark theme by default', (tester) async {
      await tester.pumpWidget(ProviderScope(overrides: getTestOverrides(), child: const App()));
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);
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

class MockActiveFeed extends ActiveFeed {
  @override
  String build() => 'home';
}

class MockPinnedFeedsNotifier extends PinnedFeedsNotifier {
  @override
  Stream<List<SavedFeedData>> build() => Stream.value([]);
}
