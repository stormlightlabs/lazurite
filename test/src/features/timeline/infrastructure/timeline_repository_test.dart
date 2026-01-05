import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/timeline/infrastructure/timeline_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

class MockXrpcClient extends Mock implements XrpcClient {}

class MockLogger extends Mock implements Logger {}

void main() {
  late MockXrpcClient mockApi;
  late AppDatabase db;
  late MockLogger mockLogger;
  late TimelineRepository repository;

  setUp(() {
    mockApi = MockXrpcClient();
    db = AppDatabase(NativeDatabase.memory());
    mockLogger = MockLogger();
    repository = TimelineRepository(mockApi, db.timelineDao, mockLogger);

    when(() => mockApi.isAuthenticated).thenReturn(true);
  });

  tearDown(() async {
    await db.close();
  });

  group('TimelineRepository', () {
    test('fetchAndCacheTimeline fetches from API and inserts into DAO', () async {
      final mockResponse = {
        'cursor': 'next_cursor',
        'feed': [
          {
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
              'record': {'text': 'Hello world', 'createdAt': '2024-01-01T00:00:00Z'},
              'indexedAt': '2024-01-01T00:00:00Z',
              'likeCount': 0,
              'replyCount': 0,
              'repostCount': 0,
            },
            'reason': null,
          },
        ],
      };

      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => mockResponse);

      await repository.fetchAndCacheTimeline();

      verify(
        () => mockApi.call('app.bsky.feed.getTimeline', params: any(named: 'params')),
      ).called(1);

      final timeline = await db.timelineDao.watchTimeline('home').first;
      expect(timeline, hasLength(1));
      expect(timeline.first.post.uri, 'at://did:1/app.bsky.feed.post/1');
      expect(timeline.first.author.handle, 'alice');

      final cursor = await db.timelineDao.getCursor('home');
      expect(cursor, 'next_cursor');
    });

    test('watchTimeline returns stream from DAO', () async {
      await db.timelineDao.insertTimelineBatch(
        feedKey: 'home',
        newPosts: [
          PostsCompanion.insert(
            uri: 'at://did:1/app.bsky.feed.post/1',
            cid: 'cid1',
            authorDid: 'did:1',
            record: '{}',
          ),
        ],
        newProfiles: [ProfilesCompanion.insert(did: 'did:1', handle: 'alice')],
        newItems: [
          TimelineItemsCompanion.insert(
            feedKey: 'home',
            postUri: 'at://did:1/app.bsky.feed.post/1',
            sortKey: '999',
          ),
        ],
      );

      final stream = repository.watchTimeline();
      expect(stream, emits(hasLength(1)));
    });

    test('fetchAndCacheTimeline passes cursor to API', () async {
      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => {'feed': [], 'cursor': null});

      await repository.fetchAndCacheTimeline(cursor: 'foo');

      verify(
        () => mockApi.call('app.bsky.feed.getTimeline', params: {'limit': 50, 'cursor': 'foo'}),
      ).called(1);
    });

    test('fetchAndCacheTimeline handles API error logs error and rethrows', () async {
      final exception = Exception('Network error');
      when(() => mockApi.call(any(), params: any(named: 'params'))).thenThrow(exception);

      expect(repository.fetchAndCacheTimeline(), throwsException);

      verify(() => mockLogger.error(any(), exception, any())).called(1);
    });

    test('fetchAndCacheTimeline handles duplicate posts gracefully', () async {
      final mockItem = {
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
          'record': {'text': 'Hello world', 'createdAt': '2024-01-01T00:00:00Z'},
          'indexedAt': '2024-01-01T00:00:00Z',
          'likeCount': 0,
          'replyCount': 0,
          'repostCount': 0,
        },
        'reason': null,
      };

      final mockResponse = {
        'cursor': 'next_cursor',
        'feed': [mockItem, mockItem],
      };

      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => mockResponse);

      await db.timelineDao.insertTimelineBatch(
        feedKey: 'home',
        newPosts: [
          PostsCompanion.insert(
            uri: 'at://did:1/app.bsky.feed.post/1',
            cid: 'cid1',
            authorDid: 'did:1',
            record: '{}',
          ),
        ],
        newProfiles: [ProfilesCompanion.insert(did: 'did:1', handle: 'alice')],
        newItems: [],
      );

      await repository.fetchAndCacheTimeline();

      final timeline = await db.timelineDao.watchTimeline('home').first;
      expect(timeline, hasLength(1));
    });
  });
}
