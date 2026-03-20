import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/feed_architecture.dart';

void main() {
  group('FeedArchitecture', () {
    group('fromString', () {
      test('parses grid', () {
        expect(FeedArchitecture.fromString('grid'), FeedArchitecture.grid);
      });

      test('parses linear', () {
        expect(FeedArchitecture.fromString('linear'), FeedArchitecture.linear);
      });

      test('null returns grid', () {
        expect(FeedArchitecture.fromString(null), FeedArchitecture.grid);
      });

      test('unknown value returns grid', () {
        expect(FeedArchitecture.fromString('unknown'), FeedArchitecture.grid);
      });

      test('round-trips all values via name', () {
        for (final arch in FeedArchitecture.values) {
          expect(FeedArchitecture.fromString(arch.name), arch, reason: 'arch: $arch');
        }
      });
    });
  });
}
