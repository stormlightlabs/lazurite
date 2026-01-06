import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theming/theme_spec.dart';
import 'package:lazurite/src/app/theming/theme_variant.dart';

void main() {
  group('ThemeVariant', () {
    late ThemeSpec testSpec;
    late ColorScheme testScheme;
    late ThemeVariant darkVariant;
    late ThemeVariant lightVariant;

    setUp(() {
      testSpec = const ThemeSpec(
        surface: Color(0xFF1C1C1C),
        primary: Color(0xFF0085FF),
        onSurface: Color(0xFFF2F4F8),
      );

      testScheme = const ColorScheme.dark(
        surface: Color(0xFF1C1C1C),
        primary: Color(0xFF0085FF),
        onSurface: Color(0xFFF2F4F8),
      );

      darkVariant = ThemeVariant(
        id: 'test-dark',
        name: 'Dark',
        brightness: Brightness.dark,
        spec: testSpec,
        derivedScheme: testScheme,
      );

      lightVariant = ThemeVariant(
        id: 'test-light',
        name: 'Light',
        brightness: Brightness.light,
        spec: testSpec,
        derivedScheme: const ColorScheme.light(
          surface: Color(0xFFF2F4F8),
          primary: Color(0xFF0085FF),
          onSurface: Color(0xFF161616),
        ),
      );
    });

    test('stores all required properties', () {
      expect(darkVariant.id, 'test-dark');
      expect(darkVariant.name, 'Dark');
      expect(darkVariant.brightness, Brightness.dark);
      expect(darkVariant.spec, testSpec);
      expect(darkVariant.derivedScheme, testScheme);
    });

    group('brightness helpers', () {
      test('isDark returns true for dark variants', () {
        expect(darkVariant.isDark, isTrue);
        expect(darkVariant.isLight, isFalse);
      });

      test('isLight returns true for light variants', () {
        expect(lightVariant.isLight, isTrue);
        expect(lightVariant.isDark, isFalse);
      });
    });

    group('equality', () {
      test('equal variants are equal', () {
        final variant1 = ThemeVariant(
          id: 'test-dark',
          name: 'Dark',
          brightness: Brightness.dark,
          spec: testSpec,
          derivedScheme: testScheme,
        );
        final variant2 = ThemeVariant(
          id: 'test-dark',
          name: 'Dark',
          brightness: Brightness.dark,
          spec: testSpec,
          derivedScheme: testScheme,
        );

        expect(variant1, equals(variant2));
        expect(variant1.hashCode, equals(variant2.hashCode));
      });

      test('different ids are not equal', () {
        final variant1 = ThemeVariant(
          id: 'test-dark-1',
          name: 'Dark',
          brightness: Brightness.dark,
          spec: testSpec,
          derivedScheme: testScheme,
        );
        final variant2 = ThemeVariant(
          id: 'test-dark-2',
          name: 'Dark',
          brightness: Brightness.dark,
          spec: testSpec,
          derivedScheme: testScheme,
        );

        expect(variant1, isNot(equals(variant2)));
      });

      test('different brightness are not equal', () {
        final variant1 = ThemeVariant(
          id: 'test',
          name: 'Test',
          brightness: Brightness.dark,
          spec: testSpec,
          derivedScheme: testScheme,
        );
        final variant2 = ThemeVariant(
          id: 'test',
          name: 'Test',
          brightness: Brightness.light,
          spec: testSpec,
          derivedScheme: testScheme,
        );

        expect(variant1, isNot(equals(variant2)));
      });

      test('different specs are not equal', () {
        const otherSpec = ThemeSpec(surface: Color(0xFF262626), primary: Color(0xFF0085FF));

        final variant1 = ThemeVariant(
          id: 'test',
          name: 'Test',
          brightness: Brightness.dark,
          spec: testSpec,
          derivedScheme: testScheme,
        );
        final variant2 = ThemeVariant(
          id: 'test',
          name: 'Test',
          brightness: Brightness.dark,
          spec: otherSpec,
          derivedScheme: testScheme,
        );

        expect(variant1, isNot(equals(variant2)));
      });
    });
  });
}
