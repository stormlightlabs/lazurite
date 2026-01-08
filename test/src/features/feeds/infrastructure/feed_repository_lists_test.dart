import 'package:drift/drift.dart' hide isNotNull, isNull;
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
  const ownerDid = 'did:web:tester';

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

  group('getListMetadata', () {
    test('fetches and parses list metadata correctly', () async {
      const listUri = 'at://did:plc:abc123/app.bsky.graph.list/testlist';
      final apiResponse = {
        'list': {
          'uri': listUri,
          'cid': 'bafyreiabc123',
          'creator': {
            'did': 'did:plc:abc123',
            'handle': 'creator.bsky.social',
            'displayName': 'Creator',
          },
          'name': 'Test List',
          'purpose': 'app.bsky.graph.defs#curatelist',
          'description': 'A curated list of interesting accounts',
          'avatar': 'https://example.com/list-avatar.jpg',
          'listItemCount': 42,
          'indexedAt': '2024-01-15T10:30:00Z',
        },
      };

      when(
        () => mockApi.call('app.bsky.graph.getList', params: {'list': listUri}),
      ).thenAnswer((_) async => apiResponse);

      final listView = await repository.getListMetadata(listUri);

      expect(listView.uri, listUri);
      expect(listView.cid, 'bafyreiabc123');
      expect(listView.creator.did, 'did:plc:abc123');
      expect(listView.creator.handle, 'creator.bsky.social');
      expect(listView.name, 'Test List');
      expect(listView.purpose, 'app.bsky.graph.defs#curatelist');
      expect(listView.description, 'A curated list of interesting accounts');
      expect(listView.avatar, 'https://example.com/list-avatar.jpg');
      expect(listView.listItemCount, 42);
    });

    test('throws FormatException when API response is invalid', () async {
      const listUri = 'at://did:plc:abc123/app.bsky.graph.list/testlist';
      final apiResponse = {'list': 'not a map'};

      when(
        () => mockApi.call('app.bsky.graph.getList', params: {'list': listUri}),
      ).thenAnswer((_) async => apiResponse);

      expect(() => repository.getListMetadata(listUri), throwsA(isA<FormatException>()));
    });

    test('rethrows API errors', () async {
      const listUri = 'at://did:plc:abc123/app.bsky.graph.list/testlist';

      when(
        () => mockApi.call('app.bsky.graph.getList', params: {'list': listUri}),
      ).thenThrow(Exception('Network error'));

      expect(() => repository.getListMetadata(listUri), throwsA(isA<Exception>()));
    });
  });

  group('syncPreferences with lists', () {
    test('syncs list feeds from preferences and hydrates with metadata', () async {
      const prefsResponse = {
        'preferences': [
          {
            '\$type': 'app.bsky.actor.defs#savedFeedsPref',
            'saved': [
              'at://did:plc:abc/app.bsky.graph.list/mylist',
              'at://did:plc:def/app.bsky.feed.generator/test',
            ],
            'pinned': ['at://did:plc:abc/app.bsky.graph.list/mylist'],
          },
        ],
      };

      final listMetadata = {
        'list': {
          'uri': 'at://did:plc:abc/app.bsky.graph.list/mylist',
          'cid': 'bafytest1',
          'creator': {'did': 'did:plc:abc', 'handle': 'creator.test'},
          'name': 'My List',
          'purpose': 'app.bsky.graph.defs#curatelist',
          'description': 'A test list',
          'avatar': 'avatar1.jpg',
          'listItemCount': 10,
        },
      };

      final feedMetadata = {
        'uri': 'at://did:plc:def/app.bsky.feed.generator/test',
        'cid': 'bafytest2',
        'did': 'did:web:feedgen.test',
        'displayName': 'Test Feed',
        'description': 'A test feed',
        'avatar': 'avatar2.jpg',
        'creator': {'did': 'did:plc:def', 'handle': 'creator2.test'},
        'likeCount': 50,
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => prefsResponse);

      when(
        () => mockApi.call(
          'app.bsky.graph.getList',
          params: {'list': 'at://did:plc:abc/app.bsky.graph.list/mylist'},
        ),
      ).thenAnswer((_) async => listMetadata);

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerators', params: any(named: 'params')),
      ).thenAnswer(
        (_) async => {
          'feeds': [feedMetadata],
        },
      );

      await repository.syncPreferences(ownerDid);

      final feeds = await db.savedFeedsDao.getAllFeeds(ownerDid);
      expect(feeds, hasLength(2));

      final list = feeds.firstWhere((f) => f.uri == 'at://did:plc:abc/app.bsky.graph.list/mylist');
      expect(list.displayName, 'My List');
      expect(list.description, 'A test list');
      expect(list.isPinned, isTrue);
      expect(list.creatorDid, 'did:plc:abc');
      expect(list.likeCount, 10);

      final feed = feeds.firstWhere(
        (f) => f.uri == 'at://did:plc:def/app.bsky.feed.generator/test',
      );
      expect(feed.displayName, 'Test Feed');
      expect(feed.isPinned, isFalse);
    });
  });

  group('syncPreferences with special feeds', () {
    test('syncs special feed "following" from preferences', () async {
      const prefsResponse = {
        'preferences': [
          {
            '\$type': 'app.bsky.actor.defs#savedFeedsPref',
            'saved': ['following', 'at://did:plc:def/app.bsky.feed.generator/test'],
            'pinned': ['following'],
          },
        ],
      };

      final feedMetadata = {
        'uri': 'at://did:plc:def/app.bsky.feed.generator/test',
        'cid': 'bafytest',
        'did': 'did:web:feedgen.test',
        'displayName': 'Test Feed',
        'creator': {'did': 'did:plc:def', 'handle': 'creator.test'},
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => prefsResponse);

      when(
        () => mockApi.call('app.bsky.feed.getFeedGenerators', params: any(named: 'params')),
      ).thenAnswer(
        (_) async => {
          'feeds': [feedMetadata],
        },
      );

      await repository.syncPreferences(ownerDid);

      final feeds = await db.savedFeedsDao.getAllFeeds(ownerDid);
      expect(feeds, hasLength(2));

      final followingFeed = feeds.firstWhere((f) => f.uri == 'following');
      expect(followingFeed.displayName, 'Following');
      expect(followingFeed.description, 'Posts from people you follow');
      expect(followingFeed.isPinned, isTrue);
      expect(followingFeed.creatorDid, '');
      expect(followingFeed.avatar, isNull);
    });

    test('syncs special feed "timeline" from preferences', () async {
      const prefsResponse = {
        'preferences': [
          {
            '\$type': 'app.bsky.actor.defs#savedFeedsPref',
            'saved': ['timeline'],
            'pinned': [],
          },
        ],
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => prefsResponse);

      await repository.syncPreferences(ownerDid);

      final feeds = await db.savedFeedsDao.getAllFeeds(ownerDid);
      expect(feeds, hasLength(1));

      final timelineFeed = feeds.first;
      expect(timelineFeed.uri, 'timeline');
      expect(timelineFeed.displayName, 'Home');
      expect(timelineFeed.description, 'Your home timeline');
      expect(timelineFeed.isPinned, isFalse);
    });

    test('updates existing special feed when remote is newer', () async {
      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: 'following',
          displayName: 'Following',
          creatorDid: '',
          sortOrder: 0,
          isPinned: const Value(false),
          lastSynced: DateTime.now().subtract(const Duration(days: 1)),
          localUpdatedAt: const Value(null),
          ownerDid: ownerDid,
        ),
      );

      const prefsResponse = {
        'preferences': [
          {
            '\$type': 'app.bsky.actor.defs#savedFeedsPref',
            'saved': ['following'],
            'pinned': ['following'],
          },
        ],
      };

      when(
        () => mockApi.call('app.bsky.actor.getPreferences'),
      ).thenAnswer((_) async => prefsResponse);

      await repository.syncPreferences(ownerDid);

      final feeds = await db.savedFeedsDao.getAllFeeds(ownerDid);
      expect(feeds, hasLength(1));

      final followingFeed = feeds.first;
      expect(followingFeed.isPinned, isTrue);
    });
  });

  group('refreshStaleMetadata with lists and special feeds', () {
    test('refreshes stale list metadata', () async {
      final now = DateTime.now();
      final staleTimestamp = now.subtract(const Duration(hours: 25));

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.graph.list/mylist',
          displayName: 'Old Name',
          creatorDid: 'did:plc:abc',
          sortOrder: 0,
          lastSynced: staleTimestamp,
          ownerDid: ownerDid,
        ),
      );

      final listMetadata = {
        'list': {
          'uri': 'at://did:plc:abc/app.bsky.graph.list/mylist',
          'cid': 'bafytest',
          'creator': {'did': 'did:plc:abc', 'handle': 'creator.test'},
          'name': 'Updated List Name',
          'purpose': 'app.bsky.graph.defs#curatelist',
          'description': 'Updated description',
          'listItemCount': 20,
        },
      };

      when(
        () => mockApi.call(
          'app.bsky.graph.getList',
          params: {'list': 'at://did:plc:abc/app.bsky.graph.list/mylist'},
        ),
      ).thenAnswer((_) async => listMetadata);

      await repository.refreshStaleMetadata(ownerDid);

      final feeds = await db.savedFeedsDao.getAllFeeds(ownerDid);
      expect(feeds, hasLength(1));

      final list = feeds.first;
      expect(list.displayName, 'Updated List Name');
      expect(list.description, 'Updated description');
      expect(list.likeCount, 20);
    });

    test('skips special feeds during metadata refresh', () async {
      final now = DateTime.now();
      final staleTimestamp = now.subtract(const Duration(hours: 25));

      await db.savedFeedsDao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: 'following',
          displayName: 'Following',
          creatorDid: '',
          sortOrder: 0,
          lastSynced: staleTimestamp,
          ownerDid: ownerDid,
        ),
      );

      await repository.refreshStaleMetadata(ownerDid);

      verifyNever(() => mockApi.call('app.bsky.graph.getList', params: any(named: 'params')));
      verifyNever(
        () => mockApi.call('app.bsky.feed.getFeedGenerator', params: any(named: 'params')),
      );
    });

    test('refreshes mix of feed generators and lists correctly', () async {
      final now = DateTime.now();
      final staleTimestamp = now.subtract(const Duration(hours: 25));

      await db.savedFeedsDao.upsertFeeds([
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.graph.list/mylist',
          displayName: 'Old List Name',
          creatorDid: 'did:plc:abc',
          sortOrder: 0,
          lastSynced: staleTimestamp,
          ownerDid: ownerDid,
        ),
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:def/app.bsky.feed.generator/test',
          displayName: 'Old Feed Name',
          creatorDid: 'did:plc:def',
          sortOrder: 1,
          lastSynced: staleTimestamp,
          ownerDid: ownerDid,
        ),
      ]);

      final listMetadata = {
        'list': {
          'uri': 'at://did:plc:abc/app.bsky.graph.list/mylist',
          'cid': 'bafytest1',
          'creator': {'did': 'did:plc:abc', 'handle': 'creator.test'},
          'name': 'Updated List',
          'purpose': 'app.bsky.graph.defs#curatelist',
          'listItemCount': 15,
        },
      };

      final feedMetadata = {
        'view': {
          'uri': 'at://did:plc:def/app.bsky.feed.generator/test',
          'cid': 'bafytest2',
          'did': 'did:web:feedgen.test',
          'displayName': 'Updated Feed',
          'creator': {'did': 'did:plc:def', 'handle': 'creator2.test'},
          'likeCount': 100,
        },
      };

      when(
        () => mockApi.call(
          'app.bsky.graph.getList',
          params: {'list': 'at://did:plc:abc/app.bsky.graph.list/mylist'},
        ),
      ).thenAnswer((_) async => listMetadata);

      when(
        () => mockApi.call(
          'app.bsky.feed.getFeedGenerator',
          params: {'feed': 'at://did:plc:def/app.bsky.feed.generator/test'},
        ),
      ).thenAnswer((_) async => feedMetadata);

      await repository.refreshStaleMetadata(ownerDid);

      final feeds = await db.savedFeedsDao.getAllFeeds(ownerDid);
      expect(feeds, hasLength(2));

      final list = feeds.firstWhere((f) => f.uri == 'at://did:plc:abc/app.bsky.graph.list/mylist');
      expect(list.displayName, 'Updated List');
      expect(list.likeCount, 15);

      final feed = feeds.firstWhere(
        (f) => f.uri == 'at://did:plc:def/app.bsky.feed.generator/test',
      );
      expect(feed.displayName, 'Updated Feed');
      expect(feed.likeCount, 100);
    });
  });
}
