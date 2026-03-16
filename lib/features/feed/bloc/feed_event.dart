part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FeedLoadRequested extends FeedEvent {
  const FeedLoadRequested({required this.actor, this.filter = FeedFilter.postsAndAuthorThreads, this.limit = 50});
  final String actor;
  final FeedFilter filter;
  final int limit;

  @override
  List<Object?> get props => [actor, filter, limit];
}

class FeedLoadMoreRequested extends FeedEvent {
  const FeedLoadMoreRequested({this.limit = 50});
  final int limit;

  @override
  List<Object?> get props => [limit];
}

class FeedRefreshRequested extends FeedEvent {
  const FeedRefreshRequested();
}
