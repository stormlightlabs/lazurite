import 'dart:async';

import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/notification/list_notifications.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/notifications/domain/local_notification_adapter.dart';
import 'package:lazurite/features/notifications/domain/notification_local_mappers.dart';

/// Orchestrates notification polling flows and delivery-state persistence.
class NotificationDomainService {
  NotificationDomainService({
    required NotificationRepository notificationRepository,
    AppDatabase? database,
    String? accountDid,
    LocalNotificationAdapter? localNotificationAdapter,
    bool Function()? shouldSuppressLocalNotifications,
  }) : _notificationRepository = notificationRepository,
       _database = database,
       _accountDid = accountDid,
       _localNotificationAdapter = localNotificationAdapter,
       _shouldSuppressLocalNotifications = shouldSuppressLocalNotifications {
    if ((database == null) != (accountDid == null)) {
      throw ArgumentError('database and accountDid must both be provided together, or both omitted');
    }
  }

  final NotificationRepository _notificationRepository;
  final AppDatabase? _database;
  final String? _accountDid;
  final LocalNotificationAdapter? _localNotificationAdapter;
  final bool Function()? _shouldSuppressLocalNotifications;

  Future<NotificationListResult> listNotifications({
    String? cursor,
    int limit = 50,
    NotificationDeliverySource source = NotificationDeliverySource.poll,
  }) async {
    final result = await _notificationRepository.listNotifications(cursor: cursor, limit: limit);
    await persistNotificationDeliveries(
      result.notifications,
      source: source,
      onNewDelivery: (notification) async {
        if (notification.isRead) {
          return;
        }

        final request = NotificationLocalMapper.requestFromNotification(notification);
        if (request == null) {
          return;
        }

        if (_shouldSuppressLocalNotifications?.call() ?? false) {
          return;
        }

        await _localNotificationAdapter?.show(request);
      },
    );
    return result;
  }

  Future<int> getUnreadCount() => _notificationRepository.getUnreadCount();

  Future<void> markSeen() => _notificationRepository.updateSeen();

  Future<NotificationPushProcessingOutcome> onPushPayload(
    Map<String, String> payload, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final timedResult = await _onPushPayloadInternal(payload).timeout(
      timeout,
      onTimeout: () async {
        await _recordPushDrop('timeout');
        return NotificationPushProcessingOutcome.droppedTimeout;
      },
    );

    if (timedResult == NotificationPushProcessingOutcome.processed) {
      await _incrementCounter(_pushProcessedCountKey);
    }

    return timedResult;
  }

  Future<NotificationPushProcessingOutcome> _onPushPayloadInternal(Map<String, String> payload) async {
    final parsedPayload = NotificationPushPayload.tryParse(payload);
    if (parsedPayload == null) {
      await _recordPushDrop('invalid_payload');
      return NotificationPushProcessingOutcome.droppedInvalidPayload;
    }

    final accountDid = _accountDid;
    if (accountDid != null && parsedPayload.targetDid != accountDid) {
      await _recordPushDrop('target_mismatch');
      return NotificationPushProcessingOutcome.droppedTargetMismatch;
    }

    final canonical = await _notificationRepository.findNotificationByRecordUri(
      recordUri: parsedPayload.recordUri,
      senderDid: parsedPayload.senderDid,
      reason: parsedPayload.reason,
    );
    if (canonical == null) {
      await _recordPushDrop('not_found');
      return NotificationPushProcessingOutcome.droppedNotFound;
    }

    if (canonical.isRead) {
      await _recordPushDrop('already_read');
      return NotificationPushProcessingOutcome.droppedAlreadyRead;
    }

    final insertedCount = await persistNotificationDeliveries([canonical], source: NotificationDeliverySource.push);
    if (insertedCount == 0) {
      await _recordPushDrop('duplicate');
      return NotificationPushProcessingOutcome.droppedDuplicate;
    }

    if (_shouldSuppressLocalNotifications?.call() ?? false) {
      return NotificationPushProcessingOutcome.processed;
    }

    final request = NotificationLocalMapper.requestFromNotification(canonical);
    if (request == null) {
      await _recordPushDrop('unmappable');
      return NotificationPushProcessingOutcome.droppedUnmappable;
    }

    try {
      await _localNotificationAdapter?.show(request);
      return NotificationPushProcessingOutcome.processed;
    } catch (error, stackTrace) {
      log.w('Failed to display local notification for push payload', error: error, stackTrace: stackTrace);
      await _recordPushDrop('display_error');
      return NotificationPushProcessingOutcome.droppedDisplayError;
    }
  }

