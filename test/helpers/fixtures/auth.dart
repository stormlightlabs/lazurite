import 'dart:convert';

import 'package:lazurite/features/auth/data/models/auth_models.dart';

String base64UrlEncode(Map<String, Object?> value) =>
    base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

String buildJwt({
  required String sub,
  String? aud,
  String? clientId,
  String? iss,
  String? scope,
  int? expEpochSeconds,
  int? iatEpochSeconds,
}) {
  final nowEpochSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  final header = base64UrlEncode(const {'alg': 'none', 'typ': 'JWT'});
  final payload = base64UrlEncode({
    'sub': sub,
    'exp': expEpochSeconds ?? nowEpochSeconds + 3600,
    'iat': iatEpochSeconds ?? nowEpochSeconds,
    'aud': ?aud,
    'client_id': ?clientId,
    'iss': ?iss,
    'scope': scope ?? (clientId == null ? 'atproto' : 'atproto transition:generic'),
  });

  return '$header.$payload.signature';
}

const Object _expiresAtDefault = Object();

AuthTokens testAliceTokens({
  String accessToken = 'opaque-access-token',
  String? refreshToken = 'refresh-token',
  DateTime? expiresAt,
}) => testAuthTokens(
  accessToken: accessToken,
  refreshToken: refreshToken,
  did: 'did:plc:alice',
  handle: 'alice.bsky.social',
  displayName: 'Alice',
  expiresAt: expiresAt,
);

AuthTokens testRiverTokens({String accessToken = 'access', String? refreshToken = 'refresh', DateTime? expiresAt}) =>
    testAuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      did: 'did:plc:me',
      handle: 'me.bsky.social',
      displayName: 'River Tam',
      expiresAt: expiresAt,
    );

AuthTokens testOAuthTokens({
  String accessToken = 'oauth-access-token',
  String? refreshToken = 'oauth-refresh-token',
  String did = 'did:plc:alice',
  String handle = 'alice.bsky.social',
  String? displayName = 'Alice',
  String service = 'https://pds.example.com',
  String oauthService = 'https://bsky.social',
  String oauthClientId = 'client-id',
  String oauthTokenType = 'DPoP',
  String oauthScope = 'atproto transition:generic',
  String? dpopNonce,
  String? dpopPublicKey,
  String? dpopPrivateKey,
  DateTime? expiresAt,
}) => testAuthTokens(
  accessToken: accessToken,
  refreshToken: refreshToken,
  did: did,
  handle: handle,
  displayName: displayName,
  service: service,
  oauthService: oauthService,
  oauthClientId: oauthClientId,
  oauthTokenType: oauthTokenType,
  oauthScope: oauthScope,
  dpopNonce: dpopNonce,
  dpopPublicKey: dpopPublicKey,
  dpopPrivateKey: dpopPrivateKey,
  authMethod: AuthMethod.oauth,
  expiresAt: expiresAt,
);

AuthTokens testOpaqueOAuthTokens({
  String accessToken = 'opaque-access-token',
  String? refreshToken = 'refresh-token',
  String did = 'did:plc:alice',
  String handle = 'alice.bsky.social',
  String? displayName = 'Alice',
  String service = 'https://pds.example.com',
  String oauthClientId = 'client-id',
  String oauthTokenType = 'DPoP',
  String oauthScope = 'atproto transition:generic',
  String? dpopNonce,
  String? dpopPublicKey,
  String? dpopPrivateKey,
  DateTime? expiresAt,
}) => testOAuthTokens(
  accessToken: accessToken,
  refreshToken: refreshToken,
  did: did,
  handle: handle,
  displayName: displayName,
  service: service,
  oauthClientId: oauthClientId,
  oauthTokenType: oauthTokenType,
  oauthScope: oauthScope,
  dpopNonce: dpopNonce,
  dpopPublicKey: dpopPublicKey,
  dpopPrivateKey: dpopPrivateKey,
  expiresAt: expiresAt,
);

AuthTokens testPdsOAuthTokens({
  String accessToken = 'access',
  String? refreshToken = 'refresh',
  String service = 'https://pds.example.com',
  DateTime? expiresAt,
}) => testOAuthTokens(accessToken: accessToken, refreshToken: refreshToken, service: service, expiresAt: expiresAt);

AuthTokens testAuthTokens({
  String accessToken = 'access-token',
  String? refreshToken = 'refresh-token',
  String did = 'did:plc:test',
  String handle = 'test.bsky.social',
  String? displayName,
  String? service = 'bsky.social',
  Object? expiresAt = _expiresAtDefault,
  String? oauthService,
  String? oauthClientId,
  String? oauthTokenType,
  String? oauthScope,
  String? dpopNonce,
  String? dpopPublicKey,
  String? dpopPrivateKey,
  AuthMethod authMethod = AuthMethod.appPassword,
}) => AuthTokens(
  accessToken: accessToken,
  refreshToken: refreshToken,
  expiresAt: identical(expiresAt, _expiresAtDefault)
      ? DateTime.now().toUtc().add(const Duration(hours: 1))
      : expiresAt as DateTime?,
  did: did,
  handle: handle,
  displayName: displayName,
  service: service,
  oauthService: oauthService,
  oauthClientId: oauthClientId,
  oauthTokenType: oauthTokenType,
  oauthScope: oauthScope,
  dpopNonce: dpopNonce,
  dpopPublicKey: dpopPublicKey,
  dpopPrivateKey: dpopPrivateKey,
  authMethod: authMethod,
);
