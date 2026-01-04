/// Standardized failure types for network operations.
///
/// Uses a sealed class hierarchy to enable exhaustive pattern matching and provide type-safe
/// error handling.
sealed class NetworkFailure {
  const NetworkFailure({this.message, this.cause});

  /// Human-readable error message.
  final String? message;

  /// The underlying exception, if any.
  final Object? cause;
}

/// Connection-level failure (no network, DNS failure, timeout, etc.).
class ConnectionFailure extends NetworkFailure {
  const ConnectionFailure({super.message, super.cause});

  /// Whether this failure is due to a timeout.
  bool get isTimeout => message?.contains('timeout') ?? false;

  @override
  String toString() => 'ConnectionFailure(${message ?? 'Unknown connection error'})';
}

/// Authentication failure (401, invalid token, refresh failed).
class AuthFailure extends NetworkFailure {
  const AuthFailure({super.message, super.cause, this.requiresReauth = false});

  /// Whether the user needs to re-authenticate completely.
  ///
  /// True when token refresh has also failed.
  final bool requiresReauth;

  @override
  String toString() =>
      'AuthFailure(${message ?? 'Authentication failed'}, '
      'requiresReauth: $requiresReauth)';
}

/// Server-side error (5xx, upstream errors).
class ServerFailure extends NetworkFailure {
  const ServerFailure({super.message, super.cause, required this.statusCode});

  /// The HTTP status code returned by the server.
  final int statusCode;

  @override
  String toString() => 'ServerFailure($statusCode: ${message ?? 'Server error'})';
}

/// Client error (4xx, except 401 which is [AuthFailure]).
class ClientFailure extends NetworkFailure {
  const ClientFailure({super.message, super.cause, required this.statusCode, this.errorCode});

  /// The HTTP status code returned by the server.
  final int statusCode;

  /// ATProto error code, if available.
  ///
  /// Example: `InvalidRequest`, `RecordNotFound`
  final String? errorCode;

  @override
  String toString() =>
      'ClientFailure($statusCode${errorCode != null ? ', $errorCode' : ''}: '
      '${message ?? 'Client error'})';
}

/// Rate limit exceeded (429).
class RateLimitFailure extends NetworkFailure {
  const RateLimitFailure({super.message, super.cause, this.retryAfter});

  /// When to retry, if the server provided a Retry-After header.
  final Duration? retryAfter;

  @override
  String toString() => 'RateLimitFailure(retryAfter: $retryAfter)';
}

/// Response parsing/decoding failure.
class DecodeFailure extends NetworkFailure {
  const DecodeFailure({super.message, super.cause});

  @override
  String toString() => 'DecodeFailure(${message ?? 'Failed to decode response'})';
}
