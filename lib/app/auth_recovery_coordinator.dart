import 'dart:async';

import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/auth/data/recent_auth_recovery_policy.dart';

typedef AuthStateReader = AuthState Function();
typedef SessionRefresher = Future<AuthTokens?> Function(AuthTokens tokens);
typedef SessionPublisher = void Function(AuthTokens tokens);
typedef SessionCheckRequester = void Function();
typedef RecoveryPublishGuard = bool Function(String? did);

/// Coordinates auth recovery for stale in-memory clients, app resume, and
/// background work without requiring widget tests for every recovery branch.
final class AuthRecoveryCoordinator {
  AuthRecoveryCoordinator({
    required AuthStateReader readAuthState,
    required SessionRefresher refreshSession,
    required SessionPublisher publishSession,
    required SessionCheckRequester requestSessionCheck,
    required RecoveryPublishGuard canPublishRecoveryForDid,
    RecentAuthRecoveryPolicy? recentRecoveryPolicy,
  }) : _readAuthState = readAuthState,
       _refreshSession = refreshSession,
       _publishSession = publishSession,
       _requestSessionCheck = requestSessionCheck,
       _canPublishRecoveryForDid = canPublishRecoveryForDid,
       _recentRecoveryPolicy = recentRecoveryPolicy ?? RecentAuthRecoveryPolicy();

  final AuthStateReader _readAuthState;
  final SessionRefresher _refreshSession;
  final SessionPublisher _publishSession;
  final SessionCheckRequester _requestSessionCheck;
  final RecoveryPublishGuard _canPublishRecoveryForDid;
  final RecentAuthRecoveryPolicy _recentRecoveryPolicy;
  final Map<String, Completer<AuthTokens?>> _authRecoveryCompletersByDid = <String, Completer<AuthTokens?>>{};

  /// Shared auth recovery entry point. Recovery is coalesced by DID so
  /// simultaneous failures spend at most one rotating refresh token.
  Future<AuthTokens?> recover({required String trigger}) async {
    String? refreshingDid;
    Completer<AuthTokens?>? completer;
    try {
      final authState = _readAuthState();
      final tokens = authState.tokens;
      if (!authState.isAuthenticated || tokens == null || tokens.refreshToken == null) {
        return null;
      }

      refreshingDid = tokens.did;
      if (_recentRecoveryPolicy.shouldReuse(tokens)) {
        log.i('Auth recovery reused recently refreshed session (trigger=$trigger) for ${tokens.handle}');
        return tokens;
      }

      final inFlight = _authRecoveryCompletersByDid[refreshingDid];
      if (inFlight != null) {
        return inFlight.future;
      }

      completer = Completer<AuthTokens?>();
      _authRecoveryCompletersByDid[refreshingDid] = completer;

      final refreshed = await _refreshSession(tokens);
      if (!_canPublishRecoveryForDid(refreshingDid)) {
        completer.complete(null);
        return null;
      }

      if (refreshed == null || refreshed.did != refreshingDid) {
        completer.complete(null);
        return null;
      }

      _recentRecoveryPolicy.recordSuccess(refreshed);
      _publishSession(refreshed);
      completer.complete(refreshed);
      return refreshed;
    } catch (error, stackTrace) {
      log.w('Auth recovery failed (trigger=$trigger)', error: error, stackTrace: stackTrace);
      if (_canPublishRecoveryForDid(refreshingDid)) {
        _requestSessionCheck();
      } else if (refreshingDid != null) {
        _recentRecoveryPolicy.clear(refreshingDid);
      }
      completer?.complete(null);
      return null;
    } finally {
      if (refreshingDid != null && identical(_authRecoveryCompletersByDid[refreshingDid], completer)) {
        _authRecoveryCompletersByDid.remove(refreshingDid);
      }
    }
  }
}
