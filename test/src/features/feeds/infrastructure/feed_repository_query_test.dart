import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

class MockXrpcClient extends Mock implements XrpcClient {}

class MockLogger extends Mock implements Logger {}

void main() {
  late MockXrpcClient mockApi;
  late AppDatabase db;
  late MockLogger mockLogger;
  late FeedRepository repository;

  setUp(() {
    mockApi = MockXrpcClient();
    db = AppDatabase(NativeDatabase.memory());
    mockLogger = MockLogger();
    repository = FeedRepository(
      mockApi,
      db.savedFeedsDao,
      db.preferenceSyncQueueDao,
      db.profileDao,
      mockLogger,
    );

    when(() => mockApi.isAuthenticated).thenReturn(true);
  });

  tearDown(() async {
    await db.close();
  });

  group('discoverFeeds', () {
    test('fetches trending feeds from API', () async {
      final mockResponse = {
        'feeds': [
          {
            'uri': 'at://did:plc:abc/app.bsky.feed.generator/trending1',
            'displayName': 'Trending Feed 1',
          },
          {
            'uri': 'at://did:plc:def/app.bsky.feed.generator/trending2',
            'displayName': 'Trending Feed 2',
          },
        ],
      };

      when(
        () => mockApi.call('app.bsky.unspecced.getPopularFeedGenerators', params: {'limit': 50}),
      ).thenAnswer((_) async => mockResponse);

      final feeds = await repository.discoverFeeds();

      expect(feeds, hasLength(2));
      expect(feeds[0]['displayName'], 'Trending Feed 1');
      expect(feeds[1]['displayName'], 'Trending Feed 2');
    });

    test('respects custom limit', () async {
      final mockResponse = {'feeds': []};

      when(
        () => mockApi.call('app.bsky.unspecced.getPopularFeedGenerators', params: {'limit': 10}),
      ).thenAnswer((_) async => mockResponse);

      await repository.discoverFeeds(limit: 10);

      verify(
        () => mockApi.call('app.bsky.unspecced.getPopularFeedGenerators', params: {'limit': 10}),
      ).called(1);
    });

    test('fetches search results when query is provided', () async {
      final mockResponse = {'feeds': []};

      when(
        () => mockApi.call(
          'app.bsky.unspecced.getPopularFeedGenerators',
          params: {'limit': 50, 'query': 'test'},
        ),
      ).thenAnswer((_) async => mockResponse);

      await repository.discoverFeeds(query: 'test');

      verify(
        () => mockApi.call(
          'app.bsky.unspecced.getPopularFeedGenerators',
          params: {'limit': 50, 'query': 'test'},
        ),
      ).called(1);
    });
  });

  group('getFeedMetadata', () {
    test('fetches feed generator metadata', () async {
      const feedUri = 'at://did:plc:abc/app.bsky.feed.generator/test';

      final mockResponse = {
        'view': {
          'uri': feedUri,
          'cid': 'bafytest123',
          'did': 'did:web:feedgen.test',
          'displayName': 'Test Feed',
          'description': 'A test feed',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:abc', 'handle': 'creator.test'},
          'likeCount': 100,
        },
      };

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: {'feed': feedUri}),
      ).thenAnswer((_) async => mockResponse);

      final metadata = await repository.getFeedMetadata(feedUri);

      expect(metadata.displayName, 'Test Feed');
      expect(metadata.likeCount, 100);
    });
  });

  group('refreshStaleMetadata', () {
    test('refreshes metadata for stale feeds', () async {
      final oldDate = DateTime.now().subtract(const Duration(days: 2));
      const feedUri = 'at://did:plc:abc/app.bsky.feed.generator/stale';

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: feedUri,
          displayName: 'Old Name',
          creatorDid: 'did:plc:abc',
          sortOrder: 0,
          lastSynced: oldDate,
        ),
      );

      final updatedMetadata = {
        'view': {
          'uri': feedUri,
          'cid': 'bafyupdated',
          'did': 'did:web:feedgen.test',
          'displayName': 'Updated Name',
          'description': 'Updated description',
          'avatar': 'new-avatar.jpg',
          'creator': {'did': 'did:plc:abc', 'handle': 'creator.test'},
          'likeCount': 200,
        },
      };

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: {'feed': feedUri}),
      ).thenAnswer((_) async => updatedMetadata);

      await repository.refreshStaleMetadata();

      final feed = await db.savedFeedsDao.getFeed(feedUri);
      expect(feed!.displayName, 'Updated Name');
      expect(feed.likeCount, 200);
    });

    test('skips refresh when no stale feeds', () async {
      final recentDate = DateTime.now().subtract(const Duration(hours: 1));

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/fresh',
          displayName: 'Fresh Feed',
          creatorDid: 'did:plc:abc',
          sortOrder: 0,
          lastSynced: recentDate,
        ),
      );

      await repository.refreshStaleMetadata();

      verifyNever(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: any(named: 'params')),
      );
    });
  });

  group('watchAllFeeds', () {
    test('watches all feeds from DAO', () async {
      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/test',
          displayName: 'Test Feed',
          creatorDid: 'did:plc:abc',
          sortOrder: 0,
          lastSynced: DateTime.now(),
        ),
      );

      final stream = repository.watchAllFeeds();
      expect(stream, emits(hasLength(1)));
    });
  });

  group('watchPinnedFeeds', () {
    test('watches only pinned feeds from DAO', () async {
      await db.savedFeedsDao.upsertFeeds([
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/pinned',
          displayName: 'Pinned Feed',
          creatorDid: 'did:plc:abc',
          sortOrder: 0,
          isPinned: const Value(true),
          lastSynced: DateTime.now(),
        ),
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:def/app.bsky.feed.generator/unpinned',
          displayName: 'Unpinned Feed',
          creatorDid: 'did:plc:def',
          sortOrder: 1,
          isPinned: const Value(false),
          lastSynced: DateTime.now(),
        ),
      ]);

      final stream = repository.watchPinnedFeeds();
      final feeds = await stream.first;
      expect(feeds, hasLength(1));
      expect(feeds[0].displayName, 'Pinned Feed');
    });
  });

  group('getFeed', () {
    test('gets feed by URI from DAO', () async {
      const feedUri = 'at://did:plc:abc/app.bsky.feed.generator/test';

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: feedUri,
          displayName: 'Test Feed',
          creatorDid: 'did:plc:abc',
          sortOrder: 0,
          lastSynced: DateTime.now(),
        ),
      );

      final feed = await repository.getFeed(feedUri);
      expect(feed, isNotNull);
      expect(feed!.displayName, 'Test Feed');
    });
  });

  group('seedDefaultFeeds', () {
    test('removes all seeded feeds for authenticated users', () async {
      when(() => mockApi.isAuthenticated).thenReturn(true);

      await db.savedFeedsDao.upsertFeeds([
        SavedFeedsCompanion.insert(
          uri: FeedRepository.kHomeFeedUri,
          displayName: 'Home',
          creatorDid: '',
          sortOrder: 0,
          isPinned: const Value(true),
          lastSynced: DateTime.now(),
        ),
        SavedFeedsCompanion.insert(
          uri: FeedRepository.kForYouFeedUri,
          displayName: 'For You',
          creatorDid: 'did:plc:test',
          sortOrder: 1,
          isPinned: const Value(true),
          lastSynced: DateTime.now(),
        ),
        SavedFeedsCompanion.insert(
          uri: FeedRepository.kDiscoverFeedUri,
          displayName: 'Discover',
          creatorDid: 'did:plc:test2',
          sortOrder: 2,
          isPinned: const Value(true),
          lastSynced: DateTime.now(),
        ),
      ]);

      await repository.seedDefaultFeeds();

      final feeds = await db.savedFeedsDao.getAllFeeds();
      expect(feeds, isEmpty);
    });

    test('seeds Discover feed for unauthenticated users', () async {
      when(() => mockApi.isAuthenticated).thenReturn(false);

      final mockMetadata = {
        'view': {
          'uri': FeedRepository.kDiscoverFeedUri,
          'cid': 'bafydiscover',
          'did': 'did:web:feedgen.bsky.app',
          'displayName': 'What\'s Hot',
          'description': 'Trending posts',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:z72i7hdynmk6r22z27h6tvur', 'handle': 'bsky.app'},
          'likeCount': 1000,
        },
      };

      when(
        () => mockApi.call(
          'app.bsky.feed.getFeedGenerator',
          params: {'feed': FeedRepository.kDiscoverFeedUri},
        ),
      ).thenAnswer((_) async => mockMetadata);

      await repository.seedDefaultFeeds();

      final feeds = await db.savedFeedsDao.getAllFeeds();
      expect(feeds, hasLength(1));
      expect(feeds[0].uri, FeedRepository.kDiscoverFeedUri);
      expect(feeds[0].displayName, 'What\'s Hot');
      expect(feeds[0].isPinned, true);
    });

    test('uses fallback metadata if fetch fails for unauthenticated users', () async {
      when(() => mockApi.isAuthenticated).thenReturn(false);

      when(
        () => mockApi.call(
          'app.bsky.feed.getFeedGenerator',
          params: {'feed': FeedRepository.kDiscoverFeedUri},
        ),
      ).thenThrow(Exception('Network error'));

      await repository.seedDefaultFeeds();

      final feeds = await db.savedFeedsDao.getAllFeeds();
      expect(feeds, hasLength(1));
      expect(feeds[0].uri, FeedRepository.kDiscoverFeedUri);
      expect(feeds[0].displayName, 'Discover');
      expect(feeds[0].description, 'Explore trending posts');
      expect(feeds[0].isPinned, true);
    });

    test('does not re-add Discover feed if it already exists for unauthenticated users', () async {
      when(() => mockApi.isAuthenticated).thenReturn(false);

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: FeedRepository.kDiscoverFeedUri,
          displayName: 'Existing Discover',
          creatorDid: 'did:plc:test',
          sortOrder: 0,
          isPinned: const Value(true),
          lastSynced: DateTime.now(),
        ),
      );

      await repository.seedDefaultFeeds();

      final feeds = await db.savedFeedsDao.getAllFeeds();
      expect(feeds, hasLength(1));
      expect(feeds[0].displayName, 'Existing Discover');
      verifyNever(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: any(named: 'params')),
      );
    });

    test('removes deprecated discover URI', () async {
      when(() => mockApi.isAuthenticated).thenReturn(false);

      const deprecatedUri =
          'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/discover';

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: deprecatedUri,
          displayName: 'Old Discover',
          creatorDid: 'did:plc:test',
          sortOrder: 0,
          lastSynced: DateTime.now(),
        ),
      );

      final mockMetadata = {
        'view': {
          'uri': FeedRepository.kDiscoverFeedUri,
          'cid': 'bafydiscover',
          'did': 'did:web:feedgen.bsky.app',
          'displayName': 'What\'s Hot',
          'description': 'Trending posts',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:z72i7hdynmk6r22z27h6tvur', 'handle': 'bsky.app'},
          'likeCount': 1000,
        },
      };

      when(
        () => mockApi.call(
          'app.bsky.feed.getFeedGenerator',
          params: {'feed': FeedRepository.kDiscoverFeedUri},
        ),
      ).thenAnswer((_) async => mockMetadata);

      await repository.seedDefaultFeeds();

      final deprecatedFeed = await db.savedFeedsDao.getFeed(deprecatedUri);
      expect(deprecatedFeed, isNull);

      final feeds = await db.savedFeedsDao.getAllFeeds();
      expect(feeds, hasLength(1));
      expect(feeds[0].uri, FeedRepository.kDiscoverFeedUri);
    });

    test('migrates pinned deprecated feed preserving pin status', () async {
      when(() => mockApi.isAuthenticated).thenReturn(false);

      const deprecatedUri =
          'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/discover';

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: deprecatedUri,
          displayName: 'Old Discover',
          creatorDid: 'did:plc:test',
          sortOrder: 3,
          isPinned: const Value(true),
          lastSynced: DateTime.now(),
        ),
      );

      final mockMetadata = {
        'view': {
          'uri': FeedRepository.kDiscoverFeedUri,
          'cid': 'bafydiscover',
          'did': 'did:web:feedgen.bsky.app',
          'displayName': 'What\'s Hot',
          'description': 'Trending posts',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:z72i7hdynmk6r22z27h6tvur', 'handle': 'bsky.app'},
          'likeCount': 1000,
        },
      };

      when(
        () => mockApi.call(
          'app.bsky.feed.getFeedGenerator',
          params: {'feed': FeedRepository.kDiscoverFeedUri},
        ),
      ).thenAnswer((_) async => mockMetadata);

      await repository.seedDefaultFeeds();

      final feeds = await db.savedFeedsDao.getAllFeeds();
      expect(feeds, hasLength(1));
      expect(feeds[0].uri, FeedRepository.kDiscoverFeedUri);
      expect(feeds[0].isPinned, true, reason: 'Pin status should be preserved');
      expect(feeds[0].sortOrder, 3, reason: 'Sort order should be preserved');
    });

    test('migrates unpinned deprecated feed preserving unpinned status', () async {
      when(() => mockApi.isAuthenticated).thenReturn(false);

      const deprecatedUri =
          'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/discover';

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: deprecatedUri,
          displayName: 'Old Discover',
          creatorDid: 'did:plc:test',
          sortOrder: 5,
          isPinned: const Value(false),
          lastSynced: DateTime.now(),
        ),
      );

      final mockMetadata = {
        'view': {
          'uri': FeedRepository.kDiscoverFeedUri,
          'cid': 'bafydiscover',
          'did': 'did:web:feedgen.bsky.app',
          'displayName': 'What\'s Hot',
          'description': 'Trending posts',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:z72i7hdynmk6r22z27h6tvur', 'handle': 'bsky.app'},
          'likeCount': 1000,
        },
      };

      when(
        () => mockApi.call(
          'app.bsky.feed.getFeedGenerator',
          params: {'feed': FeedRepository.kDiscoverFeedUri},
        ),
      ).thenAnswer((_) async => mockMetadata);

      await repository.seedDefaultFeeds();

      final feeds = await db.savedFeedsDao.getAllFeeds();
      expect(feeds, hasLength(1));
      expect(feeds[0].uri, FeedRepository.kDiscoverFeedUri);
      expect(feeds[0].isPinned, false, reason: 'Unpinned status should be preserved');
      expect(feeds[0].sortOrder, 5, reason: 'Sort order should be preserved');
    });

    test('does not apply migration properties if new feed already exists', () async {
      when(() => mockApi.isAuthenticated).thenReturn(false);

      const deprecatedUri =
          'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/discover';

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: deprecatedUri,
          displayName: 'Old Discover',
          creatorDid: 'did:plc:test',
          sortOrder: 5,
          isPinned: const Value(true),
          lastSynced: DateTime.now(),
        ),
      );

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: FeedRepository.kDiscoverFeedUri,
          displayName: 'Existing Discover',
          creatorDid: 'did:plc:test',
          sortOrder: 0,
          isPinned: const Value(false),
          lastSynced: DateTime.now(),
        ),
      );

      await repository.seedDefaultFeeds();

      final deprecatedFeed = await db.savedFeedsDao.getFeed(deprecatedUri);
      expect(deprecatedFeed, isNull);

      final feeds = await db.savedFeedsDao.getAllFeeds();
      expect(feeds, hasLength(1));
      expect(feeds[0].uri, FeedRepository.kDiscoverFeedUri);
      expect(feeds[0].displayName, 'Existing Discover');
      expect(feeds[0].isPinned, false, reason: 'New feed properties should not change');
      expect(feeds[0].sortOrder, 0, reason: 'New feed properties should not change');
    });

    test('handles missing deprecated feed gracefully', () async {
      when(() => mockApi.isAuthenticated).thenReturn(false);

      final mockMetadata = {
        'view': {
          'uri': FeedRepository.kDiscoverFeedUri,
          'cid': 'bafydiscover',
          'did': 'did:web:feedgen.bsky.app',
          'displayName': 'What\'s Hot',
          'description': 'Trending posts',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:z72i7hdynmk6r22z27h6tvur', 'handle': 'bsky.app'},
          'likeCount': 1000,
        },
      };

      when(
        () => mockApi.call(
          'app.bsky.feed.getFeedGenerator',
          params: {'feed': FeedRepository.kDiscoverFeedUri},
        ),
      ).thenAnswer((_) async => mockMetadata);

      await repository.seedDefaultFeeds();

      final feeds = await db.savedFeedsDao.getAllFeeds();
      expect(feeds, hasLength(1));
      expect(feeds[0].uri, FeedRepository.kDiscoverFeedUri);
      expect(feeds[0].isPinned, true);
      expect(feeds[0].sortOrder, 0);
    });
  });
}
