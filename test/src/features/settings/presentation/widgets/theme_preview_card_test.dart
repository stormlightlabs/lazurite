import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/settings/presentation/widgets/theme_preview_card.dart';

void main() {
  group('ThemePreviewCard', () {
    testWidgets('displays label', (tester) async {
      final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemePreviewCard(label: 'Dark', colorScheme: colorScheme),
          ),
        ),
      );

      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('displays surface color samples', (tester) async {
      final colorScheme = ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemePreviewCard(label: 'Dark', colorScheme: colorScheme),
          ),
        ),
      );

      final coloredBoxes = find.byType(ColoredBox);
      expect(coloredBoxes, findsWidgets);
    });

    testWidgets('displays accent color samples', (tester) async {
      final colorScheme = ColorScheme.fromSeed(seedColor: Colors.purple);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemePreviewCard(label: 'Light', colorScheme: colorScheme),
          ),
        ),
      );

      final coloredBoxes = find.byType(ColoredBox);
      expect(coloredBoxes, findsWidgets);
    });

    testWidgets('displays text samples with correct colors', (tester) async {
      final colorScheme = ColorScheme.fromSeed(seedColor: Colors.teal);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemePreviewCard(label: 'Test', colorScheme: colorScheme),
          ),
        ),
      );

      expect(find.text('Aa'), findsNWidgets(2));
    });

    testWidgets('renders in a card container', (tester) async {
      final colorScheme = ColorScheme.fromSeed(seedColor: Colors.orange);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemePreviewCard(label: 'Preview', colorScheme: colorScheme),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
