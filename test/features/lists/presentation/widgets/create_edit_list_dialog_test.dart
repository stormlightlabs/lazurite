import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/lists/presentation/widgets/create_edit_list_dialog.dart';

void main() {
  Widget buildSubject({String? initialName, String? fixedPurpose}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<CreateEditListResult>(
              context: context,
              builder: (_) => CreateEditListDialog(initialName: initialName, fixedPurpose: fixedPurpose),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('CreateEditListDialog', () {
    testWidgets('shows Create list title in creation mode', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Create list'), findsOneWidget);
    });

    testWidgets('shows Edit list title when fixedPurpose is set', (tester) async {
      await tester.pumpWidget(
        buildSubject(initialName: 'Existing List', fixedPurpose: 'app.bsky.graph.defs#curatelist'),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Edit list'), findsOneWidget);
    });

    testWidgets('shows name and description fields', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Name'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Description (optional)'), findsOneWidget);
    });

    testWidgets('shows purpose selector in creation mode', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Feed'), findsOneWidget);
      expect(find.text('Moderation'), findsOneWidget);
    });

    testWidgets('hides purpose selector in edit mode', (tester) async {
      await tester.pumpWidget(buildSubject(initialName: 'Existing', fixedPurpose: 'app.bsky.graph.defs#curatelist'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Feed'), findsNothing);
      expect(find.text('Moderation'), findsNothing);
    });

    testWidgets('Create button is disabled when name is empty', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final createButton = find.widgetWithText(FilledButton, 'Create');
      final button = tester.widget<FilledButton>(createButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('Create button is enabled after name is entered', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'My New List');
      await tester.pump();

      final createButton = find.widgetWithText(FilledButton, 'Create');
      final button = tester.widget<FilledButton>(createButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('returns CreateEditListResult with correct data on save', (tester) async {
      CreateEditListResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showDialog<CreateEditListResult>(
                    context: context,
                    builder: (_) => const CreateEditListDialog(),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'My List');
      await tester.enterText(find.widgetWithText(TextField, 'Description (optional)'), 'A description');
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.name, 'My List');
      expect(result!.description, 'A description');
      expect(result!.purpose, 'app.bsky.graph.defs#curatelist');
    });

    testWidgets('returns null on cancel', (tester) async {
      CreateEditListResult? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showDialog<CreateEditListResult>(
                    context: context,
                    builder: (_) => const CreateEditListDialog(),
                  );
                },
                child: const Text('Open'),
              ),
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

    testWidgets('populates initial values in edit mode', (tester) async {
      await tester.pumpWidget(buildSubject(initialName: 'Existing List', fixedPurpose: 'app.bsky.graph.defs#modlist'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final nameField = tester.widget<TextField>(find.widgetWithText(TextField, 'Existing List'));
      expect(nameField.controller?.text, 'Existing List');
    });
  });
}
