import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theming/theme_pack.dart';
import 'package:lazurite/src/app/theming/theme_spec.dart';
import 'package:lazurite/src/app/theming/theme_variant.dart';

void main() {
  group('ThemePack', () {
    late ThemeSpec darkSpec;
    late ThemeSpec lightSpec;
    late ThemeVariant darkVariant;
    late ThemeVariant lightVariant;
    late ThemePack pack;

    setUp(() {
      darkSpec = const ThemeSpec(surface: Color(0xFF1C1C1C), primary: Color(0xFF0085FF));
      lightSpec = const ThemeSpec(surface: Color(0xFFF2F4F8), primary: Color(0xFF0085FF));

      darkVariant = ThemeVariant(
        id: 'test-dark',
        name: 'Dark',
        brightness: Brightness.dark,
        spec: darkSpec,
        derivedScheme: const ColorScheme.dark(primary: Color(0xFF0085FF)),
      );

      lightVariant = ThemeVariant(
        id: 'test-light',
        name: 'Light',
        brightness: Brightness.light,
        spec: lightSpec,
        derivedScheme: const ColorScheme.light(primary: Color(0xFF0085FF)),
      );

      pack = ThemePack(
        id: 'test-pack',
        name: 'Test Pack',
        author: 'Test Author',
        variants: [darkVariant, lightVariant],
      );
    });

    test('stores all required properties', () {
      expect(pack.id, 'test-pack');
      expect(pack.name, 'Test Pack');
      expect(pack.author, 'Test Author');
      expect(pack.variants, hasLength(2));
    });

    test('author is optional', () {
      final packWithoutAuthor = ThemePack(id: 'test', name: 'Test', variants: [darkVariant]);

      expect(packWithoutAuthor.author, isNull);
    });

    group('variant accessors', () {
      test('darkVariant returns dark brightness variant', () {
        expect(pack.darkVariant, equals(darkVariant));
      });

      test('lightVariant returns light brightness variant', () {
        expect(pack.lightVariant, equals(lightVariant));
      });

      test('darkVariant returns null when no dark variant exists', () {
        final lightOnlyPack = ThemePack(
          id: 'light-only',
          name: 'Light Only',
          variants: [lightVariant],
        );

        expect(lightOnlyPack.darkVariant, isNull);
      });

      test('lightVariant returns null when no light variant exists', () {
        final darkOnlyPack = ThemePack(
          id: 'dark-only',
          name: 'Dark Only',
          variants: [darkVariant],
        );

        expect(darkOnlyPack.lightVariant, isNull);
      });

      test('getVariant returns variant by id', () {
        expect(pack.getVariant('test-dark'), equals(darkVariant));
        expect(pack.getVariant('test-light'), equals(lightVariant));
      });

      test('getVariant returns null for unknown id', () {
        expect(pack.getVariant('unknown'), isNull);
      });

      test('getVariantForBrightness returns appropriate variant', () {
        expect(pack.getVariantForBrightness(Brightness.dark), equals(darkVariant));
        expect(pack.getVariantForBrightness(Brightness.light), equals(lightVariant));
      });
    });

    group('multiple variants of same brightness', () {
      test('darkVariant returns first dark variant', () {
        const oledDarkSpec = ThemeSpec(surface: Color(0xFF000000), primary: Color(0xFF0085FF));
        const oledDarkVariant = ThemeVariant(
          id: 'test-oled',
          name: 'OLED Dark',
          brightness: Brightness.dark,
          spec: oledDarkSpec,
          derivedScheme: ColorScheme.dark(primary: Color(0xFF0085FF)),
        );

        final packWithOled = ThemePack(
          id: 'test-oled-pack',
          name: 'Test OLED Pack',
          variants: [darkVariant, oledDarkVariant, lightVariant],
        );

        expect(packWithOled.darkVariant, equals(darkVariant));
      });

      test('getVariant can retrieve any variant by id', () {
        const oledDarkSpec = ThemeSpec(surface: Color(0xFF000000), primary: Color(0xFF0085FF));
        const oledDarkVariant = ThemeVariant(
          id: 'test-oled',
          name: 'OLED Dark',
          brightness: Brightness.dark,
          spec: oledDarkSpec,
          derivedScheme: ColorScheme.dark(primary: Color(0xFF0085FF)),
        );

        final packWithOled = ThemePack(
          id: 'test-oled-pack',
          name: 'Test OLED Pack',
          variants: [darkVariant, oledDarkVariant, lightVariant],
        );

        expect(packWithOled.getVariant('test-oled'), equals(oledDarkVariant));
      });
    });

    group('equality', () {
      test('equal packs are equal', () {
        final pack1 = ThemePack(
          id: 'test',
          name: 'Test',
          author: 'Author',
          variants: [darkVariant, lightVariant],
        );
        final pack2 = ThemePack(
          id: 'test',
          name: 'Test',
          author: 'Author',
          variants: [darkVariant, lightVariant],
        );

        expect(pack1, equals(pack2));
        expect(pack1.hashCode, equals(pack2.hashCode));
      });

      test('different ids are not equal', () {
        final pack1 = ThemePack(id: 'test-1', name: 'Test', variants: [darkVariant]);
        final pack2 = ThemePack(id: 'test-2', name: 'Test', variants: [darkVariant]);

        expect(pack1, isNot(equals(pack2)));
      });

      test('different variants are not equal', () {
        final pack1 = ThemePack(id: 'test', name: 'Test', variants: [darkVariant]);
        final pack2 = ThemePack(id: 'test', name: 'Test', variants: [lightVariant]);

        expect(pack1, isNot(equals(pack2)));
      });

      test('different variant order are not equal', () {
        final pack1 = ThemePack(id: 'test', name: 'Test', variants: [darkVariant, lightVariant]);
        final pack2 = ThemePack(id: 'test', name: 'Test', variants: [lightVariant, darkVariant]);

        expect(pack1, isNot(equals(pack2)));
      });
    });
  });
}
