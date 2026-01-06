import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/router.dart';
import '../../../core/utils/logger_provider.dart';
import '../../../infrastructure/auth/auth_repository.dart';
import '../../../infrastructure/auth/dpop_nonce_store.dart';
import '../../../infrastructure/auth/oauth_client.dart';
import '../../../infrastructure/auth/server_metadata.dart';
import '../../../infrastructure/auth/session_storage.dart';
import '../../../infrastructure/identity/identity_repository.dart';
import '../../../infrastructure/network/dio_clients.dart';
import '../domain/auth_state.dart';
import '../presentation/oauth_webview_screen.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) {
  return const FlutterSecureStorage();
}

@Riverpod(keepAlive: true)
SessionStorage sessionStorage(Ref ref) {
  return SessionStorage(storage: ref.watch(secureStorageProvider));
}

@Riverpod(keepAlive: true)
Dio authSupportDio(Ref ref) {
  return createPublicDio();
}

@Riverpod(keepAlive: true)
IdentityRepository identityRepository(Ref ref) {
  return IdentityRepository(
    dio: ref.watch(authSupportDioProvider),
    logger: ref.watch(loggerProvider('IdentityRepository')),
  );
}

@Riverpod(keepAlive: true)
DPoPNonceStore dpopNonceStore(Ref ref) {
  return DPoPNonceStore();
}

@Riverpod(keepAlive: true)
OAuthClient oauthClient(Ref ref) {
  return OAuthClient(
    dio: Dio(),
    logger: ref.watch(loggerProvider('OAuthClient')),
    nonceStore: ref.watch(dpopNonceStoreProvider),
  );
}

@Riverpod(keepAlive: true)
ServerMetadataRepository serverMetadataRepository(Ref ref) {
  return ServerMetadataRepository(dio: ref.watch(authSupportDioProvider));
}

@Riverpod(keepAlive: true)
OAuthBrowserCallback? oauthBrowserCallback(Ref ref) {
  if (!Platform.isIOS) return null;

  return (String authorizeUrl, String callbackUrlPrefix) async {
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) {
      throw Exception('Navigator not available for OAuth WebView');
    }

    final result = await navigator.push<Uri>(
      MaterialPageRoute(
        builder: (context) =>
            OAuthWebViewScreen(authorizeUrl: authorizeUrl, callbackUrlPrefix: callbackUrlPrefix),
      ),
    );

    if (result == null) {
      throw Exception('OAuth flow cancelled');
    }

    return result;
  };
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    identityRepository: ref.watch(identityRepositoryProvider),
    oauthClient: ref.watch(oauthClientProvider),
    sessionStorage: ref.watch(sessionStorageProvider),
    metadataRepository: ref.watch(serverMetadataRepositoryProvider),
    secureStorage: ref.watch(secureStorageProvider),
    nonceStore: ref.watch(dpopNonceStoreProvider),
    logger: ref.watch(loggerProvider('AuthRepository')),
    oauthBrowserCallback: ref.watch(oauthBrowserCallbackProvider),
  );
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _restoreSession();
    return const AuthState.loading();
  }

  Future<void> _restoreSession() async {
    state = const AuthState.loading();
    try {
      final session = await ref.read(sessionStorageProvider).getSession();
      if (session != null) {
        if (session.isExpired) {
          try {
            final newSession = await ref.read(authRepositoryProvider).refreshSession(session);
            state = AuthState.authenticated(newSession);
          } catch (e) {
            await ref.read(sessionStorageProvider).clearSession();
            state = const AuthState.unauthenticated();
          }
          return;
        }
        state = AuthState.authenticated(session);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e, st) {
      state = AuthState.error(e, st);
    }
  }

  Future<void> login(String handle) async {
    state = const AuthState.loading();
    try {
      final session = await ref.read(authRepositoryProvider).login(handle);
      state = AuthState.authenticated(session);
    } catch (e, st) {
      state = AuthState.error(e, st);
    }
  }

  Future<void> completeLogin(Uri uri) async {
    state = const AuthState.loading();
    try {
      final session = await ref.read(authRepositoryProvider).completeLogin(uri);
      state = AuthState.authenticated(session);
    } catch (e, st) {
      state = AuthState.error(e, st);
    }
  }

  Future<void> loginWithAppPassword(String handle, String password) async {
    state = const AuthState.loading();
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .loginWithAppPassword(handle, password);
      state = AuthState.authenticated(session);
    } catch (e, st) {
      state = AuthState.error(e, st);
    }
  }

  Future<void> logout() async {
    try {
      final session = await ref.read(sessionStorageProvider).getSession();

      if (session != null) {
        try {
          await ref.read(authRepositoryProvider).revokeSession(session);
        } catch (_) {
          /* Ignore revocation errors during logout */
        }
      }

      await ref.read(sessionStorageProvider).clearSession();
      state = const AuthState.unauthenticated();
    } catch (e, _) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<Session?> refreshActiveSession() async {
    final currentSession = await _currentSession();
    if (currentSession == null) {
      return null;
    }

    try {
      final refreshed = await ref.read(authRepositoryProvider).refreshSession(currentSession);
      state = AuthState.authenticated(refreshed);
      return refreshed;
    } catch (e, st) {
      state = AuthState.error(e, st);
      rethrow;
    }
  }

  Future<Session?> _currentSession() async {
    final currentState = state;
    if (currentState is AuthStateAuthenticated) {
      return currentState.session;
    }
    return ref.read(sessionStorageProvider).getSession();
  }
}
