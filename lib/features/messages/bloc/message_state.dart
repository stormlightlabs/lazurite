part of 'message_bloc.dart';

enum MessageStatus { initial, loading, loaded, sending, error }

class MessageState extends Equatable {
  const MessageState._({
    required this.status,
    this.messages = const [],
    this.cursor,
    this.hasMore = false,
    this.convoId,
    this.isSending = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  const MessageState.initial() : this._(status: MessageStatus.initial);

  const MessageState.loading() : this._(status: MessageStatus.loading);

  const MessageState.loaded({
    required List<UConvoGetMessagesMessages> messages,
    String? cursor,
    bool hasMore = false,
    required String convoId,
  }) : this._(status: MessageStatus.loaded, messages: messages, cursor: cursor, hasMore: hasMore, convoId: convoId);

  const MessageState.error(String message) : this._(status: MessageStatus.error, errorMessage: message);

  final MessageStatus status;
  final List<UConvoGetMessagesMessages> messages;
  final String? cursor;
  final bool hasMore;
  final String? convoId;
  final bool isSending;
  final bool isLoadingMore;
  final String? errorMessage;

  MessageState copyWith({
    MessageStatus? status,
    List<UConvoGetMessagesMessages>? messages,
    String? cursor,
    bool? hasMore,
    String? convoId,
    bool? isSending,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return MessageState._(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
      convoId: convoId ?? this.convoId,
      isSending: isSending ?? this.isSending,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, messages, cursor, hasMore, convoId, isSending, isLoadingMore, errorMessage];
}
