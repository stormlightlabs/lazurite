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
  ///
  /// Also inserts associated profiles for authors.
  Future<void> insertNotificationsBatch({
    required List<NotificationsCompanion> newNotifications,
    required List<ProfilesCompanion> newProfiles,
    required String? newCursor,
    required String ownerDid,
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
            ownerDid: ownerDid,
            cursor: newCursor,
            lastUpdated: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  /// Gets a stream of notifications from the local cache for a specific user.
  Stream<List<NotificationWithActor>> watchNotifications(String ownerDid) {
    return (select(notifications)
          ..where((t) => t.ownerDid.equals(ownerDid))
          ..orderBy([(t) => OrderingTerm(expression: t.indexedAt, mode: OrderingMode.desc)]))
        .join([innerJoin(profiles, profiles.did.equalsExp(notifications.actorDid))])
        .watch()
        .map((rows) {
          return rows.map((row) {
            return NotificationWithActor(
              notification: row.readTable(notifications),
              actor: row.readTable(profiles),
            );
          }).toList();
        });
  }

  /// Gets the pagination cursor for loading more notifications.
  Future<String?> getCursor(String ownerDid) {
    final query = select(notificationCursors)
      ..where((t) => t.feedKey.equals('notifications') & t.ownerDid.equals(ownerDid));
    return query.map((t) => t.cursor).getSingleOrNull();
  }

  /// Clears all cached notifications for a specific user.
  Future<void> clearNotifications(String ownerDid) async {
    await (delete(notifications)..where((t) => t.ownerDid.equals(ownerDid))).go();
    await (delete(
      notificationCursors,
    )..where((t) => t.feedKey.equals('notifications') & t.ownerDid.equals(ownerDid))).go();
  }

  /// Deletes notifications older than the specified threshold for a specific user.
  Future<int> deleteStaleNotifications(DateTime threshold, String ownerDid) {
    return (delete(notifications)
          ..where((t) => t.ownerDid.equals(ownerDid))
          ..where((t) => t.cachedAt.isSmallerThanValue(threshold)))
        .go();
  }

  /// Marks all notifications as read locally for a specific user.
  Future<void> markAllAsRead(String ownerDid) {
    return (update(notifications)..where((t) => t.ownerDid.equals(ownerDid))).write(
      const NotificationsCompanion(isRead: Value(true)),
    );
  }

  /// Marks notifications indexed before the given timestamp as seen (read + seenAt set) for a user.
  Future<void> markAsSeenBefore(DateTime seenAt, String ownerDid) {
    return (update(notifications)
          ..where((t) => t.ownerDid.equals(ownerDid))
          ..where((t) => t.indexedAt.isSmallerThanValue(seenAt)))
        .write(NotificationsCompanion(isRead: const Value(true), seenAt: Value(seenAt)));
  }

  /// Returns a stream of the unread notification count for a specific user.
  Stream<int> watchUnreadCount(String ownerDid) {
    final count = notifications.uri.count();
    final query = selectOnly(notifications)
      ..where(notifications.ownerDid.equals(ownerDid))
      ..where(notifications.isRead.not())
      ..addColumns([count]);

    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }
}

/// Represents a notification with its actor profile.
class NotificationWithActor {
  NotificationWithActor({required this.notification, required this.actor});

  final Notification notification;
  final Profile actor;
}
