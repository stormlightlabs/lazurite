import 'package:atproto_core/atproto_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
import 'package:lazurite/features/search/bloc/search_bloc.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:lazurite/features/search/presentation/search_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

class MockFeedPreferencesCubit extends MockCubit<FeedPreferencesState> implements FeedPreferencesCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(const SavedFeedType.knownValue(data: KnownSavedFeedType.feed));
  });

  group('SearchScreen', () {
    late MockSearchRepository mockSearchRepository;
    late MockAppDatabase mockDatabase;
    late MockConnectivityCubit connectivityCubit;
    late MockFeedPreferencesCubit feedPreferencesCubit;

    setUp(() {
      mockSearchRepository = MockSearchRepository();
      mockDatabase = MockAppDatabase();
      connectivityCubit = MockConnectivityCubit();
      feedPreferencesCubit = MockFeedPreferencesCubit();
      when(() => connectivityCubit.state).thenReturn(const ConnectivityState.online());
      whenListen(
        connectivityCubit,
        const Stream<ConnectivityState>.empty(),
        initialState: const ConnectivityState.online(),
      );
      when(() => feedPreferencesCubit.state).thenReturn(const FeedPreferencesState.loaded(feeds: []));
      whenListen(
        feedPreferencesCubit,
        const Stream<FeedPreferencesState>.empty(),
        initialState: const FeedPreferencesState.loaded(feeds: []),
      );
      when(
        () => feedPreferencesCubit.addFeed(
          type: any(named: 'type'),
          value: any(named: 'value'),
          pinned: any(named: 'pinned'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockDatabase.getSearchHistory(any(), limit: any(named: 'limit'))).thenAnswer((_) async => []);
      when(
        () => mockSearchRepository.searchPosts(
          query: any(named: 'query'),
          sort: any(named: 'sort'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchPostsResult(posts: []));
      when(
        () => mockSearchRepository.searchActors(
          query: any(named: 'query'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchActorsResult(actors: []));
      when(
        () => mockSearchRepository.searchActorsTypeahead(
          query: any(named: 'query'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);
      when(
        () => mockSearchRepository.searchStarterPacks(
          query: any(named: 'query'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchStarterPacksResult(starterPacks: []));
      when(
        () => mockSearchRepository.searchFeedGenerators(
          query: any(named: 'query'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchFeedsResult(feeds: []));
    });

    Widget buildSubject() {
      return MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<SearchBloc>(
              create: (_) => SearchBloc(
                searchRepository: mockSearchRepository,
                database: mockDatabase,
                accountDid: 'did:plc:test',
              ),
            ),
            BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
            BlocProvider<FeedPreferencesCubit>.value(value: feedPreferencesCubit),
          ],
          child: const SearchScreen(),
        ),
      );
    }

    Widget buildRoutedSubject() {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => BlocProvider<SearchBloc>(
              create: (_) => SearchBloc(
                searchRepository: mockSearchRepository,
                database: mockDatabase,
                accountDid: 'did:plc:test',
              ),
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
                  BlocProvider<FeedPreferencesCubit>.value(value: feedPreferencesCubit),
                ],
                child: const SearchScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/profile/view',
            builder: (context, state) => Scaffold(body: Text('profile:${state.uri.queryParameters['actor']}')),
          ),
          GoRoute(
            path: '/feeds',
            builder: (context, state) => const Scaffold(body: Text('feeds-page')),
          ),
        ],
      );

      return MaterialApp.router(routerConfig: router);
    }

    testWidgets('displays search input and tabs', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Search posts or people'), findsOneWidget);
      expect(find.text('Posts'), findsOneWidget);
      expect(find.text('People'), findsOneWidget);
      expect(find.text('Feeds'), findsOneWidget);
      expect(find.text('Top'), findsNothing);
      expect(find.text('Latest'), findsNothing);
    });

    testWidgets('shows empty state when no search history', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Search'), findsOneWidget);
      expect(find.textContaining('Find posts and people'), findsOneWidget);
    });

    testWidgets('tab switching works correctly', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final peopleTab = find.text('People');
      await tester.tap(peopleTab);
      await tester.pumpAndSettle();

      final postsTab = find.text('Posts');
      await tester.tap(postsTab);
      await tester.pumpAndSettle();
    });

    testWidgets('sort toggle shows when there are results', (tester) async {
      reset(mockSearchRepository);

      final samplePost = PostView(
        uri: AtUri.parse('at://did:plc:test/app.bsky.feed.post/1'),
        cid: 'cid-1',
        author: const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social'),
        record: {r'$type': 'app.bsky.feed.post', 'text': 'Test post', 'createdAt': DateTime.now().toIso8601String()},
        indexedAt: DateTime.now(),
      );

      when(
        () => mockSearchRepository.searchPosts(
          query: any(named: 'query'),
          sort: any(named: 'sort'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchPostsResult(posts: [samplePost], hitsTotal: 1));

      when(
        () => mockSearchRepository.searchActors(
          query: any(named: 'query'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchActorsResult(actors: []));

      when(
        () => mockSearchRepository.searchActorsTypeahead(
          query: any(named: 'query'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);

      when(() => mockDatabase.getSearchHistory(any(), limit: any(named: 'limit'))).thenAnswer((_) async => []);
      when(
        () => mockDatabase.addSearchHistoryEntry(
          query: any(named: 'query'),
          type: any(named: 'type'),
          accountDid: any(named: 'accountDid'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<SearchBloc>(
                create: (_) => SearchBloc(
                  searchRepository: mockSearchRepository,
                  database: mockDatabase,
                  accountDid: 'did:plc:test',
                ),
              ),
              BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
              BlocProvider<FeedPreferencesCubit>.value(value: feedPreferencesCubit),
            ],
            child: const SearchScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'test query');
      await tester.pumpAndSettle();

      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Latest'), findsOneWidget);
    });

    testWidgets('shows search history when available', (tester) async {
      final historyEntry = SearchHistoryEntry(
        id: 1,
        query: 'flutter',
        type: 'posts',
        searchedAt: DateTime.now(),
        accountDid: 'did:plc:test',
      );

      when(
        () => mockDatabase.getSearchHistory(any(), limit: any(named: 'limit')),
      ).thenAnswer((_) async => [historyEntry]);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<SearchBloc>(
                create: (_) => SearchBloc(
                  searchRepository: mockSearchRepository,
                  database: mockDatabase,
                  accountDid: 'did:plc:test',
                ),
              ),
              BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
              BlocProvider<FeedPreferencesCubit>.value(value: feedPreferencesCubit),
            ],
            child: const SearchScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recent Searches'), findsOneWidget);
      expect(find.text('flutter'), findsOneWidget);
    });

    testWidgets('shows jump to profile FAB and opens the handle dialog', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Jump to profile'), findsOneWidget);

      await tester.tap(find.text('Jump to profile'));
      await tester.pumpAndSettle();

      expect(find.text('Jump to profile'), findsNWidgets(2));
      expect(find.text('Handle'), findsOneWidget);
    });

    testWidgets('jump to profile dialog hides typing hint after more than 3 characters', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Jump to profile'));
      await tester.pumpAndSettle();

      expect(find.text('Start typing to search handles.'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'rive');
      await tester.pumpAndSettle();

      expect(find.text('Start typing to search handles.'), findsNothing);
    });

    testWidgets('jump to profile dialog shows typeahead suggestions and navigates on selection', (tester) async {
      when(
        () => mockSearchRepository.searchActorsTypeahead(
          query: any(named: 'query'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const [
          ProfileViewBasic(did: 'did:plc:river', handle: 'river.bsky.social', displayName: 'River Tam'),
        ],
      );

      await tester.pumpWidget(buildRoutedSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Jump to profile'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'river');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('River Tam'), findsOneWidget);

      await tester.tap(find.text('River Tam'));
      await tester.pumpAndSettle();

      expect(find.text('profile:did:plc:river'), findsOneWidget);
    });

    testWidgets('main search input with @ does not show autocomplete results', (tester) async {
      when(
        () => mockSearchRepository.searchActorsTypeahead(
          query: any(named: 'query'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const [
          ProfileViewBasic(did: 'did:plc:river', handle: 'river.bsky.social', displayName: 'River Tam'),
        ],
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '@river');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('River Tam'), findsNothing);
    });

    testWidgets('jump to profile dialog navigates on enter', (tester) async {
      await tester.pumpWidget(buildRoutedSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Jump to profile'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'custom.bsky.social');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('profile:custom.bsky.social'), findsOneWidget);
    });

    testWidgets('third Starter Packs tab renders', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Starter Packs'), findsOneWidget);
    });

    testWidgets('switching to Starter Packs tab shows empty state when no results', (tester) async {
      when(
        () => mockDatabase.addSearchHistoryEntry(
          query: any(named: 'query'),
          type: any(named: 'type'),
          accountDid: any(named: 'accountDid'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Starter Packs'));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'starter');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('No starter packs found'), findsOneWidget);
    });

    testWidgets('feed tab shows search results and adds a feed with snackbar action', (tester) async {
      final sampleFeed = GeneratorView(
        uri: AtUri.parse('at://did:plc:feed/app.bsky.feed.generator/whats-hot'),
        cid: 'cid-feed',
        did: 'did:web:feed.example.com',
        creator: ProfileView(
          did: 'did:plc:creator',
          handle: 'creator.bsky.social',
          indexedAt: DateTime.utc(2026, 1, 1),
        ),
        displayName: 'What\'s Hot',
        indexedAt: DateTime.utc(2026, 1, 1),
      );

      when(
        () => mockSearchRepository.searchFeedGenerators(
          query: any(named: 'query'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchFeedsResult(feeds: [sampleFeed]));

      when(
        () => mockDatabase.addSearchHistoryEntry(
          query: any(named: 'query'),
          type: any(named: 'type'),
          accountDid: any(named: 'accountDid'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(buildRoutedSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Feeds'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'hot');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('What\'s Hot'), findsOneWidget);
      expect(find.text('+ Add'), findsOneWidget);

      await tester.tap(find.text('+ Add'));
      await tester.pumpAndSettle();

      verify(
        () => feedPreferencesCubit.addFeed(
          type: const SavedFeedType.knownValue(data: KnownSavedFeedType.feed),
          value: sampleFeed.uri.toString(),
          pinned: false,
        ),
      ).called(1);
      expect(find.text('Added What\'s Hot to your saved feeds'), findsOneWidget);

      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();
      expect(find.text('feeds-page'), findsOneWidget);
    });

    testWidgets('starter pack results display name and creator handle', (tester) async {
      final samplePack = StarterPackViewBasic(
        uri: AtUri.parse('at://did:plc:creator/app.bsky.graph.starterpack/pack-1'),
        cid: 'cid-pack-1',
        record: const {
          r'$type': 'app.bsky.graph.starterpack',
          'name': 'My Starter Pack',
          'list': 'at://did:plc:creator/app.bsky.graph.list/list-1',
          'createdAt': '2026-01-01T00:00:00.000Z',
        },
        creator: const ProfileViewBasic(did: 'did:plc:creator', handle: 'creator.bsky.social'),
        listItemCount: 10,
        joinedWeekCount: 3,
        joinedAllTimeCount: 42,
        indexedAt: DateTime.utc(2026, 1, 1),
      );

      when(
        () => mockSearchRepository.searchStarterPacks(
          query: any(named: 'query'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchStarterPacksResult(starterPacks: [samplePack]));

      when(
        () => mockDatabase.addSearchHistoryEntry(
          query: any(named: 'query'),
          type: any(named: 'type'),
          accountDid: any(named: 'accountDid'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Starter Packs'));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'starter');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('My Starter Pack'), findsOneWidget);
      expect(find.text('by @creator.bsky.social'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('tapping starter pack result navigates to starter pack detail', (tester) async {
      final packUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.starterpack/pack-1');
      final samplePack = StarterPackViewBasic(
        uri: packUri,
        cid: 'cid-pack-1',
        record: const {
          r'$type': 'app.bsky.graph.starterpack',
          'name': 'My Starter Pack',
          'list': 'at://did:plc:creator/app.bsky.graph.list/list-1',
          'createdAt': '2026-01-01T00:00:00.000Z',
        },
        creator: const ProfileViewBasic(did: 'did:plc:creator', handle: 'creator.bsky.social'),
        indexedAt: DateTime.utc(2026, 1, 1),
      );

      when(
        () => mockSearchRepository.searchStarterPacks(
          query: any(named: 'query'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => SearchStarterPacksResult(starterPacks: [samplePack]));

      when(
        () => mockDatabase.addSearchHistoryEntry(
          query: any(named: 'query'),
          type: any(named: 'type'),
          accountDid: any(named: 'accountDid'),
        ),
      ).thenAnswer((_) async {});

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => BlocProvider<SearchBloc>(
              create: (_) => SearchBloc(
                searchRepository: mockSearchRepository,
                database: mockDatabase,
                accountDid: 'did:plc:test',
              ),
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
                  BlocProvider<FeedPreferencesCubit>.value(value: feedPreferencesCubit),
                ],
                child: const SearchScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/starter-pack',
            builder: (context, state) => Scaffold(body: Text('starterpack:${state.uri.queryParameters['uri']}')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Starter Packs'));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'starter');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      await tester.tap(find.text('My Starter Pack'));
      await tester.pumpAndSettle();

      expect(find.text('starterpack:${packUri.toString()}'), findsOneWidget);
    });
  });
}
