// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_feeds_dao.dart';

// ignore_for_file: type=lint
mixin _$SavedFeedsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $SavedFeedsTable get savedFeeds => attachedDatabase.savedFeeds;
  SavedFeedsDaoManager get managers => SavedFeedsDaoManager(this);
}

class SavedFeedsDaoManager {
  final _$SavedFeedsDaoMixin _db;
  SavedFeedsDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$SavedFeedsTableTableManager get savedFeeds =>
      $$SavedFeedsTableTableManager(_db.attachedDatabase, _db.savedFeeds);
}
