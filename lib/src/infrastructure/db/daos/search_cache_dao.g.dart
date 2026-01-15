// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_cache_dao.dart';

// ignore_for_file: type=lint
mixin _$SearchCacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $PostsTable get posts => attachedDatabase.posts;
  $SearchCacheItemsTable get searchCacheItems => attachedDatabase.searchCacheItems;
  $SearchCacheCursorsTable get searchCacheCursors => attachedDatabase.searchCacheCursors;
  SearchCacheDaoManager get managers => SearchCacheDaoManager(this);
}

class SearchCacheDaoManager {
  final _$SearchCacheDaoMixin _db;
  SearchCacheDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$PostsTableTableManager get posts => $$PostsTableTableManager(_db.attachedDatabase, _db.posts);
  $$SearchCacheItemsTableTableManager get searchCacheItems =>
      $$SearchCacheItemsTableTableManager(_db.attachedDatabase, _db.searchCacheItems);
  $$SearchCacheCursorsTableTableManager get searchCacheCursors =>
      $$SearchCacheCursorsTableTableManager(_db.attachedDatabase, _db.searchCacheCursors);
}
