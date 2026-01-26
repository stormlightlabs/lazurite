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

    group('Pins', () {
      test('savePin adds a pin', () async {
        await dao.savePin(
          uri: 'at://did:plc:123/app.bsky.feed.post/123',
          type: 'record',
          label: 'Test Pin',
        );

        final pin = await dao.getPin('at://did:plc:123/app.bsky.feed.post/123');
        expect(pin, isNotNull);
        expect(pin!.uri, 'at://did:plc:123/app.bsky.feed.post/123');
        expect(pin.type, 'record');
        expect(pin.label, 'Test Pin');
      });

      test('savePin updates existing pin', () async {
        await dao.savePin(
          uri: 'at://did:plc:123/app.bsky.feed.post/123',
          type: 'record',
          label: 'Original',
        );

        await dao.savePin(
          uri: 'at://did:plc:123/app.bsky.feed.post/123',
          type: 'record',
          label: 'Updated',
        );

        final pin = await dao.getPin('at://did:plc:123/app.bsky.feed.post/123');
        expect(pin?.label, 'Updated');
      });

      test('deletePin removes a pin', () async {
        await dao.savePin(uri: 'at://did:plc:123/app.bsky.feed.post/123', type: 'record');

        await dao.deletePin('at://did:plc:123/app.bsky.feed.post/123');

        final pin = await dao.getPin('at://did:plc:123/app.bsky.feed.post/123');
        expect(pin, isNull);
      });

      test('getAllPins and watchPins return sorted pins', () async {
        final now = DateTime.now();
        await dao.savePin(
          uri: '1',
          type: 'record',
          label: '1',
          createdAt: now.subtract(const Duration(seconds: 10)),
        );
        await dao.savePin(uri: '2', type: 'record', label: '2', createdAt: now);

        final pins = await dao.getAllPins();
        expect(pins.length, 2);
        expect(pins[0].uri, '2');
        expect(pins[1].uri, '1');

        expect(
          dao.watchPins(),
          emits(
            isA<List<DevPin>>()
                .having((l) => l[0].uri, 'first uri', '2')
                .having((l) => l[1].uri, 'second uri', '1'),
          ),
        );
      });
    });

    group('Recent Records', () {
      test('addRecentRecord adds a record', () async {
        await dao.addRecentRecord(
          uri: 'at://did:plc:123/app.bsky.feed.post/123',
          cid: 'bafyre...',
        );

        final records = await dao.watchRecentRecords().first;
        expect(records.length, 1);
        expect(records.first.uri, 'at://did:plc:123/app.bsky.feed.post/123');
        expect(records.first.cid, 'bafyre...');
      });

      test('addRecentRecord maintains LRU order', () async {
        final now = DateTime.now();
        await dao.addRecentRecord(uri: '1', viewedAt: now.subtract(const Duration(seconds: 10)));
        await dao.addRecentRecord(uri: '2', viewedAt: now);

        final records = await dao.watchRecentRecords().first;
        expect(records.length, 2);
        expect(records[0].uri, '2');
        expect(records[1].uri, '1');

        await dao.addRecentRecord(uri: '1', viewedAt: now.add(const Duration(seconds: 10)));
        final recordsAfter = await dao.watchRecentRecords().first;
        expect(recordsAfter.length, 2);
        expect(recordsAfter[0].uri, '1');
        expect(recordsAfter[1].uri, '2');
      });

      test('clearRecentRecords removes all', () async {
        await dao.addRecentRecord(uri: '1');
        await dao.clearRecentRecords();

        final records = await dao.watchRecentRecords().first;
        expect(records, isEmpty);
      });
    });
  });
}
