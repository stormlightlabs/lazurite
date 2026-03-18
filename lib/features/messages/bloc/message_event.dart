part of 'message_bloc.dart';

sealed class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

class MessagesRequested extends MessageEvent {
  const MessagesRequested({required this.convoId, this.limit = 50});

  final String convoId;
  final int limit;

  @override
  List<Object?> get props => [convoId, limit];
}

class MessagesPageLoaded extends MessageEvent {
  const MessagesPageLoaded({this.limit = 50});

  final int limit;

  @override
  List<Object?> get props => [limit];
}

class MessageSent extends MessageEvent {
  const MessageSent({required this.text});

  final String text;

  @override
  List<Object?> get props => [text];
}

class MessageDeleted extends MessageEvent {
  const MessageDeleted({required this.messageId});

  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

class ConvoMarkedRead extends MessageEvent {
  const ConvoMarkedRead();
}
