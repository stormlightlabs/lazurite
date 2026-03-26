import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_architecture.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/features/settings/presentation/settings_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

void main() {
  late MockAuthBloc authBloc;
  late MockSettingsCubit settingsCubit;

  setUp(() {
    authBloc = MockAuthBloc();
    settingsCubit = MockSettingsCubit();

    when(() => authBloc.state).thenReturn(const AuthState.unauthenticated());
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.unauthenticated());

    when(() => settingsCubit.state).thenReturn(
      const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        feedArchitecture: FeedArchitecture.grid,
      ),
    );
    whenListen(
      settingsCubit,
      const Stream<SettingsState>.empty(),
      initialState: const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
        feedArchitecture: FeedArchitecture.grid,
      ),
    );
  });

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    );
  }

  testWidgets('shows active settings controls that are wired up', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('LAYOUT'), findsOneWidget);
    expect(find.text('Feed Architecture'), findsOneWidget);
    expect(find.text('Thread Auto-Collapse'), findsOneWidget);
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
}
