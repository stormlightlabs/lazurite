import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/router/in_app_link_resolver.dart';

void main() {
  group('InAppLinkResolver.resolveRoute', () {
    test('resolves bsky profile URL to in-app profile route', () {
      final route = InAppLinkResolver.resolveRoute('https://bsky.app/profile/alice.bsky.social');

      expect(route, '/profile/alice.bsky.social');
    });

    test('resolves bsky post URL to in-app post route', () {
      final route = InAppLinkResolver.resolveRoute('https://bsky.app/profile/did:plc:alice/post/abc123');

      expect(route, '/post?uri=at%3A%2F%2Fdid%3Aplc%3Aalice%2Fapp.bsky.feed.post%2Fabc123');
    });

    test('resolves bsky group join URL to in-app preview route', () {
      final route = InAppLinkResolver.resolveRoute('https://bsky.app/messages/join/join-code');

      expect(route, '/alerts/messages/join/join-code');
    });

    test('resolves at:// post URI to in-app post route', () {
      final route = InAppLinkResolver.resolveRoute('at://did:plc:alice/app.bsky.feed.post/abc123');

      expect(route, '/post?uri=at%3A%2F%2Fdid%3Aplc%3Aalice%2Fapp.bsky.feed.post%2Fabc123');
    });

    test('resolves at:// profile URI to in-app profile route', () {
      final route = InAppLinkResolver.resolveRoute('at://did:plc:alice/app.bsky.actor.profile/self');

      expect(route, '/profile/did%3Aplc%3Aalice');
    });

    test('returns null for unsupported hosts and malformed values', () {
      expect(InAppLinkResolver.resolveRoute('https://example.com/profile/alice'), isNull);
      expect(InAppLinkResolver.resolveRoute('not a uri'), isNull);
      expect(InAppLinkResolver.resolveRoute(''), isNull);
    });
  });
}
