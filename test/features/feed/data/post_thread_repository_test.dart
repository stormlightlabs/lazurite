import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/data/post_thread_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockPostThreadRepository extends Mock implements PostThreadRepository {}

void main() {
  late MockPostThreadRepository mockRepository;

  setUp(() {
    mockRepository = MockPostThreadRepository();
  });

  final sampleThreadViewPost = ThreadViewPost(
    post: PostView(
      uri: const AtUri('at://did:plc:author/app.bsky.feed.post/abc'),
      cid: 'cid-123',
      author: const ProfileViewBasic(did: 'did:plc:author', handle: 'author.bsky.social'),
      record: {
        r'$type': 'app.bsky.feed.post',
        'text': 'Hello world',
        'createdAt': DateTime.utc(2026, 3, 15).toIso8601String(),
      },
      indexedAt: DateTime.utc(2026, 3, 15),
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
      final parentPost = PostView(
        uri: const AtUri('at://did:plc:parent/app.bsky.feed.post/root'),
        cid: 'cid-root',
        author: const ProfileViewBasic(did: 'did:plc:parent', handle: 'parent.bsky.social'),
        record: {
          r'$type': 'app.bsky.feed.post',
          'text': 'Root post',
          'createdAt': DateTime.utc(2026, 3, 14).toIso8601String(),
        },
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
      final replyPost = PostView(
        uri: const AtUri('at://did:plc:reply/app.bsky.feed.post/reply1'),
        cid: 'cid-reply',
        author: const ProfileViewBasic(did: 'did:plc:reply', handle: 'reply.bsky.social'),
        record: {
          r'$type': 'app.bsky.feed.post',
          'text': 'Reply post',
          'createdAt': DateTime.utc(2026, 3, 15, 1).toIso8601String(),
        },
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
