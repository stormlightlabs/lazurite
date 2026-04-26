import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

void main() {
  group('ThemeX', () {
    testWidgets('exposes the current ColorScheme from BuildContext', (tester) async {
      final theme = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)));
      late ColorScheme observed;
      late TextTheme observedTextTheme;
      late TextTheme expectedTextTheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              observed = context.colorScheme;
              observedTextTheme = context.textTheme;
              expectedTextTheme = Theme.of(context).textTheme;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(observed.primary, theme.colorScheme.primary);
      expect(observed.onPrimary, theme.colorScheme.onPrimary);
      expect(observed.surface, theme.colorScheme.surface);
      expect(observedTextTheme.titleMedium?.fontSize, expectedTextTheme.titleMedium?.fontSize);
      expect(observedTextTheme.bodySmall?.fontSize, expectedTextTheme.bodySmall?.fontSize);
      expect(observedTextTheme.labelLarge?.fontWeight, expectedTextTheme.labelLarge?.fontWeight);
    });

    testWidgets('tracks updated inherited theme values', (tester) async {
      final light = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)));
      final dark = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A1B9A), brightness: Brightness.dark),
      );

      late Color initialPrimary;
      late Color updatedPrimary;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Theme(
            data: light,
            child: Builder(
              builder: (context) {
                initialPrimary = context.colorScheme.primary;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Theme(
            data: dark,
            child: Builder(
              builder: (context) {
                updatedPrimary = context.colorScheme.primary;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(initialPrimary, light.colorScheme.primary);
      expect(updatedPrimary, dark.colorScheme.primary);
      expect(updatedPrimary, isNot(initialPrimary));
    });
  });
}
