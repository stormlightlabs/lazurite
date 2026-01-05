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
    repository = FeedRepository(mockApi, db.savedFeedsDao, mockLogger);

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
    test('saves new feed to preferences and local cache', () async {
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
      expect(feed.isPinned, false);
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
}
