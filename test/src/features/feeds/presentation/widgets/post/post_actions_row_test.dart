import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_actions_row.dart';

void main() {
  group('PostActionsRow', () {
    testWidgets('renders icons', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PostActionsRow())));
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.byIcon(Icons.repeat), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    testWidgets('renders counts correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PostActionsRow(replyCount: 5, repostCount: 1500, likeCount: 2000000),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.text('1.5k'), findsOneWidget);
      expect(find.text('2.0M'), findsOneWidget);
    });

    testWidgets('hides counts when zero', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PostActionsRow())));
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    group('viewer interaction states', () {
      testWidgets('shows filled like icon when viewerLikeUri is present', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PostActionsRow(viewerLikeUri: 'at://did:plc:test/app.bsky.feed.like/123'),
            ),
          ),
        );

        expect(find.byIcon(Icons.favorite), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border), findsNothing);
      });

      testWidgets('shows outline like icon when not liked', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PostActionsRow())));
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsNothing);
      });

      testWidgets('shows colored repost icon when viewerRepostUri is present', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PostActionsRow(viewerRepostUri: 'at://did:plc:test/app.bsky.feed.repost/123'),
            ),
          ),
        );

        final iconFinder = find.byIcon(Icons.repeat);
        expect(iconFinder, findsOneWidget);

        final Icon icon = tester.widget(iconFinder);
        expect(icon.color, equals(Colors.green));
      });

      testWidgets('shows filled bookmark icon when bookmarked', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: PostActionsRow(viewerBookmarked: true))),
        );

        expect(find.byIcon(Icons.bookmark), findsOneWidget);
        expect(find.byIcon(Icons.bookmark_border), findsNothing);
      });

      testWidgets('shows outline bookmark icon when not bookmarked', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PostActionsRow())));
        expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
        expect(find.byIcon(Icons.bookmark), findsNothing);
      });
    });
  });
}
