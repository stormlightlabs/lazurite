import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/settings/application/label_filter_provider.dart';
import 'package:lazurite/src/features/settings/application/settings_providers.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:lazurite/src/features/thread/application/thread_providers.dart';
import 'package:lazurite/src/features/thread/infrastructure/thread_repository.dart';
import 'package:lazurite/src/features/thread/presentation/thread_screen.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/blocked_post_card.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/not_found_post_card.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/threadgate_indicator.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockThreadRepository mockRepo;

  setUp(() {
    mockRepo = MockThreadRepository();
  });

  Widget createSubject(String postUri) {
    return ProviderScope(
      overrides: [
        threadRepositoryProvider.overrideWithValue(mockRepo),
        threadCacheProvider(postUri).overrideWith((ref) => Stream.value([])),
        labelFilterServiceProvider.overrideWith((ref) => null),
        threadViewPrefProvider.overrideWith((ref) => Stream.value(ThreadViewPref.defaultPref)),
      ],
      child: MaterialApp(home: ThreadScreen(postUri: postUri)),
    );
  }

  group('ThreadScreen', () {
    const testUri = 'at://did:test/app.bsky.feed.post/1';

    testWidgets('renders thread with focal post highlighted', (tester) async {
      when(() => mockRepo.getPostThread(testUri)).thenAnswer(
        (_) async => ThreadViewPost(
          post: ThreadPost(
            uri: testUri,
            cid: 'cid1',
            author: ThreadAuthor(did: 'did:1', handle: 'alice', displayName: 'Alice'),
            record: {'text': 'Focal post', 'createdAt': '2024-01-01T00:00:00Z'},
            indexedAt: DateTime.parse('2024-01-01T00:00:00Z'),
          ),
        ),
      );

      await tester.pumpWidget(createSubject(testUri));
      await tester.pumpAndSettle();

      expect(find.text('Focal post'), findsOneWidget);
      final container = tester
          .widgetList<Container>(find.byType(Container))
          .where(
            (c) =>
                c.decoration is BoxDecoration && (c.decoration! as BoxDecoration).border != null,
          );
      expect(container.isNotEmpty, true);
    });

    testWidgets('renders parent chain in correct order', (tester) async {
      final parentPost = ThreadViewPost(
        post: ThreadPost(
          uri: 'at://did:1/app.bsky.feed.post/parent',
          cid: 'parentcid',
          author: ThreadAuthor(did: 'did:1', handle: 'parent_user', displayName: 'Parent'),
          record: {'text': 'Parent post', 'createdAt': '2024-01-01T00:00:00Z'},
          indexedAt: DateTime.parse('2024-01-01T00:00:00Z'),
        ),
      );

      when(() => mockRepo.getPostThread(testUri)).thenAnswer(
        (_) async => ThreadViewPost(
          post: ThreadPost(
            uri: testUri,
            cid: 'cid1',
            author: ThreadAuthor(did: 'did:2', handle: 'child_user', displayName: 'Child'),
            record: {'text': 'Child post', 'createdAt': '2024-01-01T00:01:00Z'},
            indexedAt: DateTime.parse('2024-01-01T00:01:00Z'),
          ),
          parent: parentPost,
        ),
      );

      await tester.pumpWidget(createSubject(testUri));
      await tester.pumpAndSettle();

      expect(find.text('Parent post'), findsOneWidget);
      expect(find.text('Child post'), findsOneWidget);

      final parentPosition = tester.getTopLeft(find.text('Parent post'));
      final childPosition = tester.getTopLeft(find.text('Child post'));
      expect(parentPosition.dy, lessThan(childPosition.dy));
    });

    testWidgets('renders replies correctly', (tester) async {
      when(() => mockRepo.getPostThread(testUri)).thenAnswer(
        (_) async => ThreadViewPost(
          post: ThreadPost(
            uri: testUri,
            cid: 'cid1',
            author: ThreadAuthor(did: 'did:1', handle: 'alice', displayName: 'Alice'),
            record: {'text': 'Root post', 'createdAt': '2024-01-01T00:00:00Z'},
            indexedAt: DateTime.parse('2024-01-01T00:00:00Z'),
          ),
          replies: [
            ThreadViewPost(
              post: ThreadPost(
                uri: 'at://did:2/app.bsky.feed.post/reply1',
                cid: 'replycid',
                author: ThreadAuthor(did: 'did:2', handle: 'bob', displayName: 'Bob'),
                record: {'text': 'Reply to root', 'createdAt': '2024-01-01T00:01:00Z'},
                indexedAt: DateTime.parse('2024-01-01T00:01:00Z'),
              ),
            ),
          ],
        ),
      );

      await tester.pumpWidget(createSubject(testUri));
      await tester.pumpAndSettle();

      expect(find.text('Root post'), findsOneWidget);
      expect(find.text('Reply to root'), findsOneWidget);
    });

    testWidgets('displays BlockedPostCard for blocked posts', (tester) async {
      when(() => mockRepo.getPostThread(testUri)).thenAnswer(
        (_) async => ThreadViewPost(
          post: ThreadPost(
            uri: testUri,
            cid: 'cid1',
            author: ThreadAuthor(did: 'did:1', handle: 'alice'),
            record: {'text': 'Root'},
            indexedAt: DateTime.now(),
          ),
          replies: [
            ThreadViewPost(
              post: ThreadPost.placeholder(
                uri: 'at://blocked/post',
                reason: 'Post blocked',
                isBlocked: true,
              ),
              isBlocked: true,
            ),
          ],
        ),
      );

      await tester.pumpWidget(createSubject(testUri));
      await tester.pumpAndSettle();

      expect(find.byType(BlockedPostCard), findsOneWidget);
      expect(find.text("This post is from an account you've blocked"), findsOneWidget);
    });

    testWidgets('displays NotFoundPostCard for deleted posts', (tester) async {
      when(() => mockRepo.getPostThread(testUri)).thenAnswer(
        (_) async => ThreadViewPost(
          post: ThreadPost(
            uri: testUri,
            cid: 'cid1',
            author: ThreadAuthor(did: 'did:1', handle: 'alice'),
            record: {'text': 'Root'},
            indexedAt: DateTime.now(),
          ),
          replies: [
            ThreadViewPost(
              post: ThreadPost.placeholder(
                uri: 'at://notfound/post',
                reason: 'Post not found',
                isNotFound: true,
              ),
              isNotFound: true,
            ),
          ],
        ),
      );

      await tester.pumpWidget(createSubject(testUri));
      await tester.pumpAndSettle();

      expect(find.byType(NotFoundPostCard), findsOneWidget);
      expect(find.text('This post has been deleted'), findsOneWidget);
    });

    testWidgets('displays ThreadgateIndicator when threadgate is present', (tester) async {
      when(() => mockRepo.getPostThread(testUri)).thenAnswer(
        (_) async => ThreadViewPost(
          post: ThreadPost(
            uri: testUri,
            cid: 'cid1',
            author: ThreadAuthor(did: 'did:1', handle: 'alice'),
            record: {'text': 'Restricted replies post'},
            indexedAt: DateTime.now(),
          ),
          threadgate: Threadgate(
            uri: 'at://did:1/app.bsky.feed.threadgate/1',
            record: ThreadgateRecord(
              post: testUri,
              allow: [
                {r'$type': 'app.bsky.feed.threadgate#mentionRule'},
              ],
            ),
          ),
        ),
      );

      await tester.pumpWidget(createSubject(testUri));
      await tester.pumpAndSettle();

      expect(find.byType(ThreadgateIndicator), findsOneWidget);
      expect(find.text('Replies limited to mentioned users'), findsOneWidget);
    });

    testWidgets('toggles between tree and flattened view', (tester) async {
      when(() => mockRepo.getPostThread(testUri)).thenAnswer(
        (_) async => ThreadViewPost(
          post: ThreadPost(
            uri: testUri,
            cid: 'cid1',
            author: ThreadAuthor(did: 'did:1', handle: 'alice'),
            record: {'text': 'Root post'},
            indexedAt: DateTime.now(),
          ),
        ),
      );

      await tester.pumpWidget(createSubject(testUri));
      await tester.pumpAndSettle();

      final toggleButton = find.byIcon(Icons.list);
      expect(toggleButton, findsOneWidget);

      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.account_tree), findsOneWidget);
    });
  });
}
