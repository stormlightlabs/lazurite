// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluesky_preferences_dao.dart';

// ignore_for_file: type=lint
mixin _$BlueskyPreferencesDaoMixin on DatabaseAccessor<AppDatabase> {
  $BlueskyPreferencesTable get blueskyPreferences => attachedDatabase.blueskyPreferences;
  BlueskyPreferencesDaoManager get managers => BlueskyPreferencesDaoManager(this);
}

class BlueskyPreferencesDaoManager {
  final _$BlueskyPreferencesDaoMixin _db;
  BlueskyPreferencesDaoManager(this._db);
  $$BlueskyPreferencesTableTableManager get blueskyPreferences =>
      $$BlueskyPreferencesTableTableManager(_db.attachedDatabase, _db.blueskyPreferences);
}
