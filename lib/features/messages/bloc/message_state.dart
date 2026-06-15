part of 'message_bloc.dart';

enum MessageStatus { initial, loading, loaded, sending, error }

const _messageStateNoValue = Object();

class MessageState extends Equatable {
  const MessageState._({
    required this.status,
    this.messages = const [],
    this.cursor,
    this.hasMore = false,
    this.convoId,
    this.convo,
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
    ConvoView? convo,
  }) : this._(
         status: MessageStatus.loaded,
         messages: messages,
         cursor: cursor,
         hasMore: hasMore,
         convoId: convoId,
         convo: convo,
       );

  const MessageState.error(String message) : this._(status: MessageStatus.error, errorMessage: message);

  final MessageStatus status;
  final List<UConvoGetMessagesMessages> messages;
  final String? cursor;
  final bool hasMore;
  final String? convoId;
  final ConvoView? convo;
  final bool isSending;
  final bool isLoadingMore;
  final String? errorMessage;

  MessageState copyWith({
    MessageStatus? status,
    List<UConvoGetMessagesMessages>? messages,
    Object? cursor = _messageStateNoValue,
    bool? hasMore,
    Object? convoId = _messageStateNoValue,
    Object? convo = _messageStateNoValue,
    bool? isSending,
    bool? isLoadingMore,
    Object? errorMessage = _messageStateNoValue,
  }) => MessageState._(
    status: status ?? this.status,
    messages: messages ?? this.messages,
    cursor: identical(cursor, _messageStateNoValue) ? this.cursor : cursor as String?,
    hasMore: hasMore ?? this.hasMore,
    convoId: identical(convoId, _messageStateNoValue) ? this.convoId : convoId as String?,
    convo: identical(convo, _messageStateNoValue) ? this.convo : convo as ConvoView?,
    isSending: isSending ?? this.isSending,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    errorMessage: identical(errorMessage, _messageStateNoValue) ? this.errorMessage : errorMessage as String?,
  );

  @override
  List<Object?> get props => [
    status,
    messages,
    cursor,
    hasMore,
    convoId,
    convo,
    isSending,
    isLoadingMore,
    errorMessage,
  ];
}
