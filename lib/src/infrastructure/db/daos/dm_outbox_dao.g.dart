// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dm_outbox_dao.dart';

// ignore_for_file: type=lint
mixin _$DmOutboxDaoMixin on DatabaseAccessor<AppDatabase> {
  $DmOutboxTable get dmOutbox => attachedDatabase.dmOutbox;
  DmOutboxDaoManager get managers => DmOutboxDaoManager(this);
}

class DmOutboxDaoManager {
  final _$DmOutboxDaoMixin _db;
  DmOutboxDaoManager(this._db);
  $$DmOutboxTableTableManager get dmOutbox =>
      $$DmOutboxTableTableManager(_db.attachedDatabase, _db.dmOutbox);
}
