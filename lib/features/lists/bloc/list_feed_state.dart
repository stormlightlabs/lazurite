part of 'list_feed_bloc.dart';

enum ListFeedStatus { initial, loading, loaded, error }

class ListFeedState extends Equatable {
  const ListFeedState._({
    required this.status,
    this.listUri,
    this.posts = const [],
    this.cursor,
    this.hasMore = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  const ListFeedState.initial() : this._(status: ListFeedStatus.initial);

  const ListFeedState.loading({required AtUri listUri}) : this._(status: ListFeedStatus.loading, listUri: listUri);

  const ListFeedState.loaded({
    required AtUri listUri,
    required List<FeedViewPost> posts,
    String? cursor,
    required bool hasMore,
    bool isRefreshing = false,
    bool isLoadingMore = false,
    String? errorMessage,
  }) : this._(
         status: ListFeedStatus.loaded,
         listUri: listUri,
         posts: posts,
         cursor: cursor,
         hasMore: hasMore,
         isRefreshing: isRefreshing,
         isLoadingMore: isLoadingMore,
         errorMessage: errorMessage,
       );

  const ListFeedState.error(String message, {AtUri? listUri})
    : this._(status: ListFeedStatus.error, listUri: listUri, errorMessage: message);

  final ListFeedStatus status;
  final AtUri? listUri;
  final List<FeedViewPost> posts;
  final String? cursor;
  final bool hasMore;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get isLoading => status == ListFeedStatus.loading;
  bool get hasError => status == ListFeedStatus.error;
  bool get hasPosts => posts.isNotEmpty;

  ListFeedState copyWith({
    ListFeedStatus? status,
    Object? listUri = _listFeedNoValue,
    List<FeedViewPost>? posts,
    Object? cursor = _listFeedNoValue,
    bool? hasMore,
    bool? isRefreshing,
    bool? isLoadingMore,
    Object? errorMessage = _listFeedNoValue,
  }) {
    return ListFeedState._(
      status: status ?? this.status,
      listUri: listUri == _listFeedNoValue ? this.listUri : listUri as AtUri?,
      posts: posts ?? this.posts,
      cursor: cursor == _listFeedNoValue ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage == _listFeedNoValue ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, listUri, posts, cursor, hasMore, isRefreshing, isLoadingMore, errorMessage];
}

const _listFeedNoValue = Object();
