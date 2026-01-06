import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/preference_sync_queue_dao.dart';

void main() {
  group('PreferenceSyncQueueDao', () {
    late AppDatabase db;
    late PreferenceSyncQueueDao dao;

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
        PreferenceSyncQueueCompanion.insert(type: 'save', feedUri: 'at://test', createdAt: now),
      );

      final pending = await dao.getPendingItems();
      expect(pending.length, 1);
      expect(pending.first.type, 'save');
      expect(pending.first.feedUri, 'at://test');
    });

    test('getPendingItems returns ordered items', () async {
      final now = DateTime.now();
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(type: 'save', feedUri: 'first', createdAt: now),
      );
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(
          type: 'remove',
          feedUri: 'second',
          createdAt: now.add(const Duration(seconds: 1)),
        ),
      );

      final pending = await dao.getPendingItems();
      expect(pending.length, 2);
      expect(pending[0].feedUri, 'first');
      expect(pending[1].feedUri, 'second');
    });

    test('deleteItem removes specific item', () async {
      final now = DateTime.now();
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(type: 'save', feedUri: 'at://test', createdAt: now),
      );

      var pending = await dao.getPendingItems();
      final id = pending.first.id;

      await dao.deleteItem(id);

      pending = await dao.getPendingItems();
      expect(pending, isEmpty);
    });

    test('clearQueue removes all items', timeout: const Timeout(Duration(seconds: 5)), () async {
      final now = DateTime.now();
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(type: 'save', feedUri: '1', createdAt: now),
      );
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(type: 'save', feedUri: '2', createdAt: now),
      );

      await dao.clearQueue();

      final pending = await dao.getPendingItems();
      expect(pending, isEmpty);
    });

    group('retry limits', () {
      test('getRetryableItems returns only items with retryCount < kMaxSyncRetries', () async {
        final now = DateTime.now();

        await dao.enqueue(
          PreferenceSyncQueueCompanion.insert(
            type: 'save',
            feedUri: 'at://retryable',
            createdAt: now,
          ),
        );

        await db
            .into(db.preferenceSyncQueue)
            .insert(
              PreferenceSyncQueueCompanion.insert(
                type: 'save',
                feedUri: 'at://almost-maxed',
                createdAt: now,
                retryCount: const Value(4),
              ),
            );

        await db
            .into(db.preferenceSyncQueue)
            .insert(
              PreferenceSyncQueueCompanion.insert(
                type: 'save',
                feedUri: 'at://maxed-out',
                createdAt: now,
                retryCount: const Value(5),
              ),
            );

        final retryable = await dao.getRetryableItems();
        expect(retryable.length, 2);
        expect(
          retryable.map((r) => r.feedUri),
          containsAll(['at://retryable', 'at://almost-maxed']),
        );
        expect(retryable.map((r) => r.feedUri), isNot(contains('at://maxed-out')));
      });

      test('incrementRetryCount updates the retry count', () async {
        final now = DateTime.now();
        final id = await dao.enqueue(
          PreferenceSyncQueueCompanion.insert(type: 'save', feedUri: 'at://test', createdAt: now),
        );

        var items = await dao.getPendingItems();
        expect(items.first.retryCount, 0);

        await dao.incrementRetryCount(id);

        items = await dao.getPendingItems();
        expect(items.first.retryCount, 1);

        await dao.incrementRetryCount(id);
        await dao.incrementRetryCount(id);

        items = await dao.getPendingItems();
        expect(items.first.retryCount, 3);
      });

      test('cleanupOldFailedItems removes old permanently failed items', () async {
        final now = DateTime.now();
        final threshold = now.subtract(const Duration(days: 30));

        await db
            .into(db.preferenceSyncQueue)
            .insert(
              PreferenceSyncQueueCompanion.insert(
                type: 'save',
                feedUri: 'at://old-failed',
                createdAt: now.subtract(const Duration(days: 45)),
                retryCount: const Value(5),
              ),
            );

        await db
            .into(db.preferenceSyncQueue)
            .insert(
              PreferenceSyncQueueCompanion.insert(
                type: 'save',
                feedUri: 'at://old-retryable',
                createdAt: now.subtract(const Duration(days: 45)),
                retryCount: const Value(3),
              ),
            );

        await db
            .into(db.preferenceSyncQueue)
            .insert(
              PreferenceSyncQueueCompanion.insert(
                type: 'save',
                feedUri: 'at://recent-failed',
                createdAt: now.subtract(const Duration(days: 5)),
                retryCount: const Value(5),
              ),
            );

        await dao.enqueue(
          PreferenceSyncQueueCompanion.insert(
            type: 'save',
            feedUri: 'at://new-item',
            createdAt: now,
          ),
        );

        final deleted = await dao.cleanupOldFailedItems(threshold);
        expect(deleted, 1);

        final remaining = await dao.getPendingItems();
        expect(remaining.length, 3);
        expect(
          remaining.map((r) => r.feedUri),
          containsAll(['at://old-retryable', 'at://recent-failed', 'at://new-item']),
        );
        expect(remaining.map((r) => r.feedUri), isNot(contains('at://old-failed')));
      });

      test('cleanupOldFailedItems returns 0 when nothing to clean', () async {
        final now = DateTime.now();
        await dao.enqueue(
          PreferenceSyncQueueCompanion.insert(type: 'save', feedUri: 'at://test', createdAt: now),
        );

        final deleted = await dao.cleanupOldFailedItems(now.subtract(const Duration(days: 30)));
        expect(deleted, 0);

        final remaining = await dao.getPendingItems();
        expect(remaining.length, 1);
      });
    });
  });
}
