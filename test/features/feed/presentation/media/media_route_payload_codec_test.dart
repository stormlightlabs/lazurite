import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/presentation/media/media_route_payload_codec.dart';

void main() {
  group('MediaRoutePayloadCodec', () {
    test('round-trips payload through URL-safe route location', () {
      final location = MediaRoutePayloadCodec.location(
        path: '/video',
        payload: {'playlistUrl': 'https://example.com/video.m3u8', 'isGif': true, 'aspectRatio': 16 / 9},
      );

      final uri = Uri.parse(location);
      final decoded = MediaRoutePayloadCodec.tryDecode(uri);

      expect(uri.path, '/video');
      expect(decoded, {'playlistUrl': 'https://example.com/video.m3u8', 'isGif': true, 'aspectRatio': 16 / 9});
    });

    test('returns null for missing or malformed payloads', () {
      expect(MediaRoutePayloadCodec.tryDecode(Uri.parse('/images')), isNull);
      expect(MediaRoutePayloadCodec.tryDecode(Uri.parse('/images?payload=not-base64-json')), isNull);
    });

    test('returns null when decoded payload is not an object', () {
      final payload = base64Url.encode(utf8.encode(jsonEncode(['not', 'an', 'object'])));

      expect(MediaRoutePayloadCodec.tryDecode(Uri.parse('/images?payload=$payload')), isNull);
    });
  });
}
