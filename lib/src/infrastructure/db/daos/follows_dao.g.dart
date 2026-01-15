// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follows_dao.dart';

// ignore_for_file: type=lint
mixin _$FollowsDaoMixin on DatabaseAccessor<AppDatabase> {
  $FollowsTable get follows => attachedDatabase.follows;
  FollowsDaoManager get managers => FollowsDaoManager(this);
}

class FollowsDaoManager {
  final _$FollowsDaoMixin _db;
  FollowsDaoManager(this._db);
  $$FollowsTableTableManager get follows =>
      $$FollowsTableTableManager(_db.attachedDatabase, _db.follows);
}
