import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/profile/infrastructure/profile_repository.dart';
import 'package:lazurite/src/features/profile/presentation/widgets/media_tab.dart';

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
        body: MediaTab(
          items: items ?? [],
          hasMore: hasMore,
          isLoading: isLoading,
          onLoadMore: () {},
        ),
      ),
    );
  }

  group('MediaTab', () {
    testWidgets('shows empty message when no media posts', (tester) async {
      await tester.pumpWidget(createSubject(items: []));

      expect(find.text('No media posts yet'), findsOneWidget);
    });

    testWidgets('shows only posts with media', (tester) async {
      await tester.pumpWidget(
        createSubject(
          items: [
            createFeedItem(text: 'Post with image', hasImages: true),
            createFeedItem(text: 'Post with video', hasVideo: true),
            createFeedItem(text: 'Text only post'),
          ],
        ),
      );

      expect(find.text('Post with image'), findsOneWidget);
      expect(find.text('Post with video'), findsOneWidget);
      expect(find.text('Text only post'), findsNothing);
    });

    testWidgets('shows loading indicator when hasMore is true', (tester) async {
      await tester.pumpWidget(
        createSubject(items: [createFeedItem(text: 'Media post', hasImages: true)], hasMore: true),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('preserves scroll position with AutomaticKeepAlive', (tester) async {
      final items = List.generate(
        20,
        (i) => createFeedItem(uri: 'at://did:plc:test/post/$i', text: 'Post $i', hasImages: true),
      );

      await tester.pumpWidget(createSubject(items: items));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      expect(find.text('Post 5'), findsOneWidget);
    });
  });
}
