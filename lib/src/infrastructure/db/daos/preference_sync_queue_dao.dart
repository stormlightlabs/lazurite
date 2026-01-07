import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'preference_sync_queue_dao.g.dart';

/// Maximum number of retries before marking an item as permanently failed.
const int kMaxSyncRetries = 5;

/// DAO for managing the preference synchronization queue.
///
/// Stores failed preference updates for both feed preferences and Bluesky
/// account preferences for retrying when online.
@DriftAccessor(tables: [PreferenceSyncQueue])
class PreferenceSyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$PreferenceSyncQueueDaoMixin {
  PreferenceSyncQueueDao(super.db);

  /// Adds an item to the queue.
  Future<int> enqueue(PreferenceSyncQueueCompanion item) {
    return into(preferenceSyncQueue).insert(item);
  }

  /// Enqueues a feed preference update.
  Future<int> enqueueFeedSync({required String type, required String feedUri}) {
    return enqueue(
      PreferenceSyncQueueCompanion.insert(
        category: const Value('feed'),
        type: type,
        payload: feedUri,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Enqueues a Bluesky preference update.
  ///
  /// The [preferenceType] should be one of: 'adultContent', 'contentLabels',
  /// 'labelers', 'feedView', 'threadView', 'mutedWords'.
  Future<int> enqueueBlueskyPrefSync({
    required String preferenceType,
    required String preferenceData,
  }) {
    return enqueue(
      PreferenceSyncQueueCompanion.insert(
        category: const Value('bluesky_pref'),
        type: preferenceType,
        payload: preferenceData,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Gets all pending items in the queue, ordered by creation time.
  Future<List<PreferenceSyncQueueData>> getPendingItems() {
    return (select(
      preferenceSyncQueue,
    )..orderBy([(t) => OrderingTerm(expression: t.createdAt)])).get();
  }

  /// Gets items that can still be retried (retryCount < [kMaxSyncRetries]).
  Future<List<PreferenceSyncQueueData>> getRetryableItems() {
    return (select(preferenceSyncQueue)
          ..where((t) => t.retryCount.isSmallerThanValue(kMaxSyncRetries))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .get();
  }

  /// Gets retryable feed preference items.
  Future<List<PreferenceSyncQueueData>> getRetryableFeedItems() {
    return (select(preferenceSyncQueue)
          ..where(
            (t) => t.category.equals('feed') & t.retryCount.isSmallerThanValue(kMaxSyncRetries),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .get();
  }

  /// Gets retryable Bluesky preference items.
  Future<List<PreferenceSyncQueueData>> getRetryableBlueskyPrefItems() {
    return (select(preferenceSyncQueue)
          ..where(
            (t) =>
                t.category.equals('bluesky_pref') &
                t.retryCount.isSmallerThanValue(kMaxSyncRetries),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .get();
  }

  /// Increments the retry count for a specific item.
  Future<int> incrementRetryCount(int id) {
    return (update(preferenceSyncQueue)..where((t) => t.id.equals(id))).write(
      PreferenceSyncQueueCompanion.custom(
        retryCount: preferenceSyncQueue.retryCount + const Constant(1),
      ),
    );
  }

  /// Cleans up old permanently failed items.
  ///
  /// Deletes items with retryCount >= [kMaxSyncRetries] that are older than
  /// the specified threshold.
  Future<int> cleanupOldFailedItems(DateTime threshold) {
    return (delete(preferenceSyncQueue)..where(
          (t) =>
              t.retryCount.isBiggerOrEqualValue(kMaxSyncRetries) &
              t.createdAt.isSmallerThanValue(threshold),
        ))
        .go();
  }

  /// Watches all pending items in the queue.
  Stream<List<PreferenceSyncQueueData>> watchPendingItems() {
    return (select(
      preferenceSyncQueue,
    )..orderBy([(t) => OrderingTerm(expression: t.createdAt)])).watch();
  }

  /// Deletes a specific item from the queue.
  Future<int> deleteItem(int id) {
    return (delete(preferenceSyncQueue)..where((t) => t.id.equals(id))).go();
  }

  /// Clears the entire queue.
  Future<int> clearQueue() {
    return delete(preferenceSyncQueue).go();
  }
}
