import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/animation_controller.dart' as lazurite_anim;
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/app/theme.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/composer/application/composer_notifier.dart';
import 'package:lazurite/src/features/composer/application/composer_providers.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/composer/infrastructure/draft_repository.dart';
import 'package:lazurite/src/features/composer/presentation/screens/composer_screen.dart';
import 'package:lazurite/src/features/composer/presentation/screens/draft_list_screen.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_cleanup_controller.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_providers.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/application/feed_sync_controller.dart';
import 'package:lazurite/src/features/profile/application/profile_providers.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/features/search/application/search_providers.dart';
import 'package:lazurite/src/features/settings/domain/animation_preferences.dart';
import 'package:lazurite/src/features/splash/presentation/splash_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../helpers/mocks.dart';
import '../../helpers/pump_app.dart';

void main() {
  late MockSessionStorage mockSessionStorage;
  late MockSearchRepository mockSearchRepository;
  late MockProfileRepository mockProfileRepository;
  late MockAppDatabase mockDatabase;
  late MockFeedContentRepository mockFeedContentRepository;
  late Session testSession;

  setUp(() {
    mockSessionStorage = MockSessionStorage();
    mockSearchRepository = MockSearchRepository();
    mockProfileRepository = MockProfileRepository();
    mockDatabase = MockAppDatabase();
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
    when(() => mockProfileRepository.getProfile(any())).thenAnswer(
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

    when(
      () => mockFeedContentRepository.watchFeedContent(feedKey: any(named: 'feedKey')),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => mockFeedContentRepository.fetchAndCacheFeed(feedUri: any(named: 'feedUri')),
    ).thenAnswer((_) async {});
    when(
      () => mockFeedContentRepository.fetchAndCacheFeed(
        cursor: any(named: 'cursor'),
        feedUri: any(named: 'feedUri'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockFeedContentRepository.getCursor(any())).thenAnswer((_) async => null);
  });

  List<Override> getTestOverrides() {
    return [
      sessionStorageProvider.overrideWithValue(mockSessionStorage),
      appDatabaseProvider.overrideWithValue(mockDatabase),
      profileRepositoryProvider.overrideWithValue(mockProfileRepository),
      feedContentRepositoryProvider.overrideWithValue(mockFeedContentRepository),
      searchRepositoryProvider.overrideWithValue(mockSearchRepository),
      draftRepositoryProvider.overrideWithValue(MockDraftRepository()),
      feedSyncControllerProvider.overrideWith((ref) {}),
      feedContentCleanupControllerProvider.overrideWith((ref) {}),
      pinnedFeedsProvider.overrideWith(() => MockPinnedFeedsNotifier()),
      activeFeedProvider.overrideWith(() => MockActiveFeed()),
      draftsProvider.overrideWith((ref) => Stream.value([])),
      lazurite_anim.animationControllerProvider.overrideWith(MockAnimationController.new),
    ];
  }

  group('Router', () {
    testWidgets('shows splash screen when loading', (tester) async {
      final overrides = [
        ...getTestOverrides(),
        authProvider.overrideWith(
          () => _TestAuthNotifier(testSession, initialState: const AuthState.loading()),
        ),
      ];
      expect(overrides.where((override) => override.origin == authProvider).length, 1);

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: Consumer(
            builder: (context, ref, _) {
              final appRouter = ref.watch(goRouterProvider);
              return MaterialApp.router(theme: AppTheme.dark, routerConfig: appRouter);
            },
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('navigates to home after splash timer and auth complete', (tester) async {
      final container = ProviderContainer(
        overrides: [
          ...getTestOverrides(),
          authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              final appRouter = ref.watch(goRouterProvider);
              return MaterialApp.router(theme: AppTheme.dark, routerConfig: appRouter);
            },
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('No posts yet'), findsOneWidget);
    });

    testWidgets('navigates to home on initial load', (tester) async {
      await tester.pumpRouterApp(
        overrides: [
          ...getTestOverrides(),
          authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
        ],
      );
      expect(find.text('No posts yet'), findsOneWidget);
    });

    testWidgets('navigates between tabs preserving state', (tester) async {
      await tester.pumpRouterApp(
        overrides: [
          ...getTestOverrides(),
          authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
        ],
      );

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
      await tester.pumpRouterApp(
        overrides: [
          ...getTestOverrides(),
          authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
        ],
      );

      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();

      expect(find.text('Direct Messages'), findsOneWidget);
    });

    testWidgets('navigates to Profile tab', (tester) async {
      await tester.pumpRouterApp(
        overrides: [
          ...getTestOverrides(),
          authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
        ],
      );

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('redirects unauthenticated user from search to landing', (tester) async {
      final container = ProviderContainer(
        overrides: [
          ...getTestOverrides(),
          authProvider.overrideWith(
            () => _TestAuthNotifier(testSession, initialState: const AuthState.unauthenticated()),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              final appRouter = ref.watch(goRouterProvider);
              return MaterialApp.router(theme: AppTheme.dark, routerConfig: appRouter);
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Lazurite'), findsOneWidget);
      expect(find.text('A beautiful Bluesky client'), findsOneWidget);

      final router = container.read(goRouterProvider);
      router.go('/search');
      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.uri.path, equals('/landing'));
      expect(find.text('Lazurite'), findsOneWidget);
    });

    testWidgets('navigates to compose with parameters', (tester) async {
      await tester.pumpRouterApp(
        overrides: [
          ...getTestOverrides(),
          authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
          composerProvider.overrideWith(MockComposerNotifier.new),
        ],
        theme: ThemeData.dark(),
      );

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final router = app.routerConfig as GoRouter;

      unawaited(router.push('/compose?draftId=123&replyTo=at://reply&quoteTo=at://quote'));
      await tester.pumpAndSettle();

      expect(find.byType(ComposerScreen), findsOneWidget);
      final screen = tester.widget<ComposerScreen>(find.byType(ComposerScreen));
      expect(screen.draftId, '123');
      expect(screen.replyTo, 'at://reply');
      expect(screen.quoteTo, 'at://quote');
    });

    testWidgets('navigates to drafts screen', (tester) async {
      await tester.pumpRouterApp(
        overrides: [
          ...getTestOverrides(),
          authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
        ],
      );

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final router = app.routerConfig as GoRouter;

      unawaited(router.push('/drafts'));
      await tester.pumpAndSettle();

      expect(find.byType(DraftListScreen), findsOneWidget);
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

class MockActiveFeed extends ActiveFeed {
  @override
  String build() => 'home';
}

class MockPinnedFeedsNotifier extends PinnedFeedsNotifier {
  @override
  Stream<List<SavedFeedData>> build() => Stream.value([]);
}

class MockDraftRepository extends Mock implements DraftRepository {
  MockDraftRepository() {
    when(
      () => createDraft(
        replyParentUri: any(named: 'replyParentUri'),
        quoteUri: any(named: 'quoteUri'),
      ),
    ).thenAnswer(
      (_) async => Draft(
        id: '123',
        text: '',
        status: DraftStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        media: [],
      ),
    );

    when(() => getDraft(any())).thenAnswer(
      (_) async => Draft(
        id: '123',
        text: '',
        status: DraftStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        media: [],
      ),
    );
  }
}

class MockComposerNotifier extends ComposerNotifier {
  @override
  Future<ComposerState> build(ComposerArgs? args) async {
    return ComposerState(
      draft: Draft(
        id: args?.draftId ?? '123',
        text: '',
        status: DraftStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        media: [],
        replyParentUri: args?.replyTo,
        quoteUri: args?.quoteTo,
      ),
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
