import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/compose/data/draft_embed_payload.dart';

void main() {
  group('DraftEmbedPayload', () {
    test('round-trips image drafts using the existing wire shape', () {
      const payload = DraftEmbedPayload.images(paths: ['/tmp/a.png'], altTexts: ['alt text']);

      final decoded = DraftEmbedPayload.tryDecode(payload.encode());

      expect(decoded, payload);
      expect(decoded!.toJson(), {
        'type': 'images',
        'paths': ['/tmp/a.png'],
        'altTexts': ['alt text'],
      });
    });

    test('round-trips video drafts using the existing wire shape', () {
      const payload = DraftEmbedPayload.video(path: '/tmp/video.mp4', alt: 'caption');

      final decoded = DraftEmbedPayload.tryDecode(payload.encode());

      expect(decoded, payload);
      expect(decoded!.toJson(), {'type': 'video', 'path': '/tmp/video.mp4', 'alt': 'caption'});
    });

    test('preserves legacy mediaPaths JSON list support', () {
      final encoded = DraftEmbedPayload.encodeMediaPaths(['/tmp/a.png', '/tmp/b.png']);

      expect(DraftEmbedPayload.decodeMediaPaths(encoded), ['/tmp/a.png', '/tmp/b.png']);
    });

    test('returns null for malformed embed payloads', () {
      expect(DraftEmbedPayload.tryDecode('{'), isNull);
      expect(DraftEmbedPayload.tryDecode('[]'), isNull);
      expect(DraftEmbedPayload.tryDecode('{"type":"video"}'), isNull);
    });
  });
}
