// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dm_messages_dao.dart';

// ignore_for_file: type=lint
mixin _$DmMessagesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $DmMessagesTable get dmMessages => attachedDatabase.dmMessages;
  DmMessagesDaoManager get managers => DmMessagesDaoManager(this);
}

class DmMessagesDaoManager {
  final _$DmMessagesDaoMixin _db;
  DmMessagesDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$DmMessagesTableTableManager get dmMessages =>
      $$DmMessagesTableTableManager(_db.attachedDatabase, _db.dmMessages);
}
