import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'dev_tools_dao.g.dart';

@DriftAccessor(tables: [DevSettings, DevNetworkLogs, DevPins, DevRecentRecords])
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

  Future<void> savePin({
    required String uri,
    required String type,
    String? label,
    DateTime? createdAt,
  }) async {
    await into(devPins).insert(
      DevPinsCompanion(
        uri: Value(uri),
        type: Value(type),
        label: Value(label),
        createdAt: Value(createdAt ?? DateTime.now()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> deletePin(String uri) async {
    await (delete(devPins)..where((t) => t.uri.equals(uri))).go();
  }

  Future<DevPin?> getPin(String uri) async {
    return (select(devPins)..where((t) => t.uri.equals(uri))).getSingleOrNull();
  }

  Stream<List<DevPin>> watchPins() {
    return (select(
      devPins,
    )..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).watch();
  }

  Future<List<DevPin>> getAllPins() async {
    return (select(
      devPins,
    )..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).get();
  }

  Future<void> addRecentRecord({
    required String did,
    required String collection,
    required String rkey,
    required String uri,
    String? cid,
    DateTime? indexedAt,
    DateTime? viewedAt,
    int limit = 100,
  }) async {
    await transaction(() async {
      await into(devRecentRecords).insert(
        DevRecentRecordsCompanion(
          did: Value(did),
          collection: Value(collection),
          rkey: Value(rkey),
          uri: Value(uri),
          cid: Value(cid),
          indexedAt: Value(indexedAt),
          viewedAt: Value(viewedAt ?? DateTime.now()),
        ),
        mode: InsertMode.insertOrReplace,
      );

      await pruneRecentRecords(limit);
    });
  }

  Stream<List<DevRecentRecord>> watchRecentRecords() {
    return (select(
      devRecentRecords,
    )..orderBy([(t) => OrderingTerm(expression: t.viewedAt, mode: OrderingMode.desc)])).watch();
  }

  Future<void> clearRecentRecords() async {
    await delete(devRecentRecords).go();
  }

  Future<void> pruneRecentRecords(int limit) async {
    final idsToKeepQuery = select(devRecentRecords, distinct: false)
      ..orderBy([
        (t) => OrderingTerm(expression: t.viewedAt, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    final idsToKeep = await idsToKeepQuery.map((row) => row.id).get();

    if (idsToKeep.isNotEmpty) {
      await (delete(devRecentRecords)..where((t) => t.id.isNotIn(idsToKeep))).go();
    }
  }
}
