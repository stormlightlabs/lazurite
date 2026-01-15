// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_dao.dart';

// ignore_for_file: type=lint
mixin _$NotificationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $NotificationsTable get notifications => attachedDatabase.notifications;
  $NotificationCursorsTable get notificationCursors => attachedDatabase.notificationCursors;
  NotificationsDaoManager get managers => NotificationsDaoManager(this);
}

class NotificationsDaoManager {
  final _$NotificationsDaoMixin _db;
  NotificationsDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db.attachedDatabase, _db.notifications);
  $$NotificationCursorsTableTableManager get notificationCursors =>
      $$NotificationCursorsTableTableManager(_db.attachedDatabase, _db.notificationCursors);
}
