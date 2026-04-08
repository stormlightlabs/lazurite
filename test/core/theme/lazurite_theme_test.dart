import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/lazurite_theme.dart';

void main() {
  group('LazuriteTheme', () {
    group('Dark color values', () {
      test('matches expected palette tokens', () {
        expect(LazuriteTheme.darkPrimary, const Color(0xFF7dafff));
        expect(LazuriteTheme.darkOnPrimary, const Color(0xFF05080f));
        expect(LazuriteTheme.darkPrimaryContainer, const Color(0xFF0073de));
        expect(LazuriteTheme.darkOnPrimaryContainer, const Color(0xFFf4f6fb));
        expect(LazuriteTheme.darkSurface, const Color(0xFF0e0e0e));
        expect(LazuriteTheme.darkOnSurface, const Color(0xFFf4f6fb));
        expect(LazuriteTheme.darkSurfaceVariant, const Color(0xFF191919));
        expect(LazuriteTheme.darkOnSurfaceVariant, const Color(0xFFababab));
        expect(LazuriteTheme.darkSurfaceContainerLowest, const Color(0xFF000000));
        expect(LazuriteTheme.darkSurfaceContainer, const Color(0xFF191919));
        expect(LazuriteTheme.darkSurfaceContainerHigh, const Color(0xFF1f1f1f));
        expect(LazuriteTheme.darkSurfaceContainerHighest, const Color(0xF5242424));
        expect(LazuriteTheme.darkSurfaceBright, const Color(0x0Dffffff));
        expect(LazuriteTheme.darkOutline, const Color(0x33ffffff));
        expect(LazuriteTheme.darkOutlineVariant, const Color(0x1Affffff));
        expect(LazuriteTheme.darkError, const Color(0xFFff8080));
        expect(LazuriteTheme.darkErrorContainer, const Color(0xB88a1f1f));
      });
    });

    group('Light color values', () {
      test('matches expected palette tokens', () {
        expect(LazuriteTheme.lightPrimary, const Color(0xFF0b63d1));
        expect(LazuriteTheme.lightOnPrimary, const Color(0xFFffffff));
        expect(LazuriteTheme.lightPrimaryContainer, const Color(0xFF0953af));
        expect(LazuriteTheme.lightOnPrimaryContainer, const Color(0xFFffffff));
        expect(LazuriteTheme.lightSurface, const Color(0xFFffffff));
        expect(LazuriteTheme.lightOnSurface, const Color(0xFF101418));
        expect(LazuriteTheme.lightSurfaceVariant, const Color(0xFFf4f6f9));
        expect(LazuriteTheme.lightOnSurfaceVariant, const Color(0xFF45505e));
        expect(LazuriteTheme.lightSurfaceContainerLowest, const Color(0xFFeef1f5));
        expect(LazuriteTheme.lightSurfaceContainer, const Color(0xFFf4f6f9));
        expect(LazuriteTheme.lightSurfaceContainerHigh, const Color(0xFFeceff4));
        expect(LazuriteTheme.lightSurfaceContainerHighest, const Color(0xF5f6f8fc));
        expect(LazuriteTheme.lightSurfaceBright, const Color(0x0F111827));
        expect(LazuriteTheme.lightOutline, const Color(0x3D111827));
        expect(LazuriteTheme.lightOutlineVariant, const Color(0x24111827));
        expect(LazuriteTheme.lightError, const Color(0xFFb42318));
        expect(LazuriteTheme.lightErrorContainer, const Color(0xF2fee2e2));
      });
    });

    group('ThemeData', () {
      testWidgets('dark theme maps key color scheme roles', (tester) async {
        final theme = LazuriteTheme.dark();
        final scheme = theme.colorScheme;

        expect(theme.brightness, Brightness.dark);
        expect(scheme.primary, LazuriteTheme.darkPrimary);
        expect(scheme.onPrimary, LazuriteTheme.darkOnPrimary);
        expect(scheme.primaryContainer, LazuriteTheme.darkPrimaryContainer);
        expect(scheme.surfaceContainerLowest, LazuriteTheme.darkSurfaceContainerLowest);
        expect(scheme.surfaceContainerHigh, LazuriteTheme.darkSurfaceContainerHigh);
        expect(scheme.surfaceContainerHighest, LazuriteTheme.darkSurfaceContainerHighest);
        expect(scheme.onSurfaceVariant, LazuriteTheme.darkOnSurfaceVariant);
        expect(scheme.outlineVariant, LazuriteTheme.darkOutlineVariant);
        expect(scheme.errorContainer, LazuriteTheme.darkErrorContainer);
      });

      testWidgets('light theme maps key color scheme roles', (tester) async {
        final theme = LazuriteTheme.light();
        final scheme = theme.colorScheme;

        expect(theme.brightness, Brightness.light);
        expect(scheme.primary, LazuriteTheme.lightPrimary);
        expect(scheme.onPrimary, LazuriteTheme.lightOnPrimary);
        expect(scheme.primaryContainer, LazuriteTheme.lightPrimaryContainer);
        expect(scheme.surfaceContainerLowest, LazuriteTheme.lightSurfaceContainerLowest);
        expect(scheme.surfaceContainerHigh, LazuriteTheme.lightSurfaceContainerHigh);
        expect(scheme.surfaceContainerHighest, LazuriteTheme.lightSurfaceContainerHighest);
        expect(scheme.onSurfaceVariant, LazuriteTheme.lightOnSurfaceVariant);
        expect(scheme.outlineVariant, LazuriteTheme.lightOutlineVariant);
        expect(scheme.errorContainer, LazuriteTheme.lightErrorContainer);
      });
    });
  });
}
