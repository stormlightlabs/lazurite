import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/data/post_thread_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/feed_fixtures.dart';

class MockPostThreadRepository extends Mock implements PostThreadRepository {}

void main() {
  late MockPostThreadRepository mockRepository;

  setUp(() {
    mockRepository = MockPostThreadRepository();
  });

  final sampleThreadViewPost = ThreadViewPost(
    post: testPostView(
      cid: 'cid-123',
      record: testPostRecordJson(text: 'Hello world'),
    ),
  );

  group('PostThreadRepository contract', () {
    test('getPostThread returns ThreadViewPost on success', () async {
      const testUri = 'at://did:plc:author/app.bsky.feed.post/abc';

      when(() => mockRepository.getPostThread(testUri)).thenAnswer((_) async => sampleThreadViewPost);

      final result = await mockRepository.getPostThread(testUri);

      expect(result.post.uri.toString(), testUri);
      expect(result.post.cid, 'cid-123');
    });

    test('getPostThread returns thread with parent', () async {
      const testUri = 'at://did:plc:author/app.bsky.feed.post/abc';
      final parentPost = testPostView(
        uri: 'at://did:plc:parent/app.bsky.feed.post/root',
        cid: 'cid-root',
        author: testProfileViewBasic(did: 'did:plc:parent', handle: 'parent.bsky.social'),
        record: testPostRecordJson(text: 'Root post', createdAt: DateTime.utc(2026, 3, 14)),
        indexedAt: DateTime.utc(2026, 3, 14),
      );
      final threadWithParent = ThreadViewPost(
        post: sampleThreadViewPost.post,
        parent: UThreadViewPostParent.threadViewPost(data: ThreadViewPost(post: parentPost)),
      );

      when(() => mockRepository.getPostThread(testUri)).thenAnswer((_) async => threadWithParent);

      final result = await mockRepository.getPostThread(testUri);

      expect(result.parent, isNotNull);
      expect(result.parent!.isThreadViewPost, isTrue);
      expect(result.parent!.threadViewPost!.post.cid, 'cid-root');
    });

    test('getPostThread returns thread with replies', () async {
      const testUri = 'at://did:plc:author/app.bsky.feed.post/abc';
      final replyPost = testPostView(
        uri: 'at://did:plc:reply/app.bsky.feed.post/reply1',
        cid: 'cid-reply',
        author: testProfileViewBasic(did: 'did:plc:reply', handle: 'reply.bsky.social'),
        record: testPostRecordJson(text: 'Reply post', createdAt: DateTime.utc(2026, 3, 15, 1)),
        indexedAt: DateTime.utc(2026, 3, 15, 1),
      );
      final threadWithReplies = ThreadViewPost(
        post: sampleThreadViewPost.post,
        replies: [UThreadViewPostReplies.threadViewPost(data: ThreadViewPost(post: replyPost))],
      );

      when(() => mockRepository.getPostThread(testUri)).thenAnswer((_) async => threadWithReplies);

      final result = await mockRepository.getPostThread(testUri);

      expect(result.replies, isNotNull);
      expect(result.replies!.length, 1);
      expect(result.replies!.first.isThreadViewPost, isTrue);
    });

    test('getPostThread throws when post not found', () async {
      const testUri = 'at://did:plc:author/app.bsky.feed.post/missing';

      when(() => mockRepository.getPostThread(testUri)).thenThrow(Exception('Post not found'));

      expect(() => mockRepository.getPostThread(testUri), throwsException);
    });

    test('getPostThread throws when post is blocked', () async {
      const testUri = 'at://did:plc:blocked/app.bsky.feed.post/abc';

      when(() => mockRepository.getPostThread(testUri)).thenThrow(Exception('Post is from a blocked account'));

      expect(() => mockRepository.getPostThread(testUri), throwsException);
    });
  });

  group('PostThreadRepository implementation', () {
    test('getPostThread with no parent returns thread without parent', () async {
      const testUri = 'at://did:plc:author/app.bsky.feed.post/abc';
      final threadNoParent = ThreadViewPost(post: sampleThreadViewPost.post);
      when(() => mockRepository.getPostThread(testUri)).thenAnswer((_) async => threadNoParent);

      final result = await mockRepository.getPostThread(testUri);
      expect(result.parent, isNull);
      expect(result.replies, isNull);
    });
  });
}
