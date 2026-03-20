import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/ui_density.dart';

void main() {
  group('UiDensity', () {
    group('scaleFactor', () {
      test('compact has scale 0.75', () {
        expect(UiDensity.compact.scaleFactor, 0.75);
      });

      test('standard has scale 1.0', () {
        expect(UiDensity.standard.scaleFactor, 1.0);
      });

      test('relaxed has scale 1.25', () {
        expect(UiDensity.relaxed.scaleFactor, 1.25);
      });

      test('compact scale is less than standard', () {
        expect(UiDensity.compact.scaleFactor, lessThan(UiDensity.standard.scaleFactor));
      });

      test('relaxed scale is greater than standard', () {
        expect(UiDensity.relaxed.scaleFactor, greaterThan(UiDensity.standard.scaleFactor));
      });
    });

    group('fromString', () {
      test('parses compact', () {
        expect(UiDensity.fromString('compact'), UiDensity.compact);
      });

      test('parses standard', () {
        expect(UiDensity.fromString('standard'), UiDensity.standard);
      });

      test('parses relaxed', () {
        expect(UiDensity.fromString('relaxed'), UiDensity.relaxed);
      });

      test('null returns standard', () {
        expect(UiDensity.fromString(null), UiDensity.standard);
      });

      test('unknown value returns standard', () {
        expect(UiDensity.fromString('unknown'), UiDensity.standard);
      });

      test('round-trips all values via name', () {
        for (final density in UiDensity.values) {
          expect(UiDensity.fromString(density.name), density, reason: 'density: $density');
        }
      });
    });
  });
}
