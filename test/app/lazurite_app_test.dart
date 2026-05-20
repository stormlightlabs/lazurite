import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/crash_reporting/crash_reporting_service.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/embedding/embedding_service.dart';
import 'package:lazurite/core/network/app_view_fallback_service.dart';
import 'package:lazurite/core/objectbox/objectbox_store.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/notifications/domain/local_notification_adapter.dart';
import 'package:lazurite/features/notifications/domain/notification_local_models.dart';
import 'package:lazurite/features/notifications/domain/push_registration_service.dart';
import 'package:lazurite/features/public/presentation/public_home_screen.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/app/lazurite_app.dart';
import 'package:mocktail/mocktail.dart';

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

void main() {
  setUpAll(() {
    registerFallbackValue(const NotificationDeepLink(route: '/', navigationMode: NotificationTapNavigationMode.go));
  });

  testWidgets('keeps AppDatabase available to public routes after logout', (tester) async {
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

    const settingsState = SettingsState(
      themePalette: AppThemePalette.oxocarbon,
      themeVariant: AppThemeVariant.dark,
      useSystemTheme: false,
    );

    when(() => authBloc.state).thenReturn(const AuthState.unauthenticated());
    whenListen(authBloc, authStream.stream, initialState: const AuthState.unauthenticated());
    when(() => settingsCubit.state).thenReturn(settingsState);
    whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: settingsState);
    when(() => settingsCubit.refreshAppViewHealth()).thenAnswer((_) async {});
    when(() => connectivityCubit.state).thenReturn(const ConnectivityState.online());
    whenListen(
      connectivityCubit,
      const Stream<ConnectivityState>.empty(),
      initialState: const ConnectivityState.online(),
    );
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
    when(() => pushRegistrationService.dispose()).thenAnswer((_) async {});

    addTearDown(() async {
      await authStream.close();
      appViewFallbackService.dispose();
    });

    await tester.pumpWidget(
      LazuriteApp(
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
      ),
    );

    final publicContext = tester.element(find.byType(PublicHomeScreen));
    expect(publicContext.read<AppDatabase>(), same(database));
  });
}
