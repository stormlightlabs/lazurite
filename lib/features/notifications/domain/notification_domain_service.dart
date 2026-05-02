import 'package:bluesky/app_bsky_notification_listnotifications.dart';
import 'package:lazurite/core/database/app_database.dart';
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
}

enum NotificationDeliverySource {
  poll('poll'),
  push('push');

  const NotificationDeliverySource(this.value);

  final String value;
}
