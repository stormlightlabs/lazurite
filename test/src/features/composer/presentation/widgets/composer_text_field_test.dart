import 'package:extended_text_field/extended_text_field.dart';
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

    testWidgets('renders extended text field with default hint', (tester) async {
      await tester.pumpApp(
        SingleChildScrollView(child: ComposerTextField(controller: controller)),
      );
      expect(find.byType(ExtendedTextField), findsOneWidget);
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
      controller.text = 'Hello';
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

      final textField = tester.widget<ExtendedTextField>(find.byType(ExtendedTextField));
      textField.onChanged?.call('Test');
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

    testWidgets('accepts text with mentions', (tester) async {
      await tester.pumpApp(
        SingleChildScrollView(child: ComposerTextField(controller: controller)),
      );
      controller.text = 'Hello @alice.bsky.social';
      await tester.pump();
      expect(controller.text, 'Hello @alice.bsky.social');
    });

    testWidgets('accepts text with hashtags', (tester) async {
      await tester.pumpApp(
        SingleChildScrollView(child: ComposerTextField(controller: controller)),
      );
      controller.text = 'Check out #flutter';
      await tester.pump();
      expect(controller.text, 'Check out #flutter');
    });

    testWidgets('accepts text with URLs', (tester) async {
      await tester.pumpApp(
        SingleChildScrollView(child: ComposerTextField(controller: controller)),
      );
      controller.text = 'Visit https://example.com';
      await tester.pump();
      expect(controller.text, 'Visit https://example.com');
    });

    testWidgets('accepts text with mixed special text', (tester) async {
      await tester.pumpApp(
        SingleChildScrollView(child: ComposerTextField(controller: controller)),
      );
      const mixedText = 'Hey @bob.bsky.social check #flutter at https://flutter.dev';
      controller.text = mixedText;
      await tester.pump();
      expect(controller.text, mixedText);
    });
  });

  group('ComposerTextSpanBuilder', () {
    test('creates MentionText for @ flag', () {
      final builder = ComposerTextSpanBuilder(
        mentionColor: Colors.blue,
        linkColor: Colors.purple,
        hashtagColor: Colors.green,
      );

      final specialText = builder.createSpecialText('@', textStyle: const TextStyle());
      expect(specialText, isA<MentionText>());
    });

    test('creates HashtagText for # flag', () {
      final builder = ComposerTextSpanBuilder(
        mentionColor: Colors.blue,
        linkColor: Colors.purple,
        hashtagColor: Colors.green,
      );

      final specialText = builder.createSpecialText('#', textStyle: const TextStyle());
      expect(specialText, isA<HashtagText>());
    });

    test('creates LinkText for http:// flag', () {
      final builder = ComposerTextSpanBuilder(
        mentionColor: Colors.blue,
        linkColor: Colors.purple,
        hashtagColor: Colors.green,
      );

      final specialText = builder.createSpecialText('http://', textStyle: const TextStyle());
      expect(specialText, isA<LinkText>());
    });

    test('creates LinkText for https:// flag', () {
      final builder = ComposerTextSpanBuilder(
        mentionColor: Colors.blue,
        linkColor: Colors.purple,
        hashtagColor: Colors.green,
      );

      final specialText = builder.createSpecialText('https://', textStyle: const TextStyle());
      expect(specialText, isA<LinkText>());
    });

    test('returns null for unknown flag', () {
      final builder = ComposerTextSpanBuilder(
        mentionColor: Colors.blue,
        linkColor: Colors.purple,
        hashtagColor: Colors.green,
      );

      final specialText = builder.createSpecialText('unknown', textStyle: const TextStyle());
      expect(specialText, isNull);
    });

    test('returns null for empty flag', () {
      final builder = ComposerTextSpanBuilder(
        mentionColor: Colors.blue,
        linkColor: Colors.purple,
        hashtagColor: Colors.green,
      );

      final specialText = builder.createSpecialText('', textStyle: const TextStyle());
      expect(specialText, isNull);
    });
  });

  group('MentionText', () {
    test('applies correct styling to mentions', () {
      final mention = MentionText(textStyle: const TextStyle(fontSize: 16), color: Colors.blue);
      mention.appendContent('alice');

      final span = mention.finishText() as TextSpan;
      expect(span.style?.color, Colors.blue);
      expect(span.style?.fontWeight, FontWeight.w600);
    });
  });

  group('HashtagText', () {
    test('applies correct styling to hashtags', () {
      final hashtag = HashtagText(textStyle: const TextStyle(fontSize: 16), color: Colors.green);
      hashtag.appendContent('flutter');

      final span = hashtag.finishText() as TextSpan;
      expect(span.style?.color, Colors.green);
      expect(span.style?.fontWeight, FontWeight.w600);
    });
  });

  group('LinkText', () {
    test('applies correct styling to links with underline', () {
      final link = LinkText(textStyle: const TextStyle(fontSize: 16), color: Colors.purple);
      link.appendContent('s://example.com');

      final span = link.finishText() as TextSpan;
      expect(span.style?.color, Colors.purple);
      expect(span.style?.decoration, TextDecoration.underline);
    });
  });
}
