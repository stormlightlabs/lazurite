import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/app/auth_recovery_coordinator.dart';
import 'package:lazurite/core/cache/local_cache_maintenance_service.dart';
import 'package:lazurite/core/crash_reporting/crash_reporting_service.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/embedding/embedding_service.dart';
import 'package:lazurite/core/l10n/app_localizations.dart';
import 'package:lazurite/core/logging/logging_navigator_observer.dart';
import 'package:lazurite/core/network/app_view_fallback_service.dart';
import 'package:lazurite/core/network/constellation_client.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/core/objectbox/objectbox_store.dart';
import 'package:lazurite/core/router/app_router.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
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
import 'package:lazurite/features/feed/data/similar_posts_repository.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/notifications/background/notification_background_worker.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/notifications/domain/local_notification_adapter.dart';
import 'package:lazurite/features/notifications/domain/notification_deep_link_navigator.dart';
import 'package:lazurite/features/notifications/domain/notification_domain_service.dart';
import 'package:lazurite/features/notifications/domain/notification_local_models.dart';
import 'package:lazurite/features/notifications/domain/push_registration_service.dart';
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
import 'package:lazurite/shared/presentation/widgets/global_tap_outside_unfocus.dart';

class LazuriteApp extends StatefulWidget {
  const LazuriteApp({
    super.key,
    required this.authBloc,
    required this.authRepository,
    required this.database,
    required this.appViewFallbackService,
    required this.objectBoxStore,
    required this.embeddingService,
    required this.settingsCubit,
    required this.connectivityCubit,
    required this.accountSwitcherCubit,
    required this.localNotificationAdapter,
    required this.pushRegistrationService,
    required this.crashReportingService,
    required this.firebaseAvailable,
  });

  final AuthBloc authBloc;
  final AuthRepository authRepository;
  final AppDatabase database;
  final AppViewFallbackService appViewFallbackService;
  final ObjectBoxStore objectBoxStore;
  final EmbeddingService embeddingService;
  final SettingsCubit settingsCubit;
  final ConnectivityCubit connectivityCubit;
  final AccountSwitcherCubit accountSwitcherCubit;
  final LocalNotificationAdapter localNotificationAdapter;
  final PushRegistrationService pushRegistrationService;
  final CrashReportingService crashReportingService;
  final bool firebaseAvailable;

  /// factory constructor with positional params
  static LazuriteApp from(
    AuthBloc authBloc,
    AuthRepository authRepository,
    AppDatabase database,
    AppViewFallbackService appViewFallbackService,
    ObjectBoxStore objectBoxStore,
    EmbeddingService embeddingService,
    SettingsCubit settingsCubit,
    ConnectivityCubit connectivityCubit,
    AccountSwitcherCubit accountSwitcherCubit,
    LocalNotificationAdapter localNotificationAdapter,
    PushRegistrationService pushRegistrationService,
    CrashReportingService crashReportingService,
    bool firebaseAvailable,
  ) => LazuriteApp(
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
    firebaseAvailable: firebaseAvailable,
  );

  @override
  State<LazuriteApp> createState() => _LazuriteAppState();
}

