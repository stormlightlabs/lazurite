import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/widgets/lazurite_app_bar.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

void main() {
  late MockAuthBloc authBloc;
  late MockConnectivityCubit connectivityCubit;
  late MockSettingsCubit settingsCubit;

  const tokens = AuthTokens(
    accessToken: 'access',
    refreshToken: 'refresh',
    did: 'did:plc:test',
    handle: 'test.bsky.social',
    displayName: 'River Tam',
  );

  setUp(() {
    authBloc = MockAuthBloc();
    connectivityCubit = MockConnectivityCubit();
    settingsCubit = MockSettingsCubit();
    when(() => authBloc.state).thenReturn(const AuthState.authenticated(tokens));
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.authenticated(tokens));
    when(() => connectivityCubit.state).thenReturn(const ConnectivityState.online());
    whenListen(
      connectivityCubit,
      const Stream<ConnectivityState>.empty(),
      initialState: const ConnectivityState.online(),
    );
    when(() => settingsCubit.state).thenReturn(
      const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      ),
    );
    whenListen(
      settingsCubit,
      const Stream<SettingsState>.empty(),
      initialState: const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      ),
    );
    when(() => settingsCubit.setSimulateOffline(any())).thenAnswer((_) async {});
  });

  Widget buildSubject({required String sectionLabel, PreferredSizeWidget? bottom, List<Widget>? actions}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
      ],
      child: MaterialApp(
        home: Scaffold(
          appBar: LazuriteAppBar(sectionLabel: sectionLabel, bottom: bottom, actions: actions),
          body: const SizedBox.shrink(),
        ),
      ),
    );
  }

  testWidgets('renders section label in uppercase', (tester) async {
    await tester.pumpWidget(buildSubject(sectionLabel: 'Home'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('renders hamburger menu button', (tester) async {
    await tester.pumpWidget(buildSubject(sectionLabel: 'Search'));
    await tester.pumpAndSettle();
    expect(find.byType(AppShellMenuButton), findsOneWidget);
  });

  testWidgets('renders app bar when displayName is absent', (tester) async {
    authBloc = MockAuthBloc();
    const noDisplayName = AuthTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
      did: 'did:plc:test',
      handle: 'alice.bsky.social',
      displayName: null,
    );
    when(() => authBloc.state).thenReturn(const AuthState.authenticated(noDisplayName));
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.authenticated(noDisplayName));

    await tester.pumpWidget(buildSubject(sectionLabel: 'Home'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
    expect(find.byType(AppShellMenuButton), findsOneWidget);
  });

  testWidgets('shows simulated offline indicator and lets the user disable it', (tester) async {
    when(() => connectivityCubit.state).thenReturn(const ConnectivityState.online(isSimulatedOffline: true));
    whenListen(
      connectivityCubit,
      const Stream<ConnectivityState>.empty(),
      initialState: const ConnectivityState.online(isSimulatedOffline: true),
    );

    await tester.pumpWidget(buildSubject(sectionLabel: 'Home'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Disable simulated offline mode'), findsAtLeastNWidgets(1));

    await tester.tap(find.byTooltip('Disable simulated offline mode').first);
    await tester.pump();

    verify(() => settingsCubit.setSimulateOffline(false)).called(1);
  });

  testWidgets('preferred size height is 64 without bottom widget', (tester) async {
    const bar = LazuriteAppBar(sectionLabel: 'Home');
    expect(bar.preferredSize.height, 64);
  });

  testWidgets('preferred size height includes bottom widget height', (tester) async {
    const bottom = PreferredSize(preferredSize: Size.fromHeight(44), child: SizedBox(height: 44));
    const bar = LazuriteAppBar(sectionLabel: 'Home', bottom: bottom);
    expect(bar.preferredSize.height, 108);
  });

  testWidgets('renders bottom widget when provided', (tester) async {
    const bottom = PreferredSize(preferredSize: Size.fromHeight(44), child: Text('bottom-content'));
    await tester.pumpWidget(buildSubject(sectionLabel: 'Home', bottom: bottom));
    await tester.pumpAndSettle();

    expect(find.text('bottom-content'), findsOneWidget);
  });

  testWidgets('unauthenticated state still renders app bar shell', (tester) async {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthState.unauthenticated());
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.unauthenticated());

    await tester.pumpWidget(buildSubject(sectionLabel: 'Home'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(find.byType(AppShellMenuButton), findsOneWidget);
  });
}
