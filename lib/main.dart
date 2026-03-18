import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/scheduler/post_scheduler.dart';
import 'package:lazurite/core/logging/logging_bloc_observer.dart';
import 'package:lazurite/core/logging/logging_navigator_observer.dart';
import 'package:bluesky/bluesky_chat.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/core/router/app_router.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/devtools/cubit/dev_tools_cubit.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/search/bloc/search_bloc.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await log.initialize();
  await PostScheduler.initialize();
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

class LazuriteApp extends StatefulWidget {
  const LazuriteApp({super.key, required this.authBloc, required this.database, required this.settingsCubit});

  final AuthBloc authBloc;
  final AppDatabase database;
  final SettingsCubit settingsCubit;

  @override
  State<LazuriteApp> createState() => _LazuriteAppState();
}

class _LazuriteAppState extends State<LazuriteApp> {
  static final _navigatorObserver = LoggingNavigatorObserver();
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter(authBloc: widget.authBloc, navigatorObserver: _navigatorObserver).router;
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  Bluesky? _createBluesky(AuthState state) {
    if (!state.isAuthenticated) return null;
    return createBlueskyClient(state.tokens);
  }

  BlueskyChat? _createBlueskyChat(AuthState state) {
    if (!state.isAuthenticated) return null;
    return createBlueSkyChatClient(state.tokens);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.authBloc),
        BlocProvider.value(value: widget.settingsCubit),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final bluesky = _createBluesky(authState);
          final blueskyChat = _createBlueskyChat(authState);
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
                routerConfig: _router,
              );
            },
          );

          if (bluesky == null || blueskyChat == null) {
            return appShell;
          }

          final feedRepository = FeedRepository(bluesky: bluesky);
          final searchRepository = SearchRepository(bluesky: bluesky);
          final postActionRepository = PostActionRepository(bluesky: bluesky);
          final profileActionRepository = ProfileActionRepository(bluesky: bluesky);
          final accountDid = authState.tokens?.did ?? '';

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => ProfileBloc(
                  profileRepository: ProfileRepository(database: widget.database, bluesky: bluesky),
                ),
              ),
              BlocProvider(create: (_) => FeedBloc(feedRepository: feedRepository)),
              BlocProvider(
                create: (_) => FeedPreferencesCubit(
                  feedRepository: feedRepository,
                  database: widget.database,
                  accountDid: accountDid,
                )..loadPreferences(),
              ),
              BlocProvider(create: (_) => DevToolsCubit(atproto: bluesky.atproto)),
              BlocProvider(
                create: (_) =>
                    SearchBloc(searchRepository: searchRepository, database: widget.database, accountDid: accountDid),
              ),
              BlocProvider(
                create: (_) => SavedPostsCubit(
                  database: widget.database,
                  accountDid: accountDid,
                  postActionRepository: postActionRepository,
                ),
              ),
              RepositoryProvider.value(value: feedRepository),
              RepositoryProvider.value(value: searchRepository),
              RepositoryProvider.value(value: postActionRepository),
              RepositoryProvider(create: (_) => PostActionCache()),
              RepositoryProvider.value(value: profileActionRepository),
              RepositoryProvider.value(value: bluesky),
              RepositoryProvider(create: (_) => ConvoRepository(chat: blueskyChat)),
              RepositoryProvider.value(value: widget.database),
              RepositoryProvider.value(value: accountDid),
            ],
            child: appShell,
          );
        },
      ),
    );
  }
}
