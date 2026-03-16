import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

void main() {
  group('AuthState', () {
    const tokens = AuthTokens(accessToken: 'token', did: 'did:plc:abc', handle: 'user.bsky.social');

    test('should create unauthenticated state', () {
      const state = AuthState.unauthenticated();

      expect(state.status, equals(AuthStatus.unauthenticated));
      expect(state.tokens, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isFalse);
    });

    test('should create authenticating state', () {
      const state = AuthState.authenticating();

      expect(state.status, equals(AuthStatus.authenticating));
      expect(state.tokens, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isTrue);
      expect(state.hasError, isFalse);
    });

    test('should create authenticated state', () {
      const state = AuthState.authenticated(tokens);

      expect(state.status, equals(AuthStatus.authenticated));
      expect(state.tokens, equals(tokens));
      expect(state.errorMessage, isNull);
      expect(state.isAuthenticated, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isFalse);
    });

    test('should create authError state', () {
      const state = AuthState.authError('Error message');

      expect(state.status, equals(AuthStatus.authError));
      expect(state.tokens, isNull);
      expect(state.errorMessage, equals('Error message'));
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isTrue);
    });

    test('should copy with new values', () {
      const state = AuthState.unauthenticated();
      final newState = state.copyWith(status: AuthStatus.authenticated, tokens: tokens);

      expect(newState.status, equals(AuthStatus.authenticated));
      expect(newState.tokens, equals(tokens));
    });

    test('should support value equality', () {
      const state1 = AuthState.unauthenticated();
      const state2 = AuthState.unauthenticated();

      expect(state1, equals(state2));
    });

    test('should have correct props', () {
      const state = AuthState.authenticated(tokens);

      expect(state.props, equals([AuthStatus.authenticated, tokens, null]));
    });
  });
}
