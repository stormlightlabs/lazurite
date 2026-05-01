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

    test('resolves profile feed trend link to feed-detail route params', () {
      final router = AppViewRouter(provider: AppViewProviders.bluesky);

      final resolved = router.resolveTrendLink('/profile/alice.bsky.social/feed/aaabbb');
      expect(resolved.inAppRoute, equals('/feed?actor=alice.bsky.social&rkey=aaabbb'));
      expect(resolved.externalUri.toString(), equals('https://bsky.app/profile/alice.bsky.social/feed/aaabbb'));
    });

    test('resolves topic trend links to in-app topic route', () {
      final router = AppViewRouter(provider: AppViewProviders.blacksky);

      final resolved = router.resolveTrendLink('/topic/dartlang');
      expect(resolved.inAppRoute, equals('/topic?topic=dartlang'));
      expect(resolved.externalUri.toString(), equals('https://blacksky.community/topic/dartlang'));
    });

    test('degrades unknown trend links to external open', () {
      final router = AppViewRouter(provider: AppViewProviders.bluesky);

      final resolved = router.resolveTrendLink('/weird/path');
      expect(resolved.inAppRoute, isNull);
      expect(resolved.externalUri.toString(), equals('https://bsky.app/weird/path'));
    });

    test('does not deep-link non-provider hosts', () {
      final router = AppViewRouter(provider: AppViewProviders.bluesky);

      final resolved = router.resolveTrendLink('https://example.com/profile/alice/feed/xyz');
      expect(resolved.inAppRoute, isNull);
      expect(resolved.externalUri.toString(), equals('https://example.com/profile/alice/feed/xyz'));
    });

    test('health summary remains healthy when only non-critical checks fail', () {
      final health = AppViewHealth(
        providerKey: AppViewProviders.blueskyKey,
        checkedAt: DateTime.utc(2026, 5, 1),
        checks: const [
          AppViewCapabilityResult(endpointId: 'critical.a', statusCode: 200, supported: true, critical: true),
          AppViewCapabilityResult(endpointId: 'critical.b', statusCode: 200, supported: true, critical: true),
          AppViewCapabilityResult(endpointId: 'noncritical', statusCode: 500, supported: false, critical: false),
        ],
      );

      expect(health.isHealthy, isTrue);
      expect(health.summary(), equals('Healthy (2/2 critical, 2/3 total)'));
    });
  });
}
