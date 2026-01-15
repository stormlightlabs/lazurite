// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_sync_queue_dao.dart';

// ignore_for_file: type=lint
mixin _$NotificationsSyncQueueDaoMixin on DatabaseAccessor<AppDatabase> {
  $NotificationsSyncQueueTable get notificationsSyncQueue =>
      attachedDatabase.notificationsSyncQueue;
  NotificationsSyncQueueDaoManager get managers => NotificationsSyncQueueDaoManager(this);
}

class NotificationsSyncQueueDaoManager {
  final _$NotificationsSyncQueueDaoMixin _db;
  NotificationsSyncQueueDaoManager(this._db);
  $$NotificationsSyncQueueTableTableManager get notificationsSyncQueue =>
      $$NotificationsSyncQueueTableTableManager(_db.attachedDatabase, _db.notificationsSyncQueue);
}
