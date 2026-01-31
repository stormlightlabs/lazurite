import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/composer/application/composer_providers.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/notification_scheduler.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/post_publisher.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/schedule_repository.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/scheduler.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/workmanager_scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scheduling_providers.g.dart';

/// Provides the notification-based scheduler implementation.
///
/// This is the default scheduler for the app, using local notifications
/// to trigger post publishing at scheduled times.
@Riverpod(keepAlive: true)
NotificationScheduler notificationScheduler(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final sessionStorage = ref.watch(sessionStorageProvider);
  final logger = ref.watch(loggerProvider('NotificationScheduler'));

  return NotificationScheduler(
    schedulesDao: db.schedulesDao,
    sessionStorage: sessionStorage,
    logger: logger,
  );
}

/// Provides the background task-based scheduler implementation.
@Riverpod(keepAlive: true)
WorkmanagerScheduler workmanagerScheduler(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final sessionStorage = ref.watch(sessionStorageProvider);
  final logger = ref.watch(loggerProvider('WorkmanagerScheduler'));

  return WorkmanagerScheduler(
    schedulesDao: db.schedulesDao,
    sessionStorage: sessionStorage,
    logger: logger,
  );
}

/// Manages the "Auto-post scheduled drafts" setting.
///
/// When enabled, scheduled posts are automatically published in the background.
/// When disabled (default), the app shows a notification when it's time to publish.
@riverpod
class AutoPostEnabled extends _$AutoPostEnabled {
  static const _key = 'auto_post_enabled';

  @override
  Future<bool> build() async {
    final db = ref.watch(appDatabaseProvider);
    final value = await db.localSettingsDao.get(_key);
    return value == 'true';
  }

  /// Toggles the auto-post setting.
  Future<void> toggle() async {
    final current = await future;
    final db = ref.read(appDatabaseProvider);
    await db.localSettingsDao.set(_key, (!current).toString());
    ref.invalidateSelf();
  }
}

/// Provides the active scheduler instance.
///
/// Returns [WorkmanagerScheduler] if auto-post is enabled,
/// otherwise returns [NotificationScheduler].
@Riverpod(keepAlive: true)
Scheduler scheduler(Ref ref) {
  final autoPostEnabled = ref.watch(autoPostEnabledProvider).value ?? false;

  if (autoPostEnabled) {
    return ref.watch(workmanagerSchedulerProvider);
  } else {
    return ref.watch(notificationSchedulerProvider);
  }
}

/// Provides the post publisher service.
///
/// This service handles the actual publishing of scheduled drafts,
/// including session refresh, record creation, and status updates.
@Riverpod(keepAlive: true)
PostPublisher postPublisher(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final sessionStorage = ref.watch(sessionStorageProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final draftRepository = ref.watch(draftRepositoryProvider);
  final logger = ref.watch(loggerProvider('PostPublisher'));

  return PostPublisher(
    draftsDao: db.draftsDao,
    schedulesDao: db.schedulesDao,
    sessionStorage: sessionStorage,
    authRepository: authRepository,
    draftRepository: draftRepository,
    logger: logger,
  );
}

/// Provides the schedule repository.
///
/// This repository handles database operations for scheduled posts,
/// including CRUD operations and status management.
@Riverpod(keepAlive: true)
ScheduleRepository scheduleRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final sessionStorage = ref.watch(sessionStorageProvider);
  final logger = ref.watch(loggerProvider('ScheduleRepository'));

  return ScheduleRepository(dao: db.schedulesDao, sessionStorage: sessionStorage, logger: logger);
}
