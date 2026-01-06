import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_content_repository.dart';
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

class MockXrpcClient extends Mock implements XrpcClient {}

class MockFeedContentDao extends Mock implements FeedContentDao {}

class MockLogger extends Mock implements Logger {}

void main() {
  late MockXrpcClient mockApi;
  late MockFeedContentDao mockDao;
  late MockLogger mockLogger;
  late FeedContentRepository repository;

  setUp(() {
    mockApi = MockXrpcClient();
    mockDao = MockFeedContentDao();
    mockLogger = MockLogger();
    repository = FeedContentRepository(mockApi, mockDao, mockLogger);

    when(() => mockLogger.info(any(), any())).thenReturn(null);
    when(() => mockLogger.debug(any(), any())).thenReturn(null);
    when(() => mockLogger.error(any(), any(), any())).thenReturn(null);
  });

  group('FeedContentRepository', () {
    test(
      'fetchAndCacheFeed fetches authenticated timeline when no feedUri provided and authenticated',
      () async {
        when(() => mockApi.isAuthenticated).thenReturn(true);
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'feed': [], 'cursor': 'next_cursor'});
        when(
          () => mockDao.insertFeedContentBatch(
            feedKey: any(named: 'feedKey'),
            newPosts: any(named: 'newPosts'),
            newProfiles: any(named: 'newProfiles'),
            newRelationships: any(named: 'newRelationships'),
            newItems: any(named: 'newItems'),
            newCursor: any(named: 'newCursor'),
          ),
        ).thenAnswer((_) async {});

        await repository.fetchAndCacheFeed();

        verify(
          () => mockApi.call('app.bsky.feed.getTimeline', params: any(named: 'params')),
        ).called(1);
        verify(
          () => mockDao.insertFeedContentBatch(
            feedKey: FeedContentRepository.kInternalHomeFeedKey,
            newPosts: any(named: 'newPosts'),
            newProfiles: any(named: 'newProfiles'),
            newRelationships: any(named: 'newRelationships'),
            newItems: any(named: 'newItems'),
            newCursor: 'next_cursor',
          ),
        ).called(1);
      },
    );

    test(
      'fetchAndCacheFeed fetches discover feed when no feedUri provided and unauthenticated',
      () async {
        when(() => mockApi.isAuthenticated).thenReturn(false);
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'feed': [], 'cursor': 'next_cursor'});
        when(
          () => mockDao.insertFeedContentBatch(
            feedKey: any(named: 'feedKey'),
            newPosts: any(named: 'newPosts'),
            newProfiles: any(named: 'newProfiles'),
            newRelationships: any(named: 'newRelationships'),
            newItems: any(named: 'newItems'),
            newCursor: any(named: 'newCursor'),
          ),
        ).thenAnswer((_) async {});

        await repository.fetchAndCacheFeed();

        verify(
          () => mockApi.call(
            'app.bsky.feed.getFeed',
            params: any(named: 'params', that: containsPair('feed', contains('whats-hot'))),
          ),
        ).called(1);
      },
    );

    test('fetchAndCacheFeed fetches specific feed when feedUri provided', () async {
      when(() => mockApi.isAuthenticated).thenReturn(true);
      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenAnswer((_) async => {'feed': [], 'cursor': 'next_cursor'});
      when(
        () => mockDao.insertFeedContentBatch(
          feedKey: any(named: 'feedKey'),
          newPosts: any(named: 'newPosts'),
          newProfiles: any(named: 'newProfiles'),
          newRelationships: any(named: 'newRelationships'),
          newItems: any(named: 'newItems'),
          newCursor: any(named: 'newCursor'),
        ),
      ).thenAnswer((_) async {});

      const feedUri = 'at://did:example:123/app.bsky.feed.generator/custom';
      await repository.fetchAndCacheFeed(feedUri: feedUri);

      verify(
        () => mockApi.call(
          'app.bsky.feed.getFeed',
          params: any(named: 'params', that: containsPair('feed', feedUri)),
        ),
      ).called(1);

      verify(
        () => mockDao.insertFeedContentBatch(
          feedKey: feedUri,
          newPosts: any(named: 'newPosts'),
          newProfiles: any(named: 'newProfiles'),
          newRelationships: any(named: 'newRelationships'),
          newItems: any(named: 'newItems'),
          newCursor: 'next_cursor',
        ),
      ).called(1);
    });

    test('fetchAndCacheFeed handles 400 bad request by logging error', () async {
      when(() => mockApi.isAuthenticated).thenReturn(true);
      when(
        () => mockApi.call(any(), params: any(named: 'params')),
      ).thenThrow(Exception('Bad Request'));

      expect(() => repository.fetchAndCacheFeed(), throwsException);

      verify(() => mockLogger.error(any(), any(), any())).called(1);
    });

    group('Feed key collision prevention', () {
      test('home feed uses internal namespaced key', () async {
        when(() => mockApi.isAuthenticated).thenReturn(true);
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'feed': [], 'cursor': null});
        when(
          () => mockDao.insertFeedContentBatch(
            feedKey: any(named: 'feedKey'),
            newPosts: any(named: 'newPosts'),
            newProfiles: any(named: 'newProfiles'),
            newRelationships: any(named: 'newRelationships'),
            newItems: any(named: 'newItems'),
            newCursor: any(named: 'newCursor'),
          ),
        ).thenAnswer((_) async {});

        await repository.fetchAndCacheFeed();

        verify(
          () => mockDao.insertFeedContentBatch(
            feedKey: FeedContentRepository.kInternalHomeFeedKey,
            newPosts: any(named: 'newPosts'),
            newProfiles: any(named: 'newProfiles'),
            newRelationships: any(named: 'newRelationships'),
            newItems: any(named: 'newItems'),
            newCursor: any(named: 'newCursor'),
          ),
        ).called(1);

        expect(FeedContentRepository.kInternalHomeFeedKey, startsWith('__internal:'));
      });

      test('rejects feed URI with reserved internal prefix', () async {
        when(() => mockApi.isAuthenticated).thenReturn(true);
        when(() => mockApi.call(any(), params: any(named: 'params'))).thenAnswer(
          (_) async => {
            'feed': [
              {
                'post': {
                  'uri': 'at://did:example:123/app.bsky.feed.post/abc',
                  'cid': 'cid123',
                  'author': {'did': 'did:example:123', 'handle': 'user.test'},
                  'record': {'text': 'test'},
                  'indexedAt': '2024-01-01T00:00:00Z',
                },
              },
            ],
            'cursor': null,
          },
        );

        expect(
          () => repository.fetchAndCacheFeed(feedUri: '__internal:malicious'),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('cannot start with reserved prefix'),
            ),
          ),
        );
      });

      test('allows valid AT URI feed keys', () async {
        when(() => mockApi.isAuthenticated).thenReturn(true);
        when(
          () => mockApi.call(any(), params: any(named: 'params')),
        ).thenAnswer((_) async => {'feed': [], 'cursor': null});
        when(
          () => mockDao.insertFeedContentBatch(
            feedKey: any(named: 'feedKey'),
            newPosts: any(named: 'newPosts'),
            newProfiles: any(named: 'newProfiles'),
            newRelationships: any(named: 'newRelationships'),
            newItems: any(named: 'newItems'),
            newCursor: any(named: 'newCursor'),
          ),
        ).thenAnswer((_) async {});

        const validUri = 'at://did:plc:abc123/app.bsky.feed.generator/test';
        await repository.fetchAndCacheFeed(feedUri: validUri);

        verify(
          () => mockDao.insertFeedContentBatch(
            feedKey: validUri,
            newPosts: any(named: 'newPosts'),
            newProfiles: any(named: 'newProfiles'),
            newRelationships: any(named: 'newRelationships'),
            newItems: any(named: 'newItems'),
            newCursor: any(named: 'newCursor'),
          ),
        ).called(1);
      });
    });

    group('sortKey uniqueness', () {
      test('generates unique sortKeys using microseconds and compound format', () async {
        when(() => mockApi.isAuthenticated).thenReturn(true);
        when(() => mockApi.call(any(), params: any(named: 'params'))).thenAnswer(
          (_) async => {
            'feed': [
              {
                'post': {
                  'uri': 'at://did:example:123/app.bsky.feed.post/post1',
                  'cid': 'cid1',
                  'author': {'did': 'did:example:123', 'handle': 'user.test'},
                  'record': {'text': 'post 1'},
                  'indexedAt': '2024-01-01T00:00:00Z',
                },
              },
              {
                'post': {
                  'uri': 'at://did:example:123/app.bsky.feed.post/post2',
                  'cid': 'cid2',
                  'author': {'did': 'did:example:123', 'handle': 'user.test'},
                  'record': {'text': 'post 2'},
                  'indexedAt': '2024-01-01T00:00:01Z',
                },
              },
              {
                'post': {
                  'uri': 'at://did:example:123/app.bsky.feed.post/post3',
                  'cid': 'cid3',
                  'author': {'did': 'did:example:123', 'handle': 'user.test'},
                  'record': {'text': 'post 3'},
                  'indexedAt': '2024-01-01T00:00:02Z',
                },
              },
            ],
            'cursor': null,
          },
        );

        List? capturedItems;
        when(
          () => mockDao.insertFeedContentBatch(
            feedKey: any(named: 'feedKey'),
            newPosts: any(named: 'newPosts'),
            newProfiles: any(named: 'newProfiles'),
            newRelationships: any(named: 'newRelationships'),
            newItems: any(named: 'newItems'),
            newCursor: any(named: 'newCursor'),
          ),
        ).thenAnswer((invocation) async {
          capturedItems = invocation.namedArguments[#newItems] as List;
        });

        await repository.fetchAndCacheFeed();

        expect(capturedItems, isNotNull);
        final sortKeys = capturedItems!
            .map((item) => (item.sortKey as dynamic).value as String)
            .toList();

        expect(sortKeys.length, 3);
        expect(sortKeys.toSet().length, 3, reason: 'All sortKeys should be unique');

        for (var i = 0; i < sortKeys.length; i++) {
          final parts = sortKeys[i].split('-');
          expect(parts.length, 3, reason: 'sortKey should have 3 parts');

          final timestamp = int.tryParse(parts[0]);
          expect(timestamp, isNotNull);
          expect(timestamp! > 0, isTrue);

          final index = int.tryParse(parts[1]);
          expect(index, equals(i));

          final hash = int.tryParse(parts[2]);
          expect(hash, isNotNull);
          expect(hash! >= 0, isTrue);
        }

        for (var i = 0; i < sortKeys.length - 1; i++) {
          final current = int.parse(sortKeys[i].split('-')[0]);
          final next = int.parse(sortKeys[i + 1].split('-')[0]);
          expect(current > next, isTrue, reason: 'sortKeys should be in descending order');
        }
      });

      test('sortKeys remain unique even with rapid consecutive fetches', () async {
        when(() => mockApi.isAuthenticated).thenReturn(true);
        when(() => mockApi.call(any(), params: any(named: 'params'))).thenAnswer(
          (_) async => {
            'feed': [
              {
                'post': {
                  'uri': 'at://did:example:123/app.bsky.feed.post/rapid1',
                  'cid': 'cid1',
                  'author': {'did': 'did:example:123', 'handle': 'user.test'},
                  'record': {'text': 'rapid test'},
                  'indexedAt': '2024-01-01T00:00:00Z',
                },
              },
            ],
            'cursor': null,
          },
        );

        final allCapturedItems = <List>[];
        when(
          () => mockDao.insertFeedContentBatch(
            feedKey: any(named: 'feedKey'),
            newPosts: any(named: 'newPosts'),
            newProfiles: any(named: 'newProfiles'),
            newRelationships: any(named: 'newRelationships'),
            newItems: any(named: 'newItems'),
            newCursor: any(named: 'newCursor'),
          ),
        ).thenAnswer((invocation) async {
          final items = invocation.namedArguments[#newItems] as List;
          allCapturedItems.add(items);
        });

        await repository.fetchAndCacheFeed();
        await repository.fetchAndCacheFeed();

        final allSortKeys = allCapturedItems
            .expand((items) => items)
            .map((item) => (item.sortKey as dynamic).value as String)
            .toList();

        expect(
          allSortKeys.toSet().length,
          equals(allSortKeys.length),
          reason: 'Rapid fetches should not create duplicate sortKeys',
        );
      });
    });
  });
}
