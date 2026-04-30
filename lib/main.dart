import 'dart:async';

import 'package:bluesky/bluesky.dart';
import 'package:bluesky/bluesky_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/bootstrap/auth_bootstrap.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/embedding/embedding_service.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/logging/logging_bloc_observer.dart';
import 'package:lazurite/core/logging/logging_navigator_observer.dart';
import 'package:lazurite/core/network/app_view_fallback_service.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/app_view_router.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/core/objectbox/objectbox_store.dart';
import 'package:lazurite/core/router/app_router.dart';
import 'package:lazurite/core/scheduler/post_scheduler.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/connectivity/presentation/connectivity_banner_host.dart';
import 'package:lazurite/features/devtools/cubit/dev_tools_cubit.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
import 'package:lazurite/features/feed/cubit/liked_posts_sync_cubit.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/data/liked_posts_repository.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/data/post_thread_repository.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/search/bloc/search_bloc.dart';
import 'package:lazurite/features/search/cubit/semantic_index_cubit.dart';
import 'package:lazurite/features/search/cubit/semantic_search_cubit.dart';
import 'package:lazurite/features/search/data/embedding_repository.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:lazurite/features/search/data/semantic_indexer.dart';
import 'package:lazurite/features/search/data/semantic_search_repository.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/features/settings/data/video_repository.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await log.initialize();
  await PostScheduler.initialize();
  Bloc.observer = LoggingBlocObserver();

  final database = AppDatabase();
  final appViewFallbackService = AppViewFallbackService();
  final objectBoxStore = await ObjectBoxStore.open();
  final embeddingService = EmbeddingService();
  unawaited(embeddingService.initialize());
  final settingsCubit = SettingsCubit(database: database);
  final authBootstrap = await bootstrapAuthDependencies(
    loadSettings: settingsCubit.loadSettings,
    createAuthRepository: () => AuthRepository(
      database: database,
      oauthServiceResolver: () {
        final provider = AppViewProviders.descriptorForSetting(settingsCubit.state.appViewProvider);
        final router = AppViewRouter(provider: provider);
        return router.entrywayForAuth().host;
      },
      slingshotIdentityFallbackEnabledResolver: () => settingsCubit.state.slingshotIdentityFallbackEnabled,
    ),
    restoreSession: (authRepository) => authRepository.restoreSession(),
  );
  final authRepository = authBootstrap.authRepository;
  final restoredSession = authBootstrap.restoredSession;
  final authBloc = AuthBloc(
    authRepository: authRepository,
    initialState: restoredSession != null
        ? AuthState.authenticated(restoredSession)
        : const AuthState.unauthenticated(),
  );
  final connectivityCubit = ConnectivityCubit(simulateOffline: settingsCubit.state.simulateOffline);

  final accountSwitcherCubit = AccountSwitcherCubit(database: database, authRepository: authRepository);
  await accountSwitcherCubit.loadAccounts();

  log.i('AppLogger: App started');

  runApp(
    LazuriteApp.from(
      authBloc,
      database,
      appViewFallbackService,
      objectBoxStore,
      embeddingService,
      settingsCubit,
      connectivityCubit,
      accountSwitcherCubit,
    ),
  );
}

class LazuriteApp extends StatefulWidget {
  const LazuriteApp({
    super.key,
    required this.authBloc,
    required this.database,
    required this.appViewFallbackService,
    required this.objectBoxStore,
    required this.embeddingService,
    required this.settingsCubit,
    required this.connectivityCubit,
    required this.accountSwitcherCubit,
  });

  final AuthBloc authBloc;
  final AppDatabase database;
  final AppViewFallbackService appViewFallbackService;
  final ObjectBoxStore objectBoxStore;
  final EmbeddingService embeddingService;
  final SettingsCubit settingsCubit;
  final ConnectivityCubit connectivityCubit;
  final AccountSwitcherCubit accountSwitcherCubit;

  /// factory constructor with positional params
  static LazuriteApp from(
    AuthBloc authBloc,
    AppDatabase database,
    AppViewFallbackService appViewFallbackService,
    ObjectBoxStore objectBoxStore,
    EmbeddingService embeddingService,
    SettingsCubit settingsCubit,
    ConnectivityCubit connectivityCubit,
    AccountSwitcherCubit accountSwitcherCubit,
  ) => LazuriteApp(
    authBloc: authBloc,
    database: database,
    appViewFallbackService: appViewFallbackService,
    objectBoxStore: objectBoxStore,
    embeddingService: embeddingService,
    settingsCubit: settingsCubit,
    connectivityCubit: connectivityCubit,
    accountSwitcherCubit: accountSwitcherCubit,
  );

