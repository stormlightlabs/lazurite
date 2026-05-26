import 'package:lazurite/core/network/oauth_session_restorer.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart' as atp;
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/xrpc_network_interceptor.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:poptart_core/poptart_core.dart' as atp_core;
import 'package:poptart_oauth/poptart_oauth.dart' as atp_oauth;

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

    final oauthSession = restoreOAuthSessionFromTokens(tokens);

    return Bluesky.fromOAuthSession(oauthSession, getClient: _wrappedGetClient(), postClient: _wrappedPostClient());
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

  return Bluesky.fromSession(
    session,
    service: tokens.service,
    getClient: _wrappedGetClient(),
    postClient: _wrappedPostClient(),
  );
}

BlueskyChat? createBlueSkyChatClient(AuthTokens? tokens) {
  if (tokens == null) return null;

  if (tokens.usesOAuth) {
    if (tokens.dpopPublicKey == null || tokens.dpopPrivateKey == null || tokens.refreshToken == null) {
      return null;
    }

    final oauthSession = restoreOAuthSessionFromTokens(tokens);

    return BlueskyChat.fromOAuthSession(oauthSession, getClient: _wrappedGetClient(), postClient: _wrappedPostClient());
  }

  if (tokens.refreshToken == null) return null;

  final session = atp_core.Session(
    did: tokens.did,
    handle: tokens.handle,
    accessJwt: tokens.accessToken,
    refreshJwt: tokens.refreshToken!,
  );

  return BlueskyChat.fromSession(
    session,
    service: tokens.service,
    getClient: _wrappedGetClient(),
    postClient: _wrappedPostClient(),
  );
}

atp.ATProto createAtProtoForOAuthSession(atp_oauth.OAuthSession session) =>
    atp.ATProto.fromOAuthSession(session, getClient: _wrappedGetClient(), postClient: _wrappedPostClient());

Bluesky createBlueskyForOAuthSession(atp_oauth.OAuthSession session) =>
    Bluesky.fromOAuthSession(session, getClient: _wrappedGetClient(), postClient: _wrappedPostClient());

atp_core.GetClient _wrappedGetClient() => XrpcNetworkInterceptor.wrapGetClient();

atp_core.PostClient _wrappedPostClient() => XrpcNetworkInterceptor.wrapPostClient();
