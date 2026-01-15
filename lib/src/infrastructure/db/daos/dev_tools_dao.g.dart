// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dev_tools_dao.dart';

// ignore_for_file: type=lint
mixin _$DevToolsDaoMixin on DatabaseAccessor<AppDatabase> {
  $DevSettingsTable get devSettings => attachedDatabase.devSettings;
  $DevNetworkLogsTable get devNetworkLogs => attachedDatabase.devNetworkLogs;
  $DevPinsTable get devPins => attachedDatabase.devPins;
  $DevRecentRecordsTable get devRecentRecords => attachedDatabase.devRecentRecords;
  DevToolsDaoManager get managers => DevToolsDaoManager(this);
}

class DevToolsDaoManager {
  final _$DevToolsDaoMixin _db;
  DevToolsDaoManager(this._db);
  $$DevSettingsTableTableManager get devSettings =>
      $$DevSettingsTableTableManager(_db.attachedDatabase, _db.devSettings);
  $$DevNetworkLogsTableTableManager get devNetworkLogs =>
      $$DevNetworkLogsTableTableManager(_db.attachedDatabase, _db.devNetworkLogs);
  $$DevPinsTableTableManager get devPins =>
      $$DevPinsTableTableManager(_db.attachedDatabase, _db.devPins);
  $$DevRecentRecordsTableTableManager get devRecentRecords =>
      $$DevRecentRecordsTableTableManager(_db.attachedDatabase, _db.devRecentRecords);
}
