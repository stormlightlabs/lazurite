import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/preference_sync_queue_dao.dart';

void main() {
  group('PreferenceSyncQueueDao', () {
    late AppDatabase db;
    late PreferenceSyncQueueDao dao;
    const ownerDid = 'did:web:tester';

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      dao = PreferenceSyncQueueDao(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('enqueue adds item to queue', () async {
      final now = DateTime.now();
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(
          category: const Value('feed'),
          type: 'save',
          payload: 'at://test',
          createdAt: now,
          ownerDid: ownerDid,
        ),
      );

      final pending = await dao.getPendingItems(ownerDid);
      expect(pending.length, 1);
      expect(pending.first.category, 'feed');
      expect(pending.first.type, 'save');
      expect(pending.first.payload, 'at://test');
    });

    test('enqueueFeedSync adds feed item with correct category', () async {
      await dao.enqueueFeedSync(type: 'save', feedUri: 'at://test-feed', ownerDid: ownerDid);

      final pending = await dao.getPendingItems(ownerDid);
      expect(pending.length, 1);
      expect(pending.first.category, 'feed');
      expect(pending.first.type, 'save');
      expect(pending.first.payload, 'at://test-feed');
    });

    test('enqueueBlueskyPrefSync adds preference item with correct category', () async {
      await dao.enqueueBlueskyPrefSync(
        preferenceType: 'adultContent',
        preferenceData: '{"enabled": true}',
        ownerDid: ownerDid,
      );

      final pending = await dao.getPendingItems(ownerDid);
      expect(pending.length, 1);
      expect(pending.first.category, 'bluesky_pref');
      expect(pending.first.type, 'adultContent');
      expect(pending.first.payload, '{"enabled": true}');
    });

    test('getPendingItems returns ordered items', () async {
      final now = DateTime.now();
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(
          category: const Value('feed'),
          type: 'save',
          payload: 'first',
          createdAt: now,
          ownerDid: ownerDid,
        ),
      );
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(
          category: const Value('feed'),
          type: 'remove',
          payload: 'second',
          createdAt: now.add(const Duration(seconds: 1)),
          ownerDid: ownerDid,
        ),
      );

      final pending = await dao.getPendingItems(ownerDid);
      expect(pending.length, 2);
      expect(pending[0].payload, 'first');
      expect(pending[1].payload, 'second');
    });

    test('deleteItem removes specific item', () async {
      final now = DateTime.now();
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(
          category: const Value('feed'),
          type: 'save',
          payload: 'at://test',
          createdAt: now,
          ownerDid: ownerDid,
        ),
      );

      var pending = await dao.getPendingItems(ownerDid);
      final id = pending.first.id;

      await dao.deleteItem(id);

      pending = await dao.getPendingItems(ownerDid);
      expect(pending, isEmpty);
    });

    test('clearQueue removes all items', timeout: const Timeout(Duration(seconds: 5)), () async {
      final now = DateTime.now();
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(
          category: const Value('feed'),
          type: 'save',
          payload: '1',
          createdAt: now,
          ownerDid: ownerDid,
        ),
      );
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(
          category: const Value('feed'),
          type: 'save',
          payload: '2',
          createdAt: now,
          ownerDid: ownerDid,
        ),
      );

      await dao.clearQueue(ownerDid);

      final pending = await dao.getPendingItems(ownerDid);
      expect(pending, isEmpty);
    });

    group('retry limits', () {
      test('getRetryableItems returns only items with retryCount < kMaxSyncRetries', () async {
        final now = DateTime.now();

        await dao.enqueue(
          PreferenceSyncQueueCompanion.insert(
            category: const Value('feed'),
            type: 'save',
            payload: 'at://retryable',
            createdAt: now,
            ownerDid: ownerDid,
          ),
        );

        await db
            .into(db.preferenceSyncQueue)
            .insert(
              PreferenceSyncQueueCompanion.insert(
                category: const Value('feed'),
                type: 'save',
                payload: 'at://almost-maxed',
                createdAt: now,
                retryCount: const Value(4),
                ownerDid: ownerDid,
              ),
            );

        await db
            .into(db.preferenceSyncQueue)
            .insert(
              PreferenceSyncQueueCompanion.insert(
                category: const Value('feed'),
                type: 'save',
                payload: 'at://maxed-out',
                createdAt: now,
                retryCount: const Value(5),
                ownerDid: ownerDid,
              ),
            );

        final retryable = await dao.getRetryableItems(ownerDid);
        expect(retryable.length, 2);
        expect(
          retryable.map((r) => r.payload),
          containsAll(['at://retryable', 'at://almost-maxed']),
        );
        expect(retryable.map((r) => r.payload), isNot(contains('at://maxed-out')));
      });

      test('getRetryableFeedItems filters by feed category', () async {
        await dao.enqueueFeedSync(type: 'save', feedUri: 'at://feed1', ownerDid: ownerDid);
        await dao.enqueueFeedSync(type: 'remove', feedUri: 'at://feed2', ownerDid: ownerDid);
        await dao.enqueueBlueskyPrefSync(
          preferenceType: 'adultContent',
          preferenceData: '{"enabled": true}',
          ownerDid: ownerDid,
        );

        final feedItems = await dao.getRetryableFeedItems(ownerDid);
        expect(feedItems.length, 2);
        expect(feedItems.every((item) => item.category == 'feed'), true);
        expect(feedItems.map((r) => r.payload), containsAll(['at://feed1', 'at://feed2']));
      });

      test('getRetryableBlueskyPrefItems filters by bluesky_pref category', () async {
        await dao.enqueueFeedSync(type: 'save', feedUri: 'at://feed1', ownerDid: ownerDid);
        await dao.enqueueBlueskyPrefSync(
          preferenceType: 'adultContent',
          preferenceData: '{"enabled": true}',
          ownerDid: ownerDid,
        );
        await dao.enqueueBlueskyPrefSync(
          preferenceType: 'contentLabels',
          preferenceData: '[]',
          ownerDid: ownerDid,
        );

        final prefItems = await dao.getRetryableBlueskyPrefItems(ownerDid);
        expect(prefItems.length, 2);
        expect(prefItems.every((item) => item.category == 'bluesky_pref'), true);
        expect(prefItems.map((r) => r.payload), containsAll(['{"enabled": true}', '[]']));
      });

      test('incrementRetryCount updates the retry count', () async {
        final now = DateTime.now();
        final id = await dao.enqueue(
          PreferenceSyncQueueCompanion.insert(
            category: const Value('feed'),
            type: 'save',
            payload: 'at://test',
            createdAt: now,
            ownerDid: ownerDid,
          ),
        );

        var items = await dao.getPendingItems(ownerDid);
        expect(items.first.retryCount, 0);

        await dao.incrementRetryCount(id);

        items = await dao.getPendingItems(ownerDid);
        expect(items.first.retryCount, 1);

        await dao.incrementRetryCount(id);
        await dao.incrementRetryCount(id);

        items = await dao.getPendingItems(ownerDid);
        expect(items.first.retryCount, 3);
      });

      test('cleanupOldFailedItems removes old permanently failed items', () async {
        final now = DateTime.now();
        final threshold = now.subtract(const Duration(days: 30));

        await db
            .into(db.preferenceSyncQueue)
            .insert(
              PreferenceSyncQueueCompanion.insert(
                category: const Value('feed'),
                type: 'save',
                payload: 'at://old-failed',
                createdAt: now.subtract(const Duration(days: 45)),
                retryCount: const Value(5),
                ownerDid: ownerDid,
              ),
            );

        await db
            .into(db.preferenceSyncQueue)
            .insert(
              PreferenceSyncQueueCompanion.insert(
                category: const Value('feed'),
                type: 'save',
                payload: 'at://old-retryable',
                createdAt: now.subtract(const Duration(days: 45)),
                retryCount: const Value(3),
                ownerDid: ownerDid,
              ),
            );

        await db
            .into(db.preferenceSyncQueue)
            .insert(
              PreferenceSyncQueueCompanion.insert(
                category: const Value('feed'),
                type: 'save',
                payload: 'at://recent-failed',
                createdAt: now.subtract(const Duration(days: 5)),
                retryCount: const Value(5),
                ownerDid: ownerDid,
              ),
            );

        await dao.enqueue(
          PreferenceSyncQueueCompanion.insert(
            category: const Value('feed'),
            type: 'save',
            payload: 'at://new-item',
            createdAt: now,
            ownerDid: ownerDid,
          ),
        );

        final deleted = await dao.cleanupOldFailedItems(threshold, ownerDid);
        expect(deleted, 1);

        final remaining = await dao.getPendingItems(ownerDid);
        expect(remaining.length, 3);
        expect(
          remaining.map((r) => r.payload),
          containsAll(['at://old-retryable', 'at://recent-failed', 'at://new-item']),
        );
        expect(remaining.map((r) => r.payload), isNot(contains('at://old-failed')));
      });

      test('cleanupOldFailedItems returns 0 when nothing to clean', () async {
        final now = DateTime.now();
        await dao.enqueue(
          PreferenceSyncQueueCompanion.insert(
            category: const Value('feed'),
            type: 'save',
            payload: 'at://test',
            createdAt: now,
            ownerDid: ownerDid,
          ),
        );

        final deleted = await dao.cleanupOldFailedItems(now.subtract(const Duration(days: 30)), ownerDid);
        expect(deleted, 0);

        final remaining = await dao.getPendingItems(ownerDid);
        expect(remaining.length, 1);
      });
    });
  });
}
