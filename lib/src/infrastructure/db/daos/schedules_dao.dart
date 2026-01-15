import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'schedules_dao.g.dart';

/// Data access object for scheduled posts.
///
/// Manages CRUD operations for the Schedules table, handling the
/// lifecycle of scheduled post publications.
@DriftAccessor(tables: [Schedules])
class SchedulesDao extends DatabaseAccessor<AppDatabase> with _$SchedulesDaoMixin {
  SchedulesDao(super.db);

  /// Creates or updates a schedule record.
  Future<void> upsertSchedule(SchedulesCompanion entry) {
    return into(schedules).insertOnConflictUpdate(entry);
  }

  /// Gets a schedule by draft ID and owner DID.
  Future<Schedule?> getSchedule(String draftId, String ownerDid) {
    return (select(schedules)
          ..where((tbl) => tbl.draftId.equals(draftId) & tbl.ownerDid.equals(ownerDid)))
        .getSingleOrNull();
  }

  /// Streams a schedule by draft ID and owner DID.
  Stream<Schedule?> watchSchedule(String draftId, String ownerDid) {
    return (select(schedules)
          ..where((tbl) => tbl.draftId.equals(draftId) & tbl.ownerDid.equals(ownerDid)))
        .watchSingleOrNull();
  }

  /// Lists all schedules for a user, ordered by scheduled time.
  Future<List<Schedule>> listSchedules(String ownerDid) {
    return (select(schedules)
          ..where((tbl) => tbl.ownerDid.equals(ownerDid))
          ..orderBy([(s) => OrderingTerm.asc(s.scheduledAtUtc)]))
        .get();
  }

  /// Streams all schedules for a user, ordered by scheduled time.
  Stream<List<Schedule>> watchSchedules(String ownerDid) {
    return (select(schedules)
          ..where((tbl) => tbl.ownerDid.equals(ownerDid))
          ..orderBy([(s) => OrderingTerm.asc(s.scheduledAtUtc)]))
        .watch();
  }

  /// Lists schedules by status for a user.
  Future<List<Schedule>> listSchedulesByStatus(String status, String ownerDid) {
    return (select(schedules)
          ..where((tbl) => tbl.status.equals(status) & tbl.ownerDid.equals(ownerDid))
          ..orderBy([(s) => OrderingTerm.asc(s.scheduledAtUtc)]))
        .get();
  }

  /// Lists schedules that are due for publishing (scheduled time has passed).
  Future<List<Schedule>> listDueSchedules(String ownerDid) {
    final now = DateTime.now().toUtc();
    return (select(schedules)
          ..where(
            (tbl) =>
                tbl.status.equals('scheduled') &
                tbl.scheduledAtUtc.isSmallerThanValue(now) &
                tbl.ownerDid.equals(ownerDid),
          )
          ..orderBy([(s) => OrderingTerm.asc(s.scheduledAtUtc)]))
        .get();
  }

  /// Updates a schedule's status and related fields.
  Future<void> updateScheduleStatus(
    String draftId,
    String ownerDid,
    String status, {
    int? attemptsValue,
    String? lastError,
    String? postedUri,
    String? postedCid,
  }) {
    return (update(
      schedules,
    )..where((tbl) => tbl.draftId.equals(draftId) & tbl.ownerDid.equals(ownerDid))).write(
      SchedulesCompanion(
        status: Value(status),
        attempts: attemptsValue != null ? Value(attemptsValue) : const Value.absent(),
        lastError: lastError != null ? Value(lastError) : const Value.absent(),
        postedUri: postedUri != null ? Value(postedUri) : const Value.absent(),
        postedCid: postedCid != null ? Value(postedCid) : const Value.absent(),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Increments the attempts counter for a schedule.
  Future<void> incrementAttempts(String draftId, String ownerDid) {
    return (update(schedules)
          ..where((tbl) => tbl.draftId.equals(draftId) & tbl.ownerDid.equals(ownerDid)))
        .write(SchedulesCompanion.custom(attempts: schedules.attempts + const Constant(1)));
  }

  /// Deletes a schedule by draft ID and owner DID.
  Future<void> deleteSchedule(String draftId, String ownerDid) {
    return (delete(
      schedules,
    )..where((tbl) => tbl.draftId.equals(draftId) & tbl.ownerDid.equals(ownerDid))).go();
  }

  /// Deletes all schedules with the given status for a user.
  /// Returns the number of schedules deleted.
  Future<int> deleteSchedulesByStatus(String status, String ownerDid) async {
    final deleteQuery = delete(schedules)
      ..where((tbl) => tbl.status.equals(status) & tbl.ownerDid.equals(ownerDid));
    return deleteQuery.go();
  }

  /// Counts schedules by status for a user.
  Future<int> countSchedulesByStatus(String status, String ownerDid) async {
    final count = schedules.draftId.count();
    final result =
        await (selectOnly(schedules)
              ..where(schedules.status.equals(status) & schedules.ownerDid.equals(ownerDid))
              ..addColumns([count]))
            .getSingle();
    return result.read(count) ?? 0;
  }
}
