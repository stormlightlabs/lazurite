import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

void main() {
  group('AuthEvent', () {
    const tokens = AuthTokens(accessToken: 'token', did: 'did:plc:abc', handle: 'user.bsky.social');

    group('LoginRequested', () {
      test('should support value equality', () {
        const event1 = LoginRequested(handle: 'user.bsky.social', appPassword: 'password');
        const event2 = LoginRequested(handle: 'user.bsky.social', appPassword: 'password');

        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        const event = LoginRequested(handle: 'user.bsky.social', appPassword: 'password');

        expect(event.props, equals(['user.bsky.social', 'password']));
      });
    });

    group('OAuthLoginRequested', () {
      test('should support value equality', () {
        const event1 = OAuthLoginRequested(handle: 'user.bsky.social');
        const event2 = OAuthLoginRequested(handle: 'user.bsky.social');

        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        const event = OAuthLoginRequested(handle: 'user.bsky.social');

        expect(event.props, equals(['user.bsky.social']));
      });
    });

    group('LogoutRequested', () {
      test('should support value equality', () {
        const event1 = LogoutRequested();
        const event2 = LogoutRequested();

        expect(event1, equals(event2));
      });
    });

    group('LocalAuthDataClearRequested', () {
      test('should support value equality', () {
        const event1 = LocalAuthDataClearRequested();
        const event2 = LocalAuthDataClearRequested();

        expect(event1, equals(event2));
      });
    });

    group('SessionRestored', () {
      test('should support value equality', () {
        const event1 = SessionRestored(tokens: tokens);
        const event2 = SessionRestored(tokens: tokens);

        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        const event = SessionRestored(tokens: tokens);

        expect(event.props, equals([tokens]));
      });
    });

    group('CheckSessionRequested', () {
      test('should support value equality', () {
        const event1 = CheckSessionRequested();
        const event2 = CheckSessionRequested();

        expect(event1, equals(event2));
      });
    });
  });
}
