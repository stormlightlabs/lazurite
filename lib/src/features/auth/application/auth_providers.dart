import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/auth/auth_repository.dart';
import '../../../infrastructure/auth/oauth_client.dart';
import '../../../infrastructure/auth/server_metadata.dart';
import '../../../infrastructure/auth/session_storage.dart';
import '../../../infrastructure/identity/identity_repository.dart';
import '../../../infrastructure/network/providers.dart';
import '../domain/auth_state.dart';

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
IdentityRepository identityRepository(Ref ref) {
  return IdentityRepository(dio: ref.watch(dioPublicProvider));
}

@Riverpod(keepAlive: true)
OAuthClient oauthClient(Ref ref) {
  return OAuthClient(dio: Dio());
}

@Riverpod(keepAlive: true)
ServerMetadataRepository serverMetadataRepository(Ref ref) {
  return ServerMetadataRepository(dio: ref.watch(dioPublicProvider));
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    identityRepository: ref.watch(identityRepositoryProvider),
    oauthClient: ref.watch(oauthClientProvider),
    sessionStorage: ref.watch(sessionStorageProvider),
    metadataRepository: ref.watch(serverMetadataRepositoryProvider),
    secureStorage: ref.watch(secureStorageProvider),
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
      await ref.read(authRepositoryProvider).login(handle);
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

  Future<void> logout() async {
    state = const AuthState.loading();
    try {
      // Get current session for revocation
      final session = await ref.read(sessionStorageProvider).getSession();

      // Revoke tokens on server (best-effort)
      if (session != null) {
        await ref.read(authRepositoryProvider).revokeSession(session);
      }

      // Clear local session regardless of revocation result
      await ref.read(sessionStorageProvider).clearSession();
      state = const AuthState.unauthenticated();
    } catch (e, st) {
      state = AuthState.error(e, st);
    }
  }
}
