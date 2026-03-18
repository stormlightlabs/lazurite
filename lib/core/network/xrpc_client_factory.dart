import 'package:atproto/atproto.dart' as atp;
import 'package:atproto_core/atproto_core.dart' as atp_core;
import 'package:atproto_oauth/atproto_oauth.dart' as atp_oauth;
import 'package:bluesky/bluesky.dart';
import 'package:bluesky/bluesky_chat.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

/// Creates a Bluesky client from authentication tokens.
///
/// OAuth tokens are scoped to the user's PDS. Let the SDK derive that
/// endpoint from the token instead of forcing the OAuth auth server host.
Bluesky? createBlueskyClient(AuthTokens? tokens) {
  if (tokens == null) {
    return null;
  }

  if (tokens.usesOAuth) {
    if (tokens.dpopPublicKey == null || tokens.dpopPrivateKey == null || tokens.refreshToken == null) {
      return null;
    }

    final oauthSession = atp_core.restoreOAuthSession(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken!,
      dPoPNonce: tokens.dpopNonce,
      publicKey: tokens.dpopPublicKey!,
      privateKey: tokens.dpopPrivateKey!,
    );

    return Bluesky.fromOAuthSession(oauthSession);
  }

  if (tokens.refreshToken == null) {
    return null;
  }

  final session = atp_core.Session(
    did: tokens.did,
    handle: tokens.handle,
    accessJwt: tokens.accessToken,
    refreshJwt: tokens.refreshToken!,
  );

  return Bluesky.fromSession(session, service: tokens.service);
}

BlueskyChat? createBlueSkyChatClient(AuthTokens? tokens) {
  if (tokens == null) return null;

  if (tokens.usesOAuth) {
    if (tokens.dpopPublicKey == null || tokens.dpopPrivateKey == null || tokens.refreshToken == null) {
      return null;
    }

    final oauthSession = atp_core.restoreOAuthSession(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken!,
      dPoPNonce: tokens.dpopNonce,
      publicKey: tokens.dpopPublicKey!,
      privateKey: tokens.dpopPrivateKey!,
    );

    return BlueskyChat.fromOAuthSession(oauthSession);
  }

  if (tokens.refreshToken == null) return null;

  final session = atp_core.Session(
    did: tokens.did,
    handle: tokens.handle,
    accessJwt: tokens.accessToken,
    refreshJwt: tokens.refreshToken!,
  );

  return BlueskyChat.fromSession(session, service: tokens.service);
}

atp.ATProto createAtProtoForOAuthSession(atp_oauth.OAuthSession session) {
  return atp.ATProto.fromOAuthSession(session);
}

Bluesky createBlueskyForOAuthSession(atp_oauth.OAuthSession session) {
  return Bluesky.fromOAuthSession(session);
}
