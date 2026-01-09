import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/notifications_sync_queue_dao.dart';

void main() {
  group('NotificationsSyncQueueDao', () {
    late AppDatabase db;
    late NotificationsSyncQueueDao dao;
    const ownerDid = 'did:web:tester';

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      dao = NotificationsSyncQueueDao(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('enqueueMarkSeen adds item to queue', () async {
      final now = DateTime.now();
      await dao.enqueueMarkSeen(now, ownerDid);

      final pending = await dao.getRetryableItems(ownerDid);
      expect(pending.length, 1);
      expect(pending.first.type, 'mark_seen');
      expect(pending.first.seenAt, now.toIso8601String());
      expect(pending.first.retryCount, 0);
    });

    test('getRetryableItems returns ordered items', () async {
      final now = DateTime.now();
      final earlier = now.subtract(const Duration(hours: 1));

      await dao.enqueueMarkSeen(earlier, ownerDid);
      await dao.enqueueMarkSeen(now, ownerDid);

      final pending = await dao.getRetryableItems(ownerDid);
      expect(pending.length, 2);
      expect(DateTime.parse(pending[0].seenAt), earlier);
      expect(DateTime.parse(pending[1].seenAt), now);
    });

    test('getLatestSeenAt returns most recent timestamp', () async {
      final now = DateTime.now().toUtc();
      final nowRound = now.copyWith(microsecond: 0);

      final earlier = nowRound.subtract(const Duration(hours: 1));
      final earliest = nowRound.subtract(const Duration(hours: 2));

      await dao.enqueueMarkSeen(earliest, ownerDid);
      await dao.enqueueMarkSeen(earlier, ownerDid);
      await dao.enqueueMarkSeen(nowRound, ownerDid);

      final latest = await dao.getLatestSeenAt(ownerDid);

      expect(latest?.toUtc(), nowRound);
    });

    test('getLatestSeenAt returns null when queue is empty', () async {
      final latest = await dao.getLatestSeenAt(ownerDid);
      expect(latest, null);
    });

    test('getLatestSeenAt excludes maxed-out retry items', () async {
      final now = DateTime.now().toUtc();
      final nowRound = now.copyWith(microsecond: 0);
      final older = nowRound.subtract(const Duration(hours: 1));

      await dao.enqueueMarkSeen(older, ownerDid);

      await db
          .into(db.notificationsSyncQueue)
          .insert(
            NotificationsSyncQueueCompanion.insert(
              type: 'mark_seen',
              seenAt: nowRound.toIso8601String(),
              createdAt: DateTime.now(),
              retryCount: const Value(kMaxNotificationSyncRetries),
              ownerDid: ownerDid,
            ),
          );

      final latest = await dao.getLatestSeenAt(ownerDid);
      expect(latest?.toUtc(), older);
    });

    test('deleteItem removes specific item', () async {
      final now = DateTime.now();
      await dao.enqueueMarkSeen(now, ownerDid);

      var pending = await dao.getRetryableItems(ownerDid);
      final id = pending.first.id;

      await dao.deleteItem(id);

      pending = await dao.getRetryableItems(ownerDid);
      expect(pending, isEmpty);
    });

    test('deleteItemsUpTo removes items with seenAt <= timestamp', () async {
      final now = DateTime.now();
      final earlier = now.subtract(const Duration(hours: 1));
      final earliest = now.subtract(const Duration(hours: 2));
      final later = now.add(const Duration(hours: 1));

      await dao.enqueueMarkSeen(earliest, ownerDid);
      await dao.enqueueMarkSeen(earlier, ownerDid);
      await dao.enqueueMarkSeen(now, ownerDid);
      await dao.enqueueMarkSeen(later, ownerDid);

      await dao.deleteItemsUpTo(now, ownerDid);

      final remaining = await dao.getRetryableItems(ownerDid);
      expect(remaining.length, 1);
      expect(DateTime.parse(remaining.first.seenAt), later);
    });

    test('clearQueue removes all items', () async {
      final now = DateTime.now();
      await dao.enqueueMarkSeen(now, ownerDid);
      await dao.enqueueMarkSeen(now.add(const Duration(hours: 1)), ownerDid);

      await dao.clearQueue(ownerDid);

      final pending = await dao.getRetryableItems(ownerDid);
      expect(pending, isEmpty);
    });

    group('retry limits', () {
      test(
        'getRetryableItems returns only items with retryCount < kMaxNotificationSyncRetries',
        () async {
          final now = DateTime.now();

          await dao.enqueueMarkSeen(now, ownerDid);

          await db
              .into(db.notificationsSyncQueue)
              .insert(
                NotificationsSyncQueueCompanion.insert(
                  type: 'mark_seen',
                  seenAt: now.subtract(const Duration(hours: 1)).toIso8601String(),
                  createdAt: now,
                  retryCount: const Value(4),
                  ownerDid: ownerDid,
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
                  ownerDid: ownerDid,
                ),
              );

          final retryable = await dao.getRetryableItems(ownerDid);
          expect(retryable.length, 2);
          expect(retryable.map((r) => r.retryCount), containsAll([0, 4]));
        },
      );

      test('incrementRetryCount updates the retry count', () async {
        final now = DateTime.now();
        final id = await dao.enqueueMarkSeen(now, ownerDid);

        var items = await dao.getRetryableItems(ownerDid);
        expect(items.first.retryCount, 0);

        await dao.incrementRetryCount(id);

        items = await dao.getRetryableItems(ownerDid);
        expect(items.first.retryCount, 1);

        await dao.incrementRetryCount(id);
        await dao.incrementRetryCount(id);

        items = await dao.getRetryableItems(ownerDid);
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
                ownerDid: ownerDid,
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
                ownerDid: ownerDid,
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
                ownerDid: ownerDid,
              ),
            );

        await dao.enqueueMarkSeen(now, ownerDid);

        final deleted = await dao.cleanupOldFailedItems(threshold, ownerDid);
        expect(deleted, 1);

        final remaining = await dao.getRetryableItems(ownerDid);
        expect(remaining.length, 2);
      });

      test('cleanupOldFailedItems returns 0 when nothing to clean', () async {
        final now = DateTime.now();
        await dao.enqueueMarkSeen(now, ownerDid);

        final deleted = await dao.cleanupOldFailedItems(
          now.subtract(const Duration(days: 30)),
          ownerDid,
        );
        expect(deleted, 0);

        final remaining = await dao.getRetryableItems(ownerDid);
        expect(remaining.length, 1);
      });
    });
  });
}
