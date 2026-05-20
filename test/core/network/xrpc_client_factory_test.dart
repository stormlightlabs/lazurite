import 'package:poptart_core/poptart_core.dart' as atp_core;
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/shared/utils/test_utils.dart';

void main() {
  group('xrpc_client_factory', () {
    test('creates an OAuth Bluesky client that targets the token PDS', () {
      const pdsHost = 'porcini.us-east.host.bsky.network';
      final tokens = AuthTokens(
        accessToken: buildJwt(
          aud: pdsHost,
          sub: 'did:plc:alice',
          clientId: 'https://client.example/metadata.json',
          iss: 'https://bsky.social',
        ),
        refreshToken: 'refresh-token',
        did: 'did:plc:alice',
        handle: 'alice.bsky.social',
        service: 'bsky.social',
        dpopPublicKey: 'public-key',
        dpopPrivateKey: 'private-key',
        authMethod: AuthMethod.oauth,
      );

      final client = createBlueskyClient(tokens);

      expect(client, isNotNull);
      expect(client!.service, pdsHost);
      expect(client.oAuthSession, isNotNull);
      expect(client.oAuthSession!.atprotoPdsEndpoint, pdsHost);
    });

    test('creates an app-password Bluesky client that targets the stored service', () {
      const pdsHost = 'bsky.social';
      const tokens = AuthTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        did: 'did:plc:alice',
        handle: 'alice.bsky.social',
        service: pdsHost,
      );

      final client = createBlueskyClient(tokens);

      expect(client, isNotNull);
      expect(client!.service, pdsHost);
      expect(client.session, isNotNull);
    });

    test('creates an OAuth ATProto client that targets the token PDS', () {
      const pdsHost = 'porcini.us-east.host.bsky.network';
      final oauthSession = atp_core.restoreOAuthSession(
        accessToken: buildJwt(
          aud: pdsHost,
          sub: 'did:plc:alice',
          clientId: 'https://client.example/metadata.json',
          iss: 'https://bsky.social',
        ),
        refreshToken: 'refresh-token',
        publicKey: 'public-key',
        privateKey: 'private-key',
      );

      final client = createAtProtoForOAuthSession(oauthSession);

      expect(client.service, pdsHost);
      expect(client.oAuthSession, isNotNull);
      expect(client.oAuthSession!.atprotoPdsEndpoint, pdsHost);
    });
  });
}
