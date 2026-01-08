import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/dms/domain/dm_message.dart';
import 'package:lazurite/src/features/dms/presentation/conversation_detail_notifier.dart';
import 'package:lazurite/src/features/dms/providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  group('ConversationDetailNotifier', () {
    late MockDmsRepository mockRepository;
    late MockOutboxRepository mockOutboxRepository;
    late ProviderContainer container;
    late Session testSession;
    const testConvoId = 'convo-123';

    setUp(() {
      mockRepository = MockDmsRepository();
      mockOutboxRepository = MockOutboxRepository();
      testSession = Session(
        did: 'did:web:test',
        handle: 'handle',
        pdsUrl: 'https://pds',
        accessJwt: 'access',
        refreshJwt: 'refresh',
        scope: 'scope',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        dpopKey: const <String, dynamic>{},
      );
      container = ProviderContainer(
        overrides: [
          dmsRepositoryProvider.overrideWithValue(mockRepository),
          outboxRepositoryProvider.overrideWithValue(mockOutboxRepository),
          authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
        ],
      );
      addTearDown(container.dispose);
    });

    test('build watches messages stream', () async {
      when(() => mockRepository.watchMessages(any(), any())).thenAnswer((_) => Stream.value([]));
      when(
        () => mockRepository.fetchMessages(
          any(),
          ownerDid: any(named: 'ownerDid'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => mockRepository.updateReadState(
          convoId: any(named: 'convoId'),
          ownerDid: any(named: 'ownerDid'),
          messageId: any(named: 'messageId'),
        ),
      ).thenAnswer((_) async {});

      final subscription = container.listen(
        conversationDetailProvider(testConvoId),
        (previous, next) {},
      );

      expect(
        container.read(conversationDetailProvider(testConvoId)),
        const AsyncValue<List<AppDmMessage>>.loading(),
      );

      await container.read(conversationDetailProvider(testConvoId).future);

      expect(container.read(conversationDetailProvider(testConvoId)).value, isEmpty);
      verify(() => mockRepository.watchMessages(testConvoId, any())).called(2);

      subscription.close();
    });

    test('refresh fetches messages', () async {
      when(() => mockRepository.watchMessages(any(), any())).thenAnswer((_) => Stream.value([]));
      when(
        () => mockRepository.fetchMessages(any(), ownerDid: any(named: 'ownerDid')),
      ).thenAnswer((_) async => 'cursor-1');
      when(
        () => mockRepository.fetchMessages(
          any(),
          ownerDid: any(named: 'ownerDid'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => mockRepository.updateReadState(
          convoId: any(named: 'convoId'),
          ownerDid: any(named: 'ownerDid'),
          messageId: any(named: 'messageId'),
        ),
      ).thenAnswer((_) async {});

      final notifier = container.read(conversationDetailProvider(testConvoId).notifier);
      await notifier.refresh();

      verify(
        () => mockRepository.fetchMessages(testConvoId, ownerDid: any(named: 'ownerDid')),
      ).called(1);
    });

    test('sendMessage enqueues in outbox and processes', () async {
      when(() => mockRepository.watchMessages(any(), any())).thenAnswer((_) => Stream.value([]));
      when(
        () => mockRepository.fetchMessages(
          any(),
          ownerDid: any(named: 'ownerDid'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => mockRepository.updateReadState(
          convoId: any(named: 'convoId'),
          ownerDid: any(named: 'ownerDid'),
          messageId: any(named: 'messageId'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => mockOutboxRepository.enqueueSend(any(), any(), any()),
      ).thenAnswer((_) async => 'outbox-id');
      when(() => mockOutboxRepository.processOutbox(any())).thenAnswer((_) async {});

      final notifier = container.read(conversationDetailProvider(testConvoId).notifier);
      await notifier.sendMessage('Hello!');

      verify(() => mockOutboxRepository.enqueueSend(testConvoId, 'Hello!', any())).called(1);
      verify(() => mockOutboxRepository.processOutbox(any())).called(1);
    });

    test('retryMessage calls outbox retry', () async {
      when(() => mockRepository.watchMessages(any(), any())).thenAnswer((_) => Stream.value([]));
      when(
        () => mockRepository.fetchMessages(
          any(),
          ownerDid: any(named: 'ownerDid'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => mockRepository.updateReadState(
          convoId: any(named: 'convoId'),
          ownerDid: any(named: 'ownerDid'),
          messageId: any(named: 'messageId'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockOutboxRepository.retryMessage(any(), any())).thenAnswer((_) async {});

      final notifier = container.read(conversationDetailProvider(testConvoId).notifier);
      await notifier.retryMessage('outbox-456');

      verify(() => mockOutboxRepository.retryMessage('outbox-456', any())).called(1);
    });
  });
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._session);

  final Session _session;

  @override
  AuthState build() => AuthState.authenticated(_session);
}
