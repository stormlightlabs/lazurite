import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/compose/data/scheduled_compose_payload.dart';

void main() {
  group('ScheduledComposePayload', () {
    test('round-trips split thread payload', () {
      const payload = ScheduledComposePayload(
        originalText: 'original long text',
        parts: [
          ScheduledComposePart(index: 0, text: 'part one'),
          ScheduledComposePart(index: 1, text: 'part two'),
        ],
      );

      final decoded = ScheduledComposePayload.tryDecode(payload.encode());

      expect(decoded, isNotNull);
      expect(decoded!.version, 1);
      expect(decoded.kind, ScheduledComposePayload.kindThread);
      expect(decoded.originalText, 'original long text');
      expect(decoded.parts.map((part) => part.text), ['part one', 'part two']);
    });

    test('rejects malformed or non-contiguous parts', () {
      expect(
        ScheduledComposePayload.tryDecode('''
          {"version":1,"kind":"thread","originalText":"x","parts":[{"index":1,"text":"part"}]}
        '''),
        isNull,
      );
    });
  });
}
