import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/dms/domain/outbox_item.dart';
import 'package:lazurite/src/features/dms/infrastructure/outbox_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/dm_messages_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/dm_outbox_dao.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

class MockDmOutboxDao extends Mock implements DmOutboxDao {}

class MockDmMessagesDao extends Mock implements DmMessagesDao {}

class FakeDmOutboxCompanion extends Fake implements DmOutboxCompanion {}

class FakeDmMessagesCompanion extends Fake implements DmMessagesCompanion {}

void main() {
  late MockXrpcClient mockApi;
  late MockDmOutboxDao mockOutboxDao;
  late MockDmMessagesDao mockMessagesDao;
  late MockLogger mockLogger;
  late OutboxRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeDmOutboxCompanion());
    registerFallbackValue(FakeDmMessagesCompanion());
  });

  setUp(() {
    mockApi = MockXrpcClient();
    mockOutboxDao = MockDmOutboxDao();
    mockMessagesDao = MockDmMessagesDao();
    mockLogger = MockLogger();
    repository = OutboxRepository(mockApi, mockOutboxDao, mockMessagesDao, mockLogger);

    when(() => mockLogger.info(any(), any())).thenReturn(null);
    when(() => mockLogger.debug(any(), any())).thenReturn(null);
    when(() => mockLogger.error(any(), any(), any())).thenReturn(null);
  });

  group('OutboxRepository', () {
    group('enqueueSend', () {
      test('adds item to outbox and creates local message', () async {
        when(() => mockOutboxDao.enqueue(any())).thenAnswer((_) async {});
        when(() => mockMessagesDao.insertLocalMessage(any())).thenAnswer((_) async {});

        final outboxId = await repository.enqueueSend('convo1', 'Hello!', 'did:plc:owner');

        expect(outboxId, isNotEmpty);
        verify(() => mockOutboxDao.enqueue(any())).called(1);
        verify(() => mockMessagesDao.insertLocalMessage(any())).called(1);
      });
    });

    group('processOutbox', () {
      test('does nothing when queue is empty', () async {
        when(() => mockOutboxDao.getPending(any())).thenAnswer((_) async => []);

        await repository.processOutbox('did:plc:owner');

        verifyNever(() => mockApi.call(any(), body: any(named: 'body')));
      });

      test('sends pending message and removes from outbox on success', () async {
        final now = DateTime.now();
        final pendingItem = DmOutboxData(
          outboxId: 'outbox1',
          convoId: 'convo1',
          messageText: 'Hello!',
          status: 'pending',
          retryCount: 0,
          createdAt: now,
          lastAttemptAt: null,
          errorMessage: null,
          ownerDid: 'did:plc:owner',
        );

        when(() => mockOutboxDao.getPending(any())).thenAnswer((_) async => [pendingItem]);
        when(
          () => mockOutboxDao.updateStatus(
            outboxId: any(named: 'outboxId'),
            status: any(named: 'status'),
            errorMessage: any(named: 'errorMessage'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockMessagesDao.updateMessageStatus(
            messageId: any(named: 'messageId'),
            status: any(named: 'status'),
            ownerDid: any(named: 'ownerDid'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockApi.call(any(), body: any(named: 'body')),
        ).thenAnswer((_) async => {'id': 'server_msg_id'});
        when(() => mockOutboxDao.deleteItem(any())).thenAnswer((_) async => 1);

        await repository.processOutbox('did:plc:owner');

        verify(
          () => mockApi.call('chat.bsky.convo.sendMessage', body: any(named: 'body')),
        ).called(1);
        verify(() => mockOutboxDao.deleteItem('outbox1')).called(1);
      });

      test('increments retry count on failure', () async {
        final now = DateTime.now();
        final pendingItem = DmOutboxData(
          outboxId: 'outbox1',
          convoId: 'convo1',
          messageText: 'Hello!',
          status: 'pending',
          retryCount: 0,
          createdAt: now,
          lastAttemptAt: null,
          errorMessage: null,
          ownerDid: 'did:plc:owner',
        );

        when(() => mockOutboxDao.getPending(any())).thenAnswer((_) async => [pendingItem]);
        when(
          () => mockOutboxDao.updateStatus(
            outboxId: any(named: 'outboxId'),
            status: any(named: 'status'),
            errorMessage: any(named: 'errorMessage'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockMessagesDao.updateMessageStatus(
            messageId: any(named: 'messageId'),
            status: any(named: 'status'),
            ownerDid: any(named: 'ownerDid'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockApi.call(any(), body: any(named: 'body')),
        ).thenThrow(Exception('Network error'));
        when(() => mockOutboxDao.incrementRetryCount(any(), any())).thenAnswer((_) async {});
        when(() => mockOutboxDao.getById(any(), any())).thenAnswer(
          (_) async => DmOutboxData(
            outboxId: 'outbox1',
            convoId: 'convo1',
            messageText: 'Hello!',
            status: 'pending',
            retryCount: 1,
            createdAt: now,
            lastAttemptAt: now,
            errorMessage: 'Error',
            ownerDid: 'did:plc:owner',
          ),
        );

        await repository.processOutbox('did:plc:owner');

        verify(() => mockOutboxDao.incrementRetryCount('outbox1', 'did:plc:owner')).called(1);
        verifyNever(() => mockOutboxDao.deleteItem(any()));
      });

      test('marks as permanently failed after max retries', () async {
        final now = DateTime.now();
        final pendingItem = DmOutboxData(
          outboxId: 'outbox1',
          convoId: 'convo1',
          messageText: 'Hello!',
          status: 'pending',
          retryCount: 0,
          createdAt: now,
          lastAttemptAt: null,
          errorMessage: null,
          ownerDid: 'did:plc:owner',
        );

        when(() => mockOutboxDao.getPending(any())).thenAnswer((_) async => [pendingItem]);
        when(
          () => mockOutboxDao.updateStatus(
            outboxId: any(named: 'outboxId'),
            status: any(named: 'status'),
            errorMessage: any(named: 'errorMessage'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockMessagesDao.updateMessageStatus(
            messageId: any(named: 'messageId'),
            status: any(named: 'status'),
            ownerDid: any(named: 'ownerDid'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockApi.call(any(), body: any(named: 'body')),
        ).thenThrow(Exception('Network error'));
        when(() => mockOutboxDao.incrementRetryCount(any(), any())).thenAnswer((_) async {});
        when(() => mockOutboxDao.getById(any(), any())).thenAnswer(
          (_) async => DmOutboxData(
            outboxId: 'outbox1',
            convoId: 'convo1',
            messageText: 'Hello!',
            status: 'failed',
            retryCount: OutboxItem.maxRetries,
            createdAt: now,
            lastAttemptAt: now,
            errorMessage: 'Error',
            ownerDid: 'did:plc:owner',
          ),
        );

        await repository.processOutbox('did:plc:owner');

        verify(
          () => mockOutboxDao.updateStatus(
            outboxId: 'outbox1',
            status: 'failed',
            errorMessage: any(named: 'errorMessage'),
          ),
        ).called(1);
      });

      test('processes only one message per conversation at a time', () async {
        final now = DateTime.now();
        final items = [
          DmOutboxData(
            outboxId: 'outbox1',
            convoId: 'convo1',
            messageText: 'First',
            status: 'pending',
            retryCount: 0,
            createdAt: now.subtract(const Duration(minutes: 2)),
            lastAttemptAt: null,
            errorMessage: null,
            ownerDid: 'did:plc:owner',
          ),
          DmOutboxData(
            outboxId: 'outbox2',
            convoId: 'convo1',
            messageText: 'Second',
            status: 'pending',
            retryCount: 0,
            createdAt: now.subtract(const Duration(minutes: 1)),
            lastAttemptAt: null,
            errorMessage: null,
            ownerDid: 'did:plc:owner',
          ),
          DmOutboxData(
            outboxId: 'outbox3',
            convoId: 'convo2',
            messageText: 'Third',
            status: 'pending',
            retryCount: 0,
            createdAt: now,
            lastAttemptAt: null,
            errorMessage: null,
            ownerDid: 'did:plc:owner',
          ),
        ];

        when(() => mockOutboxDao.getPending(any())).thenAnswer((_) async => items);
        when(
          () => mockOutboxDao.updateStatus(
            outboxId: any(named: 'outboxId'),
            status: any(named: 'status'),
            errorMessage: any(named: 'errorMessage'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockMessagesDao.updateMessageStatus(
            messageId: any(named: 'messageId'),
            status: any(named: 'status'),
            ownerDid: any(named: 'ownerDid'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockApi.call(any(), body: any(named: 'body')),
        ).thenAnswer((_) async => {'id': 'server_msg_id'});
        when(() => mockOutboxDao.deleteItem(any())).thenAnswer((_) async => 1);

        await repository.processOutbox('did:plc:owner');

        verify(
          () => mockApi.call('chat.bsky.convo.sendMessage', body: any(named: 'body')),
        ).called(2);
        verify(() => mockOutboxDao.deleteItem('outbox1')).called(1);
        verify(() => mockOutboxDao.deleteItem('outbox3')).called(1);
        verifyNever(() => mockOutboxDao.deleteItem('outbox2'));
      });
    });

    group('retryMessage', () {
      test('resets item for retry and processes immediately', () async {
        final now = DateTime.now();
        final item = DmOutboxData(
          outboxId: 'outbox1',
          convoId: 'convo1',
          messageText: 'Hello!',
          status: 'pending',
          retryCount: 0,
          createdAt: now,
          lastAttemptAt: null,
          errorMessage: null,
          ownerDid: 'did:plc:owner',
        );

        when(() => mockOutboxDao.resetForRetry(any())).thenAnswer((_) async {});
        when(
          () => mockMessagesDao.updateMessageStatus(
            messageId: any(named: 'messageId'),
            status: any(named: 'status'),
            ownerDid: any(named: 'ownerDid'),
          ),
        ).thenAnswer((_) async {});
        when(() => mockOutboxDao.getById(any(), any())).thenAnswer((_) async => item);
        when(
          () => mockOutboxDao.updateStatus(
            outboxId: any(named: 'outboxId'),
            status: any(named: 'status'),
            errorMessage: any(named: 'errorMessage'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockApi.call(any(), body: any(named: 'body')),
        ).thenAnswer((_) async => {'id': 'server_msg_id'});
        when(() => mockOutboxDao.deleteItem(any())).thenAnswer((_) async => 1);

        await repository.retryMessage('outbox1', 'did:plc:owner');

        verify(() => mockOutboxDao.resetForRetry('outbox1')).called(1);
        verify(
          () => mockApi.call('chat.bsky.convo.sendMessage', body: any(named: 'body')),
        ).called(1);
      });
    });

    group('deleteOutboxItem', () {
      test('removes item from outbox and deletes local message', () async {
        when(() => mockOutboxDao.deleteItem(any())).thenAnswer((_) async => 1);
        when(() => mockMessagesDao.deleteMessage(any(), any())).thenAnswer((_) async => 1);

        await repository.deleteOutboxItem('outbox1', 'did:plc:owner');

        verify(() => mockOutboxDao.deleteItem('outbox1')).called(1);
        verify(() => mockMessagesDao.deleteMessage('pending:outbox1', 'did:plc:owner')).called(1);
      });
    });

    group('getPendingCount', () {
      test('returns count from DAO', () async {
        when(() => mockOutboxDao.countPending(any())).thenAnswer((_) async => 5);

        final count = await repository.getPendingCount('did:plc:owner');

        expect(count, 5);
        verify(() => mockOutboxDao.countPending('did:plc:owner')).called(1);
      });
    });
  });
}
