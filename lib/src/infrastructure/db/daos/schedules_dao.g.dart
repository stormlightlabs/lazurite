// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedules_dao.dart';

// ignore_for_file: type=lint
mixin _$SchedulesDaoMixin on DatabaseAccessor<AppDatabase> {
  $DraftsTable get drafts => attachedDatabase.drafts;
  $SchedulesTable get schedules => attachedDatabase.schedules;
  SchedulesDaoManager get managers => SchedulesDaoManager(this);
}

class SchedulesDaoManager {
  final _$SchedulesDaoMixin _db;
  SchedulesDaoManager(this._db);
  $$DraftsTableTableManager get drafts =>
      $$DraftsTableTableManager(_db.attachedDatabase, _db.drafts);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db.attachedDatabase, _db.schedules);
}