  @override
  State<LazuriteApp> createState() => _LazuriteAppState();
}

class _LazuriteAppState extends State<LazuriteApp> {
  static final _navigatorObserver = LoggingNavigatorObserver();
  late GoRouter _router;
  late String _routerSessionKey;
  late final StreamSubscription<String> _authSubscription;
  late final StreamSubscription<bool> _simulateOfflineSubscription;

  @override
  void initState() {
    super.initState();
    _routerSessionKey = _sessionKeyFor(widget.authBloc.state);
    _router = _createRouter();
    _authSubscription = widget.authBloc.stream.map(_sessionKeyFor).distinct().listen(_handleSessionKeyChanged);
    _simulateOfflineSubscription = widget.settingsCubit.stream
        .map((state) => state.simulateOffline)
        .distinct()
        .listen(widget.connectivityCubit.setSimulatedOffline);
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _simulateOfflineSubscription.cancel();
    widget.connectivityCubit.close();
    _router.dispose();
    super.dispose();
  }

  GoRouter _createRouter() {
    return AppRouter(authBloc: widget.authBloc, navigatorObserver: _navigatorObserver).router;
  }

  String _sessionKeyFor(AuthState state) => state.tokens?.did ?? 'guest';

  void _handleSessionKeyChanged(String sessionKey) {
    if (!mounted || sessionKey == _routerSessionKey) {
      return;
    }

    final previousRouter = _router;
    setState(() {
      _routerSessionKey = sessionKey;
      _router = _createRouter();
    });
    previousRouter.dispose();
  }

  Bluesky? _createBluesky(AuthState state) => state.isAuthenticated ? createBlueskyClient(state.tokens) : null;

