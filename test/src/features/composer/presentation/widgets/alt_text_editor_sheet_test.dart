import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/alt_text_editor_sheet.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('AltTextEditorSheet', () {
    Widget buildTestWidget({String? initialAltText}) {
      return Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              await showModalBottomSheet<String>(
                context: context,
                isScrollControlled: true,
                builder: (_) => Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: AltTextEditorSheet(initialAltText: initialAltText),
                ),
              );
            },
            child: const Text('Open Sheet'),
          ),
        ),
      );
    }

    Future<void> openSheet(WidgetTester tester) async {
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders text field and buttons', (tester) async {
      await tester.pumpApp(buildTestWidget());
      await openSheet(tester);

      expect(find.text('Alt Text'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('shows accessibility guidance text', (tester) async {
      await tester.pumpApp(buildTestWidget());
      await openSheet(tester);

      expect(
        find.text('Alt text helps describe images for people who use screen readers.'),
        findsOneWidget,
      );
    });

    testWidgets('populates text field with initial alt text', (tester) async {
      await tester.pumpApp(buildTestWidget(initialAltText: 'A sunset over the ocean'));
      await openSheet(tester);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'A sunset over the ocean');
    });

    testWidgets('shows character counter', (tester) async {
      await tester.pumpApp(buildTestWidget());
      await openSheet(tester);

      expect(find.text('0 / 1000'), findsOneWidget);
    });

    testWidgets('updates counter as user types', (tester) async {
      await tester.pumpApp(buildTestWidget());
      await openSheet(tester);

      await tester.enterText(find.byType(TextField), 'Test text');
      await tester.pump();

      expect(find.text('9 / 1000'), findsOneWidget);
    });

    testWidgets('save button enabled when within character limit', (tester) async {
      await tester.pumpApp(buildTestWidget());
      await openSheet(tester);

      await tester.enterText(find.byType(TextField), 'Valid alt text');
      await tester.pump();

      final saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('cancel button pops with null', (tester) async {
      String? result = 'initial';

      await tester.pumpApp(
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const AltTextEditorSheet(initialAltText: 'Test'),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('save button pops with entered text', (tester) async {
      String? result;

      await tester.pumpApp(
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const AltTextEditorSheet(),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'My alt text');
      await tester.pump();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(result, 'My alt text');
    });

    testWidgets('close icon button pops with null', (tester) async {
      String? result = 'initial';

      await tester.pumpApp(
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const AltTextEditorSheet(),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('hint text is set in text field', (tester) async {
      await tester.pumpApp(buildTestWidget());
      await openSheet(tester);

      final TextField textField = tester.widget(find.byType(TextField));
      expect(textField.decoration?.hintText, 'Describe this image...');
    });
  });
}
