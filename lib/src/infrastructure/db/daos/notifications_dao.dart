import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'notifications_dao.g.dart';

/// DAO for managing cached notifications.
///
/// Handles storage and retrieval of notifications from
/// app.bsky.notification.listNotifications API.
@DriftAccessor(tables: [Notifications, NotificationCursors, Profiles])
class NotificationsDao extends DatabaseAccessor<AppDatabase> with _$NotificationsDaoMixin {
  NotificationsDao(super.db);

  /// Inserts or updates a batch of notifications.
  /// Also updates the cursor for pagination.
  Future<void> insertNotificationsBatch({
    required List<NotificationsCompanion> newNotifications,
    required List<ProfilesCompanion> newProfiles,
    String? newCursor,
  }) {
    return transaction(() async {
      await batch((batch) {
        batch.insertAll(profiles, newProfiles, mode: InsertMode.insertOrReplace);
        batch.insertAll(notifications, newNotifications, mode: InsertMode.insertOrReplace);
      });

      if (newCursor != null) {
        await into(notificationCursors).insertOnConflictUpdate(
          NotificationCursorsCompanion.insert(
            feedKey: 'notifications',
            cursor: newCursor,
            lastUpdated: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  /// Gets a stream of notifications with their actors.
  Stream<List<NotificationWithActor>> watchNotifications() {
    final query = select(
      notifications,
    ).join([innerJoin(profiles, profiles.did.equalsExp(notifications.actorDid))]);

    query.orderBy([OrderingTerm.desc(notifications.indexedAt)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return NotificationWithActor(
          notification: row.readTable(notifications),
          actor: row.readTable(profiles),
        );
      }).toList();
    });
  }

  /// Gets the pagination cursor.
  Future<String?> getCursor() async {
    final query = select(notificationCursors)..where((t) => t.feedKey.equals('notifications'));
    final result = await query.getSingleOrNull();
    return result?.cursor;
  }

  /// Clears all cached notifications and cursor.
  Future<void> clearNotifications() async {
    await delete(notifications).go();
    await (delete(notificationCursors)..where((t) => t.feedKey.equals('notifications'))).go();
  }

  /// Deletes notifications older than the given threshold.
  Future<int> deleteStaleNotifications(DateTime threshold) async {
    return (delete(notifications)..where((t) => t.cachedAt.isSmallerThanValue(threshold))).go();
  }

  /// Marks all notifications as read.
  Future<void> markAllAsRead() async {
    await (update(notifications)..where((t) => t.isRead.equals(false))).write(
      const NotificationsCompanion(isRead: Value(true)),
    );
  }

  /// Marks notifications as read if they were indexed before the given timestamp.
  ///
  /// This is used for batching mark as seen operations - all notifications
  /// before [seenAt] are marked as read locally.
  Future<void> markAsSeenBefore(DateTime seenAt) async {
    await (update(notifications)
          ..where((t) => t.indexedAt.isSmallerOrEqualValue(seenAt) & t.isRead.equals(false)))
        .write(NotificationsCompanion(isRead: const Value(true), seenAt: Value(seenAt)));
  }

  /// Gets a stream of the unread notification count.
  ///
  /// Emits updates whenever notifications are inserted, updated, or deleted.
  Stream<int> watchUnreadCount() {
    final query = selectOnly(notifications)..addColumns([notifications.uri.count()]);
    query.where(notifications.isRead.equals(false));
    return query.map((row) => row.read(notifications.uri.count()) ?? 0).watchSingle();
  }
}

/// Represents a notification with its actor profile.
class NotificationWithActor {
  NotificationWithActor({required this.notification, required this.actor});

  final Notification notification;
  final Profile actor;
}
