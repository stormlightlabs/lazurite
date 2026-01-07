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

    group('Embed M3 roles', () {
      late ColorScheme darkCs;

      setUp(() {
        darkCs = oxocarbonDarkVariant.derivedScheme;
      });

      test('surfaceContainer is set for embed backgrounds', () {
        expect(darkCs.surfaceContainer, isNotNull);
      });

      test('surfaceContainer is distinct from surfaceContainerLow', () {
        expect(darkCs.surfaceContainer, isNot(equals(darkCs.surfaceContainerLow)));
      });

      test('surfaceContainer is lighter than surfaceContainerLow in dark theme', () {
        final containerLuminance = darkCs.surfaceContainer.computeLuminance();
        final containerLowLuminance = darkCs.surfaceContainerLow.computeLuminance();
        expect(containerLuminance, greaterThan(containerLowLuminance));
      });
    });

    group('Text emphasis M3 roles', () {
      late ColorScheme darkCs;
      late ColorScheme lightCs;

      setUp(() {
        darkCs = oxocarbonDarkVariant.derivedScheme;
        lightCs = oxocarbonLightVariant.derivedScheme;
      });

      test('onSurfaceVariant is set for secondary text', () {
        expect(darkCs.onSurfaceVariant, isNotNull);
        expect(lightCs.onSurfaceVariant, isNotNull);
      });

      test('onSurfaceVariant is distinct from onSurface', () {
        expect(darkCs.onSurfaceVariant, isNot(equals(darkCs.onSurface)));
        expect(lightCs.onSurfaceVariant, isNot(equals(lightCs.onSurface)));
      });

      test('onSurfaceVariant has lower contrast than onSurface in dark theme', () {
        final variantLuminance = darkCs.onSurfaceVariant.computeLuminance();
        final primaryLuminance = darkCs.onSurface.computeLuminance();
        expect(variantLuminance, lessThan(primaryLuminance));
      });

      test('onSurfaceVariant has lower contrast than onSurface in light theme', () {
        final variantLuminance = lightCs.onSurfaceVariant.computeLuminance();
        final primaryLuminance = lightCs.onSurface.computeLuminance();
        expect(variantLuminance, greaterThan(primaryLuminance));
      });
    });

    group('TextField M3 roles', () {
      late ColorScheme darkCs;

      setUp(() {
        darkCs = oxocarbonDarkVariant.derivedScheme;
      });

      test('surfaceContainerHighest is set for filled text field background', () {
        expect(darkCs.surfaceContainerHighest, isNotNull);
      });

      test('surfaceContainerHighest is distinct from surface', () {
        expect(darkCs.surfaceContainerHighest, isNot(equals(darkCs.surface)));
      });

      test('outline is set for text field border', () {
        expect(darkCs.outline, isNotNull);
        expect(darkCs.outline, const Color(0xFF525252));
      });

      test('onSurfaceVariant is set for hint and label text', () {
        expect(darkCs.onSurfaceVariant, isNotNull);
      });
    });

    group('Dialog M3 roles', () {
      late ColorScheme darkCs;
      late ColorScheme lightCs;

      setUp(() {
        darkCs = oxocarbonDarkVariant.derivedScheme;
        lightCs = oxocarbonLightVariant.derivedScheme;
      });

      test('surfaceContainerHigh is set for dialog background', () {
        expect(darkCs.surfaceContainerHigh, isNotNull);
        expect(lightCs.surfaceContainerHigh, isNotNull);
      });

      test('surfaceContainerHigh is distinct from surface', () {
        expect(darkCs.surfaceContainerHigh, isNot(equals(darkCs.surface)));
        expect(lightCs.surfaceContainerHigh, isNot(equals(lightCs.surface)));
      });

      test('surfaceContainerHigh is higher than surfaceContainer', () {
        final highLuminance = darkCs.surfaceContainerHigh.computeLuminance();
        final containerLuminance = darkCs.surfaceContainer.computeLuminance();
        expect(highLuminance, greaterThan(containerLuminance));
      });
    });

    group('BottomSheet M3 roles', () {
      late ColorScheme darkCs;
      late ColorScheme lightCs;

      setUp(() {
        darkCs = oxocarbonDarkVariant.derivedScheme;
        lightCs = oxocarbonLightVariant.derivedScheme;
      });

      test('surfaceContainerLow is set for bottom sheet background', () {
        expect(darkCs.surfaceContainerLow, isNotNull);
        expect(lightCs.surfaceContainerLow, isNotNull);
      });

      test('surfaceContainerLow is distinct from surface', () {
        expect(darkCs.surfaceContainerLow, isNot(equals(darkCs.surface)));
      });

      test('dark theme has full surface container ladder', () {
        expect(darkCs.surfaceContainerLowest, isNotNull);
        expect(darkCs.surfaceContainerLow, isNotNull);
        expect(darkCs.surfaceContainer, isNotNull);
        expect(darkCs.surfaceContainerHigh, isNotNull);
        expect(darkCs.surfaceContainerHighest, isNotNull);
      });
    });
  });
}
