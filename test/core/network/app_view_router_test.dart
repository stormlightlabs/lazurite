import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/app_view_router.dart';

void main() {
  group('AppViewRouter', () {
    test('builds proxy headers and public endpoint URI', () {
      final router = AppViewRouter(provider: AppViewProviders.blacksky);

      expect(router.appBskyProxyHeaders(), equals({'atproto-proxy': 'did:web:api.blacksky.community#bsky_appview'}));
      expect(
        router.publicEndpoint('/xrpc/app.bsky.unspecced.getTrends', {'limit': '10'}).toString(),
        equals('https://api.blacksky.community/xrpc/app.bsky.unspecced.getTrends?limit=10'),
      );
    });

    test('resolves relative links against provider web base', () {
      final router = AppViewRouter(provider: AppViewProviders.bluesky);

      expect(router.resolveWebLink('/topic/abc123').toString(), equals('https://bsky.app/topic/abc123'));
      expect(
        router.resolveWebLink('/profile/alice.bsky.social/feed/aaabbb').toString(),
        equals('https://bsky.app/profile/alice.bsky.social/feed/aaabbb'),
      );
    });

    test('returns absolute links unchanged', () {
      final router = AppViewRouter(provider: AppViewProviders.bluesky);
      expect(router.resolveWebLink('https://example.com/path').toString(), equals('https://example.com/path'));
    });
  });
}
