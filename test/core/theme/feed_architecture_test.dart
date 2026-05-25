import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/feed_layout.dart';

void main() {
  group('FeedLayout', () {
    group('fromString', () {
      test('parses grid', () {
        expect(FeedLayout.fromString('grid'), FeedLayout.comfortable);
      });

      test('parses linear', () {
        expect(FeedLayout.fromString('linear'), FeedLayout.compact);
      });

      test('null returns comfortable', () {
        expect(FeedLayout.fromString(null), FeedLayout.comfortable);
      });

      test('unknown value returns comfortable', () {
        expect(FeedLayout.fromString('unknown'), FeedLayout.comfortable);
      });

      test('round-trips all values via name', () {
        for (final arch in FeedLayout.values) {
          expect(FeedLayout.fromString(arch.name), arch, reason: 'arch: $arch');
        }
      });
    });
  });
}
