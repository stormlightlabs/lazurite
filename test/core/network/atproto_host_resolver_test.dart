import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/atproto_host_resolver.dart';
import '../../helpers/fixtures/auth.dart';

void main() {
  group('resolvePdsHost', () {
    test('uses stored PDS endpoint when restoring an opaque OAuth token', () {
      final tokens = testOpaqueOAuthTokens(
        expiresAt: DateTime.utc(2030),
        service: 'https://porcini.us-east.host.bsky.network',
        oauthClientId: 'https://client.example/metadata.json',
        dpopPublicKey: 'public-key',
        dpopPrivateKey: 'private-key',
      );

      expect(resolvePdsHost(tokens), 'porcini.us-east.host.bsky.network');
    });

    test('falls back to stored service when opaque OAuth metadata is incomplete', () {
      final tokens = testOpaqueOAuthTokens(
        service: 'porcini.us-east.host.bsky.network',
        dpopPublicKey: 'public-key',
        dpopPrivateKey: 'private-key',
      );

      expect(resolvePdsHost(tokens), 'porcini.us-east.host.bsky.network');
    });
  });
}
