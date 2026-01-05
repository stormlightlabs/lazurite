import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/thread/infrastructure/thread_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

class MockXrpcClient extends Mock implements XrpcClient {}

class MockLogger extends Mock implements Logger {}

void main() {
  late MockXrpcClient mockApi;
  late AppDatabase db;
  late MockLogger mockLogger;
  late ThreadRepository repository;

  setUp(() {
    mockApi = MockXrpcClient();
    db = AppDatabase(NativeDatabase.memory());
    mockLogger = MockLogger();
    repository = ThreadRepository(mockApi, db.timelineDao, mockLogger);
  });

  tearDown(() async {
    await db.close();
  });

  group('ThreadRepository', () {
    test('getPostThread fetches from API and returns ThreadViewPost', () async {
      final mockResponse = {
        'thread': {
          r'$type': 'app.bsky.feed.defs#threadViewPost',
          'post': {
            'uri': 'at://did:1/app.bsky.feed.post/1',
            'cid': 'cid1',
            'author': {
              'did': 'did:1',
              'handle': 'alice',
              'displayName': 'Alice',
              'description': 'Bio',
              'avatar': 'avatar.jpg',
            },
            'record': {'text': 'Root post', 'createdAt': '2024-01-01T00:00:00Z'},
            'indexedAt': '2024-01-01T00:00:00Z',
            'likeCount': 0,
            'replyCount': 1,
            'repostCount': 0,
          },
          'replies': [
            {
              r'$type': 'app.bsky.feed.defs#threadViewPost',
              'post': {
                'uri': 'at://did:2/app.bsky.feed.post/2',
                'cid': 'cid2',
                'author': {'did': 'did:2', 'handle': 'bob'},
                'record': {'text': 'Reply', 'createdAt': '2024-01-01T00:01:00Z'},
                'indexedAt': '2024-01-01T00:01:00Z',
              },
            },
          ],
        },
      };

      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => mockResponse);

      final thread = await repository.getPostThread('at://did:1/app.bsky.feed.post/1');

      verify(
        () => mockApi.call(
          'app.bsky.feed.getPostThread',
          params: {'uri': 'at://did:1/app.bsky.feed.post/1'},
        ),
      ).called(1);

      expect(thread.post.uri, 'at://did:1/app.bsky.feed.post/1');
      expect(thread.replies, hasLength(1));
      expect(thread.replies.first.post.uri, 'at://did:2/app.bsky.feed.post/2');

      final cached = await db.timelineDao
          .watchTimeline('thread:at://did:1/app.bsky.feed.post/1')
          .first;
      expect(cached, hasLength(2));
      expect(
        cached.map((item) => item.post.uri),
        containsAll(['at://did:1/app.bsky.feed.post/1', 'at://did:2/app.bsky.feed.post/2']),
      );
    });

    test('handles blocked and unavailable thread entries', () async {
      final mockResponse = {
        'thread': {
          r'$type': 'app.bsky.feed.defs#threadViewPost',
          'post': {
            'uri': 'at://did:1/app.bsky.feed.post/1',
            'cid': 'cid1',
            'author': {'did': 'did:1', 'handle': 'alice', 'displayName': 'Alice'},
            'record': {'text': 'Root post', 'createdAt': '2024-01-01T00:00:00Z'},
            'indexedAt': '2024-01-01T00:00:00Z',
          },
          'replies': [
            {r'$type': 'app.bsky.feed.defs#blockedPost', 'uri': 'at://did:3/app.bsky.feed.post/3'},
            {
              r'$type': 'app.bsky.feed.defs#notFoundPost',
              'uri': 'at://did:4/app.bsky.feed.post/4',
            },
          ],
        },
      };

      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => mockResponse);

      final thread = await repository.getPostThread('at://did:1/app.bsky.feed.post/1');
      expect(thread.replies, hasLength(2));
      expect(thread.replies.first.post.placeholderReason, 'Post blocked');
      expect(thread.replies.last.post.placeholderReason, 'Post not found');
    });
  });
}
