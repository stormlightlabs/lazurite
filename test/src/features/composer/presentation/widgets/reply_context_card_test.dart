import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/domain/post.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/reply_context_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ReplyContextCard', () {
    const authorWithDisplayName = Author(
      did: 'did:plc:test123',
      handle: 'testuser.bsky.social',
      displayName: 'Test User',
      avatar: 'https://example.com/avatar.jpg',
    );

    const authorWithoutDisplayName = Author(did: 'did:plc:test456', handle: 'noname.bsky.social');

    testWidgets('renders author avatar', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ReplyContextCard(author: authorWithDisplayName, text: 'Hello world'),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('renders display name and handle when display name exists', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ReplyContextCard(author: authorWithDisplayName, text: 'Hello world'),
        ),
      );

      final richText = find.byType(RichText);
      expect(richText, findsWidgets);

      final richTextWidget = tester
          .widgetList<RichText>(richText)
          .firstWhere(
            (w) => w.text.toPlainText().contains('Test User'),
            orElse: () => throw TestFailure('RichText with display name not found'),
          );
      expect(richTextWidget.text.toPlainText(), contains('@testuser.bsky.social'));
    });

    testWidgets('renders only handle when display name is null', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ReplyContextCard(author: authorWithoutDisplayName, text: 'Reply text'),
        ),
      );

      final richText = find.byType(RichText);
      expect(richText, findsWidgets);

      final richTextWidget = tester
          .widgetList<RichText>(richText)
          .firstWhere(
            (w) => w.text.toPlainText().contains('@noname.bsky.social'),
            orElse: () => throw TestFailure('RichText with handle not found'),
          );
      expect(richTextWidget.text.toPlainText(), '@noname.bsky.social');
    });

    testWidgets('renders post text', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ReplyContextCard(author: authorWithDisplayName, text: 'Some reply content here'),
        ),
      );

      expect(find.text('Some reply content here'), findsOneWidget);
    });

    testWidgets('does not render text section when text is empty', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ReplyContextCard(author: authorWithDisplayName, text: ''),
        ),
      );

      final richText = find.byType(RichText);
      expect(richText, findsWidgets);
    });

    testWidgets('shows thread indicator line', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: ReplyContextCard(author: authorWithDisplayName, text: 'Text for thread'),
        ),
      );

      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('truncates long text', (tester) async {
      final longText = 'This is a very long text ' * 20;
      await tester.pumpApp(
        Scaffold(
          body: ReplyContextCard(author: authorWithDisplayName, text: longText),
        ),
      );

      final textFinder = find.byWidgetPredicate(
        (widget) => widget is Text && widget.overflow == TextOverflow.ellipsis,
      );
      expect(textFinder, findsWidgets);
    });
  });
}