  BlueskyChat? _createBlueskyChat(AuthState state) =>
      state.isAuthenticated ? createBlueSkyChatClient(state.tokens) : null;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.authBloc),
        BlocProvider.value(value: widget.settingsCubit),
        BlocProvider.value(value: widget.connectivityCubit),
        BlocProvider.value(value: widget.accountSwitcherCubit),
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
                key: ValueKey('router-$_routerSessionKey'),
                title: 'Lazurite',
                debugShowCheckedModeBanner: false,
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeMode,
                routerConfig: _router,
                builder: (context, child) => ConnectivityBannerHost(child: child ?? const SizedBox.shrink()),
              );
            },
          );

          if (bluesky == null || blueskyChat == null) {
            return appShell;
          }

          final accountDid = authState.tokens?.did ?? '';

          return KeyedSubtree(
            key: ValueKey('account-$accountDid'),
            child: MultiRepositoryProvider(
              providers: [
                RepositoryProvider(
                  create: (_) {
                    final settingsCubit = context.read<SettingsCubit>();
                    final moderationService = ModerationService(
                      bluesky: bluesky,
                      database: widget.database,
                      accountDid: accountDid,
                      userDid: accountDid,
                      appViewProviderResolver: () => settingsCubit.state.appViewProvider,
                    );
                    unawaited(moderationService.ensureInitialized());
                    return moderationService;
                  },
                  dispose: (moderationService) => moderationService.dispose(),
                ),
                RepositoryProvider(
                  create: (context) => FeedRepository(
                    bluesky: bluesky,
                    database: widget.database,
                    accountDid: accountDid,
                    moderationService: context.read<ModerationService>(),
                    appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                    crossProviderFallbackEnabledResolver: () =>
                        context.read<SettingsCubit>().state.crossProviderFallbackEnabled,
                    appViewFallbackService: widget.appViewFallbackService,
                  ),
                ),
                RepositoryProvider(
                  create: (context) {
                    final settingsCubit = context.read<SettingsCubit>();
                    return SearchRepository(
                      bluesky: bluesky,
                      moderationService: context.read<ModerationService>(),
                      appViewProviderResolver: () => settingsCubit.state.appViewProvider,
                      crossProviderFallbackEnabledResolver: () => settingsCubit.state.crossProviderFallbackEnabled,
                      appViewFallbackService: widget.appViewFallbackService,
                    );
                  },
                ),
                RepositoryProvider(
                  create: (context) {
                    final settingsCubit = context.read<SettingsCubit>();
                    return TypeaheadRepository(
                      bluesky: bluesky,
                      providerResolver: () => settingsCubit.state.typeaheadProvider,
                      appViewProviderResolver: () => settingsCubit.state.appViewProvider,
                      moderationService: context.read<ModerationService>(),
                    );
                  },
                ),
                RepositoryProvider(
                  create: (context) => ListRepository(
                    bluesky: bluesky,
                    moderationService: context.read<ModerationService>(),
                    appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                  ),
                ),
                RepositoryProvider(
                  create: (context) {
                    final service = context.read<ModerationService>();
                    return ProfileRepository(
                      database: widget.database,
                      bluesky: bluesky,
                      moderationService: service,
                      appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                    );
                  },
                ),
                RepositoryProvider(
                  create: (context) => NotificationRepository(
                    bluesky: bluesky,
                    moderationService: context.read<ModerationService>(),
                    appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                  ),
                ),
                RepositoryProvider(
                  create: (context) => PostThreadRepository(
                    bluesky: bluesky,
                    moderationService: context.read<ModerationService>(),
                    appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                  ),
                ),
                RepositoryProvider(
                  create: (context) => StarterPackRepository(
                    bluesky: bluesky,
                    moderationService: context.read<ModerationService>(),
                    appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                  ),
                ),
                RepositoryProvider(
                  create: (context) => PostActionRepository(
                    bluesky: bluesky,
                    appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                  ),
                ),
                RepositoryProvider(
                  create: (context) => ProfileActionRepository(
                    bluesky: bluesky,
                    appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                  ),
                ),
                RepositoryProvider(create: (_) => ConvoRepository(chat: blueskyChat)),
                RepositoryProvider(create: (_) => PostActionCache()),
                RepositoryProvider(create: (_) => VideoRepository(bluesky: bluesky)),
                RepositoryProvider.value(value: bluesky),
                RepositoryProvider.value(value: widget.database),
                RepositoryProvider.value(value: widget.objectBoxStore),
                RepositoryProvider.value(value: widget.embeddingService),
                RepositoryProvider(create: (context) => EmbeddingRepository(context.read<ObjectBoxStore>())),
                RepositoryProvider(
                  create: (context) => SemanticIndexer(
                    embeddingService: context.read<EmbeddingService>(),
                    embeddingRepository: context.read<EmbeddingRepository>(),
                    database: widget.database,
                  ),
                ),
                RepositoryProvider(
                  create: (context) => LikedPostsRepository(
                    bluesky: bluesky,
                    database: widget.database,
                    semanticIndexer: context.read<SemanticIndexer>(),
                    appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                  ),
                ),
                RepositoryProvider(
                  create: (context) => SemanticSearchRepository(
                    embeddingService: context.read<EmbeddingService>(),
                    embeddingRepository: context.read<EmbeddingRepository>(),
                    database: widget.database,
                  ),
                ),
                RepositoryProvider.value(value: accountDid),
              ],
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(create: (context) => ProfileBloc(profileRepository: context.read<ProfileRepository>())),
                  BlocProvider(create: (context) => FeedBloc(feedRepository: context.read<FeedRepository>())),
                  BlocProvider(
                    create: (context) => FeedPreferencesCubit(
                      feedRepository: context.read<FeedRepository>(),
                      database: widget.database,
                      accountDid: accountDid,
                    )..loadPreferences(),
                  ),
                  BlocProvider(create: (_) => DevToolsCubit(atproto: bluesky.atproto)),
                  BlocProvider(
                    create: (context) => SearchBloc(
                      searchRepository: context.read<SearchRepository>(),
                      typeaheadRepository: context.read<TypeaheadRepository>(),
                      database: widget.database,
                      accountDid: accountDid,
                    ),
                  ),
                  BlocProvider(
                    create: (context) =>
                        ConvoListBloc(convoRepository: context.read<ConvoRepository>())
                          ..add(const ConvosRequested(limit: 100)),
                  ),
                  BlocProvider(
                    create: (context) => SavedPostsCubit(
                      database: widget.database,
                      accountDid: accountDid,
                      postActionRepository: context.read<PostActionRepository>(),
                      semanticIndexer: context.read<SemanticIndexer>(),
                    ),
                  ),
                  BlocProvider(
                    create: (context) => SemanticSearchCubit(
                      repository: context.read<SemanticSearchRepository>(),
                      embeddingService: context.read<EmbeddingService>(),
                      accountDid: accountDid,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => SemanticIndexCubit(
                      indexer: context.read<SemanticIndexer>(),
                      embeddingRepository: context.read<EmbeddingRepository>(),
                      accountDid: accountDid,
                    ),
                  ),
                  BlocProvider(
                    create: (context) =>
                        LikedPostsSyncCubit(repository: context.read<LikedPostsRepository>(), accountDid: accountDid),
                  ),
                ],
                child: appShell,
              ),
            ),
          );
        },
      ),
    );
  }
}
