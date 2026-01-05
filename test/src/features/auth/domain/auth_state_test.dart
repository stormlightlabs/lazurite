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

    test('hashCode matches session hashCode', () {
      final session = buildSession();
      final authState = AuthState.authenticated(session) as AuthStateAuthenticated;

      expect(authState.hashCode, session.hashCode);
    });
  });

  group('AuthStateError equality', () {
    test('compares by error text regardless of stack trace', () {
      final first = AuthState.error(Exception('boom'), StackTrace.fromString('one'));
      final second = AuthState.error(Exception('boom'), StackTrace.fromString('two'));

      expect(first, equals(second));
      expect(first.hashCode, equals(second.hashCode));
    });
  });
}
