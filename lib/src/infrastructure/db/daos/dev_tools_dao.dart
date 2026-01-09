import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'dev_tools_dao.g.dart';

@DriftAccessor(tables: [DevSettings, DevNetworkLogs])
class DevToolsDao extends DatabaseAccessor<AppDatabase> with _$DevToolsDaoMixin {
  DevToolsDao(super.db);

  Future<String?> getSetting(String key) async {
    final query = select(devSettings)..where((t) => t.key.equals(key));
    final result = await query.getSingleOrNull();
    return result?.value;
  }

  Future<void> setSetting(String key, String value, String type) async {
    await into(devSettings).insertOnConflictUpdate(
      DevSettingsCompanion(key: Value(key), value: Value(value), type: Value(type)),
    );
  }

  Future<void> logRequest({
    required String uuid,
    required String method,
    required String url,
    required int statusCode,
    required int durationMs,
    required String requestHeaders,
    required String responseHeaders,
    String? requestBody,
    String? responseBody,
    String? error,
  }) async {
    await into(devNetworkLogs).insert(
      DevNetworkLogsCompanion(
        uuid: Value(uuid),
        method: Value(method),
        url: Value(url),
        statusCode: Value(statusCode),
        durationMs: Value(durationMs),
        requestHeaders: Value(requestHeaders),
        responseHeaders: Value(responseHeaders),
        requestBody: Value(requestBody),
        responseBody: Value(responseBody),
        error: Value(error),
        timestamp: Value(DateTime.now()),
      ),
    );

    await pruneLogs(1000);
  }

  Stream<List<DevNetworkLog>> watchLogs() {
    return (select(devNetworkLogs)..orderBy([
          (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  Future<void> clearLogs() async {
    await delete(devNetworkLogs).go();
  }

  Future<void> pruneLogs(int limit) async {
    final idsToKeepQuery = select(devNetworkLogs, distinct: false)
      ..orderBy([
        (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    final idsToKeep = await idsToKeepQuery.map((row) => row.id).get();

    if (idsToKeep.isEmpty) return;

    final deleteQuery = delete(devNetworkLogs)..where((t) => t.id.isNotIn(idsToKeep));

    await deleteQuery.go();
  }
}
