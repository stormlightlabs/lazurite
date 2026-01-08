import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/character_count_meter.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('CharacterCountMeter', () {
    testWidgets('renders remaining characters text', (tester) async {
      await tester.pumpApp(const CharacterCountMeter(currentCount: 0, maxCount: 300));

      expect(find.text('300'), findsOneWidget);
    });

    testWidgets('uses warning color when near the limit', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CharacterCountMeter(currentCount: 295, maxCount: 300, warningThreshold: 10),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('5'));
      final context = tester.element(find.byType(CharacterCountMeter));
      final colorScheme = Theme.of(context).colorScheme;
      expect(text.style?.color, colorScheme.tertiary);
    });

    testWidgets('shows negative count when over the limit', (tester) async {
      await tester.pumpApp(const CharacterCountMeter(currentCount: 305, maxCount: 300));

      expect(find.text('-5'), findsOneWidget);
    });
  });
}
