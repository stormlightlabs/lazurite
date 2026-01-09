/// Error types for outbox message delivery.
///
/// Provides user-friendly error messages for different failure scenarios.
sealed class OutboxError {
  const OutboxError(this.userMessage);

  /// Human-readable message suitable for display in the UI.
  final String userMessage;

  /// Whether this error is transient and should be retried automatically.
  bool get isTransient;

  /// Creates an appropriate OutboxError from a failure.
  static OutboxError fromFailure(Object error) {
    return switch (error) {
      ConnectionError() => const OutboxNetworkError(),
      AuthError() => const OutboxAuthError(),
      ValidationError(:final message) => OutboxValidationError(message),
      RateLimitError() => const OutboxRateLimitError(),
      _ => OutboxServerError(error.toString()),
    };
  }
}

/// Network connectivity error (no internet, timeout).
///
/// These are transient and the message will send when online.
class OutboxNetworkError extends OutboxError {
  const OutboxNetworkError() : super('No internet connection. Message will send when online.');

  @override
  bool get isTransient => true;
}

/// Authentication error (session expired, invalid token).
///
/// User needs to sign in again.
class OutboxAuthError extends OutboxError {
  const OutboxAuthError() : super('Session expired. Please sign in again.');

  @override
  bool get isTransient => false;
}

/// Server error (5xx, upstream errors).
///
/// These are transient and will be retried automatically.
class OutboxServerError extends OutboxError {
  const OutboxServerError(String details) : super('Failed to send message. Tap to retry.');

  @override
  bool get isTransient => true;
}

/// Validation error (message too long, invalid content).
///
/// User needs to edit the message.
class OutboxValidationError extends OutboxError {
  OutboxValidationError(String? details)
    : super(details ?? 'Message could not be sent. Please edit and retry.');

  @override
  bool get isTransient => false;
}

/// Rate limit exceeded.
///
/// Transient error, will retry after delay.
class OutboxRateLimitError extends OutboxError {
  const OutboxRateLimitError() : super('Sending too fast. Message will retry shortly.');

  @override
  bool get isTransient => true;
}

/// Connection-level error marker.
class ConnectionError implements Exception {
  const ConnectionError();
}

/// Auth error marker.
class AuthError implements Exception {
  const AuthError();
}

/// Validation error marker.
class ValidationError implements Exception {
  const ValidationError({this.message});
  final String? message;
}

/// Rate limit error marker.
class RateLimitError implements Exception {
  const RateLimitError();
}
