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

  /// Enqueues a mark-as-seen operation.
  ///
  /// The [seenAt] timestamp marks all notifications up to that point as seen.
  Future<int> enqueueMarkSeen(DateTime seenAt) {
    return into(notificationsSyncQueue).insert(
      NotificationsSyncQueueCompanion.insert(
        type: 'mark_seen',
        seenAt: seenAt.toIso8601String(),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Gets all retryable items (retryCount < [kMaxNotificationSyncRetries]).
  ///
  /// Returns items ordered by creation time (oldest first).
  Future<List<NotificationsSyncQueueData>> getRetryableItems() {
    return (select(notificationsSyncQueue)
          ..where((t) => t.retryCount.isSmallerThanValue(kMaxNotificationSyncRetries))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .get();
  }

  /// Gets the latest seenAt timestamp from the queue.
  ///
  /// Returns null if queue is empty. This allows batching multiple failed
  /// operations into a single retry with the most recent timestamp.
  Future<DateTime?> getLatestSeenAt() async {
    final items = await getRetryableItems();
    if (items.isEmpty) {
      return null;
    }

    DateTime? latest;
    for (final item in items) {
      final timestamp = DateTime.parse(item.seenAt);
      if (latest == null || timestamp.isAfter(latest)) {
        latest = timestamp;
      }
    }
    return latest;
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

  /// Deletes all items with seenAt <= the specified timestamp.
  ///
  /// Used after successfully syncing to remove obsolete queue items.
  Future<int> deleteItemsUpTo(DateTime seenAt) {
    return (delete(
      notificationsSyncQueue,
    )..where((t) => t.seenAt.isSmallerOrEqualValue(seenAt.toIso8601String()))).go();
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

  /// Clears the entire queue.
  Future<int> clearQueue() {
    return delete(notificationsSyncQueue).go();
  }
}
