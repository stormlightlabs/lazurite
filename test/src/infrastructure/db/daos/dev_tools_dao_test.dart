import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/dev_tools_dao.dart';

void main() {
  late AppDatabase db;
  late DevToolsDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = DevToolsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DevToolsDao', () {
    test('getSetSetting stores and retrieves settings', () async {
      await dao.setSetting('debug_mode', 'true', 'boolean');
      final value = await dao.getSetting('debug_mode');
      expect(value, 'true');

      final missing = await dao.getSetting('non_existent');
      expect(missing, null);
    });

    test('logRequest stores network log', () async {
      await dao.logRequest(
        uuid: 'uuid-1',
        method: 'GET',
        url: 'https://example.com',
        statusCode: 200,
        durationMs: 100,
        requestHeaders: '{}',
        responseHeaders: '{}',
      );

      final logs = await dao.watchLogs().first;
      expect(logs.length, 1);
      expect(logs.first.url, 'https://example.com');
      expect(logs.first.statusCode, 200);
    });

    test('pruneLogs limits log count', () async {
      for (var i = 0; i < 10; i++) {
        await dao.logRequest(
          uuid: 'uuid-$i',
          method: 'GET',
          url: 'https://example.com/$i',
          statusCode: 200,
          durationMs: 100,
          requestHeaders: '{}',
          responseHeaders: '{}',
        );
      }

      var logs = await dao.watchLogs().first;
      expect(logs.length, 10);

      await dao.pruneLogs(5);

      logs = await dao.watchLogs().first;
      expect(logs.length, 5);
      expect(logs.first.url, 'https://example.com/9');
      expect(logs.last.url, 'https://example.com/5');
    });

    test('clearLogs removes all logs', () async {
      await dao.logRequest(
        uuid: 'uuid-1',
        method: 'GET',
        url: 'https://example.com',
        statusCode: 200,
        durationMs: 100,
        requestHeaders: '{}',
        responseHeaders: '{}',
      );

      await dao.clearLogs();
      final logs = await dao.watchLogs().first;
      expect(logs, isEmpty);
    });
  });
}
