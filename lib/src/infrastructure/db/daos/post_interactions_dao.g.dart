// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_interactions_dao.dart';

// ignore_for_file: type=lint
mixin _$PostInteractionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $PostsTable get posts => attachedDatabase.posts;
  $PostInteractionsTable get postInteractions => attachedDatabase.postInteractions;
  PostInteractionsDaoManager get managers => PostInteractionsDaoManager(this);
}

class PostInteractionsDaoManager {
  final _$PostInteractionsDaoMixin _db;
  PostInteractionsDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$PostsTableTableManager get posts => $$PostsTableTableManager(_db.attachedDatabase, _db.posts);
  $$PostInteractionsTableTableManager get postInteractions =>
      $$PostInteractionsTableTableManager(_db.attachedDatabase, _db.postInteractions);
}
