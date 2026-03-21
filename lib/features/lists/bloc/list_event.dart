part of 'list_bloc.dart';

sealed class ListEvent extends Equatable {
  const ListEvent();

  @override
  List<Object?> get props => [];
}

final class ListRequested extends ListEvent {
  const ListRequested({required this.listUri, this.limit = 50});

  final AtUri listUri;
  final int limit;

  @override
  List<Object?> get props => [listUri, limit];
}

final class ListRefreshed extends ListEvent {
  const ListRefreshed();
}

final class ListItemAdded extends ListEvent {
  const ListItemAdded({required this.subjectDid});

  final String subjectDid;

  @override
  List<Object?> get props => [subjectDid];
}

final class ListItemRemoved extends ListEvent {
  const ListItemRemoved({required this.listItemUri});

  final AtUri listItemUri;

  @override
  List<Object?> get props => [listItemUri];
}

final class ListMuted extends ListEvent {
  const ListMuted();
}

final class ListUnmuted extends ListEvent {
  const ListUnmuted();
}

final class ListBlocked extends ListEvent {
  const ListBlocked();
}

final class ListUnblocked extends ListEvent {
  const ListUnblocked();
}
