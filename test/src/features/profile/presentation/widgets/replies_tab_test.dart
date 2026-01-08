import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/replies_tab.dart';

void main() {
  FeedItem createFeedItem({
    String uri = 'at://did:plc:test/app.bsky.feed.post/123',
    String cid = 'bafytest123',
    String authorDid = 'did:plc:test',
    String authorHandle = 'testuser',
    String? authorDisplayName = 'Test User',
    String? authorAvatar,
    String text = 'Hello, world!',
    DateTime? indexedAt,
    int replyCount = 0,
    int repostCount = 0,
    int likeCount = 0,
    bool isReply = false,
    bool hasImages = false,
    bool hasVideo = false,
  }) {
    return FeedItem(
      uri: uri,
      cid: cid,
      authorDid: authorDid,
      authorHandle: authorHandle,
      authorDisplayName: authorDisplayName,
      authorAvatar: authorAvatar,
      text: text,
      indexedAt: indexedAt,
      replyCount: replyCount,
      repostCount: repostCount,
      likeCount: likeCount,
      isReply: isReply,
      hasImages: hasImages,
      hasVideo: hasVideo,
    );
  }

  Widget createSubject({List<FeedItem>? items, bool hasMore = false, bool isLoading = false}) {
    return MaterialApp(
      home: Scaffold(
        body: RepliesTab(
          items: items ?? [],
          hasMore: hasMore,
          isLoading: isLoading,
          onLoadMore: () {},
        ),
      ),
    );
  }

  group('RepliesTab', () {
    testWidgets('shows empty message when no replies', (tester) async {
      await tester.pumpWidget(createSubject(items: []));

      expect(find.text('No replies yet'), findsOneWidget);
    });

    testWidgets('shows replies with isReply flag', (tester) async {
      await tester.pumpWidget(
        createSubject(
          items: [
            createFeedItem(text: 'This is a reply', isReply: true),
            createFeedItem(text: 'Regular post not a reply', isReply: false),
          ],
        ),
      );

      expect(find.text('This is a reply'), findsOneWidget);
      expect(find.text('Regular post not a reply'), findsNothing);
    });

    testWidgets('shows loading indicator when hasMore is true', (tester) async {
      await tester.pumpWidget(
        createSubject(items: [createFeedItem(text: 'Reply Post', isReply: true)], hasMore: true),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays author info in reply cards', (tester) async {
      await tester.pumpWidget(
        createSubject(
          items: [
            createFeedItem(
              text: 'Reply text',
              authorDisplayName: 'Author Name',
              authorHandle: 'authorhandle',
              isReply: true,
            ),
          ],
        ),
      );

      expect(find.text('Author Name'), findsOneWidget);
      expect(find.text('@authorhandle'), findsOneWidget);
    });
  });
}
