import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/animation_controller.dart' as lazurite_anim;
import 'package:lazurite/src/app/app.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/app/theme_controller.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_cleanup_controller.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_providers.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/application/feed_sync_controller.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/features/search/application/search_providers.dart';
import 'package:lazurite/src/features/settings/application/preference_sync_controller.dart';
import 'package:lazurite/src/features/settings/domain/animation_preferences.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockSessionStorage mockSessionStorage;
  late MockSearchRepository mockSearchRepository;
  late MockAppDatabase mockDatabase;
  late MockProfileRepository mockProfileRepository;
  late MockFeedContentRepository mockFeedContentRepository;
  late Session testSession;

  setUp(() {
    mockSessionStorage = MockSessionStorage();
    mockSearchRepository = MockSearchRepository();
    mockDatabase = MockAppDatabase();
    mockProfileRepository = MockProfileRepository();
    mockFeedContentRepository = MockFeedContentRepository();
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
    when(() => mockProfileRepository.getProfile(any(), any())).thenAnswer(
      (_) async => ProfileData(
        did: 'did:web:test',
        handle: 'handle',
        displayName: 'Test User',
        viewerFollowing: false,
        followsCount: 0,
        followersCount: 0,
        postsCount: 0,
        indexedAt: DateTime.now(),
      ),
    );
    when(() => mockProfileRepository.watchProfile(any())).thenAnswer((_) => Stream.value(null));
    when(
      () => mockFeedContentRepository.watchFeedContent(
        ownerDid: any(named: 'ownerDid'),
        feedKey: any(named: 'feedKey'),
      ),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => mockFeedContentRepository.fetchAndCacheFeed(
        ownerDid: any(named: 'ownerDid'),
        feedUri: any(named: 'feedUri'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockFeedContentRepository.fetchAndCacheFeed(
        ownerDid: any(named: 'ownerDid'),
        cursor: any(named: 'cursor'),
        feedUri: any(named: 'feedUri'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockFeedContentRepository.getCursor(any(), any())).thenAnswer((_) async => null);
  });

  List<Override> getTestOverrides() {
    return [
      sessionStorageProvider.overrideWithValue(mockSessionStorage),
      appDatabaseProvider.overrideWithValue(mockDatabase),
      profileRepositoryProvider.overrideWithValue(mockProfileRepository),
      authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
      feedContentRepositoryProvider.overrideWithValue(mockFeedContentRepository),
      searchRepositoryProvider.overrideWithValue(mockSearchRepository),
      feedSyncControllerProvider.overrideWith((ref) {}),
      preferenceSyncControllerProvider.overrideWith((ref) {}),
      feedContentCleanupControllerProvider.overrideWith((ref) {}),
      pinnedFeedsProvider.overrideWith(() => MockPinnedFeedsNotifier()),
      activeFeedProvider.overrideWith(() => MockActiveFeed()),
      themeControllerProvider.overrideWith(MockThemeController.new),
      lazurite_anim.animationControllerProvider.overrideWith(MockAnimationController.new),
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

class MockActiveFeed extends ActiveFeed {
  @override
  String build() => 'home';
}

class MockPinnedFeedsNotifier extends PinnedFeedsNotifier {
  @override
  Stream<List<SavedFeedData>> build() => Stream.value([]);
}

/// Mock ThemeController that avoids ThemeFactory.buildThemeData()
/// which triggers Google Fonts loading.
class MockThemeController extends ThemeController {
  @override
  ThemeState build() {
    return ThemeState(
      themeMode: ThemeMode.dark,
      currentPackId: 'oxocarbon',
      lightTheme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
    );
  }
}

class MockAnimationController extends lazurite_anim.AnimationController {
  @override
  lazurite_anim.AnimationState build() => const lazurite_anim.AnimationState(
    preferences: AnimationPreferences(mode: AnimationMode.full, speedMultiplier: 1.0),
    isLoading: false,
  );
}
