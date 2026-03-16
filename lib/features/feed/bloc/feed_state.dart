part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, loaded, error }

class FeedState extends Equatable {
  const FeedState._({
    required this.status,
    this.actor,
    this.posts = const [],
    this.cursor,
    this.errorMessage,
    this.filter = FeedFilter.postsAndAuthorThreads,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  const FeedState.initial() : this._(status: FeedStatus.initial);

  const FeedState.loading({required String actor, FeedFilter filter = FeedFilter.postsAndAuthorThreads})
    : this._(status: FeedStatus.loading, actor: actor, filter: filter, hasMore: false);

  const FeedState.loaded({
    required String actor,
    required List<FeedViewPost> posts,
    String? cursor,
    FeedFilter filter = FeedFilter.postsAndAuthorThreads,
    bool hasMore = true,
  }) : this._(status: FeedStatus.loaded, actor: actor, posts: posts, cursor: cursor, filter: filter, hasMore: hasMore);

  const FeedState.error(String message) : this._(status: FeedStatus.error, errorMessage: message);

  final FeedStatus status;
  final String? actor;
  final List<FeedViewPost> posts;
  final String? cursor;
  final String? errorMessage;
  final FeedFilter filter;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;

  bool get isLoading => status == FeedStatus.loading;
  bool get hasError => status == FeedStatus.error;
  bool get hasPosts => posts.isNotEmpty;

  FeedState copyWith({
    FeedStatus? status,
    String? actor,
    List<FeedViewPost>? posts,
    String? cursor,
    String? errorMessage,
    FeedFilter? filter,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return FeedState._(
      status: status ?? this.status,
      actor: actor ?? this.actor,
      posts: posts ?? this.posts,
      cursor: cursor ?? this.cursor,
      errorMessage: errorMessage ?? this.errorMessage,
      filter: filter ?? this.filter,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [status, actor, posts, cursor, errorMessage, filter, hasMore, isLoadingMore, isRefreshing];
}
