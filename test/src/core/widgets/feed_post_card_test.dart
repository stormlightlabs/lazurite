import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/widgets/feed_post_card.dart';

void main() {
  Widget createSubject({
    String uri = 'at://did:plc:test/app.bsky.feed.post/123',
    String authorDid = 'did:plc:test',
    String authorHandle = 'testuser',
    String? authorDisplayName = 'Test User',
    String? authorAvatar,
    String text = 'Hello, world!',
    DateTime? indexedAt,
    int replyCount = 0,
    int repostCount = 0,
    int likeCount = 0,
    VoidCallback? onTap,
    VoidCallback? onAvatarTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: FeedPostCard(
          uri: uri,
          authorDid: authorDid,
          authorHandle: authorHandle,
          authorDisplayName: authorDisplayName,
          authorAvatar: authorAvatar,
          text: text,
          indexedAt: indexedAt,
          replyCount: replyCount,
          repostCount: repostCount,
          likeCount: likeCount,
          onTap: onTap,
          onAvatarTap: onAvatarTap,
        ),
      ),
    );
  }

  group('FeedPostCard', () {
    testWidgets('renders author display name', (tester) async {
      await tester.pumpWidget(createSubject(authorDisplayName: 'Test User'));
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('renders author handle when no display name', (tester) async {
      await tester.pumpWidget(createSubject(authorDisplayName: null, authorHandle: 'testhandle'));
      expect(find.text('testhandle'), findsOneWidget);
      expect(find.text('@testhandle'), findsOneWidget);
    });

    testWidgets('renders post text', (tester) async {
      await tester.pumpWidget(createSubject(text: 'This is a test post'));
      expect(find.text('This is a test post'), findsOneWidget);
    });

    testWidgets('renders action counts when non-zero', (tester) async {
      await tester.pumpWidget(createSubject(replyCount: 5, repostCount: 10, likeCount: 42));
      expect(find.text('5'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('does not render counts when zero', (tester) async {
      await tester.pumpWidget(createSubject(replyCount: 0, repostCount: 0, likeCount: 0));
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.byIcon(Icons.repeat), findsOneWidget);
      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(createSubject(onTap: () => tapped = true));

      await tester.tap(find.text('Hello, world!'));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('calls onAvatarTap when avatar tapped', (tester) async {
      var avatarTapped = false;
      await tester.pumpWidget(createSubject(onAvatarTap: () => avatarTapped = true));

      final inkWells = find.byType(InkWell);
      await tester.tap(inkWells.at(1));
      await tester.pump();

      expect(avatarTapped, true);
    });

    testWidgets('renders relative time', (tester) async {
      await tester.pumpWidget(
        createSubject(indexedAt: DateTime.now().subtract(const Duration(hours: 2))),
      );

      expect(find.text('• 2h'), findsOneWidget);
    });

    testWidgets('formats large counts with k suffix', (tester) async {
      await tester.pumpWidget(createSubject(likeCount: 1500));
      expect(find.text('1.5k'), findsOneWidget);
    });
  });
}
