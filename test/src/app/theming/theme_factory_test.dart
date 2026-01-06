import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theming/packs/oxocarbon_theme_pack.dart';

void main() {
  group('ThemeFactory integration via oxocarbon variants', () {
    group('oxocarbonDarkVariant ColorScheme', () {
      late ColorScheme cs;

      setUp(() {
        cs = oxocarbonDarkVariant.derivedScheme;
      });

      test('has correct brightness', () {
        expect(cs.brightness, Brightness.dark);
      });

      test('uses BlueSky blue as primary', () {
        expect(cs.primary, const Color(0xFF0085FF));
      });

      test('has full surface container ladder', () {
        expect(cs.surfaceDim, isNotNull);
        expect(cs.surface, isNotNull);
        expect(cs.surfaceBright, isNotNull);
        expect(cs.surfaceContainerLowest, isNotNull);
        expect(cs.surfaceContainerLow, isNotNull);
        expect(cs.surfaceContainer, isNotNull);
        expect(cs.surfaceContainerHigh, isNotNull);
        expect(cs.surfaceContainerHighest, isNotNull);
      });

      test('has on-surface variants', () {
        expect(cs.onSurface, isNotNull);
        expect(cs.onSurfaceVariant, isNotNull);
      });

      test('has outline variants', () {
        expect(cs.outline, isNotNull);
        expect(cs.outlineVariant, isNotNull);
      });

      test('has secondary container for M3 active indicators', () {
        expect(cs.secondaryContainer, isNotNull);
        expect(cs.onSecondaryContainer, isNotNull);
      });
    });

    group('oxocarbonLightVariant ColorScheme', () {
      late ColorScheme cs;

      setUp(() {
        cs = oxocarbonLightVariant.derivedScheme;
      });

      test('has correct brightness', () {
        expect(cs.brightness, Brightness.light);
      });

      test('uses same primary as dark variant', () {
        expect(cs.primary, oxocarbonDarkVariant.derivedScheme.primary);
      });

      test('has different surface from dark variant', () {
        expect(cs.surface, isNot(equals(oxocarbonDarkVariant.derivedScheme.surface)));
      });

      test('has different onSurface from dark variant', () {
        expect(cs.onSurface, isNot(equals(oxocarbonDarkVariant.derivedScheme.onSurface)));
      });
    });

    group('variant helper methods', () {
      test('isDark returns true for dark variant', () {
        expect(oxocarbonDarkVariant.isDark, isTrue);
        expect(oxocarbonDarkVariant.isLight, isFalse);
      });

      test('isLight returns true for light variant', () {
        expect(oxocarbonLightVariant.isLight, isTrue);
        expect(oxocarbonLightVariant.isDark, isFalse);
      });
    });

    group('theme pack accessors', () {
      test('darkVariant returns dark brightness variant', () {
        expect(oxocarbonPack.darkVariant, equals(oxocarbonDarkVariant));
      });

      test('lightVariant returns light brightness variant', () {
        expect(oxocarbonPack.lightVariant, equals(oxocarbonLightVariant));
      });

      test('getVariantForBrightness returns appropriate variant', () {
        expect(
          oxocarbonPack.getVariantForBrightness(Brightness.dark),
          equals(oxocarbonDarkVariant),
        );
        expect(
          oxocarbonPack.getVariantForBrightness(Brightness.light),
          equals(oxocarbonLightVariant),
        );
      });
    });

    group('pack metadata', () {
      test('has correct id', () {
        expect(oxocarbonPack.id, 'oxocarbon');
      });

      test('has correct name', () {
        expect(oxocarbonPack.name, 'Oxocarbon');
      });

      test('has IBM as author', () {
        expect(oxocarbonPack.author, 'IBM');
      });

      test('has two variants', () {
        expect(oxocarbonPack.variants, hasLength(2));
      });
    });
  });

  group('ThemeVariant spec integration', () {
    test('dark spec has correct surfaceDim', () {
      expect(oxocarbonDarkVariant.spec.surfaceDim, const Color(0xFF161616));
    });

    test('light spec has correct surfaceDim', () {
      expect(oxocarbonLightVariant.spec.surfaceDim, const Color(0xFFE8E8E8));
    });

    test('dark spec onSurfaceVariant is distinct from onSurface', () {
      expect(oxocarbonDarkSpec.onSurface, isNot(equals(oxocarbonDarkSpec.onSurfaceVariant)));
    });

    test('light spec onSurfaceVariant is distinct from onSurface', () {
      expect(oxocarbonLightSpec.onSurface, isNot(equals(oxocarbonLightSpec.onSurfaceVariant)));
    });
  });
}
