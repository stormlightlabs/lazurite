import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'dm_outbox_dao.g.dart';

/// DAO for managing the DM outbox queue.
///
/// Handles queuing messages for reliable delivery with retry support.
/// Messages are stored here until successfully sent to the server.
@DriftAccessor(tables: [DmOutbox])
class DmOutboxDao extends DatabaseAccessor<AppDatabase> with _$DmOutboxDaoMixin {
  DmOutboxDao(super.db);

  /// Adds a message to the outbox queue.
  Future<void> enqueue(DmOutboxCompanion item) async {
    await into(dmOutbox).insert(item);
  }

  /// Gets a stream of all pending outbox items.
  Stream<List<DmOutboxData>> watchPending() {
    return (select(dmOutbox)
          ..where((o) => o.status.isIn(['pending', 'sending']))
          ..orderBy([(o) => OrderingTerm.asc(o.createdAt)]))
        .watch();
  }

  /// Gets all pending outbox items, oldest first.
  Future<List<DmOutboxData>> getPending() async {
    return (select(dmOutbox)
          ..where((o) => o.status.equals('pending'))
          ..orderBy([(o) => OrderingTerm.asc(o.createdAt)]))
        .get();
  }

  /// Gets all failed outbox items.
  Future<List<DmOutboxData>> getFailed() async {
    return (select(dmOutbox)
          ..where((o) => o.status.equals('failed'))
          ..orderBy([(o) => OrderingTerm.desc(o.lastAttemptAt)]))
        .get();
  }

  /// Gets an outbox item by ID.
  Future<DmOutboxData?> getById(String outboxId) async {
    return (select(dmOutbox)..where((o) => o.outboxId.equals(outboxId))).getSingleOrNull();
  }

  /// Gets pending outbox items for a specific conversation.
  Future<List<DmOutboxData>> getByConvo(String convoId) async {
    return (select(dmOutbox)
          ..where((o) => o.convoId.equals(convoId) & o.status.isIn(['pending', 'sending']))
          ..orderBy([(o) => OrderingTerm.asc(o.createdAt)]))
        .get();
  }

  /// Updates the status of an outbox item.
  Future<void> updateStatus({
    required String outboxId,
    required String status,
    String? errorMessage,
  }) async {
    await (update(dmOutbox)..where((o) => o.outboxId.equals(outboxId))).write(
      DmOutboxCompanion(
        status: Value(status),
        lastAttemptAt: Value(DateTime.now()),
        errorMessage: Value(errorMessage),
      ),
    );
  }

  /// Increments the retry count for an outbox item.
  Future<void> incrementRetryCount(String outboxId) async {
    final item = await getById(outboxId);
    if (item == null) return;

    await (update(dmOutbox)..where((o) => o.outboxId.equals(outboxId))).write(
      DmOutboxCompanion(
        retryCount: Value(item.retryCount + 1),
        lastAttemptAt: Value(DateTime.now()),
      ),
    );
  }

  /// Resets an item for retry (resets status to pending, keeps retry count).
  Future<void> resetForRetry(String outboxId) async {
    await (update(dmOutbox)..where((o) => o.outboxId.equals(outboxId))).write(
      const DmOutboxCompanion(status: Value('pending'), errorMessage: Value(null)),
    );
  }

  /// Deletes an outbox item (after successful send).
  Future<int> deleteItem(String outboxId) async {
    return (delete(dmOutbox)..where((o) => o.outboxId.equals(outboxId))).go();
  }

  /// Clears all outbox items.
  Future<void> clearOutbox() async {
    await delete(dmOutbox).go();
  }

  /// Counts pending items.
  Future<int> countPending() async {
    final count = dmOutbox.outboxId.count();
    final query = selectOnly(dmOutbox)..addColumns([count]);
    query.where(dmOutbox.status.equals('pending'));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
