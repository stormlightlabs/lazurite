import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/composer_text_field.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ComposerTextField', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders text field with default hint', (tester) async {
      await tester.pumpApp(
        SingleChildScrollView(child: ComposerTextField(controller: controller)),
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text("What's happening?"), findsOneWidget);
    });

    testWidgets('renders custom hint text', (tester) async {
      await tester.pumpApp(
        SingleChildScrollView(
          child: ComposerTextField(controller: controller, hintText: 'Reply...'),
        ),
      );
      expect(find.text('Reply...'), findsOneWidget);
    });

    testWidgets('displays remaining character count', (tester) async {
      await tester.pumpApp(
        SingleChildScrollView(child: ComposerTextField(controller: controller, maxLength: 300)),
      );
      expect(find.text('300'), findsOneWidget);
    });

    testWidgets('updates character count on input', (tester) async {
      await tester.pumpApp(
        SingleChildScrollView(child: ComposerTextField(controller: controller)),
      );
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();
      expect(find.text('295'), findsOneWidget);
    });

    testWidgets('fires onChanged callback', (tester) async {
      String? changedValue;
      await tester.pumpApp(
        SingleChildScrollView(
          child: ComposerTextField(
            controller: controller,
            onChanged: (value) => changedValue = value,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Test');
      expect(changedValue, 'Test');
    });

    testWidgets('shows correct count when near limit', (tester) async {
      controller.text = 'abcde'; // With maxLength: 10, this is 5 remaining
      await tester.pumpApp(
        SingleChildScrollView(child: ComposerTextField(controller: controller, maxLength: 10)),
      );
      await tester.pump();
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('computes negative count for over-limit text', (tester) async {
      controller.text = 'Hello World!!';
      await tester.pumpApp(
        SingleChildScrollView(child: ComposerTextField(controller: controller, maxLength: 10)),
      );
      await tester.pump();
      expect(find.text('-3'), findsOneWidget);
    });
  });
}
