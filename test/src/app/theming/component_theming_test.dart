import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theming/packs/oxocarbon_theme_pack.dart';

void main() {
  group('Component theming via ColorScheme roles', () {
    group('NavigationBar M3 roles', () {
      late ColorScheme darkCs;
      late ColorScheme lightCs;

      setUp(() {
        darkCs = oxocarbonDarkVariant.derivedScheme;
        lightCs = oxocarbonLightVariant.derivedScheme;
      });

      test('secondaryContainer is set for active indicator', () {
        expect(darkCs.secondaryContainer, isNotNull);
        expect(darkCs.secondaryContainer, const Color(0xFF0A4A79));
      });

      test('onSecondaryContainer is set for selected icon color', () {
        expect(darkCs.onSecondaryContainer, isNotNull);
        expect(darkCs.onSecondaryContainer, const Color(0xFFD1E4FF));
      });

      test('onSurfaceVariant is set for unselected icon color', () {
        expect(darkCs.onSurfaceVariant, isNotNull);
        expect(darkCs.onSurfaceVariant, const Color(0xFF9DA5B4));
      });

      test('onSurface is set for selected label color', () {
        expect(darkCs.onSurface, isNotNull);
        expect(darkCs.onSurface, const Color(0xFFF2F4F8));
      });

      test('surface is set for nav bar background', () {
        expect(darkCs.surface, isNotNull);
        expect(darkCs.surface, const Color(0xFF1A1A1A));
      });

      test('light theme uses distinct secondary container', () {
        expect(lightCs.secondaryContainer, isNotNull);
        expect(lightCs.secondaryContainer, isNot(equals(darkCs.secondaryContainer)));
      });
    });

    group('FilterChip M3 roles', () {
      late ColorScheme darkCs;

      setUp(() {
        darkCs = oxocarbonDarkVariant.derivedScheme;
      });

      test('outline is set for unselected chip border', () {
        expect(darkCs.outline, isNotNull);
        expect(darkCs.outline, const Color(0xFF525252));
      });

      test('onSurfaceVariant is set for unselected chip label', () {
        expect(darkCs.onSurfaceVariant, isNotNull);
        expect(darkCs.onSurfaceVariant, const Color(0xFF9DA5B4));
      });

      test('secondaryContainer is set for selected chip background', () {
        expect(darkCs.secondaryContainer, isNotNull);
        expect(darkCs.secondaryContainer, const Color(0xFF0A4A79));
      });

      test('onSecondaryContainer is set for selected chip label', () {
        expect(darkCs.onSecondaryContainer, isNotNull);
        expect(darkCs.onSecondaryContainer, const Color(0xFFD1E4FF));
      });
    });

    group('Card M3 roles', () {
      late ColorScheme darkCs;

      setUp(() {
        darkCs = oxocarbonDarkVariant.derivedScheme;
      });

      test('surfaceContainerLow is set for card background', () {
        expect(darkCs.surfaceContainerLow, isNotNull);
        expect(darkCs.surfaceContainerLow, const Color(0xFF212121));
      });

      test('surfaceContainerLow is distinct from surface', () {
        expect(darkCs.surfaceContainerLow, isNot(equals(darkCs.surface)));
      });
    });

    group('Divider M3 roles', () {
      late ColorScheme darkCs;

      setUp(() {
        darkCs = oxocarbonDarkVariant.derivedScheme;
      });

      test('outlineVariant is set for subtle dividers', () {
        expect(darkCs.outlineVariant, isNotNull);
        expect(darkCs.outlineVariant, const Color(0xFF393939));
      });

      test('outlineVariant is distinct from outline', () {
        expect(darkCs.outlineVariant, isNot(equals(darkCs.outline)));
      });
    });
  });
}
