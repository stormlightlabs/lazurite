import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/notifications/data/flutter_local_notification_adapter.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/notifications/domain/notification_domain_service.dart';
import 'package:workmanager/workmanager.dart';

const notificationReconcileTaskName = 'lazurite.notification_reconcile';
const notificationReconcileUniqueName = 'notification_reconcile_periodic';

@pragma('vm:entry-point')
Future<void> notificationPushPayloadEntrypoint(Map<String, dynamic> payload) async {
  WidgetsFlutterBinding.ensureInitialized();

  final context = await _BackgroundNotificationContext.create();
  if (context == null) {
    return;
  }

  try {
    await runNotificationPushPayloadTask(
      payload: _coercePayload(payload),
      processPayload: context.domainService.onPushPayload,
    );
  } catch (error, stackTrace) {
    log.w('Background push payload processing failed', error: error, stackTrace: stackTrace);
  } finally {
    await context.dispose();
  }
}

@pragma('vm:entry-point')
Future<void> notificationFirebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await notificationPushPayloadEntrypoint(message.data);
}

Future<bool?> handleNotificationWorkmanagerTask(String taskName, Map<String, dynamic>? inputData) async {
  if (taskName != notificationReconcileTaskName && taskName != Workmanager.iOSBackgroundTask) {
    return null;
  }

  final context = await _BackgroundNotificationContext.create();
  if (context == null) {
    return true;
  }

  try {
    return await runNotificationReconcileTask(reconcile: context.domainService.onBackgroundTick);
  } catch (error, stackTrace) {
    log.w('Background notification reconcile failed', error: error, stackTrace: stackTrace);
    return false;
  } finally {
    await context.dispose();
  }
}

class NotificationBackgroundScheduler {
  NotificationBackgroundScheduler._();

  /// iOS fetch/BGTask execution is system-managed. Workmanager's
  /// `registerPeriodicTask` channel method is Android-specific,
  /// so avoid calling it on iOS.
  static Future<void> ensureScheduled() async {
    if (Platform.isAndroid) {
      await Workmanager().registerPeriodicTask(
        notificationReconcileUniqueName,
        notificationReconcileTaskName,
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
        constraints: Constraints(networkType: NetworkType.connected),
      );
      return;
    }

    if (!Platform.isIOS) {
      return;
    }

    try {
      await Workmanager().registerOneOffTask(
        notificationReconcileUniqueName,
        notificationReconcileTaskName,
        initialDelay: const Duration(minutes: 15),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    } on PlatformException catch (error, stackTrace) {
      log.w('Unable to schedule iOS notification reconcile one-off task', error: error, stackTrace: stackTrace);
    }
  }
}

Future<bool> runNotificationReconcileTask({required Future<int> Function({int limit}) reconcile}) async {
  try {
    await reconcile();
    return true;
  } catch (error, stackTrace) {
    log.w('Notification reconcile task failed', error: error, stackTrace: stackTrace);
    return false;
  }
}

Future<NotificationPushProcessingOutcome> runNotificationPushPayloadTask({
  required Map<String, String> payload,
  required Future<NotificationPushProcessingOutcome> Function(Map<String, String>) processPayload,
}) async {
  return processPayload(payload);
}

Map<String, String> _coercePayload(Map<String, dynamic> payload) {
  final coerced = <String, String>{};
  for (final entry in payload.entries) {
    final value = entry.value;
    if (value is String) {
      coerced[entry.key] = value;
    }
  }
  return coerced;
}

class _BackgroundNotificationContext {
  _BackgroundNotificationContext({
    required this.database,
    required this.moderationService,
    required this.domainService,
  });

  final AppDatabase database;
  final ModerationService moderationService;
  final NotificationDomainService domainService;

  static Future<_BackgroundNotificationContext?> create() async {
    final database = AppDatabase();
    final authRepository = AuthRepository(database: database);

    try {
      final tokens = await authRepository.restoreSession();
      if (tokens == null) {
        await database.close();
        return null;
      }

      final bluesky = createBlueskyClient(tokens);
      if (bluesky == null) {
        await database.close();
        return null;
      }

      final moderationService = ModerationService(
        bluesky: bluesky,
        database: database,
        accountDid: tokens.did,
        userDid: tokens.did,
      );
      await moderationService.ensureInitialized();

      final localNotificationAdapter = FlutterLocalNotificationAdapter();
      await localNotificationAdapter.initialize(onTap: (_) {});

      final notificationRepository = NotificationRepository(bluesky: bluesky, moderationService: moderationService);

      final domainService = NotificationDomainService(
        notificationRepository: notificationRepository,
        database: database,
        accountDid: tokens.did,
        localNotificationAdapter: localNotificationAdapter,
      );

      return _BackgroundNotificationContext(
        database: database,
        moderationService: moderationService,
        domainService: domainService,
      );
    } catch (error, stackTrace) {
      await database.close();
      log.w('Failed to create notification background context', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> dispose() async {
    moderationService.dispose();
    await database.close();
  }
}