class _LazuriteAppState extends State<LazuriteApp> with WidgetsBindingObserver {
  static final _navigatorObserver = LoggingNavigatorObserver();
  late GoRouter _router;
  late String _routerSessionKey;
  late final StreamSubscription<String> _authSubscription;
  late final StreamSubscription<AuthTokens?> _pushRegistrationSubscription;
  StreamSubscription<RemoteMessage>? _pushForegroundMessageSubscription;
  late final StreamSubscription<bool> _simulateOfflineSubscription;
  late final StreamSubscription<String> _appViewProviderSubscription;
  late final StreamSubscription<AppViewRoutingEvent> _appViewEventSubscription;
  late String _observedAppViewProvider;
  var _routerGeneration = 0;
  var _isSoftRestarting = false;
  late final AuthRecoveryCoordinator _authRecoveryCoordinator;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _routerSessionKey = _sessionKeyFor(widget.authBloc.state);
    _observedAppViewProvider = widget.settingsCubit.state.appViewProvider;
    _authRecoveryCoordinator = AuthRecoveryCoordinator(
      readAuthState: () => widget.authBloc.state,
      refreshSession: widget.authRepository.refreshSession,
      publishSession: (tokens) => widget.authBloc.add(SessionRestored(tokens: tokens)),
      requestSessionCheck: () => widget.authBloc.add(const CheckSessionRequested()),
      canPublishRecoveryForDid: _canPublishRecoveryForDid,
    );
    _router = _createRouter();
    unawaited(
      widget.localNotificationAdapter.initialize(onTap: _handleNotificationDeepLink).then((_) {
        return widget.localNotificationAdapter.requestPermissions();
      }),
    );
    widget.pushRegistrationService.configureAuthRecovery(
      () => _recoverAuthSession(trigger: 'push_registration_unauthorized'),
    );
    unawaited(widget.pushRegistrationService.start(initialTokens: widget.authBloc.state.tokens));
    _pushRegistrationSubscription = widget.authBloc.stream.map((state) => state.tokens).listen((tokens) {
      unawaited(widget.pushRegistrationService.updateSession(tokens));
    });
    if (widget.firebaseAvailable) {
      _pushForegroundMessageSubscription = FirebaseMessaging.onMessage.listen((message) {
        unawaited(notificationPushPayloadEntrypoint(message.data));
      });
    }
    _authSubscription = widget.authBloc.stream.map(_sessionKeyFor).distinct().listen(_handleSessionKeyChanged);
    _simulateOfflineSubscription = widget.settingsCubit.stream
        .map((state) => state.simulateOffline)
        .distinct()
        .listen(widget.connectivityCubit.setSimulatedOffline);
    _appViewProviderSubscription = widget.settingsCubit.stream.map((state) => state.appViewProvider).listen((provider) {
      if (provider == _observedAppViewProvider) {
        return;
      }

      _observedAppViewProvider = provider;

      if (!widget.authBloc.state.isAuthenticated) {
        return;
      }

      unawaited(_softRestartForProviderChange());
    });
    _appViewEventSubscription = widget.appViewFallbackService.events.listen(
      widget.settingsCubit.recordAppViewRoutingEvent,
    );

    unawaited(widget.settingsCubit.refreshAppViewHealth());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription.cancel();
    _pushRegistrationSubscription.cancel();
    _pushForegroundMessageSubscription?.cancel();
    _simulateOfflineSubscription.cancel();
    _appViewProviderSubscription.cancel();
    _appViewEventSubscription.cancel();
    unawaited(widget.pushRegistrationService.dispose());

    widget.connectivityCubit.close();
    widget.appViewFallbackService.dispose();

