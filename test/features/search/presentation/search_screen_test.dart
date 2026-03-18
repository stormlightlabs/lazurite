import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/search/bloc/search_bloc.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:lazurite/features/search/presentation/search_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  group('SearchScreen', () {
    late MockSearchRepository mockSearchRepository;
    late MockAppDatabase mockDatabase;

    setUp(() {
      mockSearchRepository = MockSearchRepository();
      mockDatabase = MockAppDatabase();
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
    });

    Widget buildSubject() {
      return MaterialApp(
        home: BlocProvider<SearchBloc>(
          create: (_) =>
              SearchBloc(searchRepository: mockSearchRepository, database: mockDatabase, accountDid: 'did:plc:test'),
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
              child: const SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/profile/view',
            builder: (context, state) => Scaffold(body: Text('profile:${state.uri.queryParameters['actor']}')),
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
          home: BlocProvider<SearchBloc>(
            create: (_) =>
                SearchBloc(searchRepository: mockSearchRepository, database: mockDatabase, accountDid: 'did:plc:test'),
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
          home: BlocProvider<SearchBloc>(
            create: (_) =>
                SearchBloc(searchRepository: mockSearchRepository, database: mockDatabase, accountDid: 'did:plc:test'),
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
  });
}
