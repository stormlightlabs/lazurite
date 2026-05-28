import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/app/auth_recovery_coordinator.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/auth/data/recent_auth_recovery_policy.dart';

void main() {
  group('AuthRecoveryCoordinator', () {
    late AuthState authState;
    late List<AuthTokens> published;
    late var sessionChecks = 0;
    late Set<String> publishableDids;
    late DateTime now;

    AuthTokens tokens({
      String did = 'did:plc:alice',
      String handle = 'alice.test',
      String accessToken = 'access-1',
      String refreshToken = 'refresh-1',
    }) => AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.now().add(const Duration(days: 1)),
      did: did,
      handle: handle,
      authMethod: AuthMethod.oauth,
    );

    AuthRecoveryCoordinator coordinator({
      required Future<AuthTokens?> Function(AuthTokens tokens) refreshSession,
      RecentAuthRecoveryPolicy? policy,
    }) => AuthRecoveryCoordinator(
      readAuthState: () => authState,
      refreshSession: refreshSession,
      publishSession: published.add,
      requestSessionCheck: () => sessionChecks += 1,
      canPublishRecoveryForDid: (did) => did != null && publishableDids.contains(did),
      recentRecoveryPolicy: policy,
    );

    setUp(() {
      final initial = tokens();
      authState = AuthState.authenticated(initial);
      published = <AuthTokens>[];
      sessionChecks = 0;
      publishableDids = <String>{initial.did};
      now = DateTime.utc(2026, 5, 28, 12);
    });

    test('returns null without refreshing when state is unauthenticated', () async {
      var refreshCount = 0;
      authState = const AuthState.unauthenticated();
      final subject = coordinator(
        refreshSession: (_) async {
          refreshCount += 1;
          return tokens(accessToken: 'access-2');
        },
      );

      final result = await subject.recover(trigger: 'test');

      expect(result, isNull);
      expect(refreshCount, 0);
      expect(published, isEmpty);
    });

    test('returns null without refreshing when current session has no refresh token', () async {
      var refreshCount = 0;
      authState = const AuthState.authenticated(
        AuthTokens(accessToken: 'access', did: 'did:plc:alice', handle: 'alice.test', authMethod: AuthMethod.oauth),
      );
      final subject = coordinator(
        refreshSession: (_) async {
          refreshCount += 1;
          return tokens(accessToken: 'access-2');
        },
      );

      final result = await subject.recover(trigger: 'test');

      expect(result, isNull);
      expect(refreshCount, 0);
      expect(published, isEmpty);
    });

    test('reuses recently refreshed tokens without spending refresh token again', () async {
      var refreshCount = 0;
      final current = tokens(accessToken: 'access-2');
      authState = AuthState.authenticated(current);
      final policy = RecentAuthRecoveryPolicy(now: () => now);
      policy.recordSuccess(current);
      final subject = coordinator(
        policy: policy,
        refreshSession: (_) async {
          refreshCount += 1;
          return tokens(accessToken: 'access-3');
        },
      );

      final result = await subject.recover(trigger: 'test');

      expect(result, current);
      expect(refreshCount, 0);
      expect(published, isEmpty);
    });

    test('coalesces simultaneous recovery calls by DID', () async {
      final refreshCompleter = Completer<AuthTokens?>();
      var refreshCount = 0;
      final refreshed = tokens(accessToken: 'access-2', refreshToken: 'refresh-2');
      final subject = coordinator(
        refreshSession: (_) {
          refreshCount += 1;
          return refreshCompleter.future;
        },
      );

      final first = subject.recover(trigger: 'first');
      final second = subject.recover(trigger: 'second');
      await Future<void>.delayed(Duration.zero);
      refreshCompleter.complete(refreshed);

      expect(await first, refreshed);
      expect(await second, refreshed);
      expect(refreshCount, 1);
      expect(published, <AuthTokens>[refreshed]);
    });

    test('publishes refreshed tokens when the account is still current', () async {
      final refreshed = tokens(accessToken: 'access-2', refreshToken: 'refresh-2');
      final subject = coordinator(refreshSession: (_) async => refreshed);

      final result = await subject.recover(trigger: 'test');

      expect(result, refreshed);
      expect(published, <AuthTokens>[refreshed]);
      expect(sessionChecks, 0);
    });

    test('does not publish when account switched during refresh', () async {
      final refreshed = tokens(accessToken: 'access-2', refreshToken: 'refresh-2');
      final subject = coordinator(
        refreshSession: (_) async {
          publishableDids.clear();
          return refreshed;
        },
      );

      final result = await subject.recover(trigger: 'test');

      expect(result, isNull);
      expect(published, isEmpty);
      expect(sessionChecks, 0);
    });

    test('does not publish refreshed tokens for a different DID', () async {
      final other = tokens(did: 'did:plc:bob', handle: 'bob.test', accessToken: 'access-2');
      final subject = coordinator(refreshSession: (_) async => other);

      final result = await subject.recover(trigger: 'test');

      expect(result, isNull);
      expect(published, isEmpty);
    });

    test('requests session check when refresh fails for the current account', () async {
      final subject = coordinator(refreshSession: (_) async => throw Exception('refresh failed'));

      final result = await subject.recover(trigger: 'test');

      expect(result, isNull);
      expect(sessionChecks, 1);
      expect(published, isEmpty);
    });

    test('does not request session check when refresh fails after account switch', () async {
      final subject = coordinator(
        refreshSession: (_) async {
          publishableDids.clear();
          throw Exception('refresh failed');
        },
      );

      final result = await subject.recover(trigger: 'test');

      expect(result, isNull);
      expect(sessionChecks, 0);
      expect(published, isEmpty);
    });
  });
}
