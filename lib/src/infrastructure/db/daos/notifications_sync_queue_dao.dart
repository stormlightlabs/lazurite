import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'notifications_sync_queue_dao.g.dart';

/// Maximum number of retries before marking an item as permanently failed.
const int kMaxNotificationSyncRetries = 5;

/// DAO for managing the notification synchronization queue.
///
/// Stores failed mark-as-seen operations for retrying when online.
/// Operations are batched by timestamp - we only need to store the latest
/// seenAt timestamp since marking at timestamp T implicitly marks all
/// notifications before T as seen.
@DriftAccessor(tables: [NotificationsSyncQueue])
class NotificationsSyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationsSyncQueueDaoMixin {
  NotificationsSyncQueueDao(super.db);

  /// Enqueues a mark-as-seen operation for a specific user.
  ///
  /// The [seenAt] timestamp marks all notifications up to that point as seen.
  Future<int> enqueueMarkSeen(DateTime seenAt, String ownerDid) {
    return into(notificationsSyncQueue).insert(
      NotificationsSyncQueueCompanion.insert(
        type: 'mark_seen',
        seenAt: seenAt.toIso8601String(),
        ownerDid: ownerDid,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Get the latest 'seenAt' timestamp from the queue for a user.
  Future<DateTime?> getLatestSeenAt(String ownerDid) async {
    final query = select(notificationsSyncQueue)
      ..where(
        (t) =>
            t.ownerDid.equals(ownerDid) &
            t.retryCount.isSmallerThanValue(kMaxNotificationSyncRetries),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt), (t) => OrderingTerm.desc(t.id)])
      ..limit(1);

    final item = await query.getSingleOrNull();
    if (item == null) return null;
    return DateTime.tryParse(item.seenAt);
  }

  /// Get items that can be retried for a user.
  Future<List<NotificationsSyncQueueData>> getRetryableItems(String ownerDid) {
    return (select(notificationsSyncQueue)
          ..where(
            (t) =>
                t.ownerDid.equals(ownerDid) &
                t.retryCount.isSmallerThanValue(kMaxNotificationSyncRetries),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .get();
  }

  /// Increments the retry count for a specific item.
  Future<int> incrementRetryCount(int id) {
    return (update(notificationsSyncQueue)..where((t) => t.id.equals(id))).write(
      NotificationsSyncQueueCompanion.custom(
        retryCount: notificationsSyncQueue.retryCount + const Constant(1),
      ),
    );
  }

  /// Deletes a specific item from the queue.
  Future<int> deleteItem(int id) {
    return (delete(notificationsSyncQueue)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes all items with seenAt <= the specified timestamp for a specific user.
  ///
  /// Used after successfully syncing to remove obsolete queue items.
  Future<int> deleteItemsUpTo(DateTime seenAt, String ownerDid) {
    return (delete(notificationsSyncQueue)..where(
          (t) =>
              t.seenAt.isSmallerOrEqualValue(seenAt.toIso8601String()) &
              t.ownerDid.equals(ownerDid),
        ))
        .go();
  }

  /// Cleans up old permanently failed items.
  ///
  /// Deletes items with retryCount >= [kMaxNotificationSyncRetries] that are
  /// older than the specified threshold.
  Future<int> cleanupOldFailedItems(DateTime threshold) {
    return (delete(notificationsSyncQueue)..where(
          (t) =>
              t.retryCount.isBiggerOrEqualValue(kMaxNotificationSyncRetries) &
              t.createdAt.isSmallerThanValue(threshold),
        ))
        .go();
  }

  /// Clears the entire queue for a specific user.
  Future<int> clearQueue(String ownerDid) {
    return (delete(notificationsSyncQueue)..where((t) => t.ownerDid.equals(ownerDid))).go();
  }
}
