import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/preference_sync_queue_dao.dart';

void main() {
  group('PreferenceSyncQueueDao', () {
    late AppDatabase db;
    late PreferenceSyncQueueDao dao;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      dao = PreferenceSyncQueueDao(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('enqueue adds item to queue', () async {
      final now = DateTime.now();
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(type: 'save', feedUri: 'at://test', createdAt: now),
      );

      final pending = await dao.getPendingItems();
      expect(pending.length, 1);
      expect(pending.first.type, 'save');
      expect(pending.first.feedUri, 'at://test');
    });

    test('getPendingItems returns ordered items', () async {
      final now = DateTime.now();
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(type: 'save', feedUri: 'first', createdAt: now),
      );
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(
          type: 'remove',
          feedUri: 'second',
          createdAt: now.add(const Duration(seconds: 1)),
        ),
      );

      final pending = await dao.getPendingItems();
      expect(pending.length, 2);
      expect(pending[0].feedUri, 'first');
      expect(pending[1].feedUri, 'second');
    });

    test('deleteItem removes specific item', () async {
      final now = DateTime.now();
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(type: 'save', feedUri: 'at://test', createdAt: now),
      );

      var pending = await dao.getPendingItems();
      final id = pending.first.id;

      await dao.deleteItem(id);

      pending = await dao.getPendingItems();
      expect(pending, isEmpty);
    });

    test('clearQueue removes all items', timeout: const Timeout(Duration(seconds: 5)), () async {
      final now = DateTime.now();
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(type: 'save', feedUri: '1', createdAt: now),
      );
      await dao.enqueue(
        PreferenceSyncQueueCompanion.insert(type: 'save', feedUri: '2', createdAt: now),
      );

      await dao.clearQueue();

      final pending = await dao.getPendingItems();
      expect(pending, isEmpty);
    });
  });
}
