part of 'convo_list_bloc.dart';

sealed class ConvoListEvent extends Equatable {
  const ConvoListEvent();

  @override
  List<Object?> get props => [];
}

class ConvosRequested extends ConvoListEvent {
  const ConvosRequested({this.limit = 20});

  final int limit;

  @override
  List<Object?> get props => [limit];
}

class ConvosRefreshed extends ConvoListEvent {
  const ConvosRefreshed();
}

class ConvoMuted extends ConvoListEvent {
  const ConvoMuted({required this.convoId});

  final String convoId;

  @override
  List<Object?> get props => [convoId];
}

class ConvoUnmuted extends ConvoListEvent {
  const ConvoUnmuted({required this.convoId});

  final String convoId;

  @override
  List<Object?> get props => [convoId];
}

class ConvoTabChanged extends ConvoListEvent {
  const ConvoTabChanged({required this.tab});

  final ConvoTab tab;

  @override
  List<Object?> get props => [tab];
}

class ConvoUpserted extends ConvoListEvent {
  const ConvoUpserted({required this.convo});

  final ConvoView convo;

  @override
  List<Object?> get props => [convo];
}
