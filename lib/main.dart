import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/app/lazurite_app.dart';
import 'package:lazurite/core/bootstrap/auth_bootstrap.dart';
import 'package:lazurite/core/cache/offline_cache_policy.dart';
import 'package:lazurite/core/crash_reporting/crash_reporting_service.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/embedding/embedding_service.dart';
import 'package:lazurite/core/error_reporting/crash_report_screen.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/logging/logging_bloc_observer.dart';
import 'package:lazurite/core/network/app_view_fallback_service.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/app_view_router.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/core/objectbox/objectbox_store.dart';
import 'package:lazurite/core/scheduler/post_scheduler.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/notifications/background/notification_background_worker.dart';
import 'package:lazurite/features/notifications/data/firebase_push_token_provider.dart';
import 'package:lazurite/features/notifications/data/flutter_local_notification_adapter.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/notifications/domain/push_registration_service.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';

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
