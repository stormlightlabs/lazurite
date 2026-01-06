import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theming/theme_spec.dart';

void main() {
  group('ThemeSpec', () {
    test('creates with all null values', () {
      const spec = ThemeSpec();
      expect(spec.surface, isNull);
      expect(spec.primary, isNull);
      expect(spec.onSurface, isNull);
    });

    test('creates with specified values', () {
      const spec = ThemeSpec(
        surface: Color(0xFF1C1C1C),
        surfaceContainerLow: Color(0xFF262626),
        surfaceContainerHigh: Color(0xFF393939),
        onSurface: Color(0xFFF2F4F8),
        onSurfaceVariant: Color(0xFF9DA5B4),
        outline: Color(0xFF525252),
        outlineVariant: Color(0xFF393939),
        primary: Color(0xFF0085FF),
        secondary: Color(0xFF78A9FF),
        tertiary: Color(0xFF33B1FF),
        error: Color(0xFFEE5396),
      );

      expect(spec.surface, const Color(0xFF1C1C1C));
      expect(spec.surfaceContainerLow, const Color(0xFF262626));
      expect(spec.surfaceContainerHigh, const Color(0xFF393939));
      expect(spec.onSurface, const Color(0xFFF2F4F8));
      expect(spec.onSurfaceVariant, const Color(0xFF9DA5B4));
      expect(spec.outline, const Color(0xFF525252));
      expect(spec.outlineVariant, const Color(0xFF393939));
      expect(spec.primary, const Color(0xFF0085FF));
      expect(spec.secondary, const Color(0xFF78A9FF));
      expect(spec.tertiary, const Color(0xFF33B1FF));
      expect(spec.error, const Color(0xFFEE5396));
    });

    group('equality', () {
      test('equal specs are equal', () {
        const spec1 = ThemeSpec(surface: Color(0xFF1C1C1C), primary: Color(0xFF0085FF));
        const spec2 = ThemeSpec(surface: Color(0xFF1C1C1C), primary: Color(0xFF0085FF));

        expect(spec1, equals(spec2));
        expect(spec1.hashCode, equals(spec2.hashCode));
      });

      test('different specs are not equal', () {
        const spec1 = ThemeSpec(surface: Color(0xFF1C1C1C), primary: Color(0xFF0085FF));
        const spec2 = ThemeSpec(surface: Color(0xFF262626), primary: Color(0xFF0085FF));

        expect(spec1, isNot(equals(spec2)));
      });

      test('empty specs are equal', () {
        const spec1 = ThemeSpec();
        const spec2 = ThemeSpec();

        expect(spec1, equals(spec2));
        expect(spec1.hashCode, equals(spec2.hashCode));
      });
    });

    group('surface container ladder', () {
      test('stores full M3 surface ladder', () {
        const spec = ThemeSpec(
          surfaceDim: Color(0xFF161616),
          surface: Color(0xFF1C1C1C),
          surfaceBright: Color(0xFF2B2B2B),
          surfaceContainerLowest: Color(0xFF0D0D0D),
          surfaceContainerLow: Color(0xFF1C1C1C),
          surfaceContainer: Color(0xFF262626),
          surfaceContainerHigh: Color(0xFF303030),
          surfaceContainerHighest: Color(0xFF393939),
        );

        expect(spec.surfaceDim, const Color(0xFF161616));
        expect(spec.surface, const Color(0xFF1C1C1C));
        expect(spec.surfaceBright, const Color(0xFF2B2B2B));
        expect(spec.surfaceContainerLowest, const Color(0xFF0D0D0D));
        expect(spec.surfaceContainerLow, const Color(0xFF1C1C1C));
        expect(spec.surfaceContainer, const Color(0xFF262626));
        expect(spec.surfaceContainerHigh, const Color(0xFF303030));
        expect(spec.surfaceContainerHighest, const Color(0xFF393939));
      });
    });

    group('accent roles', () {
      test('stores primary accent roles', () {
        const spec = ThemeSpec(
          primary: Color(0xFF0085FF),
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFF003D75),
          onPrimaryContainer: Color(0xFFD1E4FF),
        );

        expect(spec.primary, const Color(0xFF0085FF));
        expect(spec.onPrimary, const Color(0xFFFFFFFF));
        expect(spec.primaryContainer, const Color(0xFF003D75));
        expect(spec.onPrimaryContainer, const Color(0xFFD1E4FF));
      });

      test('stores secondary accent roles', () {
        const spec = ThemeSpec(
          secondary: Color(0xFF78A9FF),
          onSecondary: Color(0xFF003258),
          secondaryContainer: Color(0xFF0A4A79),
          onSecondaryContainer: Color(0xFFD1E4FF),
        );

        expect(spec.secondary, const Color(0xFF78A9FF));
        expect(spec.onSecondary, const Color(0xFF003258));
        expect(spec.secondaryContainer, const Color(0xFF0A4A79));
        expect(spec.onSecondaryContainer, const Color(0xFFD1E4FF));
      });

      test('stores tertiary accent roles', () {
        const spec = ThemeSpec(
          tertiary: Color(0xFF33B1FF),
          onTertiary: Color(0xFF003548),
          tertiaryContainer: Color(0xFF004D67),
          onTertiaryContainer: Color(0xFFBEEAFF),
        );

        expect(spec.tertiary, const Color(0xFF33B1FF));
        expect(spec.onTertiary, const Color(0xFF003548));
        expect(spec.tertiaryContainer, const Color(0xFF004D67));
        expect(spec.onTertiaryContainer, const Color(0xFFBEEAFF));
      });

      test('stores error roles', () {
        const spec = ThemeSpec(
          error: Color(0xFFEE5396),
          onError: Color(0xFF690033),
          errorContainer: Color(0xFF8E0049),
          onErrorContainer: Color(0xFFFFD9E3),
        );

        expect(spec.error, const Color(0xFFEE5396));
        expect(spec.onError, const Color(0xFF690033));
        expect(spec.errorContainer, const Color(0xFF8E0049));
        expect(spec.onErrorContainer, const Color(0xFFFFD9E3));
      });
    });

    group('scaffolding roles', () {
      test('stores inverse and scrim colors', () {
        const spec = ThemeSpec(
          inverseSurface: Color(0xFFE4E2E6),
          onInverseSurface: Color(0xFF313033),
          inversePrimary: Color(0xFF0068C9),
          scrim: Color(0xFF000000),
          shadow: Color(0xFF000000),
        );

        expect(spec.inverseSurface, const Color(0xFFE4E2E6));
        expect(spec.onInverseSurface, const Color(0xFF313033));
        expect(spec.inversePrimary, const Color(0xFF0068C9));
        expect(spec.scrim, const Color(0xFF000000));
        expect(spec.shadow, const Color(0xFF000000));
      });
    });
  });
}
