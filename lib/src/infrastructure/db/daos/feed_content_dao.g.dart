// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_content_dao.dart';

// ignore_for_file: type=lint
mixin _$FeedContentDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $PostsTable get posts => attachedDatabase.posts;
  $ProfileRelationshipsTable get profileRelationships => attachedDatabase.profileRelationships;
  $PostInteractionsTable get postInteractions => attachedDatabase.postInteractions;
  $FeedContentItemsTable get feedContentItems => attachedDatabase.feedContentItems;
  $FeedCursorsTable get feedCursors => attachedDatabase.feedCursors;
  FeedContentDaoManager get managers => FeedContentDaoManager(this);
}

class FeedContentDaoManager {
  final _$FeedContentDaoMixin _db;
  FeedContentDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$PostsTableTableManager get posts => $$PostsTableTableManager(_db.attachedDatabase, _db.posts);
  $$ProfileRelationshipsTableTableManager get profileRelationships =>
      $$ProfileRelationshipsTableTableManager(_db.attachedDatabase, _db.profileRelationships);
  $$PostInteractionsTableTableManager get postInteractions =>
      $$PostInteractionsTableTableManager(_db.attachedDatabase, _db.postInteractions);
  $$FeedContentItemsTableTableManager get feedContentItems =>
      $$FeedContentItemsTableTableManager(_db.attachedDatabase, _db.feedContentItems);
  $$FeedCursorsTableTableManager get feedCursors =>
      $$FeedCursorsTableTableManager(_db.attachedDatabase, _db.feedCursors);
}
