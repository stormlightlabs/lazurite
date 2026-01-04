/// OAuth 2.0 specific exceptions with typed error handling.
///
/// Provides structured error handling for OAuth 2.0 flows, including
/// standard error codes defined in RFC 6749 and OAuth extensions.
sealed class OAuthException implements Exception {
  const OAuthException({required this.error, this.errorDescription, this.errorUri});

  factory OAuthException.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as String?;
    final description = json['error_description'] as String?;
    final uri = json['error_uri'] as String?;

    if (error == null) {
      return UnknownOAuthException(
        error: 'unknown_error',
        errorDescription: description ?? 'An unknown OAuth error occurred',
        errorUri: uri,
      );
    }

    return switch (error) {
      'invalid_request' => InvalidRequestException(errorDescription: description, errorUri: uri),
      'invalid_grant' => InvalidGrantException(errorDescription: description, errorUri: uri),
      'invalid_client' => InvalidClientException(errorDescription: description, errorUri: uri),
      'unauthorized_client' => UnauthorizedClientException(
        errorDescription: description,
        errorUri: uri,
      ),
      'unsupported_grant_type' => UnsupportedGrantTypeException(
        errorDescription: description,
        errorUri: uri,
      ),
      'invalid_scope' => InvalidScopeException(errorDescription: description, errorUri: uri),
      'access_denied' => AccessDeniedException(errorDescription: description, errorUri: uri),
      'authorization_pending' => AuthorizationPendingException(
        errorDescription: description,
        errorUri: uri,
      ),
      'slow_down' => SlowDownException(errorDescription: description, errorUri: uri),
      'use_dpop_nonce' => UseDPoPNonceException(errorDescription: description, errorUri: uri),
      _ => UnknownOAuthException(error: error, errorDescription: description, errorUri: uri),
    };
  }

  /// The OAuth error code (e.g., "invalid_grant").
  final String error;

  /// Human-readable description of the error.
  final String? errorDescription;

  /// URI with more information about the error.
  final String? errorUri;

  @override
  String toString() {
    final buffer = StringBuffer('OAuthException: $error');
    if (errorDescription != null) {
      buffer.write(' - $errorDescription');
    }
    if (errorUri != null) {
      buffer.write(' (see: $errorUri)');
    }
    return buffer.toString();
  }
}

/// The request is missing a required parameter, includes an invalid parameter value,
/// includes a parameter more than once, or is otherwise malformed.
class InvalidRequestException extends OAuthException {
  const InvalidRequestException({super.errorDescription, super.errorUri})
    : super(error: 'invalid_request');
}

/// The provided authorization grant (e.g., authorization code, refresh token) is invalid,
/// expired, revoked, does not match the redirection URI, or was issued to another client.
///
/// Action: Clear session and require re-authentication.
class InvalidGrantException extends OAuthException {
  const InvalidGrantException({super.errorDescription, super.errorUri})
    : super(error: 'invalid_grant');
}

/// Client authentication failed (e.g., unknown client, no client authentication included, or
/// unsupported authentication method).
class InvalidClientException extends OAuthException {
  const InvalidClientException({super.errorDescription, super.errorUri})
    : super(error: 'invalid_client');
}

/// The authenticated client is not authorized to use this authorization grant type.
class UnauthorizedClientException extends OAuthException {
  const UnauthorizedClientException({super.errorDescription, super.errorUri})
    : super(error: 'unauthorized_client');
}

/// The authorization grant type is not supported by the authorization server.
class UnsupportedGrantTypeException extends OAuthException {
  const UnsupportedGrantTypeException({super.errorDescription, super.errorUri})
    : super(error: 'unsupported_grant_type');
}

/// The requested scope is invalid, unknown, malformed, or exceeds the scope granted by
/// the resource owner.
class InvalidScopeException extends OAuthException {
  const InvalidScopeException({super.errorDescription, super.errorUri})
    : super(error: 'invalid_scope');
}

/// The resource owner or authorization server denied the request.
///
/// Action: Inform user that authorization was denied.
class AccessDeniedException extends OAuthException {
  const AccessDeniedException({super.errorDescription, super.errorUri})
    : super(error: 'access_denied');
}

/// The authorization request is still pending (used in device flow).
///
/// Action: Continue polling.
class AuthorizationPendingException extends OAuthException {
  const AuthorizationPendingException({super.errorDescription, super.errorUri})
    : super(error: 'authorization_pending');
}

/// The client is polling too frequently.
///
/// Action: Increase polling interval (exponential backoff).
class SlowDownException extends OAuthException {
  const SlowDownException({super.errorDescription, super.errorUri}) : super(error: 'slow_down');
}

/// The server requires a DPoP nonce to be included in the proof.
///
/// Action: Extract nonce from response headers and retry with nonce.
class UseDPoPNonceException extends OAuthException {
  const UseDPoPNonceException({super.errorDescription, super.errorUri})
    : super(error: 'use_dpop_nonce');
}

/// An unknown or unhandled OAuth error occurred.
class UnknownOAuthException extends OAuthException {
  const UnknownOAuthException({required super.error, super.errorDescription, super.errorUri});
}
