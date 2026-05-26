import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:poptart_core/poptart_core.dart' as atp_core;
import 'package:poptart_oauth/poptart_oauth.dart';

/// Restores poptart's OAuth session object from Lazurite's persisted account row.
///
/// Poptart understands both JWT and opaque access tokens when supplied with the
/// sidecar metadata we persist at login/refresh time. Always pass the stored PDS
/// endpoint: poptart normalizes host, URL, and `did:web:*` forms, and this avoids
/// duplicating token-claim parsing in Lazurite.
OAuthSession restoreOAuthSessionFromTokens(AuthTokens tokens) {
  final refreshToken = tokens.refreshToken;
  final publicKey = tokens.dpopPublicKey;
  final privateKey = tokens.dpopPrivateKey;
  if (refreshToken == null || publicKey == null || privateKey == null) {
    throw StateError('OAuth session restore requires refresh token and DPoP keys.');
  }

  return atp_core.restoreOAuthSession(
    accessToken: tokens.accessToken,
    refreshToken: refreshToken,
    tokenType: tokens.oauthTokenType,
    scope: tokens.oauthScope,
    expiresAt: tokens.expiresAt,
    sub: tokens.did,
    clientId: tokens.oauthClientId,
    pdsEndpoint: tokens.service,
    dPoPNonce: tokens.dpopNonce,
    publicKey: publicKey,
    privateKey: privateKey,
  );
}
