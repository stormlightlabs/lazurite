import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/app_view_provider.dart';

void main() {
  group('AppViewProviders', () {
    test('normalizes known provider keys', () {
      expect(AppViewProviders.normalizeSettingKey(' BLACKSKY '), equals('blacksky'));
      expect(AppViewProviders.normalizeSettingKey('bluesky'), equals('bluesky'));
    });

    test('falls back to default for unknown keys', () {
      expect(AppViewProviders.normalizeSettingKey('unknown'), equals(AppViewProviders.defaultKey));
      expect(AppViewProviders.normalizeSettingKey(null), equals(AppViewProviders.defaultKey));
    });

    test('returns descriptors with expected fields', () {
      final bluesky = AppViewProviders.descriptorForSetting('bluesky');
      final blacksky = AppViewProviders.descriptorForSetting('blacksky');

      expect(bluesky.serviceDid, equals('did:web:api.bsky.app#bsky_appview'));
      expect(bluesky.publicBaseUrl.host, equals('public.api.bsky.app'));
      expect(bluesky.entrywayUrl.host, equals('bsky.social'));
      expect(bluesky.webBaseUrl.host, equals('bsky.app'));

      expect(blacksky.serviceDid, equals('did:web:api.blacksky.community#bsky_appview'));
      expect(blacksky.publicBaseUrl.host, equals('api.blacksky.community'));
      expect(blacksky.entrywayUrl.host, equals('blacksky.community'));
      expect(blacksky.webBaseUrl.host, equals('blacksky.community'));
    });
  });
}
