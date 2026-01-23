import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_failure.freezed.dart';

/// Standardized failure types for network operations.
///
/// Uses a sealed class hierarchy via Freezed to enable exhaustive pattern matching
/// and provide type-safe error handling.
@freezed
sealed class NetworkFailure with _$NetworkFailure {
  const NetworkFailure._();

  /// Connection-level failure (no network, DNS failure, timeout, etc.).
  const factory NetworkFailure.connection({String? message, Object? cause}) = ConnectionFailure;

  /// Authentication failure (401, invalid token, refresh failed).
  const factory NetworkFailure.auth({
    String? message,
    Object? cause,
    @Default(false) bool requiresReauth,
  }) = AuthFailure;

  /// Server-side error (5xx, upstream errors).
  const factory NetworkFailure.server({String? message, Object? cause, required int statusCode}) =
      ServerFailure;

  /// Client error (4xx, except 401 which is [AuthFailure]).
  const factory NetworkFailure.client({
    String? message,
    Object? cause,
    required int statusCode,
    String? errorCode,
  }) = ClientFailure;

  /// Rate limit exceeded (429).
  const factory NetworkFailure.rateLimit({String? message, Object? cause, Duration? retryAfter}) =
      RateLimitFailure;

  /// Response parsing/decoding failure.
  const factory NetworkFailure.decode({String? message, Object? cause}) = DecodeFailure;

  /// Whether this failure is due to a timeout.
  bool get isTimeout => message?.contains('timeout') ?? false;

  @override
  String toString() {
    return when(
      connection: (msg, _) => 'ConnectionFailure(${msg ?? 'Unknown connection error'})',
      auth: (msg, _, reauth) =>
          'AuthFailure(${msg ?? 'Authentication failed'}, requiresReauth: $reauth)',
      server: (msg, _, code) => 'ServerFailure($code: ${msg ?? 'Server error'})',
      client: (msg, _, code, error) =>
          'ClientFailure($code${error != null ? ', $error' : ''}: ${msg ?? 'Client error'})',
      rateLimit: (_, _, after) => 'RateLimitFailure(retryAfter: $after)',
      decode: (msg, _) => 'DecodeFailure(${msg ?? 'Failed to decode response'})',
    );
  }
}
