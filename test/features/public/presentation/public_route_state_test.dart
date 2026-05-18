import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/features/public/presentation/public_route_state.dart';

void main() {
  group('PublicRouteState', () {
    test('normalizes supported providers and tabs', () {
      final state = PublicRouteState.parse(provider: ' BLACKSKY ', tab: 'feeds');

      expect(state.providerKey, AppViewProviders.blackskyKey);
      expect(state.contentTab, PublicContentTab.feeds);
      expect(state.location, '/public/blacksky/feeds');
    });

    test('falls back to Bluesky discover for invalid route values', () {
      final state = PublicRouteState.parse(provider: 'unknown', tab: 'posts');

      expect(state.providerKey, AppViewProviders.blueskyKey);
      expect(state.contentTab, PublicContentTab.discover);
      expect(state.location, '/public/bluesky/discover');
    });
  });
}
