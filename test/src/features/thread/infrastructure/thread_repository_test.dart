import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/thread/infrastructure/thread_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

class MockXrpcClient extends Mock implements XrpcClient {}

void main() {
  late MockXrpcClient mockApi;
  late AppDatabase db;
  late ThreadRepository repository;

  setUp(() {
    mockApi = MockXrpcClient();
    db = AppDatabase(NativeDatabase.memory());
    repository = ThreadRepository(mockApi, db.timelineDao);
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

      expect(thread.post['uri'], 'at://did:1/app.bsky.feed.post/1');
      expect(thread.replies, hasLength(1));
      expect(thread.replies.first.post['uri'], 'at://did:2/app.bsky.feed.post/2');

      // TODO: Check cache side-effect
      // TODO: use a separate DAO query to verify insertion if we want.
    });
  });
}
