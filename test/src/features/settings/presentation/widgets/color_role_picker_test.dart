import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/settings/presentation/widgets/color_role_picker.dart';

void main() {
  group('ColorRolePicker', () {
    const defaultColor = Color(0xFF0085FF);
    const overrideColor = Color(0xFFFF7EB6);

    Widget buildTestWidget({
      required String label,
      required String description,
      required Color? currentColor,
      required Color defaultColor,
      required ValueChanged<Color?> onColorChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ColorRolePicker(
            label: label,
            description: description,
            currentColor: currentColor,
            defaultColor: defaultColor,
            onColorChanged: onColorChanged,
          ),
        ),
      );
    }

    testWidgets('displays label and description', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: null,
          defaultColor: defaultColor,
          onColorChanged: (_) {},
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Main accent color'), findsOneWidget);
    });

    testWidgets('displays default color when currentColor is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: null,
          defaultColor: defaultColor,
          onColorChanged: (_) {},
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(of: find.byType(GestureDetector), matching: find.byType(Container)).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, defaultColor);
    });

    testWidgets('displays override color when currentColor is set', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: overrideColor,
          defaultColor: defaultColor,
          onColorChanged: (_) {},
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(of: find.byType(GestureDetector), matching: find.byType(Container)).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, overrideColor);
    });

    testWidgets('shows edit icon when color has override', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: overrideColor,
          defaultColor: defaultColor,
          onColorChanged: (_) {},
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('does not show edit icon when using default', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: null,
          defaultColor: defaultColor,
          onColorChanged: (_) {},
        ),
      );

      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('shows restore button when color has override', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: overrideColor,
          defaultColor: defaultColor,
          onColorChanged: (_) {},
        ),
      );

      expect(find.byIcon(Icons.restore), findsOneWidget);
    });

    testWidgets('does not show restore button when using default', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: null,
          defaultColor: defaultColor,
          onColorChanged: (_) {},
        ),
      );

      expect(find.byIcon(Icons.restore), findsNothing);
    });

    testWidgets('tapping restore button calls onColorChanged with null', (tester) async {
      Color? changedColor = overrideColor;
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: overrideColor,
          defaultColor: defaultColor,
          onColorChanged: (color) => changedColor = color,
        ),
      );

      await tester.tap(find.byIcon(Icons.restore));
      await tester.pump();

      expect(changedColor, isNull);
    });

    testWidgets('tapping color box opens color picker dialog', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: null,
          defaultColor: defaultColor,
          onColorChanged: (_) {},
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(find.text('Select Color'), findsOneWidget);
    });

    testWidgets('tapping ListTile opens color picker dialog', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: null,
          defaultColor: defaultColor,
          onColorChanged: (_) {},
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      expect(find.text('Select Color'), findsOneWidget);
    });

    testWidgets('color picker dialog shows preset colors', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: null,
          defaultColor: defaultColor,
          onColorChanged: (_) {},
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('color picker dialog shows hex input', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: null,
          defaultColor: defaultColor,
          onColorChanged: (_) {},
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, '0085FF'), findsOneWidget);
    });

    testWidgets('dialog cancel button closes without callback', (tester) async {
      bool callbackCalled = false;
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: null,
          defaultColor: defaultColor,
          onColorChanged: (_) => callbackCalled = true,
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Select Color'), findsNothing);
      expect(callbackCalled, isFalse);
    });

    testWidgets('dialog select button calls onColorChanged with selected color', (tester) async {
      Color? selectedColor;
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: null,
          defaultColor: defaultColor,
          onColorChanged: (color) => selectedColor = color,
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      expect(find.text('Select Color'), findsNothing);
      expect(selectedColor, isNotNull);
    });

    testWidgets('typing hex code updates selected color', (tester) async {
      Color? selectedColor;
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: null,
          defaultColor: defaultColor,
          onColorChanged: (color) => selectedColor = color,
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'FF0000');
      await tester.pump();

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      expect(selectedColor, const Color(0xFFFF0000));
    });

    testWidgets('tapping preset color updates selection', (tester) async {
      Color? selectedColor;
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: null,
          defaultColor: defaultColor,
          onColorChanged: (color) => selectedColor = color,
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      final presetContainers = find.descendant(
        of: find.byType(Wrap),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(presetContainers.at(1));
      await tester.pump();

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      expect(selectedColor, isNotNull);
    });

    testWidgets('displayColor getter returns currentColor when set', (tester) async {
      final widget = ColorRolePicker(
        label: 'Primary',
        description: 'Test',
        currentColor: overrideColor,
        defaultColor: defaultColor,
        onColorChanged: (_) {},
      );

      expect(widget.displayColor, overrideColor);
    });

    testWidgets('displayColor getter returns defaultColor when currentColor is null', (
      tester,
    ) async {
      final widget = ColorRolePicker(
        label: 'Primary',
        description: 'Test',
        currentColor: null,
        defaultColor: defaultColor,
        onColorChanged: (_) {},
      );

      expect(widget.displayColor, defaultColor);
    });

    testWidgets('hasOverride getter returns true when currentColor is set', (tester) async {
      final widget = ColorRolePicker(
        label: 'Primary',
        description: 'Test',
        currentColor: overrideColor,
        defaultColor: defaultColor,
        onColorChanged: (_) {},
      );

      expect(widget.hasOverride, isTrue);
    });

    testWidgets('hasOverride getter returns false when currentColor is null', (tester) async {
      final widget = ColorRolePicker(
        label: 'Primary',
        description: 'Test',
        currentColor: null,
        defaultColor: defaultColor,
        onColorChanged: (_) {},
      );

      expect(widget.hasOverride, isFalse);
    });

    testWidgets('hex input handles # prefix', (tester) async {
      Color? selectedColor;
      await tester.pumpWidget(
        buildTestWidget(
          label: 'Primary',
          description: 'Main accent color',
          currentColor: null,
          defaultColor: defaultColor,
          onColorChanged: (color) => selectedColor = color,
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, '#00FF00');
      await tester.pump();

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      expect(selectedColor, const Color(0xFF00FF00));
    });
  });
}
