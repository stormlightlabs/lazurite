import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/features/settings/presentation/settings_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockAccountSwitcherCubit extends MockCubit<AccountSwitcherState> implements AccountSwitcherCubit {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

SettingsState _baseSettings({bool semanticSearchEnabled = false, int maxResults = 20}) => SettingsState(
  themePalette: AppThemePalette.oxocarbon,
  themeVariant: AppThemeVariant.dark,
  useSystemTheme: false,
  feedLayout: FeedLayout.card,
  semanticSearchEnabled: semanticSearchEnabled,
  semanticSearchMaxResults: maxResults,
);

void main() {
  const tokens = AuthTokens(
    accessToken: 'access',
    refreshToken: 'refresh',
    did: 'did:plc:test',
    handle: 'test.bsky.social',
    displayName: 'Test User',
  );

  late MockAuthBloc authBloc;
  late MockAccountSwitcherCubit accountSwitcherCubit;
  late MockSettingsCubit settingsCubit;

  setUp(() {
    authBloc = MockAuthBloc();
    accountSwitcherCubit = MockAccountSwitcherCubit();
    settingsCubit = MockSettingsCubit();

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
  });

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<AccountSwitcherCubit>.value(value: accountSwitcherCubit),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
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
      const authenticatedState = AuthState.authenticated(tokens);
      when(() => authBloc.state).thenReturn(authenticatedState);
      whenListen(authBloc, const Stream<AuthState>.empty(), initialState: authenticatedState);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Typeahead Provider'), 300);

      expect(find.text('Typeahead Provider'), findsOneWidget);
      expect(find.text('Bluesky official endpoint selected.'), findsOneWidget);
      expect(find.text('Bluesky'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);
    });

    testWidgets('selecting community provider calls setTypeaheadProvider', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const authenticatedState = AuthState.authenticated(tokens);
      when(() => authBloc.state).thenReturn(authenticatedState);
      whenListen(authBloc, const Stream<AuthState>.empty(), initialState: authenticatedState);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Typeahead Provider'), 300);

      await tester.tap(find.text('Community'));
      await tester.pumpAndSettle();

      verify(() => settingsCubit.setTypeaheadProvider('community')).called(1);
    });

    testWidgets('hides typeahead provider selector when unauthenticated', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Semantic Search'), 300);

      expect(find.text('Typeahead Provider'), findsNothing);
      expect(find.text('Community'), findsNothing);
      expect(find.text('Bluesky'), findsNothing);
    });

    testWidgets('shows semantic search management hint', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Semantic Search'), 300);
      expect(find.text('Manage semantic search from Bookmarks & Likes -> Search'), findsOneWidget);
    });

    testWidgets('does not show semantic search controls in settings', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Default Scope'), findsNothing);
      expect(find.text('Max Results'), findsNothing);
      final semanticTile = find.ancestor(of: find.text('Semantic Search'), matching: find.byType(ListTile));
      expect(find.descendant(of: semanticTile, matching: find.byType(Switch)), findsNothing);
    });
  });
}
