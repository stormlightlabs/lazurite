import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/core/logging/logging_bloc_observer.dart';
import 'package:lazurite/core/logging/logging_navigator_observer.dart';
import 'package:lazurite/core/router/app_router.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await log.initialize();
  Bloc.observer = LoggingBlocObserver();

  final database = AppDatabase();
  final authRepository = AuthRepository(database: database);
  final restoredSession = await authRepository.restoreSession();
  final authBloc = AuthBloc(
    authRepository: authRepository,
    initialState: restoredSession != null
        ? AuthState.authenticated(restoredSession)
        : const AuthState.unauthenticated(),
  );

  final settingsCubit = SettingsCubit(database: database);
  await settingsCubit.loadSettings();

  log.i('AppLogger: App started');

  runApp(LazuriteApp(authBloc: authBloc, database: database, settingsCubit: settingsCubit));
}

class LazuriteApp extends StatelessWidget {
  const LazuriteApp({super.key, required this.authBloc, required this.database, required this.settingsCubit});

  final AuthBloc authBloc;
  final AppDatabase database;
  final SettingsCubit settingsCubit;

  static final _navigatorObserver = LoggingNavigatorObserver();

  Bluesky? _createBluesky(AuthState state) {
    if (!state.isAuthenticated) {
      return null;
    }

    return createBlueskyClient(state.tokens);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: settingsCubit),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final bluesky = _createBluesky(authState);
          final appShell = BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              final themeMode = settingsState.useSystemTheme
                  ? ThemeMode.system
                  : (settingsState.themeVariant == AppThemeVariant.light ? ThemeMode.light : ThemeMode.dark);

              final lightTheme = AppTheme.getTheme(settingsState.themePalette, AppThemeVariant.light);
              final darkTheme = AppTheme.getTheme(settingsState.themePalette, AppThemeVariant.dark);

              return MaterialApp.router(
                title: 'Lazurite',
                debugShowCheckedModeBanner: false,
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeMode,
                routerConfig: AppRouter(authBloc: authBloc, navigatorObserver: _navigatorObserver).router,
              );
            },
          );

          if (bluesky == null) {
            return appShell;
          }

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => ProfileBloc(
                  profileRepository: ProfileRepository(database: database, bluesky: bluesky),
                ),
              ),
              BlocProvider(
                create: (_) => FeedBloc(feedRepository: FeedRepository(bluesky: bluesky)),
              ),
            ],
            child: appShell,
          );
        },
      ),
    );
  }
}
