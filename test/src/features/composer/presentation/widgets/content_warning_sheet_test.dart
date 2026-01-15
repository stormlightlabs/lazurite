import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/content_warning_sheet.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ContentWarningSheet', () {
    testWidgets('renders title and description', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ContentWarningSheet(
            selectedLabels: [],
            onSelectionChanged: _dummySelectionCallback,
          ),
        ),
      );

      expect(find.text('Content Warnings'), findsOneWidget);
      expect(
        find.text('Add content warnings to help others understand what to expect.'),
        findsOneWidget,
      );
    });

    testWidgets('renders all warning options', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ContentWarningSheet(
            selectedLabels: [],
            onSelectionChanged: _dummySelectionCallback,
          ),
        ),
      );

      expect(find.text('Sexual Content'), findsOneWidget);
      expect(find.text('Nudity'), findsOneWidget);
      expect(find.text('Pornography'), findsOneWidget);
      expect(find.text('Graphic Media'), findsOneWidget);
    });

    testWidgets('shows selected labels as checked', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ContentWarningSheet(
            selectedLabels: ['sexual', 'graphic-media'],
            onSelectionChanged: _dummySelectionCallback,
          ),
        ),
      );

      final sexualCheckbox = tester.widget<CheckboxListTile>(
        find.ancestor(of: find.text('Sexual Content'), matching: find.byType(CheckboxListTile)),
      );

      final graphicCheckbox = tester.widget<CheckboxListTile>(
        find.ancestor(of: find.text('Graphic Media'), matching: find.byType(CheckboxListTile)),
      );

      expect(sexualCheckbox.value, isTrue);
      expect(graphicCheckbox.value, isTrue);
    });

    testWidgets('toggles label when tapped', (tester) async {
      final selectedLabels = <String>[];

      await tester.pumpApp(
        Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ContentWarningSheet(
                selectedLabels: selectedLabels,
                onSelectionChanged: (labels) {
                  setState(() {
                    selectedLabels.clear();
                    selectedLabels.addAll(labels);
                  });
                },
              );
            },
          ),
        ),
      );

      // Tap the CheckboxListTile widget to add
      await tester.tap(
        find.ancestor(of: find.text('Sexual Content'), matching: find.byType(CheckboxListTile)),
      );
      await tester.pump();

      expect(selectedLabels, contains('sexual'));

      // Tap again to remove
      await tester.tap(
        find.ancestor(of: find.text('Sexual Content'), matching: find.byType(CheckboxListTile)),
      );
      await tester.pump();

      expect(selectedLabels, isEmpty);
    });

    testWidgets('clears all labels when Clear is tapped', (tester) async {
      final selectedLabels = ['sexual', 'graphic-media'];

      await tester.pumpApp(
        Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ContentWarningSheet(
                selectedLabels: selectedLabels,
                onSelectionChanged: (labels) {
                  setState(() {
                    selectedLabels.clear();
                    selectedLabels.addAll(labels);
                  });
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Clear'));
      await tester.pump();

      expect(selectedLabels, isEmpty);
    });
  });
}

void _dummySelectionCallback(List<String> _) {}
