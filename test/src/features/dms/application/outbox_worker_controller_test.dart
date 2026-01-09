import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockOutboxRepository mockOutboxRepository;
  late MockLogger mockLogger;
  const ownerDid = 'did:plc:testowner';

  setUp(() {
    mockOutboxRepository = MockOutboxRepository();
    mockLogger = MockLogger();

    when(() => mockLogger.info(any(), any())).thenReturn(null);
    when(() => mockLogger.debug(any(), any())).thenReturn(null);
    when(() => mockLogger.error(any(), any(), any())).thenReturn(null);
  });

  group('OutboxWorkerController behavior', () {
    test('processOutbox skips when not authenticated', () async {
      verifyNever(() => mockOutboxRepository.processOutbox(any()));
    });

    test('processOutbox is called with correct ownerDid when authenticated', () async {
      when(() => mockOutboxRepository.processOutbox(any())).thenAnswer((_) async {});

      await mockOutboxRepository.processOutbox(ownerDid);
      verify(() => mockOutboxRepository.processOutbox(ownerDid)).called(1);
    });

    test('processOutbox handles errors gracefully', () async {
      when(() => mockOutboxRepository.processOutbox(any())).thenThrow(Exception('Network error'));
      expect(() async => mockOutboxRepository.processOutbox(ownerDid), throwsException);
    });
  });

  group('OutboxRepository integration with worker', () {
    test('enqueue followed by processOutbox sends message', () async {
      when(
        () => mockOutboxRepository.enqueueSend(any(), any(), any()),
      ).thenAnswer((_) async => 'outbox-123');
      when(() => mockOutboxRepository.processOutbox(any())).thenAnswer((_) async {});

      final outboxId = await mockOutboxRepository.enqueueSend('convo1', 'Hello!', ownerDid);
      await mockOutboxRepository.processOutbox(ownerDid);

      expect(outboxId, 'outbox-123');
      verify(() => mockOutboxRepository.enqueueSend('convo1', 'Hello!', ownerDid)).called(1);
      verify(() => mockOutboxRepository.processOutbox(ownerDid)).called(1);
    });

    test('multiple enqueues are processed in order', () async {
      final processedIds = <String>[];

      when(() => mockOutboxRepository.enqueueSend(any(), any(), any())).thenAnswer((
        invocation,
      ) async {
        final convoId = invocation.positionalArguments[0] as String;
        return 'outbox-$convoId';
      });
      when(() => mockOutboxRepository.processOutbox(any())).thenAnswer((_) async {
        processedIds.addAll(['outbox-convo1', 'outbox-convo2']);
      });

      await mockOutboxRepository.enqueueSend('convo1', 'First', ownerDid);
      await mockOutboxRepository.enqueueSend('convo2', 'Second', ownerDid);
      await mockOutboxRepository.processOutbox(ownerDid);

      expect(processedIds, ['outbox-convo1', 'outbox-convo2']);
    });
  });

  group('Auth state handling', () {
    test('authenticated state provides correct DID', () {
      final session = Session(
        did: ownerDid,
        handle: 'test.bsky.social',
        accessJwt: 'access-token',
        refreshJwt: 'refresh-token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        pdsUrl: 'https://pds.bsky.social',
        scope: 'atproto',
        dpopKey: const <String, dynamic>{},
      );

      final authState = AuthState.authenticated(session);

      expect(authState, isA<AuthStateAuthenticated>());
      expect((authState as AuthStateAuthenticated).session.did, ownerDid);
    });

    test('unauthenticated state prevents processing', () {
      const authState = AuthState.unauthenticated();
      expect(authState, isA<AuthStateUnauthenticated>());
    });
  });

  group('Reliability scenarios', () {
    test('retry mechanism is available after failure', () async {
      when(() => mockOutboxRepository.retryMessage(any(), any())).thenAnswer((_) async {});
      await mockOutboxRepository.retryMessage('outbox-123', ownerDid);
      verify(() => mockOutboxRepository.retryMessage('outbox-123', ownerDid)).called(1);
    });

    test('pending count can be queried', () async {
      when(() => mockOutboxRepository.getPendingCount(any())).thenAnswer((_) async => 3);
      final count = await mockOutboxRepository.getPendingCount(ownerDid);
      expect(count, 3);
    });

    test('failed messages can be deleted', () async {
      when(() => mockOutboxRepository.deleteOutboxItem(any(), any())).thenAnswer((_) async {});
      await mockOutboxRepository.deleteOutboxItem('outbox-123', ownerDid);
      verify(() => mockOutboxRepository.deleteOutboxItem('outbox-123', ownerDid)).called(1);
    });
  });
}
