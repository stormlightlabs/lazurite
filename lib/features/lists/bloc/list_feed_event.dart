part of 'list_feed_bloc.dart';

sealed class ListFeedEvent extends Equatable {
  const ListFeedEvent();

  @override
  List<Object?> get props => [];
}

final class ListFeedRequested extends ListFeedEvent {
  const ListFeedRequested({required this.listUri, this.limit = 50});

  final AtUri listUri;
  final int limit;

  @override
  List<Object?> get props => [listUri, limit];
}

final class ListFeedLoadMoreRequested extends ListFeedEvent {
  const ListFeedLoadMoreRequested({this.limit = 50});

  final int limit;

  @override
  List<Object?> get props => [limit];
}

final class ListFeedRefreshed extends ListFeedEvent {
  const ListFeedRefreshed({this.limit = 50});

  final int limit;

  @override
  List<Object?> get props => [limit];
}
