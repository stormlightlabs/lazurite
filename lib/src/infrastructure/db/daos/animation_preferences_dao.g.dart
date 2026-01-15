// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animation_preferences_dao.dart';

// ignore_for_file: type=lint
mixin _$AnimationPreferencesDaoMixin on DatabaseAccessor<AppDatabase> {
  $AnimationPreferencesTableTable get animationPreferencesTable =>
      attachedDatabase.animationPreferencesTable;
  AnimationPreferencesDaoManager get managers => AnimationPreferencesDaoManager(this);
}

class AnimationPreferencesDaoManager {
  final _$AnimationPreferencesDaoMixin _db;
  AnimationPreferencesDaoManager(this._db);
  $$AnimationPreferencesTableTableTableManager get animationPreferencesTable =>
      $$AnimationPreferencesTableTableTableManager(
        _db.attachedDatabase,
        _db.animationPreferencesTable,
      );
}
