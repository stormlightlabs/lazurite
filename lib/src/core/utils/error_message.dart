import 'package:lazurite/src/features/dms/domain/outbox_error.dart';
import 'package:lazurite/src/infrastructure/auth/oauth_exceptions.dart';
import 'package:lazurite/src/infrastructure/network/network_failure.dart';

/// Returns a user-friendly error message for UI display.
String errorMessage(Object? error, {String fallback = 'Something went wrong. Please try again.'}) {
  if (error == null) return fallback;

  if (error is NetworkFailure) {
    return switch (error) {
      ConnectionFailure() => 'Network error. Check your connection and try again.',
      AuthFailure(:final requiresReauth) =>
        requiresReauth
            ? 'Session expired. Please sign in again.'
            : 'Authentication failed. Please try again.',
      RateLimitFailure(:final retryAfter) =>
        retryAfter != null
            ? 'Too many requests. Try again in ${retryAfter.inSeconds}s.'
            : 'Too many requests. Try again later.',
      ServerFailure() => 'Server error. Please try again later.',
      ClientFailure(:final statusCode) =>
        statusCode == 404
            ? 'Not found. The item may have been deleted.'
            : 'Request failed. Please try again.',
      DecodeFailure() => 'We received an unexpected response. Please try again.',
    };
  }

  if (error is OAuthException) {
    return error.errorDescription ?? 'Authorization failed. Please try again.';
  }

  if (error is ValidationError) {
    return error.message ?? 'Invalid input. Please update and retry.';
  }

  if (error is FormatException) {
    return error.message.isNotEmpty ? error.message : fallback;
  }

  if (error is StateError) {
    final message = error.message;
    if (message.contains('authenticated')) {
      return 'Please sign in to continue.';
    }
  }

  return fallback;
}
