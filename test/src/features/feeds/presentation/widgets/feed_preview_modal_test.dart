import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_providers.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_content_repository.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_repository.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/feed_preview_modal.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart'; // For Post, Profile classes
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

class MockFeedContentRepository extends Mock implements FeedContentRepository {}

void main() {
  late MockFeedRepository mockFeedRepository;
  late MockFeedContentRepository mockFeedContentRepository;

  setUp(() {
    mockFeedRepository = MockFeedRepository();
    mockFeedContentRepository = MockFeedContentRepository();
  });

  testWidgets('FeedPreviewModal displays info and posts', (tester) async {
    const feedUri = 'at://did:1/feed/test';
    const displayName = 'Test Feed';
    const description = 'A test feed description';

    final posts = [
      FeedPost(
        post: Post(
          uri: 'at://did:2/app.bsky.feed.post/1',
          cid: 'cid1',
          authorDid: 'did:2',
          record: '{}',
          indexedAt: DateTime.now(),
          replyCount: 0,
          repostCount: 0,
          likeCount: 0,
        ),
        author: const Profile(did: 'did:2', handle: 'handle2', displayName: 'Author 2'),
        reason: null,
      ),
    ];

    when(
      () => mockFeedContentRepository.watchFeedContent(feedKey: any(named: 'feedKey')),
    ).thenAnswer((_) => Stream.value(posts));
    when(
      () => mockFeedContentRepository.fetchAndCacheFeed(feedUri: feedUri),
    ).thenAnswer((_) async {});
    when(() => mockFeedRepository.watchAllFeeds()).thenAnswer((_) => Stream.value([]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedRepositoryProvider.overrideWithValue(mockFeedRepository),
          feedContentRepositoryProvider.overrideWithValue(mockFeedContentRepository),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: FeedPreviewModal(
              feedUri: feedUri,
              displayName: displayName,
              description: description,
              creatorHandle: 'creator',
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(displayName), findsOneWidget);
    expect(find.text(description), findsOneWidget);
    expect(find.text('@creator'), findsOneWidget);
    expect(find.text('Author 2'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('Save button in FeedPreviewModal calls repository', (tester) async {
    const feedUri = 'at://did:1/feed/test';

    when(
      () => mockFeedContentRepository.watchFeedContent(feedKey: any(named: 'feedKey')),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => mockFeedContentRepository.fetchAndCacheFeed(feedUri: feedUri),
    ).thenAnswer((_) async {});
    when(() => mockFeedRepository.watchAllFeeds()).thenAnswer((_) => Stream.value([]));
    when(
      () => mockFeedRepository.saveFeed(any(), pin: any(named: 'pin')),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedRepositoryProvider.overrideWithValue(mockFeedRepository),
          feedContentRepositoryProvider.overrideWithValue(mockFeedContentRepository),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: FeedPreviewModal(feedUri: feedUri, displayName: 'Test'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Save'));
    await tester.pump();

    verify(() => mockFeedRepository.saveFeed(feedUri, pin: false)).called(1);
  });
}
