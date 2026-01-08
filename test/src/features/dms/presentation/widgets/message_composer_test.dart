import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/dms/presentation/widgets/message_composer.dart';

void main() {
  group('MessageComposer', () {
    testWidgets('send button is disabled when text is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageComposer(onSend: (_) {})),
        ),
      );

      final sendButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(sendButton.onPressed, isNull);
    });

    testWidgets('send button is enabled when text is entered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageComposer(onSend: (_) {})),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      final sendButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(sendButton.onPressed, isNotNull);
    });

    testWidgets('calls onSend with text when send button is pressed', (tester) async {
      String? sentText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageComposer(onSend: (text) => sentText = text)),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello world');
      await tester.pump();

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(sentText, 'Hello world');
    });

    testWidgets('clears text after sending', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageComposer(onSend: (_) {})),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('shows character counter when approaching limit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageComposer(
              onSend: (_) {},
              maxCharacters: 100,
              characterWarningThreshold: 50,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'a' * 40);
      await tester.pump();
      expect(find.textContaining('/'), findsNothing);

      await tester.enterText(find.byType(TextField), 'a' * 60);
      await tester.pump();
      expect(find.text('60 / 100'), findsOneWidget);
    });

    testWidgets('send button disabled when over character limit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageComposer(
              onSend: (_) {},
              maxCharacters: 50,
              characterWarningThreshold: 40,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'a' * 60);
      await tester.pump();

      final sendButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(sendButton.onPressed, isNull);
    });

    testWidgets('trims whitespace before sending', (tester) async {
      String? sentText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageComposer(onSend: (text) => sentText = text)),
        ),
      );

      await tester.enterText(find.byType(TextField), '  Hello  ');
      await tester.pump();

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(sentText, 'Hello');
    });
  });
}
