import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/dms/domain/dm_conversation.dart';
import 'package:lazurite/src/features/dms/presentation/conversation_list_notifier.dart';
import 'package:lazurite/src/features/dms/providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  group('ConversationListNotifier', () {
    late MockDmsRepository mockRepository;
    late ProviderContainer container;
    late Session testSession;

    setUp(() {
      mockRepository = MockDmsRepository();
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
          authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
        ],
      );
      addTearDown(container.dispose);
    });

    test('build watches conversations', () async {
      when(() => mockRepository.watchConversations(any())).thenAnswer((_) => Stream.value([]));

      final subscription = container.listen(conversationListProvider, (previous, next) {});

      expect(
        container.read(conversationListProvider),
        const AsyncValue<List<DmConversation>>.loading(),
      );

      await container.read(conversationListProvider.future);

      expect(container.read(conversationListProvider).value, isEmpty);
      verify(() => mockRepository.watchConversations(any())).called(1);

      subscription.close();
    });

    test('refresh fetches conversations', () async {
      when(() => mockRepository.watchConversations(any())).thenAnswer((_) => Stream.value([]));
      when(
        () => mockRepository.fetchConversations(ownerDid: any(named: 'ownerDid')),
      ).thenAnswer((_) async => 'cursor-1');

      final notifier = container.read(conversationListProvider.notifier);
      await notifier.refresh();

      verify(() => mockRepository.fetchConversations(ownerDid: any(named: 'ownerDid'))).called(1);
    });

    test('loadMore fetches conversations with cursor', () async {
      when(() => mockRepository.watchConversations(any())).thenAnswer((_) => Stream.value([]));
      when(
        () => mockRepository.fetchConversations(ownerDid: any(named: 'ownerDid')),
      ).thenAnswer((_) async => 'cursor-1');
      when(
        () => mockRepository.fetchConversations(
          ownerDid: any(named: 'ownerDid'),
          cursor: 'cursor-1',
        ),
      ).thenAnswer((_) async => 'cursor-2');

      final notifier = container.read(conversationListProvider.notifier);

      await notifier.refresh();

      await notifier.loadMore();

      verify(
        () => mockRepository.fetchConversations(
          cursor: 'cursor-1',
          ownerDid: any(named: 'ownerDid'),
        ),
      ).called(1);
    });

    test('acceptConversation calls repository', () async {
      when(() => mockRepository.watchConversations(any())).thenAnswer((_) => Stream.value([]));
      when(() => mockRepository.acceptConversation(any(), any())).thenAnswer((_) async {});

      final notifier = container.read(conversationListProvider.notifier);
      await notifier.acceptConversation('123');

      verify(() => mockRepository.acceptConversation('123', any())).called(1);
    });
  });
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._session);

  final Session _session;

  @override
  AuthState build() => AuthState.authenticated(_session);
}
