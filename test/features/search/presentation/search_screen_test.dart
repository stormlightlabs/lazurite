import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
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

    testWidgets('displays search input and tabs', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Search posts or people'), findsOneWidget);
      expect(find.text('Posts'), findsOneWidget);
      expect(find.text('People'), findsOneWidget);
      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Latest'), findsOneWidget);
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

    testWidgets('sort toggle changes correctly', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final latestButton = find.text('Latest');
      await tester.tap(latestButton);
      await tester.pumpAndSettle();
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
  });
}
