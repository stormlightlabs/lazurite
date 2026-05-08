import 'dart:async';
import 'dart:ui';

import 'package:bluesky/bluesky.dart';
import 'package:bluesky/bluesky_chat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/bootstrap/auth_bootstrap.dart';
import 'package:lazurite/core/cache/local_cache_maintenance_service.dart';
import 'package:lazurite/core/cache/offline_cache_policy.dart';
import 'package:lazurite/core/crash_reporting/crash_reporting_service.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/embedding/embedding_service.dart';
import 'package:lazurite/core/error_reporting/crash_report_screen.dart';
import 'package:lazurite/core/l10n/app_localizations.dart';
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
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/notifications/background/notification_background_worker.dart';
import 'package:lazurite/features/notifications/data/firebase_push_token_provider.dart';
import 'package:lazurite/features/notifications/data/flutter_local_notification_adapter.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  imageCache.maximumSize = OfflineCachePolicy.imageMemoryEntryLimit;
  imageCache.maximumSizeBytes = OfflineCachePolicy.imageMemoryByteLimit;

  await log.initialize();
  var firebaseAvailable = false;
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    firebaseAvailable = Firebase.apps.isNotEmpty;
  } catch (error, stackTrace) {
    log.w(
      'Firebase initialization failed; continuing with Firebase-dependent features disabled',
      error: error,
      stackTrace: stackTrace,
    );
  }

  final crashReportingService = firebaseAvailable ? FirebaseCrashReportingService() : NoopCrashReportingService();
  final previousFlutterErrorHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    previousFlutterErrorHandler?.call(details);
    log.f('Flutter fatal error', error: details.exception, stackTrace: details.stack);
    crashReportingService.recordFlutterFatalError(details);
  };
  ErrorWidget.builder = (details) => CrashReportScreen(details: details);
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    log.f('Platform fatal error', error: error, stackTrace: stackTrace);
    unawaited(crashReportingService.recordError(error, stackTrace, fatal: true));
    return true;
  };

  await PostScheduler.initialize();
  if (firebaseAvailable) {
    FirebaseMessaging.onBackgroundMessage(notificationFirebaseMessagingBackgroundHandler);
  }
  await NotificationBackgroundScheduler.ensureScheduled();
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
  await crashReportingService.setCollectionEnabled(settingsCubit.state.crashReportingEnabled);
  final authBloc = AuthBloc(
    authRepository: authRepository,
    initialState: restoredSession != null
        ? AuthState.authenticated(restoredSession)
        : const AuthState.unauthenticated(),
  );
  final connectivityCubit = ConnectivityCubit(simulateOffline: settingsCubit.state.simulateOffline);

  final accountSwitcherCubit = AccountSwitcherCubit(database: database, authRepository: authRepository);
  await accountSwitcherCubit.loadAccounts();
  final localNotificationAdapter = FlutterLocalNotificationAdapter();
  final pushTokenProvider = FirebasePushTokenProvider();
  final pushRegistrationService = PushRegistrationService(
    tokenProvider: pushTokenProvider,
    notificationRepositoryFactory: (tokens) {
      final bluesky = createBlueskyClient(tokens);
      if (bluesky == null) {
        throw StateError('Unable to create Bluesky client for push registration');
      }
      return NotificationRepository(
        bluesky: bluesky,
        appViewProviderResolver: () => settingsCubit.state.appViewProvider,
      );
    },
  );

  log.i('AppLogger: App started');

  runZonedGuarded(
    () {
      runApp(
        LazuriteApp.from(
          authBloc,
          authRepository,
          database,
          appViewFallbackService,
          objectBoxStore,
          embeddingService,
          settingsCubit,
          connectivityCubit,
          accountSwitcherCubit,
          localNotificationAdapter,
          pushRegistrationService,
          crashReportingService,
          firebaseAvailable,
        ),
      );
    },
    (error, stackTrace) {
      log.f('Zone fatal error', error: error, stackTrace: stackTrace);
      unawaited(crashReportingService.recordError(error, stackTrace, fatal: true));
    },
  );
}

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
  Completer<AuthTokens?>? _authRecoveryCompleter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _routerSessionKey = _sessionKeyFor(widget.authBloc.state);
    _observedAppViewProvider = widget.settingsCubit.state.appViewProvider;
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

  Future<void> _refreshExpiredSessionOnResume() async {
    final authState = widget.authBloc.state;
    final tokens = authState.tokens;
    if (!authState.isAuthenticated || tokens == null || !tokens.isExpired) {
      return;
    }
    await _recoverAuthSession(trigger: 'app_resumed');
  }

  Future<AuthTokens?> _recoverAuthSession({required String trigger}) async {
    final inFlight = _authRecoveryCompleter;
    if (inFlight != null) {
      return inFlight.future;
    }

    final completer = Completer<AuthTokens?>();
    _authRecoveryCompleter = completer;
    String? refreshingDid;
    try {
      final authState = widget.authBloc.state;
      final tokens = authState.tokens;
      if (!authState.isAuthenticated || tokens == null || tokens.refreshToken == null) {
        completer.complete(null);
        return null;
      }
      refreshingDid = tokens.did;

      final refreshed = await widget.authRepository.refreshSession(tokens);
      if (!_canPublishRecoveryForDid(refreshingDid)) {
        completer.complete(null);
        return null;
      }

      if (refreshed == null || refreshed.did != refreshingDid) {
        completer.complete(null);
        return null;
      }
      widget.authBloc.add(SessionRestored(tokens: refreshed));
      completer.complete(refreshed);
      return refreshed;
    } catch (error, stackTrace) {
      log.w('Auth recovery failed (trigger=$trigger)', error: error, stackTrace: stackTrace);
      if (_canPublishRecoveryForDid(refreshingDid)) {
        widget.authBloc.add(const CheckSessionRequested());
      }
      completer.complete(null);
      return null;
    } finally {
      if (identical(_authRecoveryCompleter, completer)) {
        _authRecoveryCompleter = null;
      }
    }
  }

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

                final lightTheme = AppTheme.getTheme(settingsState.themePalette, AppThemeVariant.light);
                final darkTheme = AppTheme.getTheme(settingsState.themePalette, AppThemeVariant.dark);

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
                  RepositoryProvider(
                    create: (_) => ConvoRepository(
                      chat: blueskyChat,
                      onUnauthorized: () => _recoverAuthSession(trigger: 'unauthorized_response'),
                    ),
                  ),
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
