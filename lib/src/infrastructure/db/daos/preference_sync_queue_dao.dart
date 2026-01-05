import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'preference_sync_queue_dao.g.dart';

/// DAO for managing the preference synchronization queue.
///
/// Stores failed preference updates (save/remove feed) for retrying when online.
@DriftAccessor(tables: [PreferenceSyncQueue])
class PreferenceSyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$PreferenceSyncQueueDaoMixin {
  PreferenceSyncQueueDao(super.db);

  /// Adds an item to the queue.
  Future<int> enqueue(PreferenceSyncQueueCompanion item) {
    return into(preferenceSyncQueue).insert(item);
  }

  /// Gets all pending items in the queue, ordered by creation time.
  Future<List<PreferenceSyncQueueData>> getPendingItems() {
    return (select(
      preferenceSyncQueue,
    )..orderBy([(t) => OrderingTerm(expression: t.createdAt)])).get();
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
