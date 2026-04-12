import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/search/cubit/semantic_index_cubit.dart';
import 'package:lazurite/features/search/cubit/semantic_search_cubit.dart';
import 'package:lazurite/features/search/data/semantic_search_repository.dart';
import 'package:lazurite/features/search/data/semantic_search_result.dart';
import 'package:lazurite/features/search/presentation/semantic_search_tab.dart';
import 'package:mocktail/mocktail.dart';

class MockSemanticSearchRepository extends Mock implements SemanticSearchRepository {}

class MockPostActionRepository extends Mock implements PostActionRepository {}

class MockSemanticSearchCubit extends MockCubit<SemanticSearchState> implements SemanticSearchCubit {}

class MockSemanticIndexCubit extends MockCubit<SemanticIndexState> implements SemanticIndexCubit {}

const _accountDid = 'did:plc:testuser';

const _result1 = SemanticSearchResult(
  postUri: 'at://did:plc:a/app.bsky.feed.post/1',
  score: 82.0,
  source: 'saved',
  postJson: '{}',
);

const _result2 = SemanticSearchResult(
  postUri: 'at://did:plc:b/app.bsky.feed.post/2',
  score: 48.0,
  source: 'liked',
  postJson: '{}',
);

void main() {
  setUpAll(() {
    registerFallbackValue(SearchScope.both);
  });

  late MockSemanticSearchCubit searchCubit;
  late MockSemanticIndexCubit indexCubit;
  late MockPostActionRepository postActionRepository;

  setUp(() {
    searchCubit = MockSemanticSearchCubit();
    indexCubit = MockSemanticIndexCubit();
    postActionRepository = MockPostActionRepository();

    when(() => searchCubit.state).thenReturn(const SemanticSearchState());
    whenListen(searchCubit, const Stream<SemanticSearchState>.empty(), initialState: const SemanticSearchState());
    when(() => indexCubit.state).thenReturn(const SemanticIndexState());
    whenListen(indexCubit, const Stream<SemanticIndexState>.empty(), initialState: const SemanticIndexState());
  });

  Widget buildSubject() {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PostActionRepository>.value(value: postActionRepository),
        RepositoryProvider<PostActionCache>(create: (_) => PostActionCache()),
        RepositoryProvider<String>.value(value: _accountDid),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SemanticSearchCubit>.value(value: searchCubit),
          BlocProvider<SemanticIndexCubit>.value(value: indexCubit),
        ],
        child: const MaterialApp(home: Scaffold(body: SemanticSearchTab())),
      ),
    );
  }

  group('SemanticSearchTab', () {
    testWidgets('shows empty query state when no query entered', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Search by meaning'), findsOneWidget);
      expect(find.text('Search your saved and liked posts by meaning, not just keywords'), findsOneWidget);
    });

    testWidgets('shows unavailable state when embedding service is unavailable', (tester) async {
      when(() => searchCubit.state).thenReturn(const SemanticSearchState(status: SemanticSearchStatus.unavailable));
      whenListen(
        searchCubit,
        const Stream<SemanticSearchState>.empty(),
        initialState: const SemanticSearchState(status: SemanticSearchStatus.unavailable),
      );
      await tester.pumpWidget(buildSubject());
      expect(find.text('Semantic search unavailable'), findsOneWidget);
    });

    testWidgets('shows loading indicator while searching', (tester) async {
      when(() => searchCubit.state).thenReturn(const SemanticSearchState(status: SemanticSearchStatus.searching));
      whenListen(
        searchCubit,
        const Stream<SemanticSearchState>.empty(),
        initialState: const SemanticSearchState(status: SemanticSearchStatus.searching),
      );
      await tester.pumpWidget(buildSubject());
      expect(find.byType(CircularProgressIndicator), findsAtLeast(1));
    });

    testWidgets('shows no results state when search yields empty list', (tester) async {
      when(
        () => searchCubit.state,
      ).thenReturn(const SemanticSearchState(status: SemanticSearchStatus.loaded, results: [], query: 'rust'));
      whenListen(
        searchCubit,
        const Stream<SemanticSearchState>.empty(),
        initialState: const SemanticSearchState(status: SemanticSearchStatus.loaded, results: [], query: 'rust'),
      );
      await tester.pumpWidget(buildSubject());
      expect(find.text('No similar posts found'), findsOneWidget);
    });

    testWidgets('shows error state on search failure', (tester) async {
      when(
        () => searchCubit.state,
      ).thenReturn(const SemanticSearchState(status: SemanticSearchStatus.error, errorMessage: 'Search failed'));
      whenListen(
        searchCubit,
        const Stream<SemanticSearchState>.empty(),
        initialState: const SemanticSearchState(status: SemanticSearchStatus.error, errorMessage: 'Search failed'),
      );
      await tester.pumpWidget(buildSubject());
      expect(find.text('Search failed'), findsOneWidget);
    });

    testWidgets('renders relevance badges for results', (tester) async {
      when(() => searchCubit.state).thenReturn(
        const SemanticSearchState(status: SemanticSearchStatus.loaded, results: [_result1, _result2], query: 'flutter'),
      );
      whenListen(
        searchCubit,
        const Stream<SemanticSearchState>.empty(),
        initialState: const SemanticSearchState(
          status: SemanticSearchStatus.loaded,
          results: [_result1, _result2],
          query: 'flutter',
        ),
      );
      await tester.pumpWidget(buildSubject());
      expect(find.text('82%'), findsOneWidget);
      expect(find.text('48%'), findsOneWidget);
    });

    testWidgets('renders source tags for results', (tester) async {
      when(() => searchCubit.state).thenReturn(
        const SemanticSearchState(status: SemanticSearchStatus.loaded, results: [_result1, _result2], query: 'flutter'),
      );
      whenListen(
        searchCubit,
        const Stream<SemanticSearchState>.empty(),
        initialState: const SemanticSearchState(
          status: SemanticSearchStatus.loaded,
          results: [_result1, _result2],
          query: 'flutter',
        ),
      );
      await tester.pumpWidget(buildSubject());
      expect(find.text('Saved'), findsAtLeast(1));
      expect(find.text('Liked'), findsAtLeast(1));
    });

    testWidgets('renders scope chips', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Both'), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('Liked'), findsOneWidget);
    });

    testWidgets('tapping scope chip calls setScope', (tester) async {
      when(() => searchCubit.setScope(any())).thenAnswer((_) async {});
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Saved'));
      await tester.pump();
      verify(() => searchCubit.setScope(SearchScope.saved)).called(1);
    });

    testWidgets('entering a query calls search on the cubit', (tester) async {
      when(() => searchCubit.search(any())).thenReturn(null);
      await tester.pumpWidget(buildSubject());
      await tester.enterText(find.byType(TextField), 'flutter');
      verify(() => searchCubit.search('flutter')).called(1);
    });

    testWidgets('shows backfill banner when indexing is in progress', (tester) async {
      when(() => indexCubit.state).thenReturn(
        const SemanticIndexState(status: SemanticIndexStatus.backfilling, backfillCompleted: 42, backfillTotal: 100),
      );
      whenListen(
        indexCubit,
        const Stream<SemanticIndexState>.empty(),
        initialState: const SemanticIndexState(
          status: SemanticIndexStatus.backfilling,
          backfillCompleted: 42,
          backfillTotal: 100,
        ),
      );
      await tester.pumpWidget(buildSubject());
      expect(find.text('Indexing: 42/100 posts...'), findsOneWidget);
    });

    testWidgets('does not show backfill banner when idle', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.textContaining('Indexing:'), findsNothing);
    });
  });
}
