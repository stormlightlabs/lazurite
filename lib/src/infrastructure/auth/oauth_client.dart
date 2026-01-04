import 'package:dio/dio.dart';
import 'package:jose/jose.dart';

import '../../core/utils/logger.dart';
import 'dpop_utils.dart';
import 'oauth_exceptions.dart';
import 'server_metadata.dart';

class OAuthClient {
  OAuthClient({required Dio dio, Logger? logger})
      : _dio = dio,
        _logger = logger ?? const Logger('OAuthClient');

  final Dio _dio;
  final Logger _logger;

  static const kClientId = 'https://lazurite.stormlightlabs.org/client-metadata.json';
  static const kRedirectUri = 'org.stormlightlabs.lazurite://callback';
  static const kScope = 'atproto transition:generic';

  /// Performs Pushed Authorization Request (PAR).
  ///
  /// Returns the `request_uri` to be used in the authorization URL.
  Future<String> pushedAuthorizationRequest({
    required ServerMetadata metadata,
    required JsonWebKey key,
    required String state,
    required String codeChallenge,
    String? nonce,
  }) async {
    final parUrl = metadata.pushedAuthorizationRequestEndpoint;
    if (parUrl == null) {
      throw Exception('Server does not support PAR');
    }

    final proof = await DPoPUtils.createProof(
      url: parUrl,
      method: 'POST',
      privateKey: key,
      nonce: nonce,
    );

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        parUrl,
        options: Options(
          headers: {'DPoP': proof, 'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        data: {
          'client_id': kClientId,
          'response_type': 'code',
          'code_challenge': codeChallenge,
          'code_challenge_method': 'S256',
          'redirect_uri': kRedirectUri,
          'state': state,
          'scope': kScope,
        },
      );

      if (response.statusCode != 201) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          throw OAuthException.fromJson(response.data!);
        }
        throw Exception('PAR failed: ${response.statusCode} ${response.data}');
      }

      final data = response.data!;
      final requestUri = data['request_uri'] as String?;

      if (requestUri == null || requestUri.isEmpty) {
        throw Exception('PAR response missing or empty request_uri');
      }

      // Validate request_uri format (should start with 'urn:ietf:params:oauth:request_uri:')
      if (!requestUri.startsWith('urn:ietf:params:oauth:request_uri:')) {
        throw Exception('Invalid request_uri format: $requestUri');
      }

      final expiresIn = data['expires_in'] as int?;
      if (expiresIn == null) {
        throw Exception('PAR response missing expires_in');
      }

      // Warn if expires_in is too short (less than 30 seconds)
      if (expiresIn < 30) {
        _logger.warning('PAR expires_in is very short: $expiresIn seconds');
      }

      return requestUri;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
        throw OAuthException.fromJson(e.response!.data as Map<String, dynamic>);
      }
      rethrow;
    }
  }

  /// Exchanges the authorization code for tokens.
  Future<TokenResponse> exchangeCodeForToken({
    required ServerMetadata metadata,
    required String code,
    required String codeVerifier,
    required JsonWebKey key,
    String? nonce,
  }) async {
    final tokenUrl = metadata.tokenEndpoint;

    final proof = await DPoPUtils.createProof(
      url: tokenUrl,
      method: 'POST',
      privateKey: key,
      nonce: nonce,
    );

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        tokenUrl,
        options: Options(
          headers: {'DPoP': proof, 'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        data: {
          'client_id': kClientId,
          'grant_type': 'authorization_code',
          'code': code,
          'code_verifier': codeVerifier,
          'redirect_uri': kRedirectUri,
        },
      );

      if (response.statusCode != 200) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          throw OAuthException.fromJson(response.data!);
        }
        throw Exception('Token exchange failed: ${response.statusCode} ${response.data}');
      }

      return TokenResponse.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
        throw OAuthException.fromJson(e.response!.data as Map<String, dynamic>);
      }
      rethrow;
    }
  }

  /// Refreshes the access token using the refresh token.
  Future<TokenResponse> refreshToken({
    required ServerMetadata metadata,
    required String refreshToken,
    required JsonWebKey key,
    String? nonce,
  }) async {
    final tokenUrl = metadata.tokenEndpoint;

    final proof = await DPoPUtils.createProof(
      url: tokenUrl,
      method: 'POST',
      privateKey: key,
      nonce: nonce,
    );

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        tokenUrl,
        options: Options(
          headers: {'DPoP': proof, 'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        data: {
          'client_id': kClientId,
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode != 200) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          throw OAuthException.fromJson(response.data!);
        }
        throw Exception('Token refresh failed: ${response.statusCode} ${response.data}');
      }

      return TokenResponse.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
        throw OAuthException.fromJson(e.response!.data as Map<String, dynamic>);
      }
      rethrow;
    }
  }

  /// Revokes a token (access or refresh token).
  ///
  /// Calls the revocation endpoint to invalidate the token on the server.
  /// This should be called during logout to ensure tokens are invalidated.
  Future<void> revokeToken({
    required ServerMetadata metadata,
    required String token,
    required JsonWebKey key,
    String? nonce,
    String tokenTypeHint = 'refresh_token',
  }) async {
    final revocationUrl = metadata.revocationEndpoint;
    if (revocationUrl == null) {
      return;
    }

    final proof = await DPoPUtils.createProof(
      url: revocationUrl,
      method: 'POST',
      privateKey: key,
      nonce: nonce,
    );

    try {
      await _dio.post<void>(
        revocationUrl,
        options: Options(
          headers: {'DPoP': proof, 'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        data: {'client_id': kClientId, 'token': token, 'token_type_hint': tokenTypeHint},
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
        final error = OAuthException.fromJson(e.response!.data as Map<String, dynamic>);
        _logger.warning('Token revocation failed', error);
      }
    }
  }

  /// Builds the authorization URL for the browser.
  String buildAuthorizeUrl({required ServerMetadata metadata, required String requestUri}) {
    return '${metadata.authorizationEndpoint}?client_id=$kClientId&request_uri=$requestUri';
  }
}

class TokenResponse {
  TokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.refreshToken,
    required this.scope,
    required this.expiresIn,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      refreshToken: json['refresh_token'] as String?,
      scope: json['scope'] as String?,
      expiresIn: json['expires_in'] as int?,
    );
  }

  final String accessToken;
  final String tokenType;
  final String? refreshToken;
  final String? scope;
  final int? expiresIn;
}
