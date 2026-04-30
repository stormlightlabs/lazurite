import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/app_view_web_links.dart';

void main() {
  group('AppViewWebLinks.postFromAtUri', () {
    test('uses Bluesky web base by default', () {
      final url = AppViewWebLinks.postFromAtUri('at://did:plc:alice/app.bsky.feed.post/abc123');
      expect(url, equals('https://bsky.app/profile/did:plc:alice/post/abc123'));
    });

    test('uses selected BlackSky web base', () {
      final url = AppViewWebLinks.postFromAtUri(
        'at://did:plc:alice/app.bsky.feed.post/abc123',
        appViewProvider: AppViewProviders.blackskyKey,
      );
      expect(url, equals('https://blacksky.community/profile/did:plc:alice/post/abc123'));
    });

    test('returns original input for non-post at URI', () {
      const input = 'at://did:plc:alice/app.bsky.actor.profile/self';
      final url = AppViewWebLinks.postFromAtUri(input);
      expect(url, equals(input));
    });

    test('returns original input for malformed URI', () {
      const input = ':::not-a-uri:::';
      final url = AppViewWebLinks.postFromAtUri(input);
      expect(url, equals(input));
    });
  });

  group('AppViewWebLinks.profile', () {
    test('builds profile link against selected provider', () {
      final url = AppViewWebLinks.profile('alice.bsky.social', appViewProvider: AppViewProviders.blackskyKey);
      expect(url, equals('https://blacksky.community/profile/alice.bsky.social'));
    });
  });
}
