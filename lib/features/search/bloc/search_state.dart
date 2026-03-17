part of 'search_bloc.dart';

enum SearchTab { posts, actors }

extension SearchTabLabel on SearchTab {
  String get label => switch (this) {
    SearchTab.posts => 'Posts',
    SearchTab.actors => 'People',
  };
}

enum SearchSort {
  top,
  latest;

  factory SearchSort.fromString(String value) {
    return switch (value) {
      'top' => SearchSort.top,
      _ => SearchSort.latest,
    };
  }
}

extension SearchSortLabel on SearchSort {
  String get label => switch (this) {
    SearchSort.top => 'Top',
    SearchSort.latest => 'Latest',
  };
}

enum SearchStatus { initial, loading, loaded, error }

class SearchState extends Equatable {
  const SearchState._({
    required this.status,
    this.query = '',
    this.currentTab = SearchTab.posts,
    this.currentSort = 'top',
    this.posts = const [],
    this.actors = const [],
    this.cursor,
    this.hitsTotal,
    this.errorMessage,
    this.isLoadingMore = false,
    this.typeaheadActors = const [],
    this.searchHistory = const [],
  });

  const SearchState.initial() : this._(status: SearchStatus.initial);

  const SearchState.loadingPosts({required String query, required String sort})
    : this._(status: SearchStatus.loading, query: query, currentSort: sort);

  const SearchState.loadingActors({required String query})
    : this._(status: SearchStatus.loading, query: query, currentTab: SearchTab.actors);

  const SearchState.loadedPosts({
    required String query,
    required String sort,
    required List<PostView> posts,
    String? cursor,
    int? hitsTotal,
  }) : this._(
         status: SearchStatus.loaded,
         query: query,
         currentSort: sort,
         posts: posts,
         cursor: cursor,
         hitsTotal: hitsTotal,
       );

  const SearchState.loadedActors({required String query, required List<ProfileView> actors, String? cursor})
    : this._(status: SearchStatus.loaded, query: query, currentTab: SearchTab.actors, actors: actors, cursor: cursor);

  const SearchState.error({required String query, required String message})
    : this._(status: SearchStatus.error, query: query, errorMessage: message);

  final SearchStatus status;
  final String query;
  final SearchTab currentTab;
  final String currentSort;
  final List<PostView> posts;
  final List<ProfileView> actors;
  final String? cursor;
  final int? hitsTotal;
  final String? errorMessage;
  final bool isLoadingMore;
  final List<ProfileViewBasic> typeaheadActors;
  final List<SearchHistoryEntry> searchHistory;

  bool get isLoading => status == SearchStatus.loading;
  bool get hasError => status == SearchStatus.error;
  bool get hasResults => posts.isNotEmpty || actors.isNotEmpty;
  bool get hasMore => cursor != null;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    SearchTab? currentTab,
    String? currentSort,
    List<PostView>? posts,
    List<ProfileView>? actors,
    String? cursor,
    int? hitsTotal,
    String? errorMessage,
    bool? isLoadingMore,
    List<ProfileViewBasic>? typeaheadActors,
    List<SearchHistoryEntry>? searchHistory,
  }) {
    return SearchState._(
      status: status ?? this.status,
      query: query ?? this.query,
      currentTab: currentTab ?? this.currentTab,
      currentSort: currentSort ?? this.currentSort,
      posts: posts ?? this.posts,
      actors: actors ?? this.actors,
      cursor: cursor ?? this.cursor,
      hitsTotal: hitsTotal ?? this.hitsTotal,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      typeaheadActors: typeaheadActors ?? this.typeaheadActors,
      searchHistory: searchHistory ?? this.searchHistory,
    );
  }

  @override
  List<Object?> get props => [
    status,
    query,
    currentTab,
    currentSort,
    posts,
    actors,
    cursor,
    hitsTotal,
    errorMessage,
    isLoadingMore,
    typeaheadActors,
    searchHistory,
  ];
}
