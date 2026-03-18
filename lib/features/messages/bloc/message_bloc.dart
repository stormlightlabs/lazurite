import 'package:bluesky/chat_bsky_convo_getmessages.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  MessageBloc({required ConvoRepository convoRepository, required String currentUserDid})
    : _convoRepository = convoRepository,
      _currentUserDid = currentUserDid,
      super(const MessageState.initial()) {
    on<MessagesRequested>(_onMessagesRequested);
    on<MessagesPageLoaded>(_onMessagesPageLoaded);
    on<MessageSent>(_onMessageSent);
    on<MessageDeleted>(_onMessageDeleted);
    on<ConvoMarkedRead>(_onConvoMarkedRead);
  }

  final ConvoRepository _convoRepository;
  final String _currentUserDid;

  String get currentUserDid => _currentUserDid;

  Future<void> _onMessagesRequested(MessagesRequested event, Emitter<MessageState> emit) async {
    emit(const MessageState.loading());

    try {
      final result = await _convoRepository.getMessages(event.convoId, limit: event.limit);

      emit(
        MessageState.loaded(
          messages: result.messages,
          cursor: result.cursor,
          hasMore: result.cursor != null,
          convoId: event.convoId,
        ),
      );
    } catch (error) {
      emit(MessageState.error('Failed to load messages: $error'));
      log.e('Failed to load messages: $error');
    }
  }

  Future<void> _onMessagesPageLoaded(MessagesPageLoaded event, Emitter<MessageState> emit) async {
    if (state.status != MessageStatus.loaded || state.cursor == null || state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    try {
      final result = await _convoRepository.getMessages(state.convoId!, cursor: state.cursor, limit: event.limit);

      emit(
        state.copyWith(
          messages: [...state.messages, ...result.messages],
          cursor: result.cursor,
          hasMore: result.cursor != null,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoadingMore: false, hasMore: false));
      log.e('Failed to load more messages: $error');
    }
  }

  Future<void> _onMessageSent(MessageSent event, Emitter<MessageState> emit) async {
    if (state.status != MessageStatus.loaded || state.convoId == null) {
      return;
    }

    emit(state.copyWith(isSending: true));

    try {
      final messageView = await _convoRepository.sendMessage(state.convoId!, event.text);
      final newMessage = UConvoGetMessagesMessages.messageView(data: messageView);

      emit(state.copyWith(messages: [newMessage, ...state.messages], isSending: false));
    } catch (error) {
      emit(state.copyWith(isSending: false));
      log.w('Failed to send message: $error');
    }
  }

  Future<void> _onMessageDeleted(MessageDeleted event, Emitter<MessageState> emit) async {
    if (state.status != MessageStatus.loaded || state.convoId == null) {
      return;
    }

    try {
      final deletedView = await _convoRepository.deleteMessageForSelf(state.convoId!, event.messageId);
      final deletedMessage = UConvoGetMessagesMessages.deletedMessageView(data: deletedView);

      final updatedMessages = state.messages.map((m) {
        final isTarget = m.when(
          messageView: (data) => data.id == event.messageId,
          deletedMessageView: (_) => false,
          unknown: (_) => false,
        );
        return isTarget ? deletedMessage : m;
      }).toList();

      emit(state.copyWith(messages: updatedMessages));
    } catch (error) {
      log.w('Failed to delete message ${event.messageId}: $error');
    }
  }

  Future<void> _onConvoMarkedRead(ConvoMarkedRead event, Emitter<MessageState> emit) async {
    if (state.convoId == null) return;

    try {
      await _convoRepository.updateRead(state.convoId!);
    } catch (_) {
      log.w('Failed to mark conversation as read');
    }
  }
}
