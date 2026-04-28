import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/catppuccin_theme.dart';

void main() {
  group('CatppuccinTheme', () {
    group('Mocha (Dark) color values', () {
      test('base is #1e1e2e', () {
        expect(CatppuccinTheme.mochaBase, const Color(0xFF1e1e2e));
      });

      test('mantle is #181825', () {
        expect(CatppuccinTheme.mochaMantle, const Color(0xFF181825));
      });

      test('surface0 is #313244', () {
        expect(CatppuccinTheme.mochaSurface0, const Color(0xFF313244));
      });

      test('surface1 is #45475a', () {
        expect(CatppuccinTheme.mochaSurface1, const Color(0xFF45475a));
      });

      test('subtext0 is #a6adc8', () {
        expect(CatppuccinTheme.mochaSubtext0, const Color(0xFFa6adc8));
      });

      test('text is #cdd6f4', () {
        expect(CatppuccinTheme.mochaText, const Color(0xFFcdd6f4));
      });

      test('lavender is #b4befe', () {
        expect(CatppuccinTheme.mochaLavender, const Color(0xFFb4befe));
      });

      test('blue is #89b4fa', () {
        expect(CatppuccinTheme.mochaBlue, const Color(0xFF89b4fa));
      });

      test('sapphire is #74c7ec', () {
        expect(CatppuccinTheme.mochaSapphire, const Color(0xFF74c7ec));
      });

      test('green is #a6e3a1', () {
        expect(CatppuccinTheme.mochaGreen, const Color(0xFFa6e3a1));
      });

      test('red is #f38ba8', () {
        expect(CatppuccinTheme.mochaRed, const Color(0xFFf38ba8));
      });

      test('peach is #fab387', () {
        expect(CatppuccinTheme.mochaPeach, const Color(0xFFfab387));
      });

      test('mauve is #cba6f7', () {
        expect(CatppuccinTheme.mochaMauve, const Color(0xFFcba6f7));
      });

      test('pink is #f5c2e7', () {
        expect(CatppuccinTheme.mochaPink, const Color(0xFFf5c2e7));
      });

      test('rosewater is #f5e0dc', () {
        expect(CatppuccinTheme.mochaRosewater, const Color(0xFFf5e0dc));
      });
    });

    group('Latte (Light) color values', () {
      test('base is #eff1f5', () {
        expect(CatppuccinTheme.latteBase, const Color(0xFFeff1f5));
      });

      test('mantle is #e6e9ef', () {
        expect(CatppuccinTheme.latteMantle, const Color(0xFFe6e9ef));
      });

      test('surface0 is #ccd0da', () {
        expect(CatppuccinTheme.latteSurface0, const Color(0xFFccd0da));
      });

      test('surface1 is #bcc0cc', () {
        expect(CatppuccinTheme.latteSurface1, const Color(0xFFbcc0cc));
      });

      test('subtext0 is #6c6f85', () {
        expect(CatppuccinTheme.latteSubtext0, const Color(0xFF6c6f85));
      });

      test('text is #4c4f69', () {
        expect(CatppuccinTheme.latteText, const Color(0xFF4c4f69));
      });

      test('lavender is #7287fd', () {
        expect(CatppuccinTheme.latteLavender, const Color(0xFF7287fd));
      });

      test('blue is #1e66f5', () {
        expect(CatppuccinTheme.latteBlue, const Color(0xFF1e66f5));
      });

      test('sapphire is #209fb5', () {
        expect(CatppuccinTheme.latteSapphire, const Color(0xFF209fb5));
      });

      test('green is #40a02b', () {
        expect(CatppuccinTheme.latteGreen, const Color(0xFF40a02b));
      });

      test('red is #d20f39', () {
        expect(CatppuccinTheme.latteRed, const Color(0xFFd20f39));
      });

      test('peach is #fe640b', () {
        expect(CatppuccinTheme.lattePeach, const Color(0xFFfe640b));
      });

      test('mauve is #8839ef', () {
        expect(CatppuccinTheme.latteMauve, const Color(0xFF8839ef));
      });

      test('pink is #ea76cb', () {
        expect(CatppuccinTheme.lattePink, const Color(0xFFea76cb));
      });

      test('rosewater is #dc8a78', () {
        expect(CatppuccinTheme.latteRosewater, const Color(0xFFdc8a78));
      });
    });

    group('ThemeData', () {
      test('dark theme maps expected tokens', () {
        final theme = CatppuccinTheme.dark();
        final scheme = theme.colorScheme;

        expect(theme.useMaterial3, isTrue);
        expect(theme.brightness, Brightness.dark);
        expect(scheme.primary, CatppuccinTheme.mochaLavender);
        expect(scheme.secondary, CatppuccinTheme.mochaMauve);
        expect(scheme.tertiary, CatppuccinTheme.mochaSapphire);
        expect(scheme.surface, CatppuccinTheme.mochaMantle);
        expect(scheme.onSurface, CatppuccinTheme.mochaText);
        expect(scheme.surfaceContainerHighest, CatppuccinTheme.mochaSurface0);
        expect(scheme.outline, CatppuccinTheme.mochaSurface1);
        expect(scheme.outlineVariant, CatppuccinTheme.mochaSurface0);
        expect(theme.scaffoldBackgroundColor, CatppuccinTheme.mochaBase);
        expect(theme.appBarTheme.backgroundColor, CatppuccinTheme.mochaBase);
        expect(theme.cardTheme.color, CatppuccinTheme.mochaMantle);
        expect(theme.dividerTheme.color, CatppuccinTheme.mochaSurface0);
        expect(theme.iconTheme.color, CatppuccinTheme.mochaSubtext0);
        expect(theme.listTileTheme.textColor, CatppuccinTheme.mochaText);
        expect(theme.floatingActionButtonTheme.backgroundColor, CatppuccinTheme.mochaLavender);
        expect(theme.inputDecorationTheme.filled, isTrue);
        expect(theme.inputDecorationTheme.fillColor, CatppuccinTheme.mochaMantle);
        expect(theme.snackBarTheme.backgroundColor, CatppuccinTheme.mochaMantle);
      });

      test('light theme maps expected tokens', () {
        final theme = CatppuccinTheme.light();
        final scheme = theme.colorScheme;

        expect(theme.useMaterial3, isTrue);
        expect(theme.brightness, Brightness.light);
        expect(scheme.primary, CatppuccinTheme.latteLavender);
        expect(scheme.secondary, CatppuccinTheme.latteMauve);
        expect(scheme.tertiary, CatppuccinTheme.latteSapphire);
        expect(scheme.surface, CatppuccinTheme.latteMantle);
        expect(scheme.onSurface, CatppuccinTheme.latteText);
        expect(scheme.surfaceContainerHighest, CatppuccinTheme.latteSurface0);
        expect(scheme.outline, CatppuccinTheme.latteSurface1);
        expect(scheme.outlineVariant, CatppuccinTheme.latteSurface0);
        expect(theme.scaffoldBackgroundColor, CatppuccinTheme.latteBase);
        expect(theme.appBarTheme.backgroundColor, CatppuccinTheme.latteBase);
        expect(theme.cardTheme.color, CatppuccinTheme.latteMantle);
        expect(theme.dividerTheme.color, CatppuccinTheme.latteSurface0);
        expect(theme.iconTheme.color, CatppuccinTheme.latteSubtext0);
        expect(theme.listTileTheme.textColor, CatppuccinTheme.latteText);
        expect(theme.floatingActionButtonTheme.backgroundColor, CatppuccinTheme.latteLavender);
        expect(theme.inputDecorationTheme.filled, isTrue);
        expect(theme.inputDecorationTheme.fillColor, CatppuccinTheme.latteMantle);
        expect(theme.snackBarTheme.backgroundColor, CatppuccinTheme.latteMantle);
      });
    });
  });
}
