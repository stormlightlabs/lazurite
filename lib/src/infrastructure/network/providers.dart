import 'package:dio/dio.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dio_clients.dart';
import 'xrpc_client.dart';

part 'providers.g.dart';

/// Provides the public Dio client for unauthenticated API access.
///
/// This client is configured for the public AppView at public.api.bsky.app.
@Riverpod(keepAlive: true)
Dio dioPublic(Ref ref) {
  return createPublicDio();
}

/// Provides the PDS Dio client for authenticated API access.
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

  return createPdsDio(
    pdsUrl: session.pdsUrl,
    getSession: () => _readCurrentSession(ref),
    refreshSession: () => ref.read(authProvider.notifier).refreshActiveSession(),
    onSessionInvalidated: () {
      // Clear user-specific cached data
      try {
        final db = ref.read(appDatabaseProvider);
        db.feedContentDao.clearFeedContent('home');
      } catch (e) {
        // Ignore if database not available
      }

      // Clear session and revert to unauthenticated state
      ref.read(authProvider.notifier).logout();
    },
  );
}

/// Provides the XRPC client for making API requests.
///
/// This client automatically routes requests to the correct host
/// based on endpoint metadata in the registry.
@Riverpod(keepAlive: true)
XrpcClient xrpcClient(Ref ref) {
  return XrpcClient(publicDio: ref.watch(dioPublicProvider), pdsDio: ref.watch(dioPdsProvider));
}

Future<Session?> _readCurrentSession(Ref ref) async {
  final authState = ref.read(authProvider);
  if (authState is AuthStateAuthenticated) {
    return authState.session;
  }
  return ref.read(sessionStorageProvider).getSession();
}
