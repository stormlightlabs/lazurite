import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/scheduling/domain/schedule.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/scheduler.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:lazurite/src/infrastructure/db/daos/schedules_dao.dart';
import 'package:workmanager/workmanager.dart';

/// Background task-based scheduler implementation using Workmanager.
///
/// This scheduler uses the system's job scheduler (WorkManager on Android,
/// BGTaskScheduler on iOS) to trigger post publishing in the background,
/// even when the app is not running.
class WorkmanagerScheduler implements Scheduler {
  WorkmanagerScheduler({
    required SchedulesDao schedulesDao,
    required SessionStorage sessionStorage,
    required Logger logger,
    Workmanager? workmanager,
  }) : _schedulesDao = schedulesDao,
       _sessionStorage = sessionStorage,
       _logger = logger,
       _workmanager = workmanager ?? Workmanager();

  final SchedulesDao _schedulesDao;
  final SessionStorage _sessionStorage;
  final Logger _logger;
  final Workmanager _workmanager;

  static const String taskName = 'com.lazurite.bsky.post_publish';
  static const String tagPrefix = 'scheduled_post_';

  @override
  Future<bool> schedule(String draftId, DateTime scheduledAtUtc) async {
    try {
      final now = DateTime.now().toUtc();
      final initialDelay = scheduledAtUtc.difference(now);

      if (initialDelay.isNegative) {
        _logger.warning('Scheduled time is in the past: $scheduledAtUtc');
        return false;
      }

      final uniqueName = _getUniqueName(draftId);
      final tag = _getTag(draftId);

      await _workmanager.registerOneOffTask(
        uniqueName,
        taskName,
        tag: tag,
        initialDelay: initialDelay,
        inputData: {'draftId': draftId},
        constraints: Constraints(networkType: NetworkType.connected),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 5),
      );

      _logger.info(
        'Registered background task for draft $draftId at $scheduledAtUtc (delay: $initialDelay)',
      );
      return true;
    } catch (e, stack) {
      _logger.error('Failed to register background task for draft $draftId', e, stack);
      return false;
    }
  }

  @override
  Future<bool> cancel(String draftId) async {
    try {
      final uniqueName = _getUniqueName(draftId);
      await _workmanager.cancelByUniqueName(uniqueName);

      _logger.info('Cancelled background task for draft $draftId');
      return true;
    } catch (e, stack) {
      _logger.error('Failed to cancel background task for draft $draftId', e, stack);
      return false;
    }
  }

  @override
  Future<void> resyncAll() async {
    try {
      final session = await _sessionStorage.getSession();
      if (session == null) {
        _logger.warning('Cannot resync background tasks: no active session');
        return;
      }

      final schedules = await _schedulesDao.listSchedulesByStatus(
        ScheduleStatus.scheduled.name,
        session.did,
      );

      _logger.info('Resyncing ${schedules.length} background tasks');

      for (final schedule in schedules) {
        await this.schedule(schedule.draftId, schedule.scheduledAtUtc);
      }

      _logger.info('Resynced background tasks');
    } catch (e, stack) {
      _logger.error('Failed to resync background tasks', e, stack);
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _workmanager.cancelAll();
      _logger.info('Cancelled all background tasks');
    } catch (e, stack) {
      _logger.error('Failed to cancel all background tasks', e, stack);
    }
  }

  String _getUniqueName(String draftId) => 'task_$draftId';
  String _getTag(String draftId) => '$tagPrefix$draftId';
}
