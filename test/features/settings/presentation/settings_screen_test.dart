import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/database/app_database.dart';
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

void main() {
  late MockAccountSwitcherCubit accountSwitcherCubit;
  late MockAuthBloc authBloc;
  late MockSettingsCubit settingsCubit;

  setUp(() {
    accountSwitcherCubit = MockAccountSwitcherCubit();
    authBloc = MockAuthBloc();
    settingsCubit = MockSettingsCubit();

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

  Widget buildRoutedSubject() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<AccountSwitcherCubit>.value(value: accountSwitcherCubit),
              BlocProvider<SettingsCubit>.value(value: settingsCubit),
            ],
            child: const SettingsScreen(),
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
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows active settings controls that are wired up', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('LAYOUT'), findsOneWidget);
    expect(find.text('Feed Layout'), findsOneWidget);
    expect(find.text('Thread Auto-Collapse'), findsOneWidget);
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

  testWidgets('shows Advanced section with Constellation URL tile', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('ADVANCED'), 300);
    await tester.pumpAndSettle();

    expect(find.text('ADVANCED'), findsOneWidget);
    expect(find.text('Constellation URL'), findsOneWidget);
    expect(find.text('https://constellation.microcosm.blue'), findsOneWidget);
  });

  testWidgets('Constellation URL tile opens edit dialog on tap', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Constellation URL'), 300);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Constellation URL'));
    await tester.pumpAndSettle();

    expect(find.text('Constellation URL'), findsWidgets);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('shows Video Upload Limits tile in Account section', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Video Upload Limits'), 300);
    await tester.pumpAndSettle();

    expect(find.text('Video Upload Limits'), findsOneWidget);
    expect(find.text('Check your daily video quota'), findsOneWidget);
  });

  testWidgets('shows Account Maintenance section with Clean Follows tile', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('ACCOUNT MAINTENANCE'), 300);
    await tester.pumpAndSettle();

    expect(find.text('ACCOUNT MAINTENANCE'), findsOneWidget);
    expect(find.text('Clean Follows'), findsOneWidget);
    expect(find.text('Audit and unfollow problematic accounts in bulk'), findsOneWidget);
  });

  testWidgets('tapping Clean Follows tile navigates to clean follows screen', (tester) async {
    await tester.pumpWidget(buildRoutedSubject());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Clean Follows'), 300);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clean Follows'));
    await tester.pumpAndSettle();

    expect(find.text('clean-follows'), findsOneWidget);
  });
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
