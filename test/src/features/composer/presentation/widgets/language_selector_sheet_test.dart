import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/language_selector_sheet.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('LanguageSelectorSheet', () {
    testWidgets('renders title and search field', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: LanguageSelectorSheet(
            selectedLanguages: [],
            onSelectionChanged: _dummySelectionCallback,
          ),
        ),
      );

      expect(find.text('Select Languages'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders common languages by default', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: LanguageSelectorSheet(
            selectedLanguages: [],
            onSelectionChanged: _dummySelectionCallback,
          ),
        ),
      );
      // Allow ListView to render
      await tester.pump();

      expect(find.text('English'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);
    });

    testWidgets('shows selected languages as chips', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: LanguageSelectorSheet(
            selectedLanguages: ['en', 'es'],
            onSelectionChanged: _dummySelectionCallback,
          ),
        ),
      );

      // Look for chips by finding the EN text inside a Chip widget
      expect(find.byType(Chip), findsWidgets);
      expect(find.text('EN'), findsWidgets);
      expect(find.text('ES'), findsWidgets);
    });

    testWidgets('clears all languages when Clear is tapped', (tester) async {
      final selectedLanguages = ['en', 'es'];

      await tester.pumpApp(
        Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return LanguageSelectorSheet(
                selectedLanguages: selectedLanguages,
                onSelectionChanged: (langs) {
                  setState(() {
                    selectedLanguages.clear();
                    selectedLanguages.addAll(langs);
                  });
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Clear'));
      await tester.pump();

      expect(selectedLanguages, isEmpty);
    });

    testWidgets('filters languages when searching', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: LanguageSelectorSheet(
            selectedLanguages: [],
            onSelectionChanged: _dummySelectionCallback,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'fr');
      await tester.pump();

      expect(find.text('French'), findsOneWidget);
      expect(find.text('English'), findsNothing);
    });

    testWidgets('enforces maximum of 3 languages', (tester) async {
      final selectedLanguages = <String>[];

      await tester.pumpApp(
        Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return LanguageSelectorSheet(
                selectedLanguages: selectedLanguages,
                onSelectionChanged: (langs) {
                  setState(() {
                    selectedLanguages.clear();
                    selectedLanguages.addAll(langs);
                  });
                },
              );
            },
          ),
        ),
      );

      // Select English
      await tester.tap(
        find.ancestor(of: find.text('English'), matching: find.byType(CheckboxListTile)),
      );
      await tester.pump();

      // Select Spanish
      await tester.tap(
        find.ancestor(of: find.text('Spanish'), matching: find.byType(CheckboxListTile)),
      );
      await tester.pump();

      // Select French
      await tester.tap(
        find.ancestor(of: find.text('French'), matching: find.byType(CheckboxListTile)),
      );
      await tester.pump();

      expect(selectedLanguages.length, 3);

      // Try to select German - should not add since we're at max
      await tester.tap(
        find.ancestor(of: find.text('German'), matching: find.byType(CheckboxListTile)),
      );
      await tester.pump();

      expect(selectedLanguages.length, 3);
    });
  });
}

void _dummySelectionCallback(List<String> _) {}
