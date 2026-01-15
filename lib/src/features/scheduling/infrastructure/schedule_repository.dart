import 'package:drift/drift.dart' show Value;
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart' as db;
import 'package:lazurite/src/infrastructure/db/daos/schedules_dao.dart';
import 'package:lazurite/src/features/scheduling/domain/schedule.dart';

/// Repository for managing scheduled posts.
///
/// Provides application-layer operations for creating, retrieving, updating,
/// and canceling scheduled post publications.
class ScheduleRepository {
  ScheduleRepository({
    required SchedulesDao dao,
    required SessionStorage sessionStorage,
    required Logger logger,
  }) : _dao = dao,
       _sessionStorage = sessionStorage,
       _logger = logger;

  final SchedulesDao _dao;
  final SessionStorage _sessionStorage;
  final Logger _logger;

  /// Creates or updates a schedule for a draft.
  Future<void> upsertSchedule({required String draftId, required DateTime scheduledAtUtc}) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    final now = DateTime.now().toUtc();

    await _dao.upsertSchedule(
      db.SchedulesCompanion(
        draftId: Value(draftId),
        ownerDid: Value(ownerDid),
        scheduledAtUtc: Value(scheduledAtUtc.toUtc()),
        status: Value(ScheduleStatus.scheduled.name),
        attempts: const Value(0),
        lastError: const Value(null),
        postedUri: const Value(null),
        postedCid: const Value(null),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    _logger.info('Schedule upserted for draft $draftId at $scheduledAtUtc');
  }

  /// Gets a schedule by draft ID.
  Future<Schedule?> getSchedule(String draftId) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    final data = await _dao.getSchedule(draftId, ownerDid);
    if (data == null) return null;
    return _toDomain(data);
  }

  /// Streams a schedule by draft ID.
  Stream<Schedule?> watchSchedule(String draftId) async* {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    yield* _dao
        .watchSchedule(draftId, ownerDid)
        .map((data) => data == null ? null : _toDomain(data));
  }

  /// Lists all schedules for the current user.
  Future<List<Schedule>> listSchedules() async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    final data = await _dao.listSchedules(ownerDid);
    return data.map(_toDomain).toList();
  }

  /// Streams all schedules for the current user.
  Stream<List<Schedule>> watchSchedules() async* {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    yield* _dao.watchSchedules(ownerDid).map((data) => data.map(_toDomain).toList());
  }

  /// Lists schedules by status for the current user.
  Future<List<Schedule>> listSchedulesByStatus(ScheduleStatus status) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    final data = await _dao.listSchedulesByStatus(status.name, ownerDid);
    return data.map(_toDomain).toList();
  }

  /// Lists schedules that are due for publishing.
  Future<List<Schedule>> listDueSchedules() async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    final data = await _dao.listDueSchedules(ownerDid);
    return data.map(_toDomain).toList();
  }

  /// Updates a schedule's status.
  Future<void> updateScheduleStatus(
    String draftId,
    ScheduleStatus status, {
    int? attempts,
    String? lastError,
    String? postedUri,
    String? postedCid,
  }) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;

    await _dao.updateScheduleStatus(
      draftId,
      ownerDid,
      status.name,
      attemptsValue: attempts,
      lastError: lastError,
      postedUri: postedUri,
      postedCid: postedCid,
    );

    _logger.info('Schedule status updated for draft $draftId to ${status.name}');
  }

  /// Marks a schedule as posting.
  Future<void> markAsPublishing(String draftId) async {
    await updateScheduleStatus(draftId, ScheduleStatus.posting);
  }

  /// Marks a schedule as successfully posted.
  Future<void> markAsPosted(String draftId, String uri, String cid) async {
    await updateScheduleStatus(draftId, ScheduleStatus.posted, postedUri: uri, postedCid: cid);
  }

  /// Marks a schedule as failed with an error message.
  Future<void> markAsFailed(String draftId, String error) async {
    final schedule = await getSchedule(draftId);
    final attempts = (schedule?.attempts ?? 0) + 1;
    await updateScheduleStatus(
      draftId,
      ScheduleStatus.failed,
      attempts: attempts,
      lastError: error,
    );
  }

  /// Increments the attempts counter for a schedule.
  Future<void> incrementAttempts(String draftId) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    await _dao.incrementAttempts(draftId, ownerDid);
  }

  /// Cancels (deletes) a schedule.
  Future<void> cancelSchedule(String draftId) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    await _dao.deleteSchedule(draftId, ownerDid);
    _logger.info('Schedule cancelled for draft $draftId');
  }

  /// Deletes all schedules with the given status.
  /// Returns the number of schedules deleted.
  Future<int> deleteSchedulesByStatus(ScheduleStatus status) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    final count = await _dao.deleteSchedulesByStatus(status.name, ownerDid);
    _logger.info('Deleted $count schedules with status ${status.name}');
    return count;
  }

  /// Counts schedules by status for the current user.
  Future<int> countSchedulesByStatus(ScheduleStatus status) async {
    final session = await _sessionStorage.getSession();
    final ownerDid = session!.did;
    return _dao.countSchedulesByStatus(status.name, ownerDid);
  }

  /// Converts a database Schedule to a domain Schedule.
  Schedule _toDomain(db.Schedule data) {
    return Schedule(
      draftId: data.draftId,
      ownerDid: data.ownerDid,
      scheduledAtUtc: data.scheduledAtUtc,
      status: scheduleStatusFromString(data.status),
      attempts: data.attempts,
      lastError: data.lastError,
      postedUri: data.postedUri,
      postedCid: data.postedCid,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
