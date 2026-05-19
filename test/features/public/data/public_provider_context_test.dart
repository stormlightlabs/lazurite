import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/features/public/data/public_provider_context.dart';

void main() {
  group('PublicProviderContext', () {
    test('uses query provider before path and fallback providers', () {
      final context = PublicProviderContext.fromRoute(
        pathProvider: AppViewProviders.blueskyKey,
        queryProvider: AppViewProviders.blackskyKey,
        fallbackProvider: AppViewProviders.blueskyKey,
      );

      expect(context.providerKey, AppViewProviders.blackskyKey);
    });

    test('falls back to path provider when query provider is invalid', () {
      final context = PublicProviderContext.fromRoute(
        pathProvider: AppViewProviders.blackskyKey,
        queryProvider: 'weird',
        fallbackProvider: AppViewProviders.blueskyKey,
      );

      expect(context.providerKey, AppViewProviders.blackskyKey);
    });

    test('falls back to normalized fallback provider', () {
      final context = PublicProviderContext.fromRoute(pathProvider: 'bad', queryProvider: null, fallbackProvider: null);

      expect(context.providerKey, AppViewProviders.blueskyKey);
    });

    test('appends provider query without dropping existing query values', () {
      final uri = const PublicProviderContext(
        providerKey: AppViewProviders.blackskyKey,
      ).appendTo(Uri(path: '/post', queryParameters: {'uri': 'at://did:plc:alice/app.bsky.feed.post/abc'}));

      expect(uri.toString(), '/post?uri=at%3A%2F%2Fdid%3Aplc%3Aalice%2Fapp.bsky.feed.post%2Fabc&provider=blacksky');
    });
  });
}
