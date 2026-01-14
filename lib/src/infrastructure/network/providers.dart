import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/debug/infrastructure/debug_network_interceptor.dart';
import 'dio_clients.dart';
import 'xrpc_client.dart';

part 'providers.g.dart';

/// Provides public Dio client for unauthenticated API access.
///
/// This client is configured for public AppView at public.api.bsky.app.
@Riverpod(keepAlive: true)
Dio dioPublic(Ref ref) {
  final authState = ref.watch(authProvider);
  final session = authState is AuthStateAuthenticated ? authState.session : null;
  final db = ref.watch(appDatabaseProvider);
  final logger = ref.watch(loggerProvider('[Public-http]'));

  return createPublicDio(
    getSession: () => _readCurrentSession(ref),
    refreshSession: () => ref.read(authProvider.notifier).refreshActiveSession(),
    nonceStore: ref.read(dpopNonceStoreProvider),
    onSessionInvalidated: () {
      if (session != null) {
        try {
          db.feedContentDao.clearFeedContent('home', session.did);
        } catch (e) {
          logger.error('Failed to clear feed content for session ${session.did}', e);
        }
      }

      ref.read(authProvider.notifier).logout();
    },
    interceptors: [if (kDebugMode) DebugNetworkInterceptor(db.devToolsDao)],
  );
}

/// Provides PDS Dio client for authenticated API access.
///
/// This requires a logged-in user with a resolved PDS URL.
/// Returns null if no user is logged in.
@Riverpod(keepAlive: true)
Dio? dioPds(Ref ref) {
  final authState = ref.watch(authProvider);
  final session = authState is AuthStateAuthenticated ? authState.session : null;
  if (session == null) {
    return null;
  }

  final db = ref.watch(appDatabaseProvider);
  final logger = ref.watch(loggerProvider('[PDS-http]'));

  return createPdsDio(
    pdsUrl: session.pdsUrl,
    getSession: () => _readCurrentSession(ref),
    refreshSession: () => ref.read(authProvider.notifier).refreshActiveSession(),
    nonceStore: ref.read(dpopNonceStoreProvider),
    onSessionInvalidated: () {
      try {
        db.feedContentDao.clearFeedContent('home', session.did);
      } catch (e) {
        logger.error('Failed to clear feed content for session ${session.did}', e);
      }

      ref.read(authProvider.notifier).logout();
    },
    interceptors: [if (kDebugMode) DebugNetworkInterceptor(db.devToolsDao)],
  );
}

/// Provides video service Dio client for uploads.
///
/// This client uses service auth tokens instead of session tokens.
@Riverpod(keepAlive: true)
Dio dioVideoService(Ref ref) {
  return createVideoServiceDio(
    interceptors: [
      if (kDebugMode) DebugNetworkInterceptor(ref.watch(appDatabaseProvider).devToolsDao),
    ],
  );
}

/// Provides Tenor API Dio client for GIF search.
///
/// This client is used for GIF search and selection from Tenor.
@Riverpod(keepAlive: true)
Dio dioTenor(Ref ref) {
  return createTenorDio(
    interceptors: [
      if (kDebugMode) DebugNetworkInterceptor(ref.watch(appDatabaseProvider).devToolsDao),
    ],
  );
}

/// Provides XRPC client for making API requests.
///
/// This client automatically routes requests to correct host
/// based on endpoint metadata in the registry.
@Riverpod(keepAlive: true)
XrpcClient xrpcClient(Ref ref) {
  return XrpcClient(
    publicDio: ref.watch(dioPublicProvider),
    pdsDio: ref.watch(dioPdsProvider),
    videoServiceDio: ref.watch(dioVideoServiceProvider),
    tenorDio: ref.watch(dioTenorProvider),
    logger: ref.watch(loggerProvider('XrpcClient')),
  );
}

Future<Session?> _readCurrentSession(Ref ref) async {
  final authState = ref.read(authProvider);
  if (authState is AuthStateAuthenticated) {
    return authState.session;
  }
  return ref.read(sessionStorageProvider).getSession();
}
