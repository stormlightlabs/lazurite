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
            feedKey: 'home',
            newPosts: any(named: 'newPosts'),
            newProfiles: any(named: 'newProfiles'),
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
  });
}
