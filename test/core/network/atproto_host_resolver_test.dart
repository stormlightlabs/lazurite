import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/atproto_host_resolver.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

import '../../helpers/test_utils.dart';

void main() {
  group('resolvePdsHost', () {
    test('uses stored PDS endpoint when restoring an opaque OAuth token', () {
      final tokens = testAuthTokens(
        accessToken: 'opaque-access-token',
        refreshToken: 'refresh-token',
        expiresAt: DateTime.utc(2030),
        did: 'did:plc:alice',
        handle: 'alice.bsky.social',
        service: 'https://porcini.us-east.host.bsky.network',
        oauthClientId: 'https://client.example/metadata.json',
        oauthTokenType: 'DPoP',
        oauthScope: 'atproto transition:generic',
        dpopPublicKey: 'public-key',
        dpopPrivateKey: 'private-key',
        authMethod: AuthMethod.oauth,
      );

      expect(resolvePdsHost(tokens), 'porcini.us-east.host.bsky.network');
    });

    test('falls back to stored service when opaque OAuth metadata is incomplete', () {
      final tokens = testAuthTokens(
        accessToken: 'opaque-access-token',
        refreshToken: 'refresh-token',
        did: 'did:plc:alice',
        handle: 'alice.bsky.social',
        service: 'porcini.us-east.host.bsky.network',
        dpopPublicKey: 'public-key',
        dpopPrivateKey: 'private-key',
        authMethod: AuthMethod.oauth,
      );

      expect(resolvePdsHost(tokens), 'porcini.us-east.host.bsky.network');
    });
  });
}
