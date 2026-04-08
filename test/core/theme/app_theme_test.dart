import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    group('getPaletteName', () {
      test('returns correct name for lazurite', () {
        expect(AppTheme.getPaletteName(AppThemePalette.lazurite), 'Lazurite');
      });

      test('returns correct name for oxocarbon', () {
        expect(AppTheme.getPaletteName(AppThemePalette.oxocarbon), 'Oxocarbon');
      });

      test('returns correct name for catppuccin', () {
        expect(AppTheme.getPaletteName(AppThemePalette.catppuccin), 'Catppuccin');
      });

      test('returns correct name for nord', () {
        expect(AppTheme.getPaletteName(AppThemePalette.nord), 'Nord');
      });

      test('returns correct name for rosePine', () {
        expect(AppTheme.getPaletteName(AppThemePalette.rosePine), 'Rosé Pine');
      });
    });

    group('getVariantName', () {
      test('returns correct name for light', () {
        expect(AppTheme.getVariantName(AppThemeVariant.light), 'Light');
      });

      test('returns correct name for dark', () {
        expect(AppTheme.getVariantName(AppThemeVariant.dark), 'Dark');
      });
    });

    group('parsePalette', () {
      test('parses lazurite', () {
        expect(AppTheme.parsePalette('lazurite'), AppThemePalette.lazurite);
      });

      test('parses oxocarbon', () {
        expect(AppTheme.parsePalette('oxocarbon'), AppThemePalette.oxocarbon);
      });

      test('parses catppuccin', () {
        expect(AppTheme.parsePalette('catppuccin'), AppThemePalette.catppuccin);
      });

      test('parses nord', () {
        expect(AppTheme.parsePalette('nord'), AppThemePalette.nord);
      });

      test('parses rosePine', () {
        expect(AppTheme.parsePalette('rosePine'), AppThemePalette.rosePine);
      });

      test('returns lazurite for null', () {
        expect(AppTheme.parsePalette(null), AppThemePalette.lazurite);
      });

      test('returns lazurite for unknown value', () {
        expect(AppTheme.parsePalette('unknown'), AppThemePalette.lazurite);
      });
    });

    group('paletteToString', () {
      test('converts lazurite to string', () {
        expect(AppTheme.paletteToString(AppThemePalette.lazurite), 'lazurite');
      });

      test('converts oxocarbon to string', () {
        expect(AppTheme.paletteToString(AppThemePalette.oxocarbon), 'oxocarbon');
      });

      test('converts catppuccin to string', () {
        expect(AppTheme.paletteToString(AppThemePalette.catppuccin), 'catppuccin');
      });

      test('converts nord to string', () {
        expect(AppTheme.paletteToString(AppThemePalette.nord), 'nord');
      });

      test('converts rosePine to string', () {
        expect(AppTheme.paletteToString(AppThemePalette.rosePine), 'rosePine');
      });
    });

    group('parseVariant', () {
      test('parses light', () {
        expect(AppTheme.parseVariant('light'), AppThemeVariant.light);
      });

      test('parses dark', () {
        expect(AppTheme.parseVariant('dark'), AppThemeVariant.dark);
      });

      test('returns dark for null', () {
        expect(AppTheme.parseVariant(null), AppThemeVariant.dark);
      });

      test('returns dark for unknown value', () {
        expect(AppTheme.parseVariant('unknown'), AppThemeVariant.dark);
      });
    });

    group('variantToString', () {
      test('converts light to string', () {
        expect(AppTheme.variantToString(AppThemeVariant.light), 'light');
      });

      test('converts dark to string', () {
        expect(AppTheme.variantToString(AppThemeVariant.dark), 'dark');
      });
    });

    group('round-trip conversion', () {
      test('palette string conversion is reversible', () {
        for (final palette in AppThemePalette.values) {
          final string = AppTheme.paletteToString(palette);
          final parsed = AppTheme.parsePalette(string);
          expect(parsed, palette, reason: 'Failed for $palette -> $string');
        }
      });

      test('variant string conversion is reversible', () {
        for (final variant in AppThemeVariant.values) {
          final string = AppTheme.variantToString(variant);
          final parsed = AppTheme.parseVariant(string);
          expect(parsed, variant, reason: 'Failed for $variant -> $string');
        }
      });
    });
  });
}
