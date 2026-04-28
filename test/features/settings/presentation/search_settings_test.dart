import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/search/cubit/semantic_index_cubit.dart';
import 'package:lazurite/features/search/cubit/semantic_search_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/features/settings/presentation/settings_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockAccountSwitcherCubit extends MockCubit<AccountSwitcherState> implements AccountSwitcherCubit {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

class MockSemanticIndexCubit extends MockCubit<SemanticIndexState> implements SemanticIndexCubit {}

class MockSemanticSearchCubit extends MockCubit<SemanticSearchState> implements SemanticSearchCubit {}

SettingsState _baseSettings({bool semanticSearchEnabled = false, int maxResults = 20}) => SettingsState(
  themePalette: AppThemePalette.oxocarbon,
  themeVariant: AppThemeVariant.dark,
  useSystemTheme: false,
  feedLayout: FeedLayout.card,
  semanticSearchEnabled: semanticSearchEnabled,
  semanticSearchMaxResults: maxResults,
);

void main() {
  late MockAuthBloc authBloc;
  late MockAccountSwitcherCubit accountSwitcherCubit;
  late MockSettingsCubit settingsCubit;
  late MockSemanticIndexCubit indexCubit;
  late MockSemanticSearchCubit searchCubit;

  setUp(() {
    authBloc = MockAuthBloc();
    accountSwitcherCubit = MockAccountSwitcherCubit();
    settingsCubit = MockSettingsCubit();
    indexCubit = MockSemanticIndexCubit();
    searchCubit = MockSemanticSearchCubit();

    when(() => authBloc.state).thenReturn(const AuthState.unauthenticated());
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.unauthenticated());
    when(() => accountSwitcherCubit.state).thenReturn(const AccountSwitcherState.ready(accounts: []));
    whenListen(
      accountSwitcherCubit,
      const Stream<AccountSwitcherState>.empty(),
      initialState: const AccountSwitcherState.ready(accounts: []),
    );

    final initialSettings = _baseSettings();
    when(() => settingsCubit.state).thenReturn(initialSettings);
    whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: initialSettings);
    when(() => settingsCubit.setTypeaheadProvider(any())).thenAnswer((_) async {});

    when(() => indexCubit.state).thenReturn(const SemanticIndexState());
    whenListen(indexCubit, const Stream<SemanticIndexState>.empty(), initialState: const SemanticIndexState());

    when(() => searchCubit.state).thenReturn(const SemanticSearchState());
    whenListen(searchCubit, const Stream<SemanticSearchState>.empty(), initialState: const SemanticSearchState());
  });

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<AccountSwitcherCubit>.value(value: accountSwitcherCubit),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
        BlocProvider<SemanticIndexCubit>.value(value: indexCubit),
        BlocProvider<SemanticSearchCubit>.value(value: searchCubit),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    );
  }

  group('Settings – Search section', () {
    testWidgets('shows Search section header', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('SEARCH'), 300);
      expect(find.text('SEARCH'), findsOneWidget);
    });

    testWidgets('shows typeahead provider selector', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Typeahead Provider'), 300);

      expect(find.text('Typeahead Provider'), findsOneWidget);
      expect(find.text('Bluesky official endpoint selected. Requires login.'), findsOneWidget);
      expect(find.text('Bluesky'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);
    });

    testWidgets('selecting community provider calls setTypeaheadProvider', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Typeahead Provider'), 300);

      await tester.tap(find.text('Community'));
      await tester.pumpAndSettle();

      verify(() => settingsCubit.setTypeaheadProvider('community')).called(1);
    });

    testWidgets('shows Semantic Search toggle set to off by default', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Semantic Search'), 300);
      final semanticTile = find.ancestor(of: find.text('Semantic Search'), matching: find.byType(ListTile));
      final switchWidget = tester.widget<Switch>(find.descendant(of: semanticTile, matching: find.byType(Switch)));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('toggling Semantic Search on calls setSemanticSearchEnabled and reindex', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      when(() => settingsCubit.setSemanticSearchEnabled(any())).thenAnswer((_) async {});
      when(() => indexCubit.reindex()).thenAnswer((_) async {});

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final semanticTile = find.ancestor(of: find.text('Semantic Search'), matching: find.byType(ListTile));
      await tester.tap(find.descendant(of: semanticTile, matching: find.byType(Switch)));
      await tester.pumpAndSettle();

      verify(() => settingsCubit.setSemanticSearchEnabled(true)).called(1);
      verify(() => indexCubit.reindex()).called(1);
    });

    testWidgets('shows additional settings when semantic search is enabled', (tester) async {
      final enabledSettings = _baseSettings(semanticSearchEnabled: true);
      when(() => settingsCubit.state).thenReturn(enabledSettings);
      whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: enabledSettings);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Default Scope'), 300);

      expect(find.text('Default Scope'), findsOneWidget);
      expect(find.text('Index Status'), findsOneWidget);
      expect(find.text('Max Results'), findsOneWidget);
    });

    testWidgets('hides advanced settings when semantic search is disabled', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Default Scope'), findsNothing);
      expect(find.text('Index Status'), findsNothing);
      expect(find.text('Max Results'), findsNothing);
    });

    testWidgets('shows indexed post count in Index Status tile', (tester) async {
      when(() => indexCubit.state).thenReturn(const SemanticIndexState(indexedCount: 73));
      whenListen(
        indexCubit,
        const Stream<SemanticIndexState>.empty(),
        initialState: const SemanticIndexState(indexedCount: 73),
      );

      final enabledSettings = _baseSettings(semanticSearchEnabled: true);
      when(() => settingsCubit.state).thenReturn(enabledSettings);
      whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: enabledSettings);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('73 posts indexed'), 300);

      expect(find.text('73 posts indexed'), findsOneWidget);
    });

    testWidgets('shows backfill progress in Index Status tile while indexing', (tester) async {
      when(() => indexCubit.state).thenReturn(
        const SemanticIndexState(status: SemanticIndexStatus.backfilling, backfillCompleted: 30, backfillTotal: 100),
      );
      whenListen(
        indexCubit,
        const Stream<SemanticIndexState>.empty(),
        initialState: const SemanticIndexState(
          status: SemanticIndexStatus.backfilling,
          backfillCompleted: 30,
          backfillTotal: 100,
        ),
      );

      final enabledSettings = _baseSettings(semanticSearchEnabled: true);
      when(() => settingsCubit.state).thenReturn(enabledSettings);
      whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: enabledSettings);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Indexing: 30/100 posts...'), 300);

      expect(find.text('Indexing: 30/100 posts...'), findsOneWidget);
    });

    testWidgets('Re-index button triggers reindex', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      when(() => indexCubit.reindex()).thenAnswer((_) async {});

      final enabledSettings = _baseSettings(semanticSearchEnabled: true);
      when(() => settingsCubit.state).thenReturn(enabledSettings);
      whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: enabledSettings);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Re-index'));
      await tester.pump();

      verify(() => indexCubit.reindex()).called(1);
    });

    testWidgets('max results slider reflects current settings value', (tester) async {
      final enabledSettings = _baseSettings(semanticSearchEnabled: true, maxResults: 30);
      when(() => settingsCubit.state).thenReturn(enabledSettings);
      whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: enabledSettings);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('30'), 300);

      expect(find.text('30'), findsOneWidget);
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 30.0);
    });

    testWidgets('default scope dropdown shows current scope', (tester) async {
      final enabledSettings = _baseSettings(semanticSearchEnabled: true).copyWith(searchScope: SearchScope.saved);
      when(() => settingsCubit.state).thenReturn(enabledSettings);
      whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: enabledSettings);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Saved only'), 300);

      expect(find.text('Saved only'), findsOneWidget);
    });
  });
}
