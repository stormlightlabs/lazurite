// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dm_convos_dao.dart';

// ignore_for_file: type=lint
mixin _$DmConvosDaoMixin on DatabaseAccessor<AppDatabase> {
  $DmConvosTable get dmConvos => attachedDatabase.dmConvos;
  $ProfilesTable get profiles => attachedDatabase.profiles;
  DmConvosDaoManager get managers => DmConvosDaoManager(this);
}

class DmConvosDaoManager {
  final _$DmConvosDaoMixin _db;
  DmConvosDaoManager(this._db);
  $$DmConvosTableTableManager get dmConvos =>
      $$DmConvosTableTableManager(_db.attachedDatabase, _db.dmConvos);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
}
