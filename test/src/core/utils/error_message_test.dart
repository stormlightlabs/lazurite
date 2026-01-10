import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/error_message.dart';
import 'package:lazurite/src/features/dms/domain/outbox_error.dart';
import 'package:lazurite/src/infrastructure/auth/oauth_exceptions.dart';
import 'package:lazurite/src/infrastructure/network/network_failure.dart';

void main() {
  group('errorMessage', () {
    test('returns network-friendly messages', () {
      expect(
        errorMessage(const ConnectionFailure()),
        'Network error. Check your connection and try again.',
      );
      expect(
        errorMessage(const AuthFailure(requiresReauth: true)),
        'Session expired. Please sign in again.',
      );
      expect(
        errorMessage(const RateLimitFailure(retryAfter: Duration(seconds: 12))),
        'Too many requests. Try again in 12s.',
      );
      expect(
        errorMessage(const ClientFailure(statusCode: 404)),
        'Not found. The item may have been deleted.',
      );
      expect(
        errorMessage(const ServerFailure(statusCode: 500)),
        'Server error. Please try again later.',
      );
      expect(
        errorMessage(const DecodeFailure()),
        'We received an unexpected response. Please try again.',
      );
    });

    test('returns OAuth and validation messages', () {
      const oauthError = InvalidGrantException(errorDescription: 'Token expired');
      expect(errorMessage(oauthError), 'Token expired');

      const validation = ValidationError(message: 'Message too long');
      expect(errorMessage(validation), 'Message too long');
    });

    test('handles format and auth state errors', () {
      expect(errorMessage(const FormatException('Invalid response')), 'Invalid response');
      expect(
        errorMessage(StateError('Must be authenticated to continue')),
        'Please sign in to continue.',
      );
    });

    test('falls back to default message for unknown errors', () {
      expect(errorMessage(Exception('oops')), 'Something went wrong. Please try again.');
      expect(errorMessage(null), 'Something went wrong. Please try again.');
    });
  });
}
