import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/dms/domain/dm_conversation.dart';
import 'package:lazurite/src/features/dms/presentation/conversation_list_notifier.dart';
import 'package:lazurite/src/features/dms/providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  group('ConversationListNotifier', () {
    late MockDmsRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockDmsRepository();
      container = ProviderContainer(
        overrides: [dmsRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);
    });

    test('build watches conversations', () async {
      when(() => mockRepository.watchConversations()).thenAnswer((_) => Stream.value([]));

      final subscription = container.listen(conversationListProvider, (previous, next) {});

      expect(
        container.read(conversationListProvider),
        const AsyncValue<List<DmConversation>>.loading(),
      );

      await container.read(conversationListProvider.future);

      expect(container.read(conversationListProvider).value, isEmpty);
      verify(() => mockRepository.watchConversations()).called(1);

      subscription.close();
    });

    test('refresh fetches conversations', () async {
      when(() => mockRepository.watchConversations()).thenAnswer((_) => Stream.value([]));
      when(() => mockRepository.fetchConversations()).thenAnswer((_) async => 'cursor-1');

      final notifier = container.read(conversationListProvider.notifier);
      await notifier.refresh();

      verify(() => mockRepository.fetchConversations()).called(1);
    });

    test('loadMore fetches conversations with cursor', () async {
      when(() => mockRepository.watchConversations()).thenAnswer((_) => Stream.value([]));
      when(() => mockRepository.fetchConversations()).thenAnswer((_) async => 'cursor-1');
      when(
        () => mockRepository.fetchConversations(cursor: 'cursor-1'),
      ).thenAnswer((_) async => 'cursor-2');

      final notifier = container.read(conversationListProvider.notifier);

      await notifier.refresh();

      await notifier.loadMore();

      verify(() => mockRepository.fetchConversations(cursor: 'cursor-1')).called(1);
    });

    test('acceptConversation calls repository', () async {
      when(() => mockRepository.watchConversations()).thenAnswer((_) => Stream.value([]));
      when(() => mockRepository.acceptConversation(any())).thenAnswer((_) async {});

      final notifier = container.read(conversationListProvider.notifier);
      await notifier.acceptConversation('123');

      verify(() => mockRepository.acceptConversation('123')).called(1);
    });
  });
}
