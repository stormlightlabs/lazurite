import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/auth/oauth_exceptions.dart';

void main() {
  group('OAuthException', () {
    group('fromJson', () {
      test('creates InvalidRequestException for invalid_request error', () {
        final json = {'error': 'invalid_request', 'error_description': 'Missing parameter'};
        final exception = OAuthException.fromJson(json);

        expect(exception, isA<InvalidRequestException>());
        expect(exception.error, equals('invalid_request'));
        expect(exception.errorDescription, equals('Missing parameter'));
      });

      test('creates InvalidGrantException for invalid_grant error', () {
        final json = {'error': 'invalid_grant'};
        final exception = OAuthException.fromJson(json);

        expect(exception, isA<InvalidGrantException>());
        expect(exception.error, equals('invalid_grant'));
      });

      test('creates InvalidClientException for invalid_client error', () {
        final json = {'error': 'invalid_client'};
        final exception = OAuthException.fromJson(json);

        expect(exception, isA<InvalidClientException>());
        expect(exception.error, equals('invalid_client'));
      });

      test('creates UnauthorizedClientException for unauthorized_client error', () {
        final json = {'error': 'unauthorized_client'};
        final exception = OAuthException.fromJson(json);

        expect(exception, isA<UnauthorizedClientException>());
        expect(exception.error, equals('unauthorized_client'));
      });

      test('creates UnsupportedGrantTypeException for unsupported_grant_type error', () {
        final json = {'error': 'unsupported_grant_type'};
        final exception = OAuthException.fromJson(json);

        expect(exception, isA<UnsupportedGrantTypeException>());
        expect(exception.error, equals('unsupported_grant_type'));
      });

      test('creates InvalidScopeException for invalid_scope error', () {
        final json = {'error': 'invalid_scope'};
        final exception = OAuthException.fromJson(json);

        expect(exception, isA<InvalidScopeException>());
        expect(exception.error, equals('invalid_scope'));
      });

      test('creates AccessDeniedException for access_denied error', () {
        final json = {'error': 'access_denied'};
        final exception = OAuthException.fromJson(json);

        expect(exception, isA<AccessDeniedException>());
        expect(exception.error, equals('access_denied'));
      });

      test('creates AuthorizationPendingException for authorization_pending error', () {
        final json = {'error': 'authorization_pending'};
        final exception = OAuthException.fromJson(json);

        expect(exception, isA<AuthorizationPendingException>());
        expect(exception.error, equals('authorization_pending'));
      });

      test('creates SlowDownException for slow_down error', () {
        final json = {'error': 'slow_down'};
        final exception = OAuthException.fromJson(json);

        expect(exception, isA<SlowDownException>());
        expect(exception.error, equals('slow_down'));
      });

      test('creates UseDPoPNonceException for use_dpop_nonce error', () {
        final json = {'error': 'use_dpop_nonce'};
        final exception = OAuthException.fromJson(json);

        expect(exception, isA<UseDPoPNonceException>());
        expect(exception.error, equals('use_dpop_nonce'));
      });

      test('creates UnknownOAuthException for unknown error codes', () {
        final json = {'error': 'unknown_error_code'};
        final exception = OAuthException.fromJson(json);

        expect(exception, isA<UnknownOAuthException>());
        expect(exception.error, equals('unknown_error_code'));
      });

      test('handles null error field', () {
        final json = {'error': null, 'error_description': 'Test'};
        final exception = OAuthException.fromJson(json);

        expect(exception, isA<UnknownOAuthException>());
        expect(exception.error, equals('unknown_error'));
        expect(exception.errorDescription, equals('Test'));
      });

      test('handles missing error field', () {
        final json = {'error_description': 'No error code'};
        final exception = OAuthException.fromJson(json);

        expect(exception, isA<UnknownOAuthException>());
        expect(exception.error, equals('unknown_error'));
        expect(exception.errorDescription, equals('No error code'));
      });

      test('includes error_description when present', () {
        final json = {
          'error': 'invalid_grant',
          'error_description': 'The refresh token is expired',
        };
        final exception = OAuthException.fromJson(json) as InvalidGrantException;

        expect(exception.errorDescription, equals('The refresh token is expired'));
      });

      test('includes error_uri when present', () {
        final json = {
          'error': 'invalid_request',
          'error_uri': 'https://example.com/docs/oauth/errors',
        };
        final exception = OAuthException.fromJson(json) as InvalidRequestException;

        expect(exception.errorUri, equals('https://example.com/docs/oauth/errors'));
      });

      test('handles all fields present', () {
        final json = {
          'error': 'invalid_grant',
          'error_description': 'Token expired',
          'error_uri': 'https://example.com/docs',
        };
        final exception = OAuthException.fromJson(json) as InvalidGrantException;

        expect(exception.error, equals('invalid_grant'));
        expect(exception.errorDescription, equals('Token expired'));
        expect(exception.errorUri, equals('https://example.com/docs'));
      });

      test('handles error code with incorrect casing', () {
        final json = {'error': 'Invalid_Grant'};
        final exception = OAuthException.fromJson(json);

        expect(exception, isA<UnknownOAuthException>());
        expect(exception.error, equals('Invalid_Grant'));
      });

      test('ignores extra fields in JSON', () {
        final json = {
          'error': 'invalid_grant',
          'error_description': 'Test',
          'extra_field': 'ignored',
          'another_field': 123,
        };
        final exception = OAuthException.fromJson(json) as InvalidGrantException;

        expect(exception.error, equals('invalid_grant'));
        expect(exception.errorDescription, equals('Test'));
      });
    });

    group('toString', () {
      test('includes error code', () {
        const exception = InvalidGrantException();
        final str = exception.toString();
        expect(str, contains('invalid_grant'));
      });

      test('includes error_description when present', () {
        const exception = InvalidGrantException(errorDescription: 'Token expired');
        final str = exception.toString();
        expect(str, contains('Token expired'));
      });

      test('includes error_uri when present', () {
        const exception = InvalidGrantException(
          errorDescription: 'Test',
          errorUri: 'https://example.com',
        );
        final str = exception.toString();
        expect(str, contains('https://example.com'));
      });

      test('formats without description when null', () {
        const exception = InvalidGrantException();
        final str = exception.toString();
        expect(str, contains('OAuthException: invalid_grant'));
      });

      test('formats with separator for description', () {
        const exception = InvalidGrantException(errorDescription: 'Expired');
        final str = exception.toString();
        expect(str, contains(' - Expired'));
      });

      test('formats with separator for URI', () {
        const exception = InvalidGrantException(errorUri: 'https://example.com');
        final str = exception.toString();
        expect(str, contains('(see: https://example.com)'));
      });
    });

    group('Specific exception types', () {
      test('InvalidRequestException has correct error code', () {
        const exception = InvalidRequestException();
        expect(exception.error, equals('invalid_request'));
      });

      test('InvalidGrantException has correct error code', () {
        const exception = InvalidGrantException();
        expect(exception.error, equals('invalid_grant'));
      });

      test('InvalidClientException has correct error code', () {
        const exception = InvalidClientException();
        expect(exception.error, equals('invalid_client'));
      });

      test('UnauthorizedClientException has correct error code', () {
        const exception = UnauthorizedClientException();
        expect(exception.error, equals('unauthorized_client'));
      });

      test('UnsupportedGrantTypeException has correct error code', () {
        const exception = UnsupportedGrantTypeException();
        expect(exception.error, equals('unsupported_grant_type'));
      });

      test('InvalidScopeException has correct error code', () {
        const exception = InvalidScopeException();
        expect(exception.error, equals('invalid_scope'));
      });

      test('AccessDeniedException has correct error code', () {
        const exception = AccessDeniedException();
        expect(exception.error, equals('access_denied'));
      });

      test('AuthorizationPendingException has correct error code', () {
        const exception = AuthorizationPendingException();
        expect(exception.error, equals('authorization_pending'));
      });

      test('SlowDownException has correct error code', () {
        const exception = SlowDownException();
        expect(exception.error, equals('slow_down'));
      });

      test('UseDPoPNonceException has correct error code', () {
        const exception = UseDPoPNonceException();
        expect(exception.error, equals('use_dpop_nonce'));
      });
    });
  });
}