    _router.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshExpiredSessionOnResume());
    }
  }

  /// Resume is a cheap chance to refresh expired tokens before the first visible
  /// request hits a 401. Valid sessions are left untouched.
  Future<void> _refreshExpiredSessionOnResume() async {
    final authState = widget.authBloc.state;
    final tokens = authState.tokens;
    if (!authState.isAuthenticated || tokens == null || !tokens.isExpired) {
      return;
    }
    await _recoverAuthSession(trigger: 'app_resumed');
  }

  Future<AuthTokens?> _recoverAuthSession({required String trigger}) =>
      _authRecoveryCoordinator.recover(trigger: trigger);

  /// Guard against publishing refreshed tokens after logout or account switch.
  bool _canPublishRecoveryForDid(String? refreshingDid) {
    if (!mounted || refreshingDid == null) {
      return false;
    }

    final state = widget.authBloc.state;
    return state.isAuthenticated && state.tokens?.did == refreshingDid;
  }

  GoRouter _createRouter() {
    return AppRouter(
      authBloc: widget.authBloc,
      navigatorObserver: _navigatorObserver,
      onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
    ).router;
  }

  /// Router state is keyed by DID so authenticated route providers are rebuilt
  /// when accounts change, but not for token rotations within the same account.
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

  Future<void> _softRestartForProviderChange() async {
    if (!mounted || _isSoftRestarting) {
      return;
    }

    setState(() {
      _isSoftRestarting = true;
    });

    final previousRouter = _router;

    widget.settingsCubit.bumpRoutingEpoch();

    setState(() {
      _routerGeneration += 1;
      _router = _createRouter();
    });

    previousRouter.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      setState(() {
        _isSoftRestarting = false;
      });
      unawaited(widget.settingsCubit.refreshAppViewHealth());
    }
  }

  void _handleNotificationDeepLink(NotificationDeepLink deepLink) {
    if (!mounted) {
      return;
    }
    NotificationDeepLinkNavigator.navigate(_router, deepLink);
  }

  bool _isAlertsRouteActive() {
    final path = _router.routerDelegate.currentConfiguration.uri.path;
    return path.startsWith('/alerts');
  }

  Bluesky? _createBluesky(AuthState state) => state.isAuthenticated ? createBlueskyClient(state.tokens) : null;

  BlueskyChat? _createBlueskyChat(AuthState state) =>
      state.isAuthenticated ? createBlueSkyChatClient(state.tokens) : null;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CrashReportingService>.value(value: widget.crashReportingService),
        RepositoryProvider<AppDatabase>.value(value: widget.database),
        RepositoryProvider(
          create: (_) => LocalCacheMaintenanceService(database: widget.database, objectBoxStore: widget.objectBoxStore),
        ),
      ],
      child: MultiBlocProvider(
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

                final lightTheme = AppTheme.getThemeFromState(AppThemeVariant.light, settingsState);
                final darkTheme = AppTheme.getThemeFromState(AppThemeVariant.dark, settingsState);

                return MaterialApp.router(
                  key: ValueKey('router-$_routerSessionKey-$_routerGeneration'),
                  title: 'Lazurite',
                  onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
                  debugShowCheckedModeBanner: false,
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: themeMode,
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  routerConfig: _router,
                  builder: (context, child) => GlobalTapOutsideUnfocus(
                    child: Stack(
                      children: [
                        ConnectivityBannerHost(child: child ?? const SizedBox.shrink()),
                        if (_isSoftRestarting)
                          const ColoredBox(
                            color: Color(0xC0000000),
                            child: Center(
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2.5),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Applying provider change...'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );

            if (bluesky == null || blueskyChat == null) {
              return appShell;
            }

            final accountDid = authState.tokens?.did ?? '';

            return KeyedSubtree(
              key: ValueKey('account-$accountDid-routing-${context.read<SettingsCubit>().state.routingEpoch}'),
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
                        onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
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
                      routingEpoch: context.read<SettingsCubit>().state.routingEpoch,
                      routingEpochResolver: () => context.read<SettingsCubit>().state.routingEpoch,
                      onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
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
                        routingEpoch: settingsCubit.state.routingEpoch,
                        routingEpochResolver: () => settingsCubit.state.routingEpoch,
                        onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
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
                        onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
                      );
                    },
                  ),
                  RepositoryProvider(
                    create: (context) => ListRepository(
                      bluesky: bluesky,
                      moderationService: context.read<ModerationService>(),
                      appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                      onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
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
                        onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
                      );
                    },
                  ),
                  RepositoryProvider(
                    create: (context) => NotificationRepository(
                      bluesky: bluesky,
                      moderationService: context.read<ModerationService>(),
                      appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                      onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
                    ),
                  ),
                  RepositoryProvider(
                    create: (context) => NotificationDomainService(
                      notificationRepository: context.read<NotificationRepository>(),
                      database: widget.database,
                      accountDid: accountDid,
                      localNotificationAdapter: widget.localNotificationAdapter,
                      shouldSuppressLocalNotifications: _isAlertsRouteActive,
                    ),
                  ),
                  RepositoryProvider(
                    create: (context) => PostThreadRepository(
                      bluesky: bluesky,
                      database: widget.database,
                      accountDid: accountDid,
                      moderationService: context.read<ModerationService>(),
                      appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                      onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
                    ),
                  ),
                  RepositoryProvider(
                    create: (context) => SimilarPostsRepository(
                      bluesky: bluesky,
                      constellationClient: ConstellationClient(
                        baseUrl: context.read<SettingsCubit>().state.constellationUrl,
                      ),
                      moderationService: context.read<ModerationService>(),
                      appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                      onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
                    ),
                  ),
                  RepositoryProvider(
                    create: (context) => StarterPackRepository(
                      bluesky: bluesky,
                      moderationService: context.read<ModerationService>(),
                      appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                      onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
                    ),
                  ),
                  RepositoryProvider(
                    create: (context) => PostActionRepository(
                      bluesky: bluesky,
                      appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                      onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
                    ),
                  ),
                  RepositoryProvider(
                    create: (context) => ProfileActionRepository(
                      bluesky: bluesky,
                      appViewProviderResolver: () => context.read<SettingsCubit>().state.appViewProvider,
                      onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
                    ),
                  ),
                  RepositoryProvider(
                    create: (_) => ConvoRepository(
                      chat: blueskyChat,
                      onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
                    ),
                  ),
                  RepositoryProvider(create: (_) => PostActionCache()),
                  RepositoryProvider(
                    create: (_) => VideoRepository(
                      bluesky: bluesky,
                      onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
                    ),
                  ),
                  RepositoryProvider.value(value: bluesky),
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
                      onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
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
                    BlocProvider(
                      create: (context) => ProfileBloc(profileRepository: context.read<ProfileRepository>()),
                    ),
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
                          UnreadCountCubit(notificationDomainService: context.read<NotificationDomainService>()),
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
      ),
    );
  }
}
