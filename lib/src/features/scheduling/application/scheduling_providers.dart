import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/composer/application/composer_providers.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/notification_scheduler.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/post_publisher.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/schedule_repository.dart';
import 'package:lazurite/src/features/scheduling/infrastructure/scheduler.dart';
import 'package:lazurite/src/infrastructure/auth/session_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scheduling_providers.g.dart';

/// Provides the session storage for scheduling operations.
@Riverpod(keepAlive: true)
SessionStorage sessionStorage(Ref ref) {
  return SessionStorage();
}

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

/// Provides the active scheduler instance.
///
/// Currently returns the notification-based scheduler, but can be
/// swapped to use background task scheduling in the future.
@Riverpod(keepAlive: true)
Scheduler scheduler(Ref ref) {
  return ref.watch(notificationSchedulerProvider);
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
