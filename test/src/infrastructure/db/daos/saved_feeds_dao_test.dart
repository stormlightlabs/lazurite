import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/saved_feeds_dao.dart';

void main() {
  late AppDatabase db;
  late SavedFeedsDao dao;
  const ownerDid = 'did:plc:owner';

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = db.savedFeedsDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('upsertFeed', () {
    test('inserts a new feed', () async {
      final feed = SavedFeedsCompanion.insert(
        uri: 'at://did:plc:abc/app.bsky.feed.generator/test',
        displayName: 'Test Feed',
        creatorDid: 'did:plc:abc',
        ownerDid: ownerDid,
        sortOrder: 0,
        lastSynced: DateTime(2025, 1, 1),
      );

      await dao.upsertFeed(feed);

      final result = await dao.getFeed('at://did:plc:abc/app.bsky.feed.generator/test', ownerDid);
      expect(result, isNotNull);
      expect(result!.displayName, 'Test Feed');
      expect(result.creatorDid, 'did:plc:abc');
      expect(result.sortOrder, 0);
      expect(result.isPinned, false);
    });

    test('updates an existing feed', () async {
      final feed = SavedFeedsCompanion.insert(
        uri: 'at://did:plc:abc/app.bsky.feed.generator/test',
        displayName: 'Test Feed',
        creatorDid: 'did:plc:abc',
        ownerDid: ownerDid,
        sortOrder: 0,
        lastSynced: DateTime(2025, 1, 1),
        likeCount: const Value(10),
      );

      await dao.upsertFeed(feed);

      final updated = SavedFeedsCompanion.insert(
        uri: 'at://did:plc:abc/app.bsky.feed.generator/test',
        displayName: 'Updated Feed',
        creatorDid: 'did:plc:abc',
        ownerDid: ownerDid,
        sortOrder: 1,
        lastSynced: DateTime(2025, 1, 2),
        likeCount: const Value(20),
      );

      await dao.upsertFeed(updated);

      final result = await dao.getFeed('at://did:plc:abc/app.bsky.feed.generator/test', ownerDid);
      expect(result!.displayName, 'Updated Feed');
      expect(result.sortOrder, 1);
      expect(result.likeCount, 20);
    });
  });

  group('upsertFeeds', () {
    test('batch inserts multiple feeds', () async {
      final feeds = [
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/feed1',
          displayName: 'Feed 1',
          creatorDid: 'did:plc:abc',
          ownerDid: ownerDid,
          sortOrder: 0,
          lastSynced: DateTime(2025, 1, 1),
        ),
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:def/app.bsky.feed.generator/feed2',
          displayName: 'Feed 2',
          creatorDid: 'did:plc:def',
          ownerDid: ownerDid,
          sortOrder: 1,
          lastSynced: DateTime(2025, 1, 1),
        ),
      ];

      await dao.upsertFeeds(feeds);

      final result = await dao.getAllFeeds(ownerDid);
      expect(result, hasLength(2));
      expect(result[0].displayName, 'Feed 1');
      expect(result[1].displayName, 'Feed 2');
    });

    test('batch updates existing feeds', () async {
      await dao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/feed1',
          displayName: 'Feed 1',
          creatorDid: 'did:plc:abc',
          ownerDid: ownerDid,
          sortOrder: 0,
          lastSynced: DateTime(2025, 1, 1),
        ),
      );

      final updates = [
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/feed1',
          displayName: 'Updated Feed 1',
          creatorDid: 'did:plc:abc',
          ownerDid: ownerDid,
          sortOrder: 0,
          lastSynced: DateTime(2025, 1, 2),
        ),
      ];

      await dao.upsertFeeds(updates);

      final result = await dao.getFeed('at://did:plc:abc/app.bsky.feed.generator/feed1', ownerDid);
      expect(result!.displayName, 'Updated Feed 1');
    });
  });

  group('deleteFeed', () {
    test('deletes a feed by URI', () async {
      await dao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/test',
          displayName: 'Test Feed',
          creatorDid: 'did:plc:abc',
          ownerDid: ownerDid,
          sortOrder: 0,
          lastSynced: DateTime(2025, 1, 1),
        ),
      );

      final deleted = await dao.deleteFeed(
        'at://did:plc:abc/app.bsky.feed.generator/test',
        ownerDid,
      );
      expect(deleted, 1);

      final result = await dao.getFeed('at://did:plc:abc/app.bsky.feed.generator/test', ownerDid);
      expect(result, isNull);
    });

    test('returns 0 when feed does not exist', () async {
      final deleted = await dao.deleteFeed(
        'at://did:plc:nonexistent/app.bsky.feed.generator/test',
        ownerDid,
      );
      expect(deleted, 0);
    });
  });

  group('deleteAllFeeds', () {
    test('deletes all feeds', () async {
      await dao.upsertFeeds([
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/feed1',
          displayName: 'Feed 1',
          creatorDid: 'did:plc:abc',
          ownerDid: ownerDid,
          sortOrder: 0,
          lastSynced: DateTime(2025, 1, 1),
        ),
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:def/app.bsky.feed.generator/feed2',
          displayName: 'Feed 2',
          creatorDid: 'did:plc:def',
          ownerDid: ownerDid,
          sortOrder: 1,
          lastSynced: DateTime(2025, 1, 1),
        ),
      ]);

      final deleted = await dao.deleteAllFeeds(ownerDid);
      expect(deleted, 2);

      final result = await dao.getAllFeeds(ownerDid);
      expect(result, isEmpty);
    });
  });

  group('getFeed', () {
    test('returns feed by URI', () async {
      await dao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/test',
          displayName: 'Test Feed',
          creatorDid: 'did:plc:abc',
          ownerDid: ownerDid,
          sortOrder: 0,
          lastSynced: DateTime(2025, 1, 1),
        ),
      );

      final result = await dao.getFeed('at://did:plc:abc/app.bsky.feed.generator/test', ownerDid);
      expect(result, isNotNull);
      expect(result!.displayName, 'Test Feed');
    });

    test('returns null when feed does not exist', () async {
      final result = await dao.getFeed(
        'at://did:plc:nonexistent/app.bsky.feed.generator/test',
        ownerDid,
      );
      expect(result, isNull);
    });
  });

  group('watchFeed', () {
    test('watches a feed reactively', () async {
      await dao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/test',
          displayName: 'Test Feed',
          creatorDid: 'did:plc:abc',
          ownerDid: ownerDid,
          sortOrder: 0,
          lastSynced: DateTime(2025, 1, 1),
        ),
      );

      final result = await dao
          .watchFeed('at://did:plc:abc/app.bsky.feed.generator/test', ownerDid)
          .first;
      expect(result, isNotNull);
      expect(result!.displayName, 'Test Feed');
    });

    test('emits null when feed does not exist', () async {
      final result = await dao
          .watchFeed('at://did:plc:nonexistent/app.bsky.feed.generator/test', ownerDid)
          .first;
      expect(result, isNull);
    });
  });

  group('getAllFeeds', () {
    test('returns all feeds ordered by sortOrder', () async {
      await dao.upsertFeeds([
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/feed3',
          displayName: 'Feed 3',
          creatorDid: 'did:plc:abc',
          ownerDid: ownerDid,
          sortOrder: 2,
          lastSynced: DateTime(2025, 1, 1),
        ),
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:def/app.bsky.feed.generator/feed1',
          displayName: 'Feed 1',
          creatorDid: 'did:plc:def',
          ownerDid: ownerDid,
          sortOrder: 0,
          lastSynced: DateTime(2025, 1, 1),
        ),
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:ghi/app.bsky.feed.generator/feed2',
          displayName: 'Feed 2',
          creatorDid: 'did:plc:ghi',
          ownerDid: ownerDid,
          sortOrder: 1,
          lastSynced: DateTime(2025, 1, 1),
        ),
      ]);

      final result = await dao.getAllFeeds(ownerDid);
      expect(result, hasLength(3));
      expect(result[0].displayName, 'Feed 1');
      expect(result[1].displayName, 'Feed 2');
      expect(result[2].displayName, 'Feed 3');
    });

    test('returns empty list when no feeds exist', () async {
      final result = await dao.getAllFeeds(ownerDid);
      expect(result, isEmpty);
    });
  });

  group('watchAllFeeds', () {
    test('watches all feeds reactively ordered by sortOrder', () async {
      await dao.upsertFeeds([
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/feed2',
          displayName: 'Feed 2',
          creatorDid: 'did:plc:abc',
          ownerDid: ownerDid,
          sortOrder: 1,
          lastSynced: DateTime(2025, 1, 1),
        ),
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:def/app.bsky.feed.generator/feed1',
          displayName: 'Feed 1',
          creatorDid: 'did:plc:def',
          ownerDid: ownerDid,
          sortOrder: 0,
          lastSynced: DateTime(2025, 1, 1),
        ),
      ]);

      final result = await dao.watchAllFeeds(ownerDid).first;
      expect(result, hasLength(2));
      expect(result[0].displayName, 'Feed 1');
      expect(result[1].displayName, 'Feed 2');
    });
  });

  group('getPinnedFeeds', () {
    test('returns only pinned feeds ordered by sortOrder', () async {
      await dao.upsertFeeds([
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/feed1',
          displayName: 'Feed 1',
          creatorDid: 'did:plc:abc',
          ownerDid: ownerDid,
          sortOrder: 0,
          isPinned: const Value(true),
          lastSynced: DateTime(2025, 1, 1),
        ),
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:def/app.bsky.feed.generator/feed2',
          displayName: 'Feed 2',
          creatorDid: 'did:plc:def',
          ownerDid: ownerDid,
          sortOrder: 1,
          isPinned: const Value(false),
          lastSynced: DateTime(2025, 1, 1),
        ),
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:ghi/app.bsky.feed.generator/feed3',
          displayName: 'Feed 3',
          creatorDid: 'did:plc:ghi',
          ownerDid: ownerDid,
          sortOrder: 2,
          isPinned: const Value(true),
          lastSynced: DateTime(2025, 1, 1),
        ),
      ]);

      final result = await dao.getPinnedFeeds(ownerDid);
      expect(result, hasLength(2));
      expect(result[0].displayName, 'Feed 1');
      expect(result[1].displayName, 'Feed 3');
    });

    test('returns empty list when no pinned feeds exist', () async {
      await dao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/feed1',
          displayName: 'Feed 1',
          creatorDid: 'did:plc:abc',
          ownerDid: ownerDid,
          sortOrder: 0,
          isPinned: const Value(false),
          lastSynced: DateTime(2025, 1, 1),
        ),
      );

      final result = await dao.getPinnedFeeds(ownerDid);
      expect(result, isEmpty);
    });
  });

  group('watchPinnedFeeds', () {
    test('watches pinned feeds reactively', () async {
      await dao.upsertFeeds([
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/feed1',
          displayName: 'Feed 1',
          creatorDid: 'did:plc:abc',
          ownerDid: ownerDid,
          sortOrder: 0,
          isPinned: const Value(true),
          lastSynced: DateTime(2025, 1, 1),
        ),
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:def/app.bsky.feed.generator/feed2',
          displayName: 'Feed 2',
          creatorDid: 'did:plc:def',
          ownerDid: ownerDid,
          sortOrder: 1,
          isPinned: const Value(false),
          lastSynced: DateTime(2025, 1, 1),
        ),
      ]);

      final result = await dao.watchPinnedFeeds(ownerDid).first;
      expect(result, hasLength(1));
      expect(result[0].displayName, 'Feed 1');
    });
  });

  group('getStaleFeeds', () {
    test('returns feeds older than threshold', () async {
      final now = DateTime(2025, 1, 5);
      final yesterday = DateTime(2025, 1, 4);
      final weekAgo = DateTime(2024, 12, 29);

      await dao.upsertFeeds([
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/fresh',
          displayName: 'Fresh Feed',
          creatorDid: 'did:plc:abc',
          ownerDid: ownerDid,
          sortOrder: 0,
          lastSynced: now,
        ),
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:def/app.bsky.feed.generator/stale1',
          displayName: 'Stale Feed 1',
          creatorDid: 'did:plc:def',
          ownerDid: ownerDid,
          sortOrder: 1,
          lastSynced: yesterday,
        ),
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:ghi/app.bsky.feed.generator/stale2',
          displayName: 'Stale Feed 2',
          creatorDid: 'did:plc:ghi',
          ownerDid: ownerDid,
          sortOrder: 2,
          lastSynced: weekAgo,
        ),
      ]);

      final threshold = DateTime(2025, 1, 4, 12);
      final result = await dao.getStaleFeeds(threshold, ownerDid);

      expect(result, hasLength(2));
      expect(result.any((f) => f.displayName == 'Stale Feed 1'), true);
      expect(result.any((f) => f.displayName == 'Stale Feed 2'), true);
    });

    test('returns empty list when no stale feeds exist', () async {
      await dao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/fresh',
          displayName: 'Fresh Feed',
          creatorDid: 'did:plc:abc',
          ownerDid: ownerDid,
          sortOrder: 0,
          lastSynced: DateTime(2025, 1, 5),
        ),
      );

      final threshold = DateTime(2025, 1, 1);
      final result = await dao.getStaleFeeds(threshold, ownerDid);
      expect(result, isEmpty);
    });
  });

  group('updateSortOrder', () {
    test('updates sortOrder for a feed', () async {
      await dao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/test',
          displayName: 'Test Feed',
          creatorDid: 'did:plc:abc',
          ownerDid: ownerDid,
          sortOrder: 0,
          lastSynced: DateTime(2025, 1, 1),
        ),
      );

      final updated = await dao.updateSortOrder(
        'at://did:plc:abc/app.bsky.feed.generator/test',
        5,
        ownerDid,
      );
      expect(updated, 1);

      final result = await dao.getFeed('at://did:plc:abc/app.bsky.feed.generator/test', ownerDid);
      expect(result!.sortOrder, 5);
    });

    test('returns 0 when feed does not exist', () async {
      final updated = await dao.updateSortOrder(
        'at://did:plc:nonexistent/app.bsky.feed.generator/test',
        5,
        ownerDid,
      );
      expect(updated, 0);
    });
  });

  group('updatePinnedStatus', () {
    test('updates isPinned status for a feed', () async {
      await dao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: 'at://did:plc:abc/app.bsky.feed.generator/test',
          displayName: 'Test Feed',
          creatorDid: 'did:plc:abc',
          ownerDid: ownerDid,
          sortOrder: 0,
          isPinned: const Value(false),
          lastSynced: DateTime(2025, 1, 1),
        ),
      );

      final updated = await dao.updatePinnedStatus(
        'at://did:plc:abc/app.bsky.feed.generator/test',
        true,
        ownerDid,
      );
      expect(updated, 1);

      final result = await dao.getFeed('at://did:plc:abc/app.bsky.feed.generator/test', ownerDid);
      expect(result!.isPinned, true);
    });

    test('returns 0 when feed does not exist', () async {
      final updated = await dao.updatePinnedStatus(
        'at://did:plc:nonexistent/app.bsky.feed.generator/test',
        true,
        ownerDid,
      );
      expect(updated, 0);
    });
  });
}
