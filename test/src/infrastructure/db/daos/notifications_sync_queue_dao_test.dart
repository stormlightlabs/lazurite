import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/notifications_sync_queue_dao.dart';

void main() {
  group('NotificationsSyncQueueDao', () {
    late AppDatabase db;
    late NotificationsSyncQueueDao dao;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      dao = NotificationsSyncQueueDao(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('enqueueMarkSeen adds item to queue', () async {
      final now = DateTime.now();
      await dao.enqueueMarkSeen(now);

      final pending = await dao.getRetryableItems();
      expect(pending.length, 1);
      expect(pending.first.type, 'mark_seen');
      expect(pending.first.seenAt, now.toIso8601String());
      expect(pending.first.retryCount, 0);
    });

    test('getRetryableItems returns ordered items', () async {
      final now = DateTime.now();
      final earlier = now.subtract(const Duration(hours: 1));

      await dao.enqueueMarkSeen(earlier);
      await dao.enqueueMarkSeen(now);

      final pending = await dao.getRetryableItems();
      expect(pending.length, 2);
      expect(DateTime.parse(pending[0].seenAt), earlier);
      expect(DateTime.parse(pending[1].seenAt), now);
    });

    test('getLatestSeenAt returns most recent timestamp', () async {
      final now = DateTime.now();
      final earlier = now.subtract(const Duration(hours: 1));
      final earliest = now.subtract(const Duration(hours: 2));

      await dao.enqueueMarkSeen(earliest);
      await dao.enqueueMarkSeen(earlier);
      await dao.enqueueMarkSeen(now);

      final latest = await dao.getLatestSeenAt();
      expect(latest, now);
    });

    test('getLatestSeenAt returns null when queue is empty', () async {
      final latest = await dao.getLatestSeenAt();
      expect(latest, null);
    });

    test('getLatestSeenAt excludes maxed-out retry items', () async {
      final now = DateTime.now();
      final older = now.subtract(const Duration(hours: 1));

      await dao.enqueueMarkSeen(older);

      await db
          .into(db.notificationsSyncQueue)
          .insert(
            NotificationsSyncQueueCompanion.insert(
              type: 'mark_seen',
              seenAt: now.toIso8601String(),
              createdAt: DateTime.now(),
              retryCount: const Value(kMaxNotificationSyncRetries),
            ),
          );

      final latest = await dao.getLatestSeenAt();
      expect(latest, older);
    });

    test('deleteItem removes specific item', () async {
      final now = DateTime.now();
      await dao.enqueueMarkSeen(now);

      var pending = await dao.getRetryableItems();
      final id = pending.first.id;

      await dao.deleteItem(id);

      pending = await dao.getRetryableItems();
      expect(pending, isEmpty);
    });

    test('deleteItemsUpTo removes items with seenAt <= timestamp', () async {
      final now = DateTime.now();
      final earlier = now.subtract(const Duration(hours: 1));
      final earliest = now.subtract(const Duration(hours: 2));
      final later = now.add(const Duration(hours: 1));

      await dao.enqueueMarkSeen(earliest);
      await dao.enqueueMarkSeen(earlier);
      await dao.enqueueMarkSeen(now);
      await dao.enqueueMarkSeen(later);

      await dao.deleteItemsUpTo(now);

      final remaining = await dao.getRetryableItems();
      expect(remaining.length, 1);
      expect(DateTime.parse(remaining.first.seenAt), later);
    });

    test('clearQueue removes all items', () async {
      final now = DateTime.now();
      await dao.enqueueMarkSeen(now);
      await dao.enqueueMarkSeen(now.add(const Duration(hours: 1)));

      await dao.clearQueue();

      final pending = await dao.getRetryableItems();
      expect(pending, isEmpty);
    });

    group('retry limits', () {
      test(
        'getRetryableItems returns only items with retryCount < kMaxNotificationSyncRetries',
        () async {
          final now = DateTime.now();

          await dao.enqueueMarkSeen(now);

          await db
              .into(db.notificationsSyncQueue)
              .insert(
                NotificationsSyncQueueCompanion.insert(
                  type: 'mark_seen',
                  seenAt: now.subtract(const Duration(hours: 1)).toIso8601String(),
                  createdAt: now,
                  retryCount: const Value(4),
                ),
              );

          await db
              .into(db.notificationsSyncQueue)
              .insert(
                NotificationsSyncQueueCompanion.insert(
                  type: 'mark_seen',
                  seenAt: now.subtract(const Duration(hours: 2)).toIso8601String(),
                  createdAt: now,
                  retryCount: const Value(5),
                ),
              );

          final retryable = await dao.getRetryableItems();
          expect(retryable.length, 2);
          expect(retryable.map((r) => r.retryCount), containsAll([0, 4]));
        },
      );

      test('incrementRetryCount updates the retry count', () async {
        final now = DateTime.now();
        final id = await dao.enqueueMarkSeen(now);

        var items = await dao.getRetryableItems();
        expect(items.first.retryCount, 0);

        await dao.incrementRetryCount(id);

        items = await dao.getRetryableItems();
        expect(items.first.retryCount, 1);

        await dao.incrementRetryCount(id);
        await dao.incrementRetryCount(id);

        items = await dao.getRetryableItems();
        expect(items.first.retryCount, 3);
      });

      test('cleanupOldFailedItems removes old permanently failed items', () async {
        final now = DateTime.now();
        final threshold = now.subtract(const Duration(days: 30));

        await db
            .into(db.notificationsSyncQueue)
            .insert(
              NotificationsSyncQueueCompanion.insert(
                type: 'mark_seen',
                seenAt: now.subtract(const Duration(days: 50)).toIso8601String(),
                createdAt: now.subtract(const Duration(days: 45)),
                retryCount: const Value(5),
              ),
            );

        await db
            .into(db.notificationsSyncQueue)
            .insert(
              NotificationsSyncQueueCompanion.insert(
                type: 'mark_seen',
                seenAt: now.subtract(const Duration(days: 50)).toIso8601String(),
                createdAt: now.subtract(const Duration(days: 45)),
                retryCount: const Value(3),
              ),
            );

        await db
            .into(db.notificationsSyncQueue)
            .insert(
              NotificationsSyncQueueCompanion.insert(
                type: 'mark_seen',
                seenAt: now.toIso8601String(),
                createdAt: now.subtract(const Duration(days: 5)),
                retryCount: const Value(5),
              ),
            );

        await dao.enqueueMarkSeen(now);

        final deleted = await dao.cleanupOldFailedItems(threshold);
        expect(deleted, 1);

        final remaining = await dao.getRetryableItems();
        expect(remaining.length, 2);
      });

      test('cleanupOldFailedItems returns 0 when nothing to clean', () async {
        final now = DateTime.now();
        await dao.enqueueMarkSeen(now);

        final deleted = await dao.cleanupOldFailedItems(now.subtract(const Duration(days: 30)));
        expect(deleted, 0);

        final remaining = await dao.getRetryableItems();
        expect(remaining.length, 1);
      });
    });
  });
}
