import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/app/lazurite_app.dart';
import 'package:lazurite/core/crash_reporting/crash_reporting_service.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/embedding/embedding_service.dart';
import 'package:lazurite/core/network/app_view_fallback_service.dart';
import 'package:lazurite/core/objectbox/objectbox_store.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/notifications/domain/local_notification_adapter.dart';
import 'package:lazurite/features/notifications/domain/notification_local_models.dart';
import 'package:lazurite/features/notifications/domain/push_registration_service.dart';
import 'package:lazurite/features/public/presentation/public_home_screen.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/connectivity_helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockObjectBoxStore extends Mock implements ObjectBoxStore {}

class MockEmbeddingService extends Mock implements EmbeddingService {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

class MockAccountSwitcherCubit extends MockCubit<AccountSwitcherState> implements AccountSwitcherCubit {}

class MockLocalNotificationAdapter extends Mock implements LocalNotificationAdapter {}

class MockPushRegistrationService extends Mock implements PushRegistrationService {}

class MockCrashReportingService extends Mock implements CrashReportingService {}

const _oauthTokens = AuthTokens(
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
  did: 'did:plc:alice',
  handle: 'alice.test',
  authMethod: AuthMethod.oauth,
);

final class _AppHarness {
  _AppHarness({AuthState initialAuthState = const AuthState.unauthenticated()}) : authState = initialAuthState {
    when(() => authBloc.state).thenAnswer((_) => authState);
    whenListen(authBloc, authStream.stream, initialState: initialAuthState);
    when(() => settingsCubit.state).thenReturn(settingsState);
    whenListen(settingsCubit, settingsStream.stream, initialState: settingsState);
    when(() => settingsCubit.refreshAppViewHealth()).thenAnswer((_) async {});
    when(() => settingsCubit.bumpRoutingEpoch()).thenReturn(null);
    stubConnectivityCubit(connectivityCubit, state: const ConnectivityState.online());
    when(() => connectivityCubit.setSimulatedOffline(any())).thenReturn(null);
    when(() => connectivityCubit.close()).thenAnswer((_) async {});
    when(() => accountSwitcherCubit.state).thenReturn(const AccountSwitcherState.ready(accounts: []));
    whenListen(
      accountSwitcherCubit,
      const Stream<AccountSwitcherState>.empty(),
      initialState: const AccountSwitcherState.ready(accounts: []),
    );
    when(() => localNotificationAdapter.initialize(onTap: any(named: 'onTap'))).thenAnswer((_) async {});
    when(() => localNotificationAdapter.requestPermissions()).thenAnswer((_) async {});
    when(() => pushRegistrationService.configureAuthRecovery(any())).thenReturn(null);
    when(() => pushRegistrationService.start(initialTokens: any(named: 'initialTokens'))).thenAnswer((_) async {});
    when(() => pushRegistrationService.updateSession(any())).thenAnswer((_) async {});
    when(() => pushRegistrationService.dispose()).thenAnswer((_) async {});
  }

  AuthState authState;
  final authBloc = MockAuthBloc();
  final authRepository = MockAuthRepository();
  final database = MockAppDatabase();
  final appViewFallbackService = AppViewFallbackService();
  final objectBoxStore = MockObjectBoxStore();
  final embeddingService = MockEmbeddingService();
  final settingsCubit = MockSettingsCubit();
  final connectivityCubit = MockConnectivityCubit();
  final accountSwitcherCubit = MockAccountSwitcherCubit();
  final localNotificationAdapter = MockLocalNotificationAdapter();
  final pushRegistrationService = MockPushRegistrationService();
  final crashReportingService = MockCrashReportingService();
  final authStream = StreamController<AuthState>.broadcast();
  final settingsStream = StreamController<SettingsState>.broadcast();

  static const settingsState = SettingsState(
    themePalette: AppThemePalette.oxocarbon,
    themeVariant: AppThemeVariant.dark,
    useSystemTheme: false,
  );

  void setAuthState(AuthState state) {
    authState = state;
    when(() => authBloc.state).thenReturn(state);
  }

