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
    repository = FeedRepository(mockApi, db.savedFeedsDao, db.preferenceSyncQueueDao, mockLogger);

    when(() => mockApi.isAuthenticated).thenReturn(true);
  });

  tearDown(() async {
    await db.close();
  });

  group('syncPreferences', () {
    test('syncs saved feeds from preferences and hydrates with metadata', () async {
      const prefsResponse = {
        'preferences': [
          {
            '\$type': 'app.bsky.actor.defs#savedFeedsPref',
            'saved': [
              'at://did:plc:abc/app.bsky.feed.generator/test1',
              'at://did:plc:def/app.bsky.feed.generator/test2',
            ],
            'pinned': ['at://did:plc:abc/app.bsky.feed.generator/test1'],
          },
        ],
      };

      final feed1Metadata = {
        'view': {
          'displayName': 'Test Feed 1',
          'description': 'Description 1',
          'avatar': 'avatar1.jpg',
          'creator': {'did': 'did:plc:abc'},
          'likeCount': 100,
        },
      };

      final feed2Metadata = {
        'view': {
          'displayName': 'Test Feed 2',
          'description': 'Description 2',
          'avatar': 'avatar2.jpg',
          'creator': {'did': 'did:plc:def'},
          'likeCount': 50,
        },
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => prefsResponse);

      when(
        () => mockApi.call(
          'app.bsky.feed.getFeedGenerator',
          params: {'feed': 'at://did:plc:abc/app.bsky.feed.generator/test1'},
        ),
      ).thenAnswer((_) async => feed1Metadata);

      when(
        () => mockApi.call(
          'app.bsky.feed.getFeedGenerator',
          params: {'feed': 'at://did:plc:def/app.bsky.feed.generator/test2'},
        ),
      ).thenAnswer((_) async => feed2Metadata);

      await repository.syncPreferences();

      final feeds = await db.savedFeedsDao.getAllFeeds();
      expect(feeds, hasLength(2));
      expect(feeds[0].uri, 'at://did:plc:abc/app.bsky.feed.generator/test1');
      expect(feeds[0].displayName, 'Test Feed 1');
      expect(feeds[0].isPinned, true);
      expect(feeds[0].sortOrder, 0);
      expect(feeds[1].uri, 'at://did:plc:def/app.bsky.feed.generator/test2');
      expect(feeds[1].displayName, 'Test Feed 2');
      expect(feeds[1].isPinned, false);
      expect(feeds[1].sortOrder, 1);
    });

    test('handles empty savedFeedsPref', () async {
      const prefsResponse = {
        'preferences': [
          {'\$type': 'app.bsky.actor.defs#savedFeedsPref', 'saved': [], 'pinned': []},
        ],
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => prefsResponse);

      await repository.syncPreferences();

      final feeds = await db.savedFeedsDao.getAllFeeds();
      expect(feeds, isEmpty);
    });

    test('handles missing savedFeedsPref', () async {
      const prefsResponse = {
        'preferences': [
          {'\$type': 'app.bsky.actor.defs#contentLabelPref'},
        ],
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => prefsResponse);

      await repository.syncPreferences();

      final feeds = await db.savedFeedsDao.getAllFeeds();
      expect(feeds, isEmpty);
    });

    test('skips sync for unauthenticated user', () async {
      when(() => mockApi.isAuthenticated).thenReturn(false);

      await repository.syncPreferences();

      verifyNever(() => mockApi.call('app.bsky.actor.getPreferences'));
    });

    test('continues on metadata fetch failure for individual feed', () async {
      const prefsResponse = {
        'preferences': [
          {
            '\$type': 'app.bsky.actor.defs#savedFeedsPref',
            'saved': [
              'at://did:plc:abc/app.bsky.feed.generator/test1',
              'at://did:plc:def/app.bsky.feed.generator/test2',
            ],
            'pinned': [],
          },
        ],
      };

      final feed2Metadata = {
        'view': {
          'displayName': 'Test Feed 2',
          'description': 'Description 2',
          'avatar': 'avatar2.jpg',
          'creator': {'did': 'did:plc:def'},
          'likeCount': 50,
        },
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => prefsResponse);

      when(
        () => mockApi.call(
          'app.bsky.feed.getFeedGenerator',
          params: {'feed': 'at://did:plc:abc/app.bsky.feed.generator/test1'},
        ),
      ).thenThrow(Exception('Feed not found'));

      when(
        () => mockApi.call(
          'app.bsky.feed.getFeedGenerator',
          params: {'feed': 'at://did:plc:def/app.bsky.feed.generator/test2'},
        ),
      ).thenAnswer((_) async => feed2Metadata);

      await repository.syncPreferences();

      final feeds = await db.savedFeedsDao.getAllFeeds();
      expect(feeds, hasLength(1));
      expect(feeds[0].displayName, 'Test Feed 2');
    });
  });

  group('saveFeed', () {
    test('optimistically saves feed and syncs to remote', () async {
      const feedUri = 'at://did:plc:abc/app.bsky.feed.generator/new';

      const currentPrefs = {
        'preferences': [
          {'\$type': 'app.bsky.actor.defs#savedFeedsPref', 'saved': [], 'pinned': []},
        ],
      };

      final feedMetadata = {
        'view': {
          'displayName': 'New Feed',
          'description': 'A new feed',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:abc'},
          'likeCount': 10,
        },
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => currentPrefs);

      when(
        () => mockApi.call('app.bsky.actor.putPreferences', body: any(named: 'body')),
      ).thenAnswer((_) async => {});

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: {'feed': feedUri}),
      ).thenAnswer((_) async => feedMetadata);

      await repository.saveFeed(feedUri);

      verify(
        () => mockApi.call(
          'app.bsky.actor.putPreferences',
          body: {
            'preferences': [
              {
                '\$type': 'app.bsky.actor.defs#savedFeedsPref',
                'saved': [feedUri],
                'pinned': [],
              },
            ],
          },
        ),
      ).called(1);

      final feed = await db.savedFeedsDao.getFeed(feedUri);
      expect(feed, isNotNull);
      expect(feed!.displayName, 'New Feed');
      final queue = await db.preferenceSyncQueueDao.getPendingItems();
      expect(queue, isEmpty);
    });

    test('optimistically saves with default metadata if fetch fails', () async {
      const feedUri = 'at://did:plc:abc/app.bsky.feed.generator/failmeta';

      const currentPrefs = {
        'preferences': [
          {'\$type': 'app.bsky.actor.defs#savedFeedsPref', 'saved': [], 'pinned': []},
        ],
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => currentPrefs);

      when(
        () => mockApi.call('app.bsky.actor.putPreferences', body: any(named: 'body')),
      ).thenAnswer((_) async => {});

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: {'feed': feedUri}),
      ).thenThrow(Exception('Network error'));

      await repository.saveFeed(feedUri);

      verify(
        () => mockApi.call('app.bsky.actor.putPreferences', body: any(named: 'body')),
      ).called(1);
      final feed = await db.savedFeedsDao.getFeed(feedUri);
      expect(feed, isNotNull);
      expect(feed!.displayName, 'Saved Feed');
    });

    test('queues update if network call fails', () async {
      const feedUri = 'at://did:plc:abc/app.bsky.feed.generator/offline';

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: {'feed': feedUri}),
      ).thenThrow(Exception('Network error'));
      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenThrow(Exception('Network error'));

      await repository.saveFeed(feedUri);

      final queue = await db.preferenceSyncQueueDao.getPendingItems();
      expect(queue, hasLength(1));
      expect(queue.first.type, 'save');
      expect(queue.first.feedUri, feedUri);
      final feed = await db.savedFeedsDao.getFeed(feedUri);
      expect(feed, isNotNull);
    });

    test('saves feed with pin=true', () async {
      const feedUri = 'at://did:plc:abc/app.bsky.feed.generator/new';

      const currentPrefs = {
        'preferences': [
          {'\$type': 'app.bsky.actor.defs#savedFeedsPref', 'saved': [], 'pinned': []},
        ],
      };

      final feedMetadata = {
        'view': {
          'displayName': 'New Feed',
          'description': 'A new feed',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:abc'},
          'likeCount': 10,
        },
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => currentPrefs);

      when(
        () => mockApi.call('app.bsky.actor.putPreferences', body: any(named: 'body')),
      ).thenAnswer((_) async => {});

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: {'feed': feedUri}),
      ).thenAnswer((_) async => feedMetadata);

      await repository.saveFeed(feedUri, pin: true);

      verify(
        () => mockApi.call(
          'app.bsky.actor.putPreferences',
          body: {
            'preferences': [
              {
                '\$type': 'app.bsky.actor.defs#savedFeedsPref',
                'saved': [feedUri],
                'pinned': [feedUri],
              },
            ],
          },
        ),
      ).called(1);

      final feed = await db.savedFeedsDao.getFeed(feedUri);
      expect(feed!.isPinned, true);
    });

    test('creates savedFeedsPref if missing', () async {
      const feedUri = 'at://did:plc:abc/app.bsky.feed.generator/new';

      const currentPrefs = {
        'preferences': [
          {'\$type': 'app.bsky.actor.defs#contentLabelPref'},
        ],
      };

      final feedMetadata = {
        'view': {
          'displayName': 'New Feed',
          'description': 'A new feed',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:abc'},
          'likeCount': 10,
        },
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => currentPrefs);

      when(
        () => mockApi.call('app.bsky.actor.putPreferences', body: any(named: 'body')),
      ).thenAnswer((_) async => {});

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: {'feed': feedUri}),
      ).thenAnswer((_) async => feedMetadata);

      await repository.saveFeed(feedUri);

      verify(
        () => mockApi.call(
          'app.bsky.actor.putPreferences',
          body: {
            'preferences': [
              {'\$type': 'app.bsky.actor.defs#contentLabelPref'},
              {
                '\$type': 'app.bsky.actor.defs#savedFeedsPref',
                'saved': [feedUri],
                'pinned': [],
              },
            ],
          },
        ),
      ).called(1);
    });

    test('preserves other preference categories', () async {
      const feedUri = 'at://did:plc:abc/app.bsky.feed.generator/new';

      const currentPrefs = {
        'preferences': [
          {'\$type': 'app.bsky.actor.defs#contentLabelPref', 'label': 'hide'},
          {'\$type': 'app.bsky.actor.defs#savedFeedsPref', 'saved': [], 'pinned': []},
        ],
      };

      final feedMetadata = {
        'view': {
          'displayName': 'New Feed',
          'description': 'A new feed',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:abc'},
          'likeCount': 10,
        },
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => currentPrefs);

      when(
        () => mockApi.call('app.bsky.actor.putPreferences', body: any(named: 'body')),
      ).thenAnswer((_) async => {});

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: {'feed': feedUri}),
      ).thenAnswer((_) async => feedMetadata);

      await repository.saveFeed(feedUri);

      final captured =
          verify(
                () =>
                    mockApi.call('app.bsky.actor.putPreferences', body: captureAny(named: 'body')),
              ).captured.single
              as Map<String, dynamic>;

      final prefs = captured['preferences'] as List;
      expect(prefs, hasLength(2));
      expect(prefs[0]['\$type'], 'app.bsky.actor.defs#contentLabelPref');
      expect(prefs[0]['label'], 'hide');
    });

    test('throws when unauthenticated', () async {
      when(() => mockApi.isAuthenticated).thenReturn(false);

      expect(
        () => repository.saveFeed('at://did:plc:abc/app.bsky.feed.generator/test'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('removeFeed', () {
    test('removes feed from preferences and local cache', () async {
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

      final currentPrefs = {
        'preferences': [
          {
            '\$type': 'app.bsky.actor.defs#savedFeedsPref',
            'saved': [feedUri],
            'pinned': [feedUri],
          },
        ],
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => currentPrefs);

      when(
        () => mockApi.call('app.bsky.actor.putPreferences', body: any(named: 'body')),
      ).thenAnswer((_) async => {});

      await repository.removeFeed(feedUri);

      verify(
        () => mockApi.call(
          'app.bsky.actor.putPreferences',
          body: {
            'preferences': [
              {'\$type': 'app.bsky.actor.defs#savedFeedsPref', 'saved': [], 'pinned': []},
            ],
          },
        ),
      ).called(1);

      final feed = await db.savedFeedsDao.getFeed(feedUri);
      expect(feed, isNull);
    });

    test('handles missing savedFeedsPref gracefully', () async {
      const feedUri = 'at://did:plc:abc/app.bsky.feed.generator/test';

      const currentPrefs = {
        'preferences': [
          {'\$type': 'app.bsky.actor.defs#contentLabelPref'},
        ],
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => currentPrefs);

      await repository.removeFeed(feedUri);

      verifyNever(() => mockApi.call('app.bsky.actor.putPreferences', body: any(named: 'body')));
    });

    test('throws when unauthenticated', () async {
      when(() => mockApi.isAuthenticated).thenReturn(false);

      expect(
        () => repository.removeFeed('at://did:plc:abc/app.bsky.feed.generator/test'),
        throwsA(isA<Exception>()),
      );
    });
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
  });

  group('getFeedMetadata', () {
    test('fetches feed generator metadata', () async {
      const feedUri = 'at://did:plc:abc/app.bsky.feed.generator/test';

      final mockResponse = {
        'view': {
          'uri': feedUri,
          'displayName': 'Test Feed',
          'description': 'A test feed',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:abc'},
          'likeCount': 100,
        },
      };

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: {'feed': feedUri}),
      ).thenAnswer((_) async => mockResponse);

      final metadata = await repository.getFeedMetadata(feedUri);

      expect(metadata['displayName'], 'Test Feed');
      expect(metadata['likeCount'], 100);
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
          'displayName': 'Updated Name',
          'description': 'Updated description',
          'avatar': 'new-avatar.jpg',
          'creator': {'did': 'did:plc:abc'},
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

      // Insert seeded feeds to verify they get removed
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
          'displayName': 'What\'s Hot',
          'description': 'Trending posts',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:z72i7hdynmk6r22z27h6tvur'},
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
          'displayName': 'What\'s Hot',
          'description': 'Trending posts',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:z72i7hdynmk6r22z27h6tvur'},
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

      // Insert deprecated feed with pin status = true
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
          'displayName': 'What\'s Hot',
          'description': 'Trending posts',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:z72i7hdynmk6r22z27h6tvur'},
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

      // Insert deprecated feed with pin status = false
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
          'displayName': 'What\'s Hot',
          'description': 'Trending posts',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:z72i7hdynmk6r22z27h6tvur'},
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

      // Insert deprecated feed with sortOrder=5, pinned=true
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

      // Insert new feed with different sortOrder and unpinned
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

      // Deprecated feed should be deleted
      final deprecatedFeed = await db.savedFeedsDao.getFeed(deprecatedUri);
      expect(deprecatedFeed, isNull);

      // New feed should keep its original properties
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
          'displayName': 'What\'s Hot',
          'description': 'Trending posts',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:z72i7hdynmk6r22z27h6tvur'},
          'likeCount': 1000,
        },
      };

      when(
        () => mockApi.call(
          'app.bsky.feed.getFeedGenerator',
          params: {'feed': FeedRepository.kDiscoverFeedUri},
        ),
      ).thenAnswer((_) async => mockMetadata);

      // No deprecated feed exists, just seed default
      await repository.seedDefaultFeeds();

      final feeds = await db.savedFeedsDao.getAllFeeds();
      expect(feeds, hasLength(1));
      expect(feeds[0].uri, FeedRepository.kDiscoverFeedUri);
      // With no migration, should use defaults
      expect(feeds[0].isPinned, true);
      expect(feeds[0].sortOrder, 0);
    });
  });

  group('Feed URI Validation', () {
    test('rejects empty feed URI', () {
      expect(
        () => repository.saveFeed(''),
        throwsA(
          isA<ArgumentError>().having((e) => e.message, 'message', contains('cannot be empty')),
        ),
      );
    });

    test('rejects URI without at:// scheme', () {
      expect(
        () => repository.saveFeed('did:plc:abc/app.bsky.feed.generator/test'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('must start with "at://"'),
          ),
        ),
      );
    });

    test('rejects URI with insufficient components', () {
      expect(
        () => repository.saveFeed('at://did:plc:abc'),
        throwsA(
          isA<ArgumentError>().having((e) => e.message, 'message', contains('must have format')),
        ),
      );
    });

    test('rejects URI without valid DID', () {
      expect(
        () => repository.saveFeed('at://invalid/app.bsky.feed.generator/test'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('must contain a valid DID'),
          ),
        ),
      );
    });

    test('rejects URI with wrong collection', () {
      expect(
        () => repository.saveFeed('at://did:plc:abc/app.bsky.post/test'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('collection must be "app.bsky.feed.generator"'),
          ),
        ),
      );
    });

    test('rejects URI with empty rkey', () {
      expect(
        () => repository.saveFeed('at://did:plc:abc/app.bsky.feed.generator/'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('must have a valid record key'),
          ),
        ),
      );
    });

    test('accepts valid AT URI', () async {
      const validUri = 'at://did:plc:abc123xyz/app.bsky.feed.generator/my-feed';

      final currentPrefs = {'preferences': <Map<String, dynamic>>[]};

      final feedMetadata = {
        'view': {
          'displayName': 'Valid Feed',
          'description': 'A valid feed',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:abc123xyz'},
          'likeCount': 5,
        },
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => currentPrefs);

      when(
        () => mockApi.call('app.bsky.actor.putPreferences', body: any(named: 'body')),
      ).thenAnswer((_) async => {});

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: {'feed': validUri}),
      ).thenAnswer((_) async => feedMetadata);

      await repository.saveFeed(validUri);

      final feed = await db.savedFeedsDao.getFeed(validUri);
      expect(feed, isNotNull);
      expect(feed!.displayName, 'Valid Feed');
    });
  });

  group('Transaction Atomicity', () {
    test('saveFeed creates queue entry atomically with local update', () async {
      const feedUri = 'at://did:plc:test/app.bsky.feed.generator/atomic';

      final feedMetadata = {
        'view': {
          'displayName': 'Atomic Feed',
          'description': 'Test atomic operations',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:test'},
          'likeCount': 42,
        },
      };

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: {'feed': feedUri}),
      ).thenAnswer((_) async => feedMetadata);

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenThrow(Exception('Network error'));

      await repository.saveFeed(feedUri);

      final feed = await db.savedFeedsDao.getFeed(feedUri);
      expect(feed, isNotNull, reason: 'Local feed should be saved');

      final queueItems = await db.preferenceSyncQueueDao.getPendingItems();
      expect(queueItems, hasLength(1), reason: 'Should have queued sync operation');
      expect(queueItems[0].feedUri, feedUri);
      expect(queueItems[0].type, 'save');
    });

    test('saveFeed removes queue entry on successful remote sync', () async {
      const feedUri = 'at://did:plc:success/app.bsky.feed.generator/sync';

      final currentPrefs = {'preferences': <Map<String, dynamic>>[]};

      final feedMetadata = {
        'view': {
          'displayName': 'Success Feed',
          'description': 'Successful sync test',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:success'},
          'likeCount': 10,
        },
      };

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: {'feed': feedUri}),
      ).thenAnswer((_) async => feedMetadata);

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => currentPrefs);

      when(
        () => mockApi.call('app.bsky.actor.putPreferences', body: any(named: 'body')),
      ).thenAnswer((_) async => {});

      await repository.saveFeed(feedUri);

      final feed = await db.savedFeedsDao.getFeed(feedUri);
      expect(feed, isNotNull, reason: 'Local feed should be saved');

      final queueItems = await db.preferenceSyncQueueDao.getPendingItems();
      expect(queueItems, isEmpty, reason: 'Queue should be empty after successful sync');
    });

    test('removeFeed creates queue entry atomically with local delete', () async {
      const feedUri = 'at://did:plc:remove/app.bsky.feed.generator/test';

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: feedUri,
          displayName: 'To Remove',
          creatorDid: 'did:plc:remove',
          sortOrder: 0,
          lastSynced: DateTime.now(),
        ),
      );

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenThrow(Exception('Network error'));

      await repository.removeFeed(feedUri);

      final feed = await db.savedFeedsDao.getFeed(feedUri);
      expect(feed, isNull, reason: 'Local feed should be deleted');

      final queueItems = await db.preferenceSyncQueueDao.getPendingItems();
      expect(queueItems, hasLength(1), reason: 'Should have queued sync operation');
      expect(queueItems[0].feedUri, feedUri);
      expect(queueItems[0].type, 'remove');
    });

    test('removeFeed removes queue entry on successful remote sync', () async {
      const feedUri = 'at://did:plc:remove/app.bsky.feed.generator/success';

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: feedUri,
          displayName: 'To Remove',
          creatorDid: 'did:plc:remove',
          sortOrder: 0,
          lastSynced: DateTime.now(),
        ),
      );

      final currentPrefs = {
        'preferences': [
          {
            '\$type': 'app.bsky.actor.defs#savedFeedsPref',
            'saved': [feedUri],
            'pinned': <String>[],
          },
        ],
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => currentPrefs);

      when(
        () => mockApi.call('app.bsky.actor.putPreferences', body: any(named: 'body')),
      ).thenAnswer((_) async => {});

      await repository.removeFeed(feedUri);

      final feed = await db.savedFeedsDao.getFeed(feedUri);
      expect(feed, isNull, reason: 'Local feed should be deleted');

      final queueItems = await db.preferenceSyncQueueDao.getPendingItems();
      expect(queueItems, isEmpty, reason: 'Queue should be empty after successful sync');
    });
  });

  group('Sync Queue Retry Limits', () {
    test('processSyncQueue increments retry count on failure', () async {
      const feedUri = 'at://did:plc:test/app.bsky.feed.generator/retry-test';
      final now = DateTime.now();

      await db.preferenceSyncQueueDao.enqueue(
        PreferenceSyncQueueCompanion.insert(type: 'save', feedUri: feedUri, createdAt: now),
      );

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: feedUri,
          displayName: 'Test Feed',
          creatorDid: 'did:plc:test',
          sortOrder: 0,
          lastSynced: now,
        ),
      );

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenThrow(Exception('Network error'));

      await repository.processSyncQueue();

      final items = await db.preferenceSyncQueueDao.getPendingItems();
      expect(items.length, 1);
      expect(items.first.retryCount, 1, reason: 'Retry count should be incremented');
    });

    test('processSyncQueue skips items at max retries', () async {
      const feedUri = 'at://did:plc:test/app.bsky.feed.generator/maxed-out';
      final now = DateTime.now();

      await db
          .into(db.preferenceSyncQueue)
          .insert(
            PreferenceSyncQueueCompanion.insert(
              type: 'save',
              feedUri: feedUri,
              createdAt: now,
              retryCount: const Value(5),
            ),
          );

      await repository.processSyncQueue();

      verifyNever(() => mockApi.call('app.bsky.actor.getPreferences'));

      final items = await db.preferenceSyncQueueDao.getPendingItems();
      expect(items.length, 1);
      expect(items.first.retryCount, 5, reason: 'Retry count should not change');
    });

    test('syncOnResume cleans up old failed items', () async {
      final now = DateTime.now();

      await db
          .into(db.preferenceSyncQueue)
          .insert(
            PreferenceSyncQueueCompanion.insert(
              type: 'save',
              feedUri: 'at://did:plc:test/app.bsky.feed.generator/old-failed',
              createdAt: now.subtract(const Duration(days: 45)),
              retryCount: const Value(5),
            ),
          );

      await db.preferenceSyncQueueDao.enqueue(
        PreferenceSyncQueueCompanion.insert(
          type: 'save',
          feedUri: 'at://did:plc:test/app.bsky.feed.generator/recent',
          createdAt: now,
        ),
      );

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenThrow(Exception('Network error'));

      await repository.syncOnResume();

      final items = await db.preferenceSyncQueueDao.getPendingItems();
      expect(items.length, 1);
      expect(items.first.feedUri, 'at://did:plc:test/app.bsky.feed.generator/recent');
    });

    test('processSyncQueue processes only retryable items', () async {
      final now = DateTime.now();

      await db.preferenceSyncQueueDao.enqueue(
        PreferenceSyncQueueCompanion.insert(
          type: 'save',
          feedUri: 'at://did:plc:ok/app.bsky.feed.generator/retryable',
          createdAt: now,
        ),
      );

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:ok/app.bsky.feed.generator/retryable',
          displayName: 'Retryable Feed',
          creatorDid: 'did:plc:ok',
          sortOrder: 0,
          lastSynced: now,
        ),
      );

      await db
          .into(db.preferenceSyncQueue)
          .insert(
            PreferenceSyncQueueCompanion.insert(
              type: 'save',
              feedUri: 'at://did:plc:fail/app.bsky.feed.generator/maxed',
              createdAt: now,
              retryCount: const Value(5),
            ),
          );

      final currentPrefs = {'preferences': <Map<String, dynamic>>[]};
      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => currentPrefs);
      when(
        () => mockApi.call('app.bsky.actor.putPreferences', body: any(named: 'body')),
      ).thenAnswer((_) async => {});

      await repository.processSyncQueue();

      final items = await db.preferenceSyncQueueDao.getPendingItems();
      expect(items.length, 1, reason: 'Only the maxed-out item should remain');
      expect(items.first.feedUri, 'at://did:plc:fail/app.bsky.feed.generator/maxed');
    });
  });

  group('Multi-Device Sync Conflict Resolution', () {
    test('local changes win when localUpdatedAt is newer than lastSynced', () async {
      const feedUri = 'at://did:plc:test/app.bsky.feed.generator/conflict';
      final baseTime = DateTime.now().subtract(const Duration(hours: 2));

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: feedUri,
          displayName: 'Local Name',
          creatorDid: 'did:plc:test',
          sortOrder: 0,
          isPinned: const Value(true),
          lastSynced: baseTime,
          localUpdatedAt: Value(baseTime.add(const Duration(hours: 1))),
        ),
      );

      const remotePrefs = {
        'preferences': [
          {
            '\$type': 'app.bsky.actor.defs#savedFeedsPref',
            'saved': [feedUri],
            'pinned': [],
          },
        ],
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => remotePrefs);

      await repository.syncPreferences();

      final feed = await db.savedFeedsDao.getFeed(feedUri);
      expect(feed, isNotNull);
      expect(feed!.isPinned, true, reason: 'Local pin status should win');
      expect(feed.displayName, 'Local Name', reason: 'Local display name should be preserved');
      final queue = await db.preferenceSyncQueueDao.getPendingItems();
      expect(queue.any((q) => q.feedUri == feedUri && q.type == 'save'), true);
    });

    test('remote changes win when no local modifications', () async {
      const feedUri = 'at://did:plc:test/app.bsky.feed.generator/remote-wins';
      final baseTime = DateTime.now().subtract(const Duration(hours: 2));

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: feedUri,
          displayName: 'Old Name',
          creatorDid: 'did:plc:test',
          sortOrder: 5,
          isPinned: const Value(false),
          lastSynced: baseTime,
        ),
      );

      const remotePrefs = {
        'preferences': [
          {
            '\$type': 'app.bsky.actor.defs#savedFeedsPref',
            'saved': [feedUri],
            'pinned': [feedUri],
          },
        ],
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => remotePrefs);

      await repository.syncPreferences();

      final feed = await db.savedFeedsDao.getFeed(feedUri);
      expect(feed, isNotNull);
      expect(feed!.isPinned, true, reason: 'Remote pin status should win');
      expect(feed.sortOrder, 0, reason: 'Should use remote sort order');
    });

    test('new remote feeds are added locally', () async {
      const newFeedUri = 'at://did:plc:new/app.bsky.feed.generator/remote-only';

      const remotePrefs = {
        'preferences': [
          {
            '\$type': 'app.bsky.actor.defs#savedFeedsPref',
            'saved': [newFeedUri],
            'pinned': [newFeedUri],
          },
        ],
      };

      final feedMetadata = {
        'view': {
          'displayName': 'New Remote Feed',
          'description': 'Added on another device',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:new'},
          'likeCount': 42,
        },
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => remotePrefs);

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: {'feed': newFeedUri}),
      ).thenAnswer((_) async => feedMetadata);

      await repository.syncPreferences();

      final feed = await db.savedFeedsDao.getFeed(newFeedUri);
      expect(feed, isNotNull);
      expect(feed!.displayName, 'New Remote Feed');
      expect(feed.isPinned, true);
      expect(
        feed.localUpdatedAt,
        isNull,
        reason: 'New remote feed should have no local modification',
      );
    });

    test('remotely deleted feeds are removed locally when no local modifications', () async {
      const deletedFeedUri = 'at://did:plc:test/app.bsky.feed.generator/to-delete';
      final baseTime = DateTime.now().subtract(const Duration(hours: 2));

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: deletedFeedUri,
          displayName: 'To Be Deleted',
          creatorDid: 'did:plc:test',
          sortOrder: 0,
          lastSynced: baseTime,
        ),
      );

      const remotePrefs = {
        'preferences': [
          {'\$type': 'app.bsky.actor.defs#savedFeedsPref', 'saved': [], 'pinned': []},
        ],
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => remotePrefs);

      await repository.syncPreferences();

      final feed = await db.savedFeedsDao.getFeed(deletedFeedUri);
      expect(feed, isNull, reason: 'Remotely deleted feed should be removed locally');
    });

    test('local-only feeds with modifications are queued for remote sync', () async {
      const localOnlyFeedUri = 'at://did:plc:local/app.bsky.feed.generator/local-only';
      final baseTime = DateTime.now().subtract(const Duration(hours: 2));

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: localOnlyFeedUri,
          displayName: 'Local Only Feed',
          creatorDid: 'did:plc:local',
          sortOrder: 0,
          isPinned: const Value(true),
          lastSynced: baseTime,
          localUpdatedAt: Value(baseTime.add(const Duration(hours: 1))),
        ),
      );

      const remotePrefs = {
        'preferences': [
          {'\$type': 'app.bsky.actor.defs#savedFeedsPref', 'saved': [], 'pinned': []},
        ],
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => remotePrefs);

      await repository.syncPreferences();

      final feed = await db.savedFeedsDao.getFeed(localOnlyFeedUri);
      expect(feed, isNotNull, reason: 'Local-only feed with modifications should be kept');

      final queue = await db.preferenceSyncQueueDao.getPendingItems();
      expect(
        queue.any((q) => q.feedUri == localOnlyFeedUri && q.type == 'save'),
        true,
        reason: 'Local-only feed should be queued for remote sync',
      );
    });

    test('concurrent modifications resolve correctly based on timestamps', () async {
      const feedUri = 'at://did:plc:test/app.bsky.feed.generator/concurrent';
      final baseTime = DateTime.now().subtract(const Duration(hours: 3));

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: feedUri,
          displayName: 'Concurrent Feed',
          creatorDid: 'did:plc:test',
          sortOrder: 5,
          isPinned: const Value(true),
          lastSynced: baseTime,
          localUpdatedAt: Value(baseTime.add(const Duration(hours: 1))),
        ),
      );

      const remotePrefs = {
        'preferences': [
          {
            '\$type': 'app.bsky.actor.defs#savedFeedsPref',
            'saved': [feedUri],
            'pinned': [],
          },
        ],
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => remotePrefs);

      await repository.syncPreferences();

      final feed = await db.savedFeedsDao.getFeed(feedUri);
      expect(feed, isNotNull);
      expect(feed!.isPinned, true, reason: 'Local pin status should be preserved (newer)');
    });
  });
}
