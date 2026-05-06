import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/features/auth/presentation/login_screen.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

class MockAccountSwitcherCubit extends MockCubit<AccountSwitcherState> implements AccountSwitcherCubit {}

void main() {
  late MockAuthBloc authBloc;
  late MockSettingsCubit settingsCubit;
  late MockAccountSwitcherCubit accountSwitcherCubit;

  setUp(() {
    authBloc = MockAuthBloc();
    settingsCubit = MockSettingsCubit();
    accountSwitcherCubit = MockAccountSwitcherCubit();
    when(() => authBloc.state).thenReturn(const AuthState.unauthenticated());
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.unauthenticated());
    const settingsState = SettingsState(
      themePalette: AppThemePalette.oxocarbon,
      themeVariant: AppThemeVariant.dark,
      useSystemTheme: false,
    );
    when(() => settingsCubit.state).thenReturn(settingsState);
    whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: settingsState);
    when(() => settingsCubit.setAppViewProvider(any())).thenAnswer((_) async {});
    when(() => accountSwitcherCubit.state).thenReturn(const AccountSwitcherState.ready(accounts: []));
    whenListen(
      accountSwitcherCubit,
      const Stream<AccountSwitcherState>.empty(),
      initialState: const AccountSwitcherState.ready(accounts: []),
    );
    when(() => accountSwitcherCubit.loadAccounts()).thenAnswer((_) async {});
  });

  Widget buildSubject({
    ThemeMode themeMode = ThemeMode.system,
    MockAccountSwitcherCubit? accountCubit,
    String? initialHandle,
    bool autoStartOAuth = false,
  }) {
    final typeaheadRepository = _FakeTypeaheadRepository(
      searchHandler: ({required String query, int limit = 10}) async => const [],
    );

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<SettingsCubit>.value(value: settingsCubit),
              BlocProvider<AccountSwitcherCubit>.value(value: accountCubit ?? accountSwitcherCubit),
            ],
            child: LoginScreen(
              initialHandle: initialHandle,
              autoStartOAuth: autoStartOAuth,
              typeaheadRepository: typeaheadRepository,
            ),
          ),
        ),
        GoRoute(
          path: '/terms',
          builder: (context, state) => const Scaffold(body: Text('terms-route')),
        ),
        GoRoute(
          path: '/privacy',
          builder: (context, state) => const Scaffold(body: Text('privacy-route')),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const Scaffold(body: Text('public-settings-route')),
        ),
      ],
      initialLocation: '/login',
    );

    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
    );
  }

  testWidgets('shows settings icon plus terms and privacy links', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Terms of Service'), 200, scrollable: scrollable);
    await tester.scrollUntilVisible(find.text('Privacy Policy'), 200, scrollable: scrollable);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Settings'), findsOneWidget);
    expect(find.text('Settings'), findsNothing);
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
  });

  testWidgets('tapping settings icon opens public settings route', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('public-settings-route'), findsOneWidget);
  });

  testWidgets('tapping Terms of Service opens terms route', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.scrollUntilVisible(find.text('Terms of Service'), 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Terms of Service'));
    await tester.pumpAndSettle();

    expect(find.text('terms-route'), findsOneWidget);
  });

  testWidgets('tapping Privacy Policy opens privacy route', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Privacy Policy'), 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();

    expect(find.text('privacy-route'), findsOneWidget);
  });

  testWidgets('login typeahead shows community results and selecting triggers OAuth login', (tester) async {
    final typeaheadRepository = _FakeTypeaheadRepository(
      searchHandler: ({required String query, int limit = 10}) async {
        if (query == 'ri') {
          return const [TypeaheadResult(did: 'did:plc:river', handle: 'river.bsky.social', displayName: 'River Tam')];
        }
        return const [];
      },
    );

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<SettingsCubit>.value(value: settingsCubit),
            ],
            child: LoginScreen(typeaheadRepository: typeaheadRepository),
          ),
        ),
      ],
      initialLocation: '/login',
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'ri');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('River Tam'), findsOneWidget);
    final suggestionTile = tester.widget<ListTile>(
      find.byKey(const ValueKey<String>('typeahead-result-did:plc:river')),
    );
    suggestionTile.onTap?.call();
    await tester.pumpAndSettle();

    verify(() => authBloc.add(const OAuthLoginRequested(handle: 'river.bsky.social'))).called(1);
  });

  testWidgets('persists selected provider before triggering OAuth login', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'river.bsky.social');
    await tester.tap(find.byKey(const ValueKey<String>('login-continue-button')));
    await tester.pumpAndSettle();

    verifyInOrder([
      () => settingsCubit.setAppViewProvider('bluesky'),
      () => authBloc.add(const OAuthLoginRequested(handle: 'river.bsky.social')),
    ]);
  });

  testWidgets('auto-starts OAuth once when reauth opens with an initial handle', (tester) async {
    await tester.pumpWidget(buildSubject(initialHandle: 'alice.bsky.social', autoStartOAuth: true));
    await tester.pumpAndSettle();

    final field = tester.widget<TextFormField>(find.byType(TextFormField).first);
    expect(field.controller?.text, 'alice.bsky.social');
    verifyInOrder([
      () => settingsCubit.setAppViewProvider('bluesky'),
      () => authBloc.add(const OAuthLoginRequested(handle: 'alice.bsky.social')),
    ]);

    await tester.pump();
    verifyNever(() => authBloc.add(const OAuthLoginRequested(handle: 'alice.bsky.social')));
  });

  testWidgets('tints BlackSky logo in dark mode', (tester) async {
    await tester.pumpWidget(buildSubject(themeMode: ThemeMode.dark));
    await tester.pumpAndSettle();

    final blackSkyRow = find.ancestor(of: find.text('BlackSky'), matching: find.byType(Row));
    final blackSkyLogo = find.descendant(of: blackSkyRow, matching: find.byType(SvgPicture));
    final blackSkySvg = tester.widget<SvgPicture>(blackSkyLogo.first);
    expect(blackSkySvg.colorFilter, const ColorFilter.mode(Color(0xFF6868B6), BlendMode.srcIn));

    final blueSkyRow = find.ancestor(of: find.text('BlueSky'), matching: find.byType(Row));
    final blueSkyLogo = find.descendant(of: blueSkyRow, matching: find.byType(SvgPicture));
    final blueSkySvg = tester.widget<SvgPicture>(blueSkyLogo.first);
    expect(blueSkySvg.colorFilter, isNull);
  });

  testWidgets('saved account row tap restores stored session', (tester) async {
    final account = _makeAccount(did: 'did:plc:alice', handle: 'alice.bsky.social', displayName: 'Alice');
    final state = AccountSwitcherState.ready(accounts: [account], activeDid: account.did);
    const tokens = AuthTokens(accessToken: 'token', did: 'did:plc:alice', handle: 'alice.bsky.social');
    when(() => accountSwitcherCubit.state).thenReturn(state);
    whenListen(accountSwitcherCubit, const Stream<AccountSwitcherState>.empty(), initialState: state);
    when(() => accountSwitcherCubit.switchAccount(account.did)).thenAnswer((_) async => tokens);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Saved accounts'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('@alice.bsky.social'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('saved-account-did:plc:alice')));
    await tester.pumpAndSettle();

    final field = tester.widget<TextFormField>(find.byType(TextFormField).first);
    expect(field.controller?.text, 'alice.bsky.social');
    verify(() => accountSwitcherCubit.switchAccount(account.did)).called(1);
    verify(() => authBloc.add(const SessionRestored(tokens: tokens))).called(1);
    verifyNever(() => authBloc.add(const OAuthLoginRequested(handle: 'alice.bsky.social')));
  });

  testWidgets('saved account row tap starts OAuth reauth when stored session cannot be restored', (tester) async {
    final account = _makeAccount(did: 'did:plc:alice', handle: 'alice.bsky.social', displayName: 'Alice');
    final state = AccountSwitcherState.ready(accounts: [account], activeDid: account.did);
    when(() => accountSwitcherCubit.state).thenReturn(state);
    whenListen(accountSwitcherCubit, const Stream<AccountSwitcherState>.empty(), initialState: state);
    when(() => accountSwitcherCubit.switchAccount(account.did)).thenAnswer((_) async => null);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('saved-account-did:plc:alice')));
    await tester.pumpAndSettle();

    final field = tester.widget<TextFormField>(find.byType(TextFormField).first);
    expect(field.controller?.text, 'alice.bsky.social');
    verify(() => accountSwitcherCubit.switchAccount(account.did)).called(1);
    verifyInOrder([
      () => settingsCubit.setAppViewProvider('bluesky'),
      () => authBloc.add(const OAuthLoginRequested(handle: 'alice.bsky.social')),
    ]);
    verifyNever(
      () => authBloc.add(
        const SessionRestored(
          tokens: AuthTokens(accessToken: 'token', did: 'did:plc:alice', handle: 'alice.bsky.social'),
        ),
      ),
    );
  });

  testWidgets('shows saved accounts loading state while account list is loading', (tester) async {
    when(() => accountSwitcherCubit.state).thenReturn(const AccountSwitcherState.loading());
    whenListen(
      accountSwitcherCubit,
      const Stream<AccountSwitcherState>.empty(),
      initialState: const AccountSwitcherState.loading(),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Saved accounts'), findsOneWidget);
    expect(find.text('Loading saved accounts...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('remove saved account dispatches SessionCleared and hides section when list becomes empty', (
    tester,
  ) async {
    final account = _makeAccount(did: 'did:plc:alice', handle: 'alice.bsky.social', displayName: 'Alice');
    final initial = AccountSwitcherState.ready(accounts: [account], activeDid: account.did);
    const empty = AccountSwitcherState.ready(accounts: []);
    final states = StreamController<AccountSwitcherState>();
    addTearDown(states.close);

    when(() => accountSwitcherCubit.state).thenReturn(initial);
    whenListen(accountSwitcherCubit, states.stream, initialState: initial);
    when(() => accountSwitcherCubit.removeAccount(account.did)).thenAnswer((_) async {
      states.add(empty);
      return const AccountRemovalResult.requiresSignIn();
    });

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Saved accounts'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove account').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    verify(() => accountSwitcherCubit.removeAccount(account.did)).called(1);
    verify(() => authBloc.add(const SessionCleared())).called(1);
    expect(find.text('Saved accounts'), findsNothing);
  });
}

class _FakeTypeaheadRepository extends TypeaheadRepository {
  _FakeTypeaheadRepository({required this.searchHandler}) : super(provider: TypeaheadRepository.communityProvider);

  final Future<List<TypeaheadResult>> Function({required String query, int limit}) searchHandler;

  @override
  Future<List<TypeaheadResult>> search({required String query, int limit = 10}) {
    return searchHandler(query: query, limit: limit);
  }
}

Account _makeAccount({required String did, required String handle, String? displayName}) {
  return Account(
    did: did,
    handle: handle,
    displayName: displayName,
    service: null,
    oauthService: null,
    oauthClientId: null,
    accessToken: 'token',
    refreshToken: null,
    dpopPublicKey: null,
    dpopPrivateKey: null,
    dpopNonce: null,
    expiresAt: null,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}
