import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lazurite/src/core/infrastructure/notifications/notification_initializer.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/scheduling/domain/schedule.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/scheduler.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:lazurite/src/infrastructure/db/daos/schedules_dao.dart';
import 'package:timezone/timezone.dart' as tz;

/// Notification-based scheduler implementation.
///
/// This scheduler uses local notifications to trigger post publishing.
/// When the scheduled time arrives, a notification is shown to the user.
/// Tapping the notification deep-links to the scheduled post detail screen
/// where the user can choose to publish, edit, or cancel the schedule.
///
/// This approach provides reliable scheduling within mobile OS limitations
/// and gives the user control over when the post is actually published.
class NotificationScheduler implements Scheduler {
  NotificationScheduler({
    required SchedulesDao schedulesDao,
    required SessionStorage sessionStorage,
    required Logger logger,
    FlutterLocalNotificationsPlugin? plugin,
  }) : _schedulesDao = schedulesDao,
       _sessionStorage = sessionStorage,
       _logger = logger,
       _plugin = plugin;

  final SchedulesDao _schedulesDao;
  final SessionStorage _sessionStorage;
  final Logger _logger;
  final FlutterLocalNotificationsPlugin? _plugin;

  FlutterLocalNotificationsPlugin get _notificationsPlugin =>
      _plugin ?? NotificationInitializer.instance.plugin;

  static const _notificationChannelId = 'scheduled_posts';
  static const _notificationIdBase = 1000000;

  @override
  Future<bool> schedule(String draftId, DateTime scheduledAtUtc) async {
    try {
      final session = await _sessionStorage.getSession();
      if (session == null) {
        _logger.warning('Cannot schedule notification: no active session');
        return false;
      }

      final scheduledTz = _convertUtcToLocal(scheduledAtUtc);
      final now = tz.TZDateTime.now(scheduledTz.location);

      if (scheduledTz.isBefore(now)) {
        _logger.warning('Scheduled time is in the past: $scheduledAtUtc');
        return false;
      }

      final notificationId = _generateNotificationId(draftId);
      final plugin = _notificationsPlugin;

      const androidDetails = AndroidNotificationDetails(
        _notificationChannelId,
        'Scheduled Posts',
        channelDescription: 'Notifications for scheduled posts',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await plugin.zonedSchedule(
        id: notificationId,
        scheduledDate: scheduledTz,
        notificationDetails: notificationDetails,
        payload: 'draft:$draftId',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      _logger.info('Scheduled notification for draft $draftId at $scheduledAtUtc');
      return true;
    } catch (e, stack) {
      _logger.error('Failed to schedule notification for draft $draftId', e, stack);
      return false;
    }
  }

  @override
  Future<bool> cancel(String draftId) async {
    try {
      final notificationId = _generateNotificationId(draftId);
      final plugin = _notificationsPlugin;

      await plugin.cancel(id: notificationId);

      _logger.info('Cancelled notification for draft $draftId');
      return true;
    } catch (e, stack) {
      _logger.error('Failed to cancel notification for draft $draftId', e, stack);
      return false;
    }
  }

  @override
  Future<void> resyncAll() async {
    try {
      final session = await _sessionStorage.getSession();
      if (session == null) {
        _logger.warning('Cannot resync notifications: no active session');
        return;
      }

      final schedules = await _schedulesDao.listSchedulesByStatus(
        ScheduleStatus.scheduled.name,
        session.did,
      );

      _logger.info('Resyncing ${schedules.length} scheduled notifications');

      for (final schedule in schedules) {
        final scheduledAt = schedule.scheduledAtUtc;
        final scheduledTz = _convertUtcToLocal(scheduledAt);
        final now = tz.TZDateTime.now(scheduledTz.location);

        if (scheduledTz.isBefore(now.add(const Duration(minutes: 1)))) {
          _logger.info('Skipping past notification for draft ${schedule.draftId}');
          continue;
        }

        await this.schedule(schedule.draftId, scheduledAt);
      }

      _logger.info('Resynced scheduled notifications');
    } catch (e, stack) {
      _logger.error('Failed to resync notifications', e, stack);
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
      _logger.info('Cancelled all scheduled notifications');
    } catch (e, stack) {
      _logger.error('Failed to cancel all scheduled notifications', e, stack);
    }
  }

  /// Generates a consistent notification ID from a draft ID.
  int _generateNotificationId(String draftId) => _notificationIdBase + draftId.hashCode.abs();

  /// Converts a UTC DateTime to the user's local timezone.
  tz.TZDateTime _convertUtcToLocal(DateTime utcDateTime) {
    final local = tz.getLocation(tz.local.name);
    return tz.TZDateTime.from(utcDateTime, local);
  }
}
