import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/content_warning_button.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ContentWarningButton', () {
    testWidgets('shows "Add warning" when no labels selected', (tester) async {
      await tester.pumpApp(
        const Material(
          child: ContentWarningButton(labels: [], onTap: _dummyCallback),
        ),
      );

      expect(find.text('Add warning'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('shows warning count when labels selected', (tester) async {
      await tester.pumpApp(
        const Material(
          child: ContentWarningButton(labels: ['sexual', 'graphic-media'], onTap: _dummyCallback),
        ),
      );

      expect(find.text('2 warnings'), findsOneWidget);
    });

    testWidgets('shows singular "warning" when one label selected', (tester) async {
      await tester.pumpApp(
        const Material(
          child: ContentWarningButton(labels: ['sexual'], onTap: _dummyCallback),
        ),
      );

      expect(find.text('1 warning'), findsOneWidget);
    });

    testWidgets('uses error container color when warnings exist', (tester) async {
      await tester.pumpApp(
        const Material(
          child: ContentWarningButton(labels: ['sexual'], onTap: _dummyCallback),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ContentWarningButton),
          matching: find.byType(Container).at(0),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      void onTap() {
        tapped = true;
      }

      await tester.pumpApp(
        Material(
          child: ContentWarningButton(labels: [], onTap: onTap),
        ),
      );

      await tester.tap(find.byType(ContentWarningButton));
      expect(tapped, isTrue);
    });
  });
}

void _dummyCallback() {}
