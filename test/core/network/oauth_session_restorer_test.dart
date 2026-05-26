import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/oauth_session_restorer.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:poptart_core/poptart_core.dart';

import '../../helpers/fixtures/auth.dart';

void main() {
  group('restoreOAuthSessionFromTokens', () {
    test('passes stored PDS endpoint for opaque OAuth tokens', () {
      final tokens = AuthTokens(
        accessToken: 'opaque-access-token',
        refreshToken: 'refresh-token',
        expiresAt: DateTime.utc(2030),
        did: 'did:plc:alice',
        handle: 'alice.example',
        service: 'https://pds.example',
        oauthClientId: 'https://client.example/metadata.json',
        oauthTokenType: 'DPoP',
        oauthScope: 'atproto transition:generic',
        dpopPublicKey: 'public-key',
        dpopPrivateKey: 'private-key',
        authMethod: AuthMethod.oauth,
      );

      final session = restoreOAuthSessionFromTokens(tokens);

      expect(session.accessToken, 'opaque-access-token');
      expect(session.sub, 'did:plc:alice');
      expect(session.scope, 'atproto transition:generic');
      expect(session.atprotoPdsEndpoint, 'pds.example');
    });

    test('lets stored PDS endpoint override URL-shaped JWT audience', () {
      final tokens = AuthTokens(
        accessToken: buildJwt(
          aud: 'https://pds.example',
          sub: 'did:plc:alice',
          clientId: 'https://client.example/metadata.json',
        ),
        refreshToken: 'refresh-token',
        did: 'did:plc:alice',
        handle: 'alice.example',
        service: 'pds.example',
        dpopPublicKey: 'public-key',
        dpopPrivateKey: 'private-key',
        authMethod: AuthMethod.oauth,
      );

      final session = restoreOAuthSessionFromTokens(tokens);

      expect(session.atprotoPdsEndpoint, 'pds.example');
    });
  });
}
