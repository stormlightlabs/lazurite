import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';

void main() {
  Session buildSession({String handle = 'user', String token = 'access-token'}) {
    return Session(
      did: 'did:web:$handle',
      handle: '$handle.example.com',
      pdsUrl: 'https://$handle.example.com',
      accessJwt: token,
      refreshJwt: 'refresh-$token',
      scope: 'app.bsky.test',
      expiresAt: DateTime.utc(2024, 01, 01),
      dpopKey: const {'alg': 'ES256'},
    );
  }

  group('AuthState factories', () {
    test('creates unknown, unauthenticated, loading, and error states', () {
      expect(const AuthState.unknown(), isA<AuthStateUnknown>());
      expect(const AuthState.unauthenticated(), isA<AuthStateUnauthenticated>());
      expect(const AuthState.loading(), isA<AuthStateLoading>());

      final error = Exception('boom');
      final state = AuthState.error(error, StackTrace.empty);
      expect(state, isA<AuthStateError>());
      expect((state as AuthStateError).error, error);
    });

    test('authenticated state keeps provided session instance', () {
      final session = buildSession();
      final authState = AuthState.authenticated(session) as AuthStateAuthenticated;

      expect(authState.session, same(session));
    });
  });

  group('AuthStateAuthenticated equality', () {
    test('compares by session equality', () {
      final session = buildSession();

      expect(AuthState.authenticated(session), AuthState.authenticated(session.copyWith()));

      expect(
        AuthState.authenticated(session),
        isNot(AuthState.authenticated(buildSession(token: 'other-token'))),
      );
    });

    test('hashCode is consistent for equal states', () {
      final session = buildSession();
      final authState1 = AuthState.authenticated(session);
      final authState2 = AuthState.authenticated(session.copyWith());

      expect(authState1.hashCode, equals(authState2.hashCode));
    });
  });

  group('AuthStateError equality', () {
    test('compares all fields including stack trace', () {
      final st1 = StackTrace.fromString('one');
      final st2 = StackTrace.fromString('two');
      final error = Exception('boom');
      final first = AuthState.error(error, st1);
      final second = AuthState.error(error, st2);
      final third = AuthState.error(error, st1);

      expect(first, isNot(equals(second)));
      expect(first, equals(third));
    });
  });
}
