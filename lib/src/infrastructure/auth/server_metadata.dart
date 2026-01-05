import 'package:dio/dio.dart';

/// OAuth 2.0 Authorization Server Metadata per RFC 8414.
///
/// Provides discovery of OAuth endpoints and capabilities via the
/// .well-known/oauth-authorization-server endpoint.
class ServerMetadata {
  const ServerMetadata({
    required this.issuer,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    this.pushedAuthorizationRequestEndpoint,
    this.revocationEndpoint,
    this.scopesSupported,
    this.responseTypesSupported,
    this.grantTypesSupported,
    this.codeChallengeMethodsSupported,
    this.tokenEndpointAuthMethodsSupported,
    this.dpopSigningAlgValuesSupported,
    this.requirePushedAuthorizationRequests = false,
  });

  factory ServerMetadata.fromJson(Map<String, dynamic> json) {
    return ServerMetadata(
      issuer: json['issuer'] as String,
      authorizationEndpoint: json['authorization_endpoint'] as String,
      tokenEndpoint: json['token_endpoint'] as String,
      pushedAuthorizationRequestEndpoint: json['pushed_authorization_request_endpoint'] as String?,
      revocationEndpoint: json['revocation_endpoint'] as String?,
      scopesSupported: (json['scopes_supported'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      responseTypesSupported: (json['response_types_supported'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      grantTypesSupported: (json['grant_types_supported'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      codeChallengeMethodsSupported: (json['code_challenge_methods_supported'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tokenEndpointAuthMethodsSupported:
          (json['token_endpoint_auth_methods_supported'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      dpopSigningAlgValuesSupported: (json['dpop_signing_alg_values_supported'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      requirePushedAuthorizationRequests:
          json['require_pushed_authorization_requests'] as bool? ?? false,
    );
  }

  /// The authorization server's issuer identifier (e.g., PDS URL).
  final String issuer;

  /// URL of the authorization endpoint.
  final String authorizationEndpoint;

  /// URL of the token endpoint.
  final String tokenEndpoint;

  /// URL of the Pushed Authorization Request (PAR) endpoint.
  final String? pushedAuthorizationRequestEndpoint;

  /// URL of the token revocation endpoint.
  final String? revocationEndpoint;

  /// List of supported OAuth scopes.
  final List<String>? scopesSupported;

  /// List of supported response types (e.g., ["code"]).
  final List<String>? responseTypesSupported;

  /// List of supported grant types (e.g., ["authorization_code", "refresh_token"]).
  final List<String>? grantTypesSupported;

  /// List of supported PKCE code challenge methods (e.g., ["S256"]).
  final List<String>? codeChallengeMethodsSupported;

  /// List of supported token endpoint authentication methods (e.g., ["none"]).
  final List<String>? tokenEndpointAuthMethodsSupported;

  /// List of supported DPoP signing algorithms (e.g., ["ES256"]).
  final List<String>? dpopSigningAlgValuesSupported;

  /// Whether the server requires PAR for all authorization requests.
  final bool requirePushedAuthorizationRequests;

  /// Validates that the server supports required features for ATProto.
  ///
  /// Throws an exception if required features are missing.
  void validateRequirements() {
    if (requirePushedAuthorizationRequests && pushedAuthorizationRequestEndpoint == null) {
      throw Exception('Server requires PAR but does not advertise PAR endpoint');
    }

    if (codeChallengeMethodsSupported != null &&
        !codeChallengeMethodsSupported!.contains('S256')) {
      throw Exception('Server does not support required PKCE method S256');
    }

    if (dpopSigningAlgValuesSupported != null &&
        !dpopSigningAlgValuesSupported!.contains('ES256')) {
      throw Exception('Server does not support required DPoP algorithm ES256');
    }

    if (grantTypesSupported != null &&
        (!grantTypesSupported!.contains('authorization_code') ||
            !grantTypesSupported!.contains('refresh_token'))) {
      throw Exception('Server does not support required grant types');
    }
  }

  Map<String, dynamic> toJson() => {
    'issuer': issuer,
    'authorization_endpoint': authorizationEndpoint,
    'token_endpoint': tokenEndpoint,
    if (pushedAuthorizationRequestEndpoint != null)
      'pushed_authorization_request_endpoint': pushedAuthorizationRequestEndpoint,
    if (revocationEndpoint != null) 'revocation_endpoint': revocationEndpoint,
    if (scopesSupported != null) 'scopes_supported': scopesSupported,
    if (responseTypesSupported != null) 'response_types_supported': responseTypesSupported,
    if (grantTypesSupported != null) 'grant_types_supported': grantTypesSupported,
    if (codeChallengeMethodsSupported != null)
      'code_challenge_methods_supported': codeChallengeMethodsSupported,
    if (tokenEndpointAuthMethodsSupported != null)
      'token_endpoint_auth_methods_supported': tokenEndpointAuthMethodsSupported,
    if (dpopSigningAlgValuesSupported != null)
      'dpop_signing_alg_values_supported': dpopSigningAlgValuesSupported,
    'require_pushed_authorization_requests': requirePushedAuthorizationRequests,
  };
}

/// Repository for discovering and caching OAuth server metadata.
class ServerMetadataRepository {
  ServerMetadataRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;
  final Map<String, _CachedMetadata> _cache = {};

  /// Discovers OAuth server metadata for the given PDS URL.
  ///
  /// Fetches metadata from the .well-known/oauth-authorization-server endpoint and caches it with a TTL.
  /// For Bluesky-hosted PDS instances (*.host.bsky.network), uses bsky.social as the OAuth server.
  Future<ServerMetadata> discover(String pdsUrl) async {
    final cached = _cache[pdsUrl];
    if (cached != null && !cached.isExpired) {
      return cached.metadata;
    }

    final oauthServer = _getOAuthServerUrl(pdsUrl);
    final metadataUrl = '$oauthServer/.well-known/oauth-authorization-server';

    try {
      final response = await _dio.get<Map<String, dynamic>>(metadataUrl);

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('Failed to fetch server metadata: ${response.statusCode}');
      }

      final metadata = ServerMetadata.fromJson(response.data!);

      metadata.validateRequirements();

      _cache[pdsUrl] = _CachedMetadata(
        metadata: metadata,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      return metadata;
    } catch (e) {
      return _defaultMetadata(oauthServer);
    }
  }

  /// Determines the OAuth server URL for a given PDS URL.
  ///
  /// For Bluesky-hosted PDS instances (*.host.bsky.network), returns https://bsky.social.
  /// For self-hosted instances, returns the PDS URL itself.
  String _getOAuthServerUrl(String pdsUrl) {
    final uri = Uri.parse(pdsUrl);

    if (uri.host.endsWith('.host.bsky.network')) {
      return 'https://bsky.social';
    }

    return pdsUrl;
  }

  /// Clears the metadata cache for a specific PDS URL or all entries.
  void clearCache([String? pdsUrl]) {
    if (pdsUrl != null) {
      _cache.remove(pdsUrl);
    } else {
      _cache.clear();
    }
  }

  /// Provides default metadata for servers without .well-known support.
  ServerMetadata _defaultMetadata(String pdsUrl) {
    return ServerMetadata(
      issuer: pdsUrl,
      authorizationEndpoint: '$pdsUrl/oauth/authorize',
      tokenEndpoint: '$pdsUrl/oauth/token',
      pushedAuthorizationRequestEndpoint: '$pdsUrl/oauth/par',
      revocationEndpoint: '$pdsUrl/oauth/revoke',
      scopesSupported: ['atproto', 'transition:generic'],
      responseTypesSupported: ['code'],
      grantTypesSupported: ['authorization_code', 'refresh_token'],
      codeChallengeMethodsSupported: ['S256'],
      tokenEndpointAuthMethodsSupported: ['none'],
      dpopSigningAlgValuesSupported: ['ES256'],
      requirePushedAuthorizationRequests: true,
    );
  }
}

class _CachedMetadata {
  _CachedMetadata({required this.metadata, required this.expiresAt});

  final ServerMetadata metadata;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
