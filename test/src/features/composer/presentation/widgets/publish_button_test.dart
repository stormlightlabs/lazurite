import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/publish_button.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('PublishButton', () {
    testWidgets('renders with default label', (tester) async {
      await tester.pumpApp(const PublishButton());
      expect(find.text('Post'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('renders custom label', (tester) async {
      await tester.pumpApp(const PublishButton(label: 'Reply'));
      expect(find.text('Reply'), findsOneWidget);
    });

    testWidgets('calls onPressed when enabled and tapped', (tester) async {
      var pressed = false;
      await tester.pumpApp(PublishButton(onPressed: () => pressed = true));
      await tester.tap(find.byType(FilledButton));
      expect(pressed, isTrue);
    });

    testWidgets('is disabled when isDisabled is true', (tester) async {
      var pressed = false;
      await tester.pumpApp(PublishButton(isDisabled: true, onPressed: () => pressed = true));
      await tester.tap(find.byType(FilledButton));
      expect(pressed, isFalse);
    });

    testWidgets('shows spinner when isLoading is true', (tester) async {
      await tester.pumpApp(const PublishButton(isLoading: true));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Post'), findsNothing);
    });

    testWidgets('is not pressable when isLoading is true', (tester) async {
      var pressed = false;
      await tester.pumpApp(PublishButton(isLoading: true, onPressed: () => pressed = true));
      await tester.tap(find.byType(FilledButton));
      expect(pressed, isFalse);
    });
  });
}
