import 'package:dio/dio.dart';
import 'package:jose/jose.dart';
import 'dpop_utils.dart';

class OAuthClient {
  OAuthClient({required Dio dio}) : _dio = dio;

  final Dio _dio;

  static const kClientId =
      'https://lazurite.stormlightlabs.org/client-metadata.json'; // Placeholder
  static const kRedirectUri = 'org.stormlightlabs.lazurite://callback';
  static const kScope = 'atproto transition:generic';

  /// Performs Pushed Authorization Request (PAR).
  ///
  /// Returns the `request_uri` to be used in the authorization URL.
  Future<String> pushedAuthorizationRequest({
    required String pdsUrl,
    required JsonWebKey key,
    required String state,
    required String codeChallenge,
  }) async {
    final parUrl = '$pdsUrl/oauth/par';

    final proof = await DPoPUtils.createProof(url: parUrl, method: 'POST', privateKey: key);

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
      throw Exception('PAR failed: ${response.statusCode} ${response.data}');
    }

    final data = response.data!;
    return data['request_uri'] as String;
  }

  /// Exchanges the authorization code for tokens.
  Future<TokenResponse> exchangeCodeForToken({
    required String pdsUrl,
    required String code,
    required String codeVerifier,
    required JsonWebKey key,
  }) async {
    final tokenUrl = '$pdsUrl/oauth/token';

    final proof = await DPoPUtils.createProof(url: tokenUrl, method: 'POST', privateKey: key);

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
      throw Exception('Token exchange failed: ${response.statusCode} ${response.data}');
    }

    return TokenResponse.fromJson(response.data!);
  }

  /// Refreshes the access token using the refresh token.
  Future<TokenResponse> refreshToken({
    required String pdsUrl,
    required String refreshToken,
    required JsonWebKey key,
  }) async {
    final tokenUrl = '$pdsUrl/oauth/token';

    final proof = await DPoPUtils.createProof(url: tokenUrl, method: 'POST', privateKey: key);

    final response = await _dio.post<Map<String, dynamic>>(
      tokenUrl,
      options: Options(
        headers: {'DPoP': proof, 'Content-Type': 'application/x-www-form-urlencoded'},
      ),
      data: {'client_id': kClientId, 'grant_type': 'refresh_token', 'refresh_token': refreshToken},
    );

    if (response.statusCode != 200) {
      throw Exception('Token refresh failed: ${response.statusCode} ${response.data}');
    }

    return TokenResponse.fromJson(response.data!);
  }

  /// Builds the authorization URL for the browser.
  String buildAuthorizeUrl({required String pdsUrl, required String requestUri}) {
    return '$pdsUrl/oauth/authorize?client_id=$kClientId&request_uri=$requestUri';
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
