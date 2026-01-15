// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_sync_queue_dao.dart';

// ignore_for_file: type=lint
mixin _$PreferenceSyncQueueDaoMixin on DatabaseAccessor<AppDatabase> {
  $PreferenceSyncQueueTable get preferenceSyncQueue => attachedDatabase.preferenceSyncQueue;
  PreferenceSyncQueueDaoManager get managers => PreferenceSyncQueueDaoManager(this);
}

class PreferenceSyncQueueDaoManager {
  final _$PreferenceSyncQueueDaoMixin _db;
  PreferenceSyncQueueDaoManager(this._db);
  $$PreferenceSyncQueueTableTableManager get preferenceSyncQueue =>
      $$PreferenceSyncQueueTableTableManager(_db.attachedDatabase, _db.preferenceSyncQueue);
}
