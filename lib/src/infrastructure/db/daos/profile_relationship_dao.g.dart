// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_relationship_dao.dart';

// ignore_for_file: type=lint
mixin _$ProfileRelationshipDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $ProfileRelationshipsTable get profileRelationships => attachedDatabase.profileRelationships;
  ProfileRelationshipDaoManager get managers => ProfileRelationshipDaoManager(this);
}

class ProfileRelationshipDaoManager {
  final _$ProfileRelationshipDaoMixin _db;
  ProfileRelationshipDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$ProfileRelationshipsTableTableManager get profileRelationships =>
      $$ProfileRelationshipsTableTableManager(_db.attachedDatabase, _db.profileRelationships);
}
