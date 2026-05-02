import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/search/cubit/semantic_index_cubit.dart';
import 'package:lazurite/features/search/cubit/semantic_search_cubit.dart';
import 'package:lazurite/features/search/data/semantic_search_repository.dart';
import 'package:lazurite/features/search/data/semantic_search_result.dart';
import 'package:lazurite/features/search/presentation/semantic_search_tab.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class MockSemanticSearchRepository extends Mock implements SemanticSearchRepository {}

class MockPostActionRepository extends Mock implements PostActionRepository {}

class MockSemanticSearchCubit extends MockCubit<SemanticSearchState> implements SemanticSearchCubit {}

class MockSemanticIndexCubit extends MockCubit<SemanticIndexState> implements SemanticIndexCubit {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

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
  late MockSettingsCubit settingsCubit;
  late MockPostActionRepository postActionRepository;

  setUp(() {
    searchCubit = MockSemanticSearchCubit();
    indexCubit = MockSemanticIndexCubit();
    settingsCubit = MockSettingsCubit();
    postActionRepository = MockPostActionRepository();

    when(() => searchCubit.state).thenReturn(const SemanticSearchState());
    whenListen(searchCubit, const Stream<SemanticSearchState>.empty(), initialState: const SemanticSearchState());
    when(() => searchCubit.setScope(any())).thenAnswer((_) async {});
    when(() => searchCubit.setMaxResults(any())).thenReturn(null);
    when(() => indexCubit.state).thenReturn(const SemanticIndexState());
    whenListen(indexCubit, const Stream<SemanticIndexState>.empty(), initialState: const SemanticIndexState());
    when(() => indexCubit.loadCount()).thenReturn(null);
    when(() => indexCubit.reindex()).thenAnswer((_) async {});
    when(() => settingsCubit.state).thenReturn(
      const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        semanticSearchEnabled: true,
      ),
    );
    whenListen(
      settingsCubit,
      const Stream<SettingsState>.empty(),
      initialState: const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        semanticSearchEnabled: true,
      ),
    );
    when(() => settingsCubit.setSemanticSearchEnabled(any())).thenAnswer((_) async {});
    when(() => settingsCubit.setSemanticSearchMaxResults(any())).thenAnswer((_) async {});
    when(() => settingsCubit.setSearchScope(any())).thenAnswer((_) async {});
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
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
        ],
        child: const MaterialApp(home: Scaffold(body: SemanticSearchTab())),
      ),
    );
  }

  group('SemanticSearchTab', () {
    testWidgets('shows empty query state when no query entered', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Search your saved & liked posts'), findsOneWidget);
      expect(find.text('Find posts by handle, text, and semantic similarity'), findsOneWidget);
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
      verify(() => settingsCubit.setSearchScope(SearchScope.saved)).called(1);
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
      expect(find.text('Indexing 42/100'), findsOneWidget);
    });

    testWidgets('shows indexed count header when idle', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('0 indexed'), findsOneWidget);
    });

    testWidgets('kebab menu refresh action triggers loadCount', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byTooltip('Search index actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Refresh indexed count'));
      await tester.pumpAndSettle();
      verify(() => indexCubit.loadCount()).called(2);
    });

    testWidgets('kebab menu reindex action triggers reindex', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byTooltip('Search index actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Re-index posts'));
      await tester.pump();
      verify(() => indexCubit.reindex()).called(1);
    });

    testWidgets('semantic settings sheet opens from kebab menu', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byTooltip('Search index actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Semantic settings'));
      await tester.pumpAndSettle();
      expect(find.text('Semantic settings'), findsOneWidget);
      expect(find.text('Semantic search is always enabled for saved and liked posts.'), findsOneWidget);
    });

    testWidgets('semantic settings sheet does not show enable toggle', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byTooltip('Search index actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Semantic settings'));
      await tester.pumpAndSettle();
      expect(find.byType(Switch), findsNothing);
      expect(find.text('Default scope'), findsOneWidget);
      expect(find.text('Max results'), findsOneWidget);
    });
  });
}
