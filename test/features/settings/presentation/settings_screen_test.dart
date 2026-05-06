import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/cache/local_cache_maintenance_service.dart';
import 'package:lazurite/core/crash_reporting/crash_reporting_service.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/features/settings/presentation/settings_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountSwitcherCubit extends MockCubit<AccountSwitcherState> implements AccountSwitcherCubit {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

class MockLocalCacheMaintenanceService extends Mock implements LocalCacheMaintenanceService {}

class FakeCrashReportingService implements CrashReportingService {
  var crashCalls = 0;

  @override
  void crash() {
    crashCalls += 1;
  }

  @override
  Future<void> deleteUnsentReports() async {}

  @override
  Future<void> recordError(Object error, StackTrace stackTrace, {bool fatal = false}) async {}

  @override
  void recordFlutterFatalError(FlutterErrorDetails details) {}

  @override
  Future<void> sendUnsentReports() async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}
}

void main() {
  late MockAccountSwitcherCubit accountSwitcherCubit;
  late MockAuthBloc authBloc;
  late MockSettingsCubit settingsCubit;
  late MockLocalCacheMaintenanceService cacheMaintenanceService;
  late FakeCrashReportingService crashReportingService;

  setUp(() {
    accountSwitcherCubit = MockAccountSwitcherCubit();
    authBloc = MockAuthBloc();
    settingsCubit = MockSettingsCubit();
    cacheMaintenanceService = MockLocalCacheMaintenanceService();
    crashReportingService = FakeCrashReportingService();

    when(() => authBloc.state).thenReturn(const AuthState.unauthenticated());
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.unauthenticated());
    when(() => accountSwitcherCubit.state).thenReturn(const AccountSwitcherState.ready(accounts: []));
    whenListen(
      accountSwitcherCubit,
      const Stream<AccountSwitcherState>.empty(),
      initialState: const AccountSwitcherState.ready(accounts: []),
    );

    when(() => settingsCubit.state).thenReturn(
      const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        feedLayout: FeedLayout.card,
      ),
    );
    whenListen(
      settingsCubit,
      const Stream<SettingsState>.empty(),
      initialState: const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        feedLayout: FeedLayout.card,
      ),
    );
    when(() => settingsCubit.setAppViewProvider(any())).thenAnswer((_) async {});
    when(() => settingsCubit.refreshAppViewHealth()).thenAnswer((_) async {});
    when(() => settingsCubit.setCrashReportingEnabled(any())).thenAnswer((_) async {});
    when(() => settingsCubit.setCrashReportingConsentPrompted(any())).thenAnswer((_) async {});
    when(() => cacheMaintenanceService.clearCaches()).thenAnswer((_) async {});
  });

  Widget buildSubject() {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CrashReportingService>.value(value: crashReportingService),
        RepositoryProvider<LocalCacheMaintenanceService>.value(value: cacheMaintenanceService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<AccountSwitcherCubit>.value(value: accountSwitcherCubit),
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
  }

  Widget buildRoutedSubject() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiRepositoryProvider(
            providers: [
              RepositoryProvider<CrashReportingService>.value(value: crashReportingService),
              RepositoryProvider<LocalCacheMaintenanceService>.value(value: cacheMaintenanceService),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: authBloc),
                BlocProvider<AccountSwitcherCubit>.value(value: accountSwitcherCubit),
                BlocProvider<SettingsCubit>.value(value: settingsCubit),
              ],
              child: const SettingsScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/settings/devtools',
          builder: (context, state) => Scaffold(body: Text('devtools:${state.uri.queryParameters['query'] ?? ''}')),
        ),
        GoRoute(
          path: '/settings/clean-follows',
          builder: (context, state) => const Scaffold(body: Text('clean-follows')),
        ),
        GoRoute(
          path: '/terms',
          builder: (context, state) => const Scaffold(body: Text('terms-screen')),
        ),
        GoRoute(
          path: '/privacy',
          builder: (context, state) => const Scaffold(body: Text('privacy-screen')),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  Widget buildPublicRoutedSubject() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => RepositoryProvider<CrashReportingService>.value(
            value: crashReportingService,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: authBloc),
                BlocProvider<AccountSwitcherCubit>.value(value: accountSwitcherCubit),
                BlocProvider<SettingsCubit>.value(value: settingsCubit),
              ],
              child: const SettingsScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/settings/about',
          builder: (context, state) => const Scaffold(body: Text('public-about-screen')),
        ),
        GoRoute(
          path: '/settings/logs',
          builder: (context, state) => const Scaffold(body: Text('public-logs-screen')),
        ),
        GoRoute(
          path: '/settings/devtools',
          builder: (context, state) => const Scaffold(body: Text('public-devtools-screen')),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows active settings controls that are wired up', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('APPEARANCE', skipOffstage: false), findsOneWidget);
    expect(find.text('System'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Feed Layout'), 300);
    await tester.pumpAndSettle();

    expect(find.text('LAYOUT', skipOffstage: false), findsOneWidget);
    expect(find.text('Feed Layout'), findsOneWidget);
    expect(find.text('Thread Auto-Collapse'), findsOneWidget);
    expect(find.text('Animations'), findsOneWidget);
  });

  testWidgets('shows the AT Protocol connection card for the authenticated account', (tester) async {
    final tokens = AuthTokens(
      accessToken: _buildJwt(
        aud: 'shaggymane.us-west.host.bsky.network',
        sub: 'did:plc:lazurite123',
        clientId: 'https://client.example/metadata.json',
        iss: 'https://bsky.social',
      ),
      refreshToken: 'refresh-token',
      did: 'did:plc:lazurite123',
      handle: 'owais.bsky.social',
      service: 'bsky.social',
      dpopPublicKey: 'public-key',
      dpopPrivateKey: 'private-key',
      authMethod: AuthMethod.oauth,
    );
    final account = Account(
      did: tokens.did,
      handle: tokens.handle,
      displayName: 'Owais',
      service: tokens.service,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      dpopPublicKey: null,
      dpopPrivateKey: null,
      dpopNonce: null,
      expiresAt: null,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    when(() => authBloc.state).thenReturn(AuthState.authenticated(tokens));
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: AuthState.authenticated(tokens));
    when(
      () => accountSwitcherCubit.state,
    ).thenReturn(AccountSwitcherState.ready(accounts: [account], activeDid: account.did));
    whenListen(
      accountSwitcherCubit,
      const Stream<AccountSwitcherState>.empty(),
      initialState: AccountSwitcherState.ready(accounts: [account], activeDid: account.did),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('AT Protocol Connection'), 300);
    await tester.pumpAndSettle();

    expect(find.text('AT Protocol Connection'), findsOneWidget);
    expect(find.text('HANDLE'), findsOneWidget);
    expect(find.text('@owais.bsky.social'), findsOneWidget);
    expect(find.text('DID'), findsOneWidget);
    expect(find.text('did:plc:lazurite123'), findsOneWidget);
    expect(find.text('PDS'), findsOneWidget);
    expect(find.text('shaggymane.us-west.host.bsky.network'), findsOneWidget);
  });

  testWidgets('tapping the DID row opens Dev Tools with the DID query', (tester) async {
    final tokens = AuthTokens(
      accessToken: _buildJwt(
        aud: 'shaggymane.us-west.host.bsky.network',
        sub: 'did:plc:lazurite123',
        clientId: 'https://client.example/metadata.json',
        iss: 'https://bsky.social',
      ),
      refreshToken: 'refresh-token',
      did: 'did:plc:lazurite123',
      handle: 'owais.bsky.social',
      service: 'bsky.social',
      dpopPublicKey: 'public-key',
      dpopPrivateKey: 'private-key',
      authMethod: AuthMethod.oauth,
    );
    final account = Account(
      did: tokens.did,
      handle: tokens.handle,
      displayName: 'Owais',
      service: tokens.service,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      dpopPublicKey: null,
      dpopPrivateKey: null,
      dpopNonce: null,
      expiresAt: null,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    when(() => authBloc.state).thenReturn(AuthState.authenticated(tokens));
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: AuthState.authenticated(tokens));
    when(
      () => accountSwitcherCubit.state,
    ).thenReturn(AccountSwitcherState.ready(accounts: [account], activeDid: account.did));
    whenListen(
      accountSwitcherCubit,
      const Stream<AccountSwitcherState>.empty(),
      initialState: AccountSwitcherState.ready(accounts: [account], activeDid: account.did),
    );

    await tester.pumpWidget(buildRoutedSubject());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('did:plc:lazurite123'), 300);
    await tester.pumpAndSettle();

    await tester.tap(find.text('did:plc:lazurite123'));
    await tester.pumpAndSettle();

    expect(find.text('devtools:did:plc:lazurite123'), findsOneWidget);
  });

  testWidgets('does not render removed placeholder settings', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('UI Density'), findsNothing);
    expect(find.text('Edit Profile'), findsNothing);
    expect(find.text('Privacy'), findsNothing);
    expect(find.text('Push Notifications'), findsNothing);
    expect(find.text('Email Notifications'), findsNothing);
    expect(find.text('Help & Support'), findsNothing);
  });

  testWidgets('shows Advanced section with read-only Constellation URL tile', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('ADVANCED'), 300);
    await tester.pumpAndSettle();

    expect(find.text('ADVANCED'), findsOneWidget);
    expect(find.text('Logs'), findsOneWidget);
    expect(find.text('Constellation URL'), findsOneWidget);
    expect(find.text('https://constellation.microcosm.blue'), findsOneWidget);
    expect(find.text('AppView Provider'), findsOneWidget);
    expect(find.text('Cross-Provider Fallback'), findsOneWidget);
    expect(find.text('Slingshot Identity Fallback'), findsOneWidget);
    expect(find.text('Crash Reporting'), findsOneWidget);
    expect(find.text('Provider Diagnostics'), findsOneWidget);
    expect(find.text('Refresh Provider Health'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });

  testWidgets('troubleshooting reset sign-in data requires confirmation before clearing local auth data', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('TROUBLESHOOTING'), 300);
    await tester.pumpAndSettle();

    expect(find.text('TROUBLESHOOTING'), findsOneWidget);
    expect(find.text('Reset Sign-In Data'), findsOneWidget);
    expect(
      find.text('Troubleshoot OAuth or account-switching issues by clearing local sessions on this device'),
      findsOneWidget,
    );

    await tester.tap(find.text('Reset Sign-In Data'));
    await tester.pumpAndSettle();

    expect(find.text('Reset sign-in data?'), findsOneWidget);
    expect(find.textContaining('It does not delete your Bluesky account or posts.'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => authBloc.add(const LocalAuthDataClearRequested()));

    await tester.tap(find.text('Reset Sign-In Data'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Reset Sign-In Data'));
    await tester.pumpAndSettle();

    verify(() => authBloc.add(const LocalAuthDataClearRequested())).called(1);
  });

  testWidgets('troubleshooting clear cache requires confirmation and keeps auth state intact', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('TROUBLESHOOTING'), 300);
    await tester.pumpAndSettle();

    expect(find.text('Clear Cache'), findsOneWidget);
    expect(
      find.text('Remove cached posts, profiles, images, feeds, threads, and semantic search data'),
      findsOneWidget,
    );

    await tester.tap(find.text('Clear Cache'));
    await tester.pumpAndSettle();

    expect(find.text('Clear cache?'), findsOneWidget);
    expect(find.textContaining('Accounts, settings, drafts, bookmarks, and likes are kept.'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => cacheMaintenanceService.clearCaches());

    await tester.tap(find.text('Clear Cache'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Clear Cache'));
    await tester.pumpAndSettle();

    verify(() => cacheMaintenanceService.clearCaches()).called(1);
    verifyNever(() => authBloc.add(const LocalAuthDataClearRequested()));
    expect(find.text('Cache cleared'), findsOneWidget);
  });

  testWidgets('crash reporting toggle persists consent and reporting state', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Crash Reporting'), 300);
    await tester.pumpAndSettle();

    final crashTile = find.ancestor(of: find.text('Crash Reporting'), matching: find.byType(ListTile));
    await tester.ensureVisible(crashTile);
    final crashSwitch = find.descendant(of: crashTile, matching: find.byType(Switch));
    expect(crashSwitch, findsOneWidget);
    await tester.tap(crashSwitch);
    await tester.pumpAndSettle();

    verify(() => settingsCubit.setCrashReportingEnabled(true)).called(1);
    verify(() => settingsCubit.setCrashReportingConsentPrompted(true)).called(1);
  });

  testWidgets('developer crash row triggers crash reporting test crash', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Crashlytics Test Crash'), 300);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crashlytics Test Crash'));
    await tester.pumpAndSettle();

    expect(crashReportingService.crashCalls, 1);
  });

  testWidgets('provider change confirmation can be cancelled', (tester) async {
    when(() => settingsCubit.state).thenReturn(
      const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        feedLayout: FeedLayout.card,
        appViewProvider: AppViewProviders.blueskyKey,
      ),
    );
    whenListen(
      settingsCubit,
      const Stream<SettingsState>.empty(),
      initialState: const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        feedLayout: FeedLayout.card,
        appViewProvider: AppViewProviders.blueskyKey,
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    final segmented = find.byKey(const Key('appview-provider-segmented'));
    await tester.scrollUntilVisible(segmented, 300);
    final segmentedWidget = tester.widget<SegmentedButton<String>>(segmented);
    segmentedWidget.onSelectionChanged?.call(const {AppViewProviders.blackskyKey});
    await tester.pumpAndSettle();

    expect(find.text('Switch AppView provider?'), findsOneWidget);
    expect(find.text('Apply and Restart'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => settingsCubit.setAppViewProvider(any()));
  });

  testWidgets('provider change confirmation applies selection when confirmed', (tester) async {
    when(() => settingsCubit.state).thenReturn(
      const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        feedLayout: FeedLayout.card,
        appViewProvider: AppViewProviders.blueskyKey,
      ),
    );
    whenListen(
      settingsCubit,
      const Stream<SettingsState>.empty(),
      initialState: const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        feedLayout: FeedLayout.card,
        appViewProvider: AppViewProviders.blueskyKey,
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    final segmented = find.byKey(const Key('appview-provider-segmented'));
    await tester.scrollUntilVisible(segmented, 300);
    final segmentedWidget = tester.widget<SegmentedButton<String>>(segmented);
    segmentedWidget.onSelectionChanged?.call(const {AppViewProviders.blackskyKey});
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply and Restart'));
    await tester.pumpAndSettle();

    verify(() => settingsCubit.setAppViewProvider(AppViewProviders.blackskyKey)).called(1);
  });

  testWidgets('shows Video Upload Limits tile in Account section', (tester) async {
    final tokens = _authenticatedTokens();
    when(() => authBloc.state).thenReturn(AuthState.authenticated(tokens));
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: AuthState.authenticated(tokens));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Video Upload Limits'), 300);
    await tester.pumpAndSettle();

    expect(find.text('Video Upload Limits'), findsOneWidget);
    expect(find.text('Check your daily video quota'), findsOneWidget);
  });

  testWidgets('shows Account Maintenance section with Clean Follows tile', (tester) async {
    final tokens = _authenticatedTokens();
    when(() => authBloc.state).thenReturn(AuthState.authenticated(tokens));
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: AuthState.authenticated(tokens));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('ACCOUNT MAINTENANCE'), 300);
    await tester.pumpAndSettle();

    expect(find.text('ACCOUNT MAINTENANCE'), findsOneWidget);
    expect(find.text('Clean Follows'), findsOneWidget);
    expect(find.text('Audit and unfollow problematic accounts in bulk'), findsOneWidget);
  });

  testWidgets('shows legal rows in About section', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Terms of Service'), 300);
    await tester.pumpAndSettle();

    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
  });

  testWidgets('uses back button when unauthenticated', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byTooltip('Open menu'), findsNothing);
  });

  testWidgets('uses menu button when authenticated', (tester) async {
    final tokens = _authenticatedTokens();
    final authenticatedState = AuthState.authenticated(tokens);
    when(() => authBloc.state).thenReturn(authenticatedState);
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: authenticatedState);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byType(AppShellMenuButton), findsOneWidget);
  });

  testWidgets('public mode hides account-gated sections and logout controls', (tester) async {
    await tester.pumpWidget(
      RepositoryProvider<CrashReportingService>.value(
        value: crashReportingService,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<AccountSwitcherCubit>.value(value: accountSwitcherCubit),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Log Out'), findsNothing);
    expect(find.text('ACCOUNT'), findsNothing);
    expect(find.text('ACCOUNT MAINTENANCE'), findsNothing);
    expect(find.text('DANGER ZONE'), findsNothing);
    expect(find.text('Video Upload Limits'), findsNothing);
    expect(find.text('Clean Follows'), findsNothing);
    expect(find.text('APPEARANCE'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('AT Explorer'), 300);
    await tester.pumpAndSettle();
    expect(find.text('AT Explorer'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Terms of Service'), 300);
    await tester.pumpAndSettle();
    expect(find.text('Terms of Service'), findsOneWidget);
  });

  testWidgets('public mode Logs and About rows use public /settings routes', (tester) async {
    await tester.pumpWidget(buildPublicRoutedSubject());
    await tester.pumpAndSettle();

    final logsTile = find.widgetWithText(ListTile, 'Logs');
    await tester.scrollUntilVisible(logsTile, 300);
    await tester.pumpAndSettle();
    await tester.tap(logsTile);
    await tester.pumpAndSettle();
    expect(find.text('public-logs-screen'), findsOneWidget);

    final router = GoRouter.of(tester.element(find.text('public-logs-screen')));
    router.go('/');
    await tester.pumpAndSettle();

    final aboutTile = find.widgetWithText(ListTile, 'About');
    await tester.scrollUntilVisible(aboutTile, 300);
    await tester.pumpAndSettle();
    await tester.tap(aboutTile);
    await tester.pumpAndSettle();
    expect(find.text('public-about-screen'), findsOneWidget);
  });

  testWidgets('public mode AT Explorer row uses public /settings/devtools route', (tester) async {
    await tester.pumpWidget(buildPublicRoutedSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('AT Explorer'), 300);
    await tester.pumpAndSettle();
    await tester.tap(find.text('AT Explorer'));
    await tester.pumpAndSettle();

    expect(find.text('public-devtools-screen'), findsOneWidget);
  });

  testWidgets('tapping Clean Follows tile navigates to clean follows screen', (tester) async {
    final tokens = _authenticatedTokens();
    when(() => authBloc.state).thenReturn(AuthState.authenticated(tokens));
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: AuthState.authenticated(tokens));

    await tester.pumpWidget(buildRoutedSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Clean Follows'), 300);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clean Follows'));
    await tester.pumpAndSettle();

    expect(find.text('clean-follows'), findsOneWidget);
  });

  testWidgets('tapping Terms of Service row navigates to terms screen', (tester) async {
    await tester.pumpWidget(buildRoutedSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Terms of Service'), 300);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Terms of Service'));
    await tester.pumpAndSettle();

    expect(find.text('terms-screen'), findsOneWidget);
  });

  testWidgets('tapping Privacy Policy row navigates to privacy screen', (tester) async {
    await tester.pumpWidget(buildRoutedSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Privacy Policy'), 300);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();

    expect(find.text('privacy-screen'), findsOneWidget);
  });
}

AuthTokens _authenticatedTokens() {
  return const AuthTokens(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    did: 'did:plc:test',
    handle: 'test.bsky.social',
    displayName: 'Test User',
  );
}

String _buildJwt({required String aud, required String sub, required String clientId, required String iss}) {
  final header = _base64UrlEncode({'alg': 'none', 'typ': 'JWT'});
  final payload = _base64UrlEncode({
    'aud': aud,
    'sub': sub,
    'client_id': clientId,
    'scope': 'atproto transition:generic',
    'iss': iss,
    'exp': DateTime.now().toUtc().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
    'iat': DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
  });

  return '$header.$payload.signature';
}

String _base64UrlEncode(Map<String, Object> value) {
  return base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
}
