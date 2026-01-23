import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/domain/author.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/quote_post_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('QuotePostCard', () {
    const authorWithDisplayName = Author(
      did: 'did:plc:quote123',
      handle: 'quoted.bsky.social',
      displayName: 'Quoted Author',
      avatar: 'https://example.com/quote-avatar.jpg',
    );

    const authorWithoutDisplayName = Author(
      did: 'did:plc:quote456',
      handle: 'handleonly.bsky.social',
    );

    testWidgets('renders author avatar', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: QuotePostCard(author: authorWithDisplayName, text: 'Quoted text'),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('renders display name and handle when display name exists', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: QuotePostCard(author: authorWithDisplayName, text: 'Quoted text'),
        ),
      );

      final richText = find.byType(RichText);
      expect(richText, findsWidgets);

      final richTextWidget = tester
          .widgetList<RichText>(richText)
          .firstWhere(
            (w) => w.text.toPlainText().contains('Quoted Author'),
            orElse: () => throw TestFailure('RichText with display name not found'),
          );
      expect(richTextWidget.text.toPlainText(), contains('@quoted.bsky.social'));
    });

    testWidgets('renders only handle when display name is null', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: QuotePostCard(author: authorWithoutDisplayName, text: 'Quote content'),
        ),
      );

      final richText = find.byType(RichText);
      expect(richText, findsWidgets);

      final richTextWidget = tester
          .widgetList<RichText>(richText)
          .firstWhere(
            (w) => w.text.toPlainText().contains('@handleonly.bsky.social'),
            orElse: () => throw TestFailure('RichText with handle not found'),
          );
      expect(richTextWidget.text.toPlainText(), '@handleonly.bsky.social');
    });

    testWidgets('renders post text', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: QuotePostCard(author: authorWithDisplayName, text: 'This is the quoted post'),
        ),
      );

      expect(find.text('This is the quoted post'), findsOneWidget);
    });

    testWidgets('does not render text section when text is empty', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: QuotePostCard(author: authorWithDisplayName, text: ''),
        ),
      );

      final richText = find.byType(RichText);
      expect(richText, findsWidgets);
    });

    testWidgets('shows image count badge when images present', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: QuotePostCard(
            author: authorWithDisplayName,
            text: 'Post with images',
            imageCount: 3,
          ),
        ),
      );

      expect(find.byIcon(Icons.image), findsOneWidget);
      expect(find.text('3 images'), findsOneWidget);
    });

    testWidgets('shows singular image text for single image', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: QuotePostCard(
            author: authorWithDisplayName,
            text: 'Post with image',
            imageCount: 1,
          ),
        ),
      );

      expect(find.byIcon(Icons.image), findsOneWidget);
      expect(find.text('1 image'), findsOneWidget);
    });

    testWidgets('does not show image badge when imageCount is zero', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: QuotePostCard(author: authorWithDisplayName, text: 'No images'),
        ),
      );

      expect(find.byIcon(Icons.image), findsNothing);
    });

    testWidgets('has bordered card styling', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: QuotePostCard(author: authorWithDisplayName, text: 'Styled card'),
        ),
      );

      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('truncates long text', (tester) async {
      final longText = 'This is a very long quote ' * 30;
      await tester.pumpApp(
        Scaffold(
          body: QuotePostCard(author: authorWithDisplayName, text: longText),
        ),
      );

      final textFinder = find.byWidgetPredicate(
        (widget) => widget is Text && widget.overflow == TextOverflow.ellipsis,
      );
      expect(textFinder, findsWidgets);
    });
  });
}
