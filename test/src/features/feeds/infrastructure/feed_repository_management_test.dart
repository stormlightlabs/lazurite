import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

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
          'uri': feedUri,
          'cid': 'bafynew',
          'did': 'did:web:feedgen.test',
          'displayName': 'New Feed',
          'description': 'A new feed',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:abc', 'handle': 'creator.test'},
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
      expect(queue.first.payload, feedUri);
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
          'uri': feedUri,
          'cid': 'bafynew',
          'did': 'did:web:feedgen.test',
          'displayName': 'New Feed',
          'description': 'A new feed',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:abc', 'handle': 'creator.test'},
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
          'uri': feedUri,
          'cid': 'bafynew',
          'did': 'did:web:feedgen.test',
          'displayName': 'New Feed',
          'description': 'A new feed',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:abc', 'handle': 'creator.test'},
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
          'uri': feedUri,
          'cid': 'bafynew',
          'did': 'did:web:feedgen.test',
          'displayName': 'New Feed',
          'description': 'A new feed',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:abc', 'handle': 'creator.test'},
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

  group('reorderFeeds', () {
    test('updates local sortOrder for feeds', () async {
      const feed1 = 'at://did:plc:abc/app.bsky.feed.generator/a';
      const feed2 = 'at://did:plc:def/app.bsky.feed.generator/b';
      const feed3 = 'at://did:plc:ghi/app.bsky.feed.generator/c';

      await db.savedFeedsDao.upsertFeeds([
        SavedFeedsCompanion.insert(
          uri: feed1,
          displayName: 'Feed A',
          creatorDid: 'did:plc:abc',
          sortOrder: 0,
          lastSynced: DateTime.now(),
        ),
        SavedFeedsCompanion.insert(
          uri: feed2,
          displayName: 'Feed B',
          creatorDid: 'did:plc:def',
          sortOrder: 1,
          lastSynced: DateTime.now(),
        ),
        SavedFeedsCompanion.insert(
          uri: feed3,
          displayName: 'Feed C',
          creatorDid: 'did:plc:ghi',
          sortOrder: 2,
          lastSynced: DateTime.now(),
        ),
      ]);

      const currentPrefs = {
        'preferences': [
          {
            '\$type': 'app.bsky.actor.defs#savedFeedsPref',
            'saved': [feed1, feed2, feed3],
            'pinned': [],
          },
        ],
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => currentPrefs);

      when(
        () => mockApi.call('app.bsky.actor.putPreferences', body: any(named: 'body')),
      ).thenAnswer((_) async => {});

      await repository.reorderFeeds([feed3, feed1, feed2]);

      final feeds = await db.savedFeedsDao.getAllFeeds();
      expect(feeds[0].uri, feed3);
      expect(feeds[0].sortOrder, 0);
      expect(feeds[1].uri, feed1);
      expect(feeds[1].sortOrder, 1);
      expect(feeds[2].uri, feed2);
      expect(feeds[2].sortOrder, 2);
    });

    test('syncs reordering to remote preferences', () async {
      const feed1 = 'at://did:plc:abc/app.bsky.feed.generator/a';
      const feed2 = 'at://did:plc:def/app.bsky.feed.generator/b';

      await db.savedFeedsDao.upsertFeeds([
        SavedFeedsCompanion.insert(
          uri: feed1,
          displayName: 'Feed A',
          creatorDid: 'did:plc:abc',
          sortOrder: 0,
          lastSynced: DateTime.now(),
        ),
        SavedFeedsCompanion.insert(
          uri: feed2,
          displayName: 'Feed B',
          creatorDid: 'did:plc:def',
          sortOrder: 1,
          lastSynced: DateTime.now(),
        ),
      ]);

      const currentPrefs = {
        'preferences': [
          {
            '\$type': 'app.bsky.actor.defs#savedFeedsPref',
            'saved': [feed1, feed2],
            'pinned': [feed1],
          },
        ],
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => currentPrefs);

      when(
        () => mockApi.call('app.bsky.actor.putPreferences', body: any(named: 'body')),
      ).thenAnswer((_) async => {});

      await repository.reorderFeeds([feed2, feed1]);

      verify(
        () => mockApi.call(
          'app.bsky.actor.putPreferences',
          body: {
            'preferences': [
              {
                '\$type': 'app.bsky.actor.defs#savedFeedsPref',
                'saved': [feed2, feed1],
                'pinned': [feed1],
              },
            ],
          },
        ),
      ).called(1);
    });

    test('queues reorder operation on network failure', () async {
      const feed1 = 'at://did:plc:abc/app.bsky.feed.generator/a';
      const feed2 = 'at://did:plc:def/app.bsky.feed.generator/b';

      await db.savedFeedsDao.upsertFeeds([
        SavedFeedsCompanion.insert(
          uri: feed1,
          displayName: 'Feed A',
          creatorDid: 'did:plc:abc',
          sortOrder: 0,
          lastSynced: DateTime.now(),
        ),
        SavedFeedsCompanion.insert(
          uri: feed2,
          displayName: 'Feed B',
          creatorDid: 'did:plc:def',
          sortOrder: 1,
          lastSynced: DateTime.now(),
        ),
      ]);

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenThrow(Exception('Network error'));

      await repository.reorderFeeds([feed2, feed1]);

      final feeds = await db.savedFeedsDao.getAllFeeds();
      expect(feeds[0].uri, feed2);
      expect(feeds[1].uri, feed1);

      final queue = await db.preferenceSyncQueueDao.getPendingItems();
      expect(queue, hasLength(1));
      expect(queue.first.type, 'reorder');
      expect(queue.first.payload, '$feed2,$feed1');
    });

    test('throws when unauthenticated', () async {
      when(() => mockApi.isAuthenticated).thenReturn(false);

      expect(
        () => repository.reorderFeeds(['at://did:plc:abc/app.bsky.feed.generator/test']),
        throwsA(isA<Exception>()),
      );
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
          'uri': validUri,
          'cid': 'bafyvalid',
          'did': 'did:web:feedgen.test',
          'displayName': 'Valid Feed',
          'description': 'A valid feed',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:abc123xyz', 'handle': 'creator.test'},
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
}
