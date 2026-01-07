import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/preference_sync_queue_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

class MockXrpcClient extends Mock implements XrpcClient {}

class MockLogger extends Mock implements Logger {}

class _FailingPreferenceSyncQueueDao extends PreferenceSyncQueueDao {
  _FailingPreferenceSyncQueueDao(super.db);

  @override
  Future<int> enqueue(PreferenceSyncQueueCompanion item) {
    throw Exception('Simulated queue enqueue failure');
  }
}

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
          'uri': 'at://did:plc:abc/app.bsky.feed.generator/test1',
          'cid': 'bafytest1',
          'did': 'did:web:feedgen.test1',
          'displayName': 'Test Feed 1',
          'description': 'Description 1',
          'avatar': 'avatar1.jpg',
          'creator': {'did': 'did:plc:abc', 'handle': 'creator1.test'},
          'likeCount': 100,
        },
      };

      final feed2Metadata = {
        'view': {
          'uri': 'at://did:plc:def/app.bsky.feed.generator/test2',
          'cid': 'bafytest2',
          'did': 'did:web:feedgen.test2',
          'displayName': 'Test Feed 2',
          'description': 'Description 2',
          'avatar': 'avatar2.jpg',
          'creator': {'did': 'did:plc:def', 'handle': 'creator2.test'},
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
          'uri': 'at://did:plc:def/app.bsky.feed.generator/test2',
          'cid': 'bafytest2',
          'did': 'did:web:feedgen.test2',
          'displayName': 'Test Feed 2',
          'description': 'Description 2',
          'avatar': 'avatar2.jpg',
          'creator': {'did': 'did:plc:def', 'handle': 'creator2.test'},
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

  group('Transaction Atomicity', () {
    test('saveFeed creates queue entry atomically with local update', () async {
      const feedUri = 'at://did:plc:test/app.bsky.feed.generator/atomic';

      final feedMetadata = {
        'view': {
          'uri': feedUri,
          'cid': 'bafyatomic',
          'did': 'did:web:feedgen.test',
          'displayName': 'Atomic Feed',
          'description': 'Test atomic operations',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:test', 'handle': 'test.user'},
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
      expect(queueItems[0].payload, feedUri);
      expect(queueItems[0].type, 'save');
    });

    test('saveFeed removes queue entry on successful remote sync', () async {
      const feedUri = 'at://did:plc:success/app.bsky.feed.generator/sync';

      final currentPrefs = {'preferences': <Map<String, dynamic>>[]};

      final feedMetadata = {
        'view': {
          'uri': feedUri,
          'cid': 'bafysuccess',
          'did': 'did:web:feedgen.test',
          'displayName': 'Success Feed',
          'description': 'Successful sync test',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:success', 'handle': 'success.user'},
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
      expect(queueItems[0].payload, feedUri);
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

    test('rolls back local save when queue enqueue fails', () async {
      const feedUri = 'at://did:plc:fail/app.bsky.feed.generator/rollback';

      final failingRepo = FeedRepository(
        mockApi,
        db.savedFeedsDao,
        _FailingPreferenceSyncQueueDao(db),
        db.profileDao,
        mockLogger,
      );

      final feedMetadata = {
        'view': {
          'uri': feedUri,
          'cid': 'bafyrollback',
          'did': 'did:web:feedgen.rollback',
          'displayName': 'Rollback Feed',
          'description': 'Should not persist when queue fails',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:fail', 'handle': 'rollback.user'},
          'likeCount': 1,
        },
      };

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: {'feed': feedUri}),
      ).thenAnswer((_) async => feedMetadata);

      expect(() => failingRepo.saveFeed(feedUri), throwsA(isA<Exception>()));

      final feed = await db.savedFeedsDao.getFeed(feedUri);
      expect(feed, isNull, reason: 'Local insert should be rolled back');

      final queueItems = await db.preferenceSyncQueueDao.getPendingItems();
      expect(queueItems, isEmpty, reason: 'Queue should remain empty on failure');
    });
  });

  group('Sync Queue Retry Limits', () {
    test('processSyncQueue increments retry count on failure', () async {
      const feedUri = 'at://did:plc:test/app.bsky.feed.generator/retry-test';
      final now = DateTime.now();

      await db.preferenceSyncQueueDao.enqueue(
        PreferenceSyncQueueCompanion.insert(
          category: const Value('feed'),
          type: 'save',
          payload: feedUri,
          createdAt: now,
        ),
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
              category: const Value('feed'),
              type: 'save',
              payload: feedUri,
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
              category: const Value('feed'),
              type: 'save',
              payload: 'at://did:plc:test/app.bsky.feed.generator/old-failed',
              createdAt: now.subtract(const Duration(days: 45)),
              retryCount: const Value(5),
            ),
          );

      await db.preferenceSyncQueueDao.enqueue(
        PreferenceSyncQueueCompanion.insert(
          category: const Value('feed'),
          type: 'save',
          payload: 'at://did:plc:test/app.bsky.feed.generator/recent',
          createdAt: now,
        ),
      );

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenThrow(Exception('Network error'));

      await repository.syncOnResume();

      final items = await db.preferenceSyncQueueDao.getPendingItems();
      expect(items.length, 1);
      expect(items.first.payload, 'at://did:plc:test/app.bsky.feed.generator/recent');
    });

    test('processSyncQueue processes only retryable items', () async {
      final now = DateTime.now();

      await db.preferenceSyncQueueDao.enqueue(
        PreferenceSyncQueueCompanion.insert(
          category: const Value('feed'),
          type: 'save',
          payload: 'at://did:plc:ok/app.bsky.feed.generator/retryable',
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
              category: const Value('feed'),
              type: 'save',
              payload: 'at://did:plc:fail/app.bsky.feed.generator/maxed',
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
      expect(items.first.payload, 'at://did:plc:fail/app.bsky.feed.generator/maxed');
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
      expect(queue.any((q) => q.payload == feedUri && q.type == 'save'), true);
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
          'uri': newFeedUri,
          'cid': 'bafynew',
          'did': 'did:web:feedgen.test',
          'displayName': 'New Remote Feed',
          'description': 'Added on another device',
          'avatar': 'avatar.jpg',
          'creator': {'did': 'did:plc:new', 'handle': 'new.user'},
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
        queue.any((q) => q.payload == localOnlyFeedUri && q.type == 'save'),
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
