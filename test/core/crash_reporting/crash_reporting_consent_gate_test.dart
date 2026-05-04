import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/crash_reporting/crash_reporting_consent_gate.dart';
import 'package:lazurite/core/crash_reporting/crash_reporting_service.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

class RecordingCrashReportingService implements CrashReportingService {
  final List<bool> collectionUpdates = <bool>[];
  var sendCalls = 0;
  var deleteCalls = 0;

  @override
  Future<void> deleteUnsentReports() async {
    deleteCalls += 1;
  }

  @override
  Future<void> recordError(Object error, StackTrace stackTrace, {bool fatal = false}) async {}

  @override
  void recordFlutterFatalError(FlutterErrorDetails details) {}

  @override
  Future<void> sendUnsentReports() async {
    sendCalls += 1;
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    collectionUpdates.add(enabled);
  }

  @override
  void crash() {}
}

void main() {
  late MockAuthBloc authBloc;
  late MockSettingsCubit settingsCubit;
  late RecordingCrashReportingService crashReportingService;
  late StreamController<AuthState> authController;
  late StreamController<SettingsState> settingsController;
  late SettingsState settingsState;

  setUp(() {
    authBloc = MockAuthBloc();
    settingsCubit = MockSettingsCubit();
    crashReportingService = RecordingCrashReportingService();
    authController = StreamController<AuthState>.broadcast();
    settingsController = StreamController<SettingsState>.broadcast();

    settingsState = const SettingsState(
      themePalette: AppThemePalette.oxocarbon,
      themeVariant: AppThemeVariant.dark,
      useSystemTheme: false,
      feedLayout: FeedLayout.card,
      crashReportingEnabled: false,
      crashReportingConsentPrompted: false,
    );

    whenListen(authBloc, authController.stream, initialState: const AuthState.unauthenticated());
    whenListen(settingsCubit, settingsController.stream, initialState: settingsState);

    when(() => settingsCubit.setCrashReportingConsentPrompted(any())).thenAnswer((invocation) async {
      final prompted = invocation.positionalArguments.first as bool;
      settingsState = settingsState.copyWith(crashReportingConsentPrompted: prompted);
      settingsController.add(settingsState);
    });
    when(() => settingsCubit.setCrashReportingEnabled(any())).thenAnswer((invocation) async {
      final enabled = invocation.positionalArguments.first as bool;
      settingsState = settingsState.copyWith(crashReportingEnabled: enabled);
      settingsController.add(settingsState);
    });
  });

  tearDown(() async {
    await authController.close();
    await settingsController.close();
  });

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: CrashReportingConsentGate(crashReportingService: crashReportingService, child: const Text('home')),
        ),
      ),
    );
  }

  testWidgets('shows consent dialog once on first authenticated usage', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    expect(find.text('Help Improve Stability?'), findsNothing);

    authController.add(
      const AuthState.authenticated(AuthTokens(accessToken: 'token', did: 'did:plc:test', handle: 'test.bsky.social')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Help Improve Stability?'), findsOneWidget);
    await tester.tap(find.text('Enable'));
    await tester.pumpAndSettle();

    verify(() => settingsCubit.setCrashReportingConsentPrompted(true)).called(1);
    verify(() => settingsCubit.setCrashReportingEnabled(true)).called(1);
    expect(crashReportingService.collectionUpdates, <bool>[true]);
    expect(crashReportingService.sendCalls, 1);
    expect(crashReportingService.deleteCalls, 0);

    authController.add(
      const AuthState.authenticated(
        AuthTokens(accessToken: 'token2', did: 'did:plc:other', handle: 'other.bsky.social'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Help Improve Stability?'), findsNothing);
  });

  testWidgets('not now persists decision and disables collection', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    authController.add(
      const AuthState.authenticated(AuthTokens(accessToken: 'token', did: 'did:plc:test', handle: 'test.bsky.social')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    verify(() => settingsCubit.setCrashReportingConsentPrompted(true)).called(1);
    verify(() => settingsCubit.setCrashReportingEnabled(false)).called(1);
    expect(crashReportingService.collectionUpdates, <bool>[false]);
    expect(crashReportingService.sendCalls, 0);
    expect(crashReportingService.deleteCalls, 1);
  });
}
