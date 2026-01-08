import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/dm_outbox_dao.dart';

void main() {
  late AppDatabase database;
  late DmOutboxDao dao;
  const ownerDid = 'did:web:tester';

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = database.dmOutboxDao;
  });

  tearDown(() async {
    await database.close();
  });

  group('DmOutboxDao', () {
    group('enqueue', () {
      test('adds item to outbox', () async {
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox1',
            convoId: 'convo1',
            messageText: 'Hello!',
            status: 'pending',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );

        final pending = await dao.getPending(ownerDid);
        expect(pending, hasLength(1));
        expect(pending.first.outboxId, 'outbox1');
        expect(pending.first.messageText, 'Hello!');
        expect(pending.first.status, 'pending');
      });
    });

    group('getPending', () {
      test('returns pending items sorted by createdAt', () async {
        final now = DateTime.now();

        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox2',
            convoId: 'convo1',
            messageText: 'Second',
            status: 'pending',
            createdAt: now,
            ownerDid: ownerDid,
          ),
        );
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox1',
            convoId: 'convo1',
            messageText: 'First',
            status: 'pending',
            createdAt: now.subtract(const Duration(minutes: 1)),
            ownerDid: ownerDid,
          ),
        );

        final pending = await dao.getPending(ownerDid);
        expect(pending, hasLength(2));
        expect(pending[0].outboxId, 'outbox1');
        expect(pending[1].outboxId, 'outbox2');
      });

      test('excludes non-pending items', () async {
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox1',
            convoId: 'convo1',
            messageText: 'Pending',
            status: 'pending',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox2',
            convoId: 'convo1',
            messageText: 'Failed',
            status: 'failed',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );

        final pending = await dao.getPending(ownerDid);
        expect(pending, hasLength(1));
        expect(pending.first.outboxId, 'outbox1');
      });
    });

    group('getFailed', () {
      test('returns only failed items', () async {
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox1',
            convoId: 'convo1',
            messageText: 'Pending',
            status: 'pending',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox2',
            convoId: 'convo1',
            messageText: 'Failed',
            status: 'failed',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );

        final failed = await dao.getFailed(ownerDid);
        expect(failed, hasLength(1));
        expect(failed.first.outboxId, 'outbox2');
      });
    });

    group('getById', () {
      test('returns item by ID', () async {
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox1',
            convoId: 'convo1',
            messageText: 'Test',
            status: 'pending',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );

        final result = await dao.getById('outbox1');
        expect(result, isNotNull);
        expect(result!.messageText, 'Test');
      });

      test('returns null for non-existent ID', () async {
        final result = await dao.getById('nonexistent');
        expect(result, isNull);
      });
    });

    group('getByConvo', () {
      test('returns pending and sending items for a conversation', () async {
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox1',
            convoId: 'convo1',
            messageText: 'Pending',
            status: 'pending',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox2',
            convoId: 'convo1',
            messageText: 'Sending',
            status: 'sending',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox3',
            convoId: 'convo2',
            messageText: 'Other convo',
            status: 'pending',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );

        final results = await dao.getByConvo('convo1', ownerDid);
        expect(results, hasLength(2));
      });
    });

    group('updateStatus', () {
      test('updates status and lastAttemptAt', () async {
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox1',
            convoId: 'convo1',
            messageText: 'Test',
            status: 'pending',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );

        await dao.updateStatus(outboxId: 'outbox1', status: 'sending');

        final result = await dao.getById('outbox1');
        expect(result!.status, 'sending');
        expect(result.lastAttemptAt, isNotNull);
      });

      test('stores error message on failure', () async {
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox1',
            convoId: 'convo1',
            messageText: 'Test',
            status: 'pending',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );

        await dao.updateStatus(
          outboxId: 'outbox1',
          status: 'failed',
          errorMessage: 'Network error',
        );

        final result = await dao.getById('outbox1');
        expect(result!.status, 'failed');
        expect(result.errorMessage, 'Network error');
      });
    });

    group('incrementRetryCount', () {
      test('increments retry count', () async {
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox1',
            convoId: 'convo1',
            messageText: 'Test',
            status: 'pending',
            retryCount: const Value(0),
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );

        await dao.incrementRetryCount('outbox1');

        final result = await dao.getById('outbox1');
        expect(result!.retryCount, 1);
      });
    });

    group('resetForRetry', () {
      test('resets status to pending and clears error', () async {
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox1',
            convoId: 'convo1',
            messageText: 'Test',
            status: 'failed',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );
        await dao.updateStatus(outboxId: 'outbox1', status: 'failed', errorMessage: 'Error');

        await dao.resetForRetry('outbox1');

        final result = await dao.getById('outbox1');
        expect(result!.status, 'pending');
        expect(result.errorMessage, isNull);
      });
    });

    group('deleteItem', () {
      test('removes item from outbox', () async {
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox1',
            convoId: 'convo1',
            messageText: 'Test',
            status: 'pending',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );

        final deletedCount = await dao.deleteItem('outbox1');
        expect(deletedCount, 1);

        final result = await dao.getById('outbox1');
        expect(result, isNull);
      });
    });

    group('countPending', () {
      test('counts pending items', () async {
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox1',
            convoId: 'convo1',
            messageText: 'Pending 1',
            status: 'pending',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox2',
            convoId: 'convo1',
            messageText: 'Pending 2',
            status: 'pending',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox3',
            convoId: 'convo1',
            messageText: 'Failed',
            status: 'failed',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );

        final count = await dao.countPending(ownerDid);
        expect(count, 2);
      });
    });

    group('clearOutbox', () {
      test('removes all items', () async {
        await dao.enqueue(
          DmOutboxCompanion.insert(
            outboxId: 'outbox1',
            convoId: 'convo1',
            messageText: 'Test',
            status: 'pending',
            createdAt: DateTime.now(),
            ownerDid: ownerDid,
          ),
        );

        await dao.clearOutbox(ownerDid);

        final pending = await dao.getPending(ownerDid);
        expect(pending, isEmpty);
      });
    });
  });
}
