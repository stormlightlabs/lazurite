import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:jose/jose.dart';
import 'package:uuid/uuid.dart';

class DPoPUtils {
  static const _uuid = Uuid();

  /// Generates a new EC key pair (P-256) for DPoP.
  static Future<JsonWebKey> generateKey() async => JsonWebKey.generate('ES256');

  /// Creates a signed DPoP proof JWT.
  ///
  /// [url] is the full URL of the request.
  /// [method] is the HTTP method (GET, POST, etc).
  /// [privateKey] is the JWK used for signing.
  /// [nonce] is the optional DPoP-Nonce from the server.
  /// [accessToken] is the optional access token (ath) to bind.
  static Future<String> createProof({
    required String url,
    required String method,
    required JsonWebKey privateKey,
    String? nonce,
    String? accessToken,
  }) async {
    final claims = JsonWebTokenClaims.fromJson({
      'htm': method.toUpperCase(),
      'htu': url,
      'iat': (DateTime.now().millisecondsSinceEpoch / 1000).floor(),
      'jti': _uuid.v4(),
      if (nonce != null) 'nonce': nonce,
      if (accessToken != null)
        'ath': base64Url
            .encode(sha256.convert(utf8.encode(accessToken)).bytes)
            .replaceAll('=', ''),
    });

    final builder = JsonWebSignatureBuilder();
    builder.jsonContent = claims.toJson();

    builder.setProtectedHeader('typ', 'dpop+jwt');

    final publicJwk = {
      'kty': privateKey.toJson()['kty'],
      'crv': privateKey.toJson()['crv'],
      'x': privateKey.toJson()['x'],
      'y': privateKey.toJson()['y'],
      'use': 'sig',
    };
    builder.setProtectedHeader('jwk', publicJwk);
    builder.setProtectedHeader('alg', 'ES256');

    builder.addRecipient(privateKey);

    final jws = builder.build();
    return jws.toCompactSerialization();
  }
}