  Future<int> onBackgroundTick({int limit = 50}) async {
    final result = await listNotifications(limit: limit, source: NotificationDeliverySource.poll);
    return result.notifications.length;
  }

  Future<int> persistNotificationDeliveries(
    Iterable<Notification> notifications, {
    NotificationDeliverySource source = NotificationDeliverySource.poll,
    Future<void> Function(Notification notification)? onNewDelivery,
  }) async {
    final database = _database;
    final accountDid = _accountDid;
    if (database == null || accountDid == null) {
      return 0;
    }

    var insertedCount = 0;
    for (final notification in notifications) {
      final didInsert = await database.recordNotificationDelivery(
        accountDid: accountDid,
        notificationUri: notification.uri.toString(),
        notificationCid: notification.cid,
        reason: _reasonName(notification.reason),
        indexedAt: notification.indexedAt,
        source: source.value,
      );
      if (didInsert) {
        insertedCount += 1;
        await onNewDelivery?.call(notification);
      }
    }

    return insertedCount;
  }

  String _reasonName(NotificationReason reason) {
    final knownReason = reason.knownValue;
    if (knownReason != null) {
      return knownReason.name;
    }
    return 'unknown';
  }

  Future<void> _recordPushDrop(String reason) async {
    await _incrementCounter(_pushDroppedCountKey);
    await _incrementCounter('$_pushDroppedReasonPrefix$reason');
  }

  Future<void> _incrementCounter(String key) async {
    final database = _database;
    if (database == null) {
      return;
    }

    final currentValue = int.tryParse(await database.getSetting(key) ?? '') ?? 0;
    await database.setSetting(key, '${currentValue + 1}');
  }
}

enum NotificationDeliverySource {
  poll('poll'),
  push('push');

  const NotificationDeliverySource(this.value);

  final String value;
}

enum NotificationPushProcessingOutcome {
  processed,
  droppedInvalidPayload,
  droppedTargetMismatch,
  droppedNotFound,
  droppedAlreadyRead,
  droppedDuplicate,
  droppedUnmappable,
  droppedDisplayError,
  droppedTimeout,
}

class NotificationPushPayload {
  NotificationPushPayload({
    required this.senderDid,
    required this.targetDid,
    required this.recordUri,
    required this.reason,
  });

  final String senderDid;
  final String targetDid;
  final String recordUri;
  final String reason;

  static NotificationPushPayload? tryParse(Map<String, String> payload) {
    final senderDid = payload['senderDid']?.trim();
    final targetDid = payload['targetDid']?.trim();
    final recordUri = payload['recordUri']?.trim();
    final reason = payload['reason']?.trim();

    if (senderDid == null || senderDid.isEmpty || !senderDid.startsWith('did:')) {
      return null;
    }
    if (targetDid == null || targetDid.isEmpty || !targetDid.startsWith('did:')) {
      return null;
    }
    if (recordUri == null || recordUri.isEmpty || !_isAtUri(recordUri)) {
      return null;
    }
    if (reason == null || reason.isEmpty) {
      return null;
    }

    return NotificationPushPayload(senderDid: senderDid, targetDid: targetDid, recordUri: recordUri, reason: reason);
  }

  static bool _isAtUri(String value) {
    try {
      final atUri = AtUri.parse(value);
      return atUri.toString().isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

const _pushProcessedCountKey = 'notification_push_processed_count';
const _pushDroppedCountKey = 'notification_push_dropped_count';
const _pushDroppedReasonPrefix = 'notification_push_dropped_reason_';
