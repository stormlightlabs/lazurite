import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/app_bsky_routing_policy.dart';

void main() {
  group('AppBskyRoutingPolicy', () {
    test('bypasses proxy for known non-essential endpoints', () {
      const endpoints = <String>[
        'app.bsky.actor.getProfile',
        'app.bsky.actor.getProfiles',
        'app.bsky.actor.searchActorsTypeahead',
        'app.bsky.graph.getList',
        'app.bsky.graph.getLists',
        'app.bsky.feed.getActorLikes',
        'app.bsky.feed.getPosts',
        'app.bsky.feed.getQuotes',
        'app.bsky.unspecced.getTopicFeed',
      ];

      for (final endpoint in endpoints) {
        expect(
          AppBskyRoutingPolicy.modeForEndpoint(endpoint),
          AppBskyProxyMode.bypassProxy,
          reason: 'Expected bypass policy for $endpoint',
        );
        expect(AppBskyRoutingPolicy.shouldUseProxy(endpoint), isFalse);
      }
    });

    test('uses proxy for explicit provider-sensitive and service-routed endpoints', () {
      const endpoints = <String>[
        'app.bsky.feed.getTimeline',
        'app.bsky.feed.getFeed',
        'app.bsky.feed.searchPosts',
        'app.bsky.feed.getPostThread',
        'app.bsky.feed.getAuthorFeed',
        'app.bsky.notification.listNotifications',
        'app.bsky.notification.getUnreadCount',
        'app.bsky.notification.updateSeen',
        'app.bsky.labeler.getServices',
        'app.bsky.feed.sendInteractions',
        'chat.bsky.convo.listConvos',
      ];

      for (final endpoint in endpoints) {
        expect(
          AppBskyRoutingPolicy.modeForEndpoint(endpoint),
          AppBskyProxyMode.useProxy,
          reason: 'Expected useProxy policy for $endpoint',
        );
        expect(AppBskyRoutingPolicy.shouldUseProxy(endpoint), isTrue);
      }
    });

    test('uses proxy for unknown endpoints by default', () {
      expect(AppBskyRoutingPolicy.modeForEndpoint('app.bsky.unknown.operation'), AppBskyProxyMode.useProxy);
      expect(AppBskyRoutingPolicy.modeForEndpoint('   '), AppBskyProxyMode.useProxy);
    });
  });
}
