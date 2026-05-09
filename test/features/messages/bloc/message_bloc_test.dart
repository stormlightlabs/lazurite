import 'package:bloc_test/bloc_test.dart';
import 'package:poptart_lex/chat/bsky/convo/defs.dart';
import 'package:poptart_lex/chat/bsky/convo/get_messages.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/messages/bloc/message_bloc.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockConvoRepository extends Mock implements ConvoRepository {}

void main() {
  late MockConvoRepository mockConvoRepository;

  const testConvoId = 'convo-123';
  const testUserDid = 'did:plc:testuser';

  setUp(() {
    mockConvoRepository = MockConvoRepository();
  });

  MessageView makeMessageView(String id, String text) => MessageView(
    id: id,
    rev: 'rev-1',
    text: text,
    sender: const MessageViewSender(did: testUserDid),
    sentAt: DateTime.utc(2026, 3, 15),
  );

  UConvoGetMessagesMessages makeMessage(String id, String text) =>
      UConvoGetMessagesMessages.messageView(data: makeMessageView(id, text));

  group('MessageBloc', () {
    blocTest<MessageBloc, MessageState>(
      'emits loading and loaded when MessagesRequested succeeds',
      build: () => MessageBloc(convoRepository: mockConvoRepository, currentUserDid: testUserDid),
      setUp: () {
        when(
          () => mockConvoRepository.getMessages(
            any(),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => MessageListResult(messages: [makeMessage('msg-1', 'Hello')], cursor: 'cursor-1'));
      },
      act: (bloc) => bloc.add(const MessagesRequested(convoId: testConvoId)),
      expect: () => [
        const MessageState.loading(),
        predicate<MessageState>(
          (state) =>
              state.status == MessageStatus.loaded &&
              state.messages.length == 1 &&
              state.cursor == 'cursor-1' &&
              state.hasMore == true &&
              state.convoId == testConvoId,
        ),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'emits error when MessagesRequested fails',
      build: () => MessageBloc(convoRepository: mockConvoRepository, currentUserDid: testUserDid),
      setUp: () {
        when(
          () => mockConvoRepository.getMessages(
            any(),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('Network error'));
      },
      act: (bloc) => bloc.add(const MessagesRequested(convoId: testConvoId)),
      expect: () => [
        const MessageState.loading(),
        predicate<MessageState>((state) => state.status == MessageStatus.error),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'loads more messages on MessagesPageLoaded',
      build: () => MessageBloc(convoRepository: mockConvoRepository, currentUserDid: testUserDid),
      seed: () => MessageState.loaded(
        messages: [makeMessage('msg-1', 'Hello')],
        cursor: 'cursor-1',
        hasMore: true,
        convoId: testConvoId,
      ),
      setUp: () {
        when(
          () => mockConvoRepository.getMessages(
            any(),
            cursor: 'cursor-1',
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => MessageListResult(messages: [makeMessage('msg-2', 'World')], cursor: null));
      },
      act: (bloc) => bloc.add(const MessagesPageLoaded()),
      expect: () => [
        predicate<MessageState>((state) => state.isLoadingMore),
        predicate<MessageState>(
          (state) =>
              state.status == MessageStatus.loaded &&
              state.messages.length == 2 &&
              !state.hasMore &&
              !state.isLoadingMore,
        ),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'does not load more when already loading more',
      build: () => MessageBloc(convoRepository: mockConvoRepository, currentUserDid: testUserDid),
      seed: () => MessageState.loaded(
        messages: [makeMessage('msg-1', 'Hello')],
        cursor: 'cursor-1',
        hasMore: true,
        convoId: testConvoId,
      ).copyWith(isLoadingMore: true),
      act: (bloc) => bloc.add(const MessagesPageLoaded()),
      expect: () => [],
      verify: (_) {
        verifyNever(
          () => mockConvoRepository.getMessages(
            any(),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        );
      },
    );

    blocTest<MessageBloc, MessageState>(
      'sends message and prepends to list on MessageSent',
      build: () => MessageBloc(convoRepository: mockConvoRepository, currentUserDid: testUserDid),
      seed: () => MessageState.loaded(messages: [makeMessage('msg-1', 'Hello')], cursor: null, convoId: testConvoId),
      setUp: () {
        when(
          () => mockConvoRepository.sendMessage(any(), any()),
        ).thenAnswer((_) async => makeMessageView('msg-new', 'World'));
      },
      act: (bloc) => bloc.add(const MessageSent(text: 'World')),
      expect: () => [
        predicate<MessageState>((state) => state.isSending),
        predicate<MessageState>((state) => state.messages.length == 2 && !state.isSending),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'handles send failure silently',
      build: () => MessageBloc(convoRepository: mockConvoRepository, currentUserDid: testUserDid),
      seed: () => MessageState.loaded(messages: [makeMessage('msg-1', 'Hello')], cursor: null, convoId: testConvoId),
      setUp: () {
        when(() => mockConvoRepository.sendMessage(any(), any())).thenThrow(Exception('Send failed'));
      },
      act: (bloc) => bloc.add(const MessageSent(text: 'World')),
      expect: () => [
        predicate<MessageState>((state) => state.isSending),
        predicate<MessageState>((state) => !state.isSending && state.messages.length == 1),
      ],
    );

    blocTest<MessageBloc, MessageState>(
      'calls updateRead on ConvoMarkedRead',
      build: () => MessageBloc(convoRepository: mockConvoRepository, currentUserDid: testUserDid),
      seed: () => const MessageState.loaded(messages: [], cursor: null, convoId: testConvoId),
      setUp: () {
        when(() => mockConvoRepository.updateRead(any())).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const ConvoMarkedRead()),
      expect: () => [],
      verify: (_) {
        verify(() => mockConvoRepository.updateRead(testConvoId)).called(1);
      },
    );

    blocTest<MessageBloc, MessageState>(
      'handles updateRead failure silently',
      build: () => MessageBloc(convoRepository: mockConvoRepository, currentUserDid: testUserDid),
      seed: () => const MessageState.loaded(messages: [], cursor: null, convoId: testConvoId),
      setUp: () {
        when(() => mockConvoRepository.updateRead(any())).thenThrow(Exception('Network error'));
      },
      act: (bloc) => bloc.add(const ConvoMarkedRead()),
      expect: () => [],
    );

    blocTest<MessageBloc, MessageState>(
      'does not send when state is not loaded',
      build: () => MessageBloc(convoRepository: mockConvoRepository, currentUserDid: testUserDid),
      act: (bloc) => bloc.add(const MessageSent(text: 'Hello')),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockConvoRepository.sendMessage(any(), any()));
      },
    );
  });
}