  LazuriteApp widget() => LazuriteApp(
    authBloc: authBloc,
    authRepository: authRepository,
    database: database,
    appViewFallbackService: appViewFallbackService,
    objectBoxStore: objectBoxStore,
    embeddingService: embeddingService,
    settingsCubit: settingsCubit,
    connectivityCubit: connectivityCubit,
    accountSwitcherCubit: accountSwitcherCubit,
    localNotificationAdapter: localNotificationAdapter,
    pushRegistrationService: pushRegistrationService,
    crashReportingService: crashReportingService,
    firebaseAvailable: false,
  );

  Future<void> dispose() async {
    await authStream.close();
    await settingsStream.close();
    appViewFallbackService.dispose();
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(const NotificationDeepLink(route: '/', navigationMode: NotificationTapNavigationMode.go));
    registerFallbackValue(const SessionRestored(tokens: _oauthTokens));
    registerFallbackValue(_oauthTokens);
  });

  testWidgets('keeps AppDatabase available to public routes after logout', (tester) async {
    final harness = _AppHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.widget());

    final publicContext = tester.element(find.byType(PublicHomeScreen));
    expect(publicContext.read<AppDatabase>(), same(harness.database));
  });

  test('from forwards positional dependencies into a LazuriteApp', () {
    final harness = _AppHarness();
    addTearDown(harness.dispose);

    final app = LazuriteApp.from(
      harness.authBloc,
      harness.authRepository,
      harness.database,
      harness.appViewFallbackService,
      harness.objectBoxStore,
      harness.embeddingService,
      harness.settingsCubit,
      harness.connectivityCubit,
      harness.accountSwitcherCubit,
      harness.localNotificationAdapter,
      harness.pushRegistrationService,
      harness.crashReportingService,
      false,
    );

    expect(app.authBloc, same(harness.authBloc));
    expect(app.authRepository, same(harness.authRepository));
    expect(app.database, same(harness.database));
    expect(app.firebaseAvailable, isFalse);
  });

  testWidgets('push auth recovery callback refreshes and publishes the current session', (tester) async {
    final harness = _AppHarness();
    addTearDown(harness.dispose);
    final refreshed = _oauthTokens.copyWith(accessToken: 'access-2', refreshToken: 'refresh-2');
    when(() => harness.authRepository.refreshSession(_oauthTokens)).thenAnswer((_) async => refreshed);

    await tester.pumpWidget(harness.widget());
    harness.setAuthState(const AuthState.authenticated(_oauthTokens));
    final capturedCallback =
        verify(() => harness.pushRegistrationService.configureAuthRecovery(captureAny())).captured.single
            as Future<AuthTokens?> Function();

    final result = await capturedCallback();

    expect(result, refreshed);
    verify(() => harness.authBloc.add(SessionRestored(tokens: refreshed))).called(1);
  });

  testWidgets('lifecycle resume refreshes an expired authenticated session', (tester) async {
    final expiredTokens = _oauthTokens.copyWith(expiresAt: DateTime.now().subtract(const Duration(minutes: 10)));
    final refreshed = expiredTokens.copyWith(accessToken: 'access-2', refreshToken: 'refresh-2');
    final harness = _AppHarness();
    addTearDown(harness.dispose);
    when(() => harness.authRepository.refreshSession(expiredTokens)).thenAnswer((_) async => refreshed);

    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(harness.widget());
    harness.setAuthState(AuthState.authenticated(expiredTokens));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    verify(() => harness.authRepository.refreshSession(expiredTokens)).called(1);
    verify(() => harness.authBloc.add(SessionRestored(tokens: refreshed))).called(1);
  });

  testWidgets('lifecycle resume leaves a valid authenticated session alone', (tester) async {
    final validTokens = _oauthTokens.copyWith(expiresAt: DateTime.now().add(const Duration(hours: 1)));
    final harness = _AppHarness();
    addTearDown(harness.dispose);

    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(harness.widget());
    harness.setAuthState(AuthState.authenticated(validTokens));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    verifyNever(() => harness.authRepository.refreshSession(any()));
  });
}
