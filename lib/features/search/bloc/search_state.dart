part of 'search_bloc.dart';

enum SearchTab { posts, actors, starterPacks }

extension SearchTabLabel on SearchTab {
  String get label => switch (this) {
    SearchTab.posts => 'Posts',
    SearchTab.actors => 'People',
    SearchTab.starterPacks => 'Starter Packs',
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
    this.starterPacks = const [],
    this.cursor,
    this.starterPacksCursor,
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

  const SearchState.loadingStarterPacks({required String query})
    : this._(status: SearchStatus.loading, query: query, currentTab: SearchTab.starterPacks);

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

  const SearchState.loadedStarterPacks({
    required String query,
    required List<StarterPackViewBasic> starterPacks,
    String? starterPacksCursor,
  }) : this._(
         status: SearchStatus.loaded,
         query: query,
         currentTab: SearchTab.starterPacks,
         starterPacks: starterPacks,
         starterPacksCursor: starterPacksCursor,
       );

  const SearchState.error({required String query, required String message})
    : this._(status: SearchStatus.error, query: query, errorMessage: message);

  final SearchStatus status;
  final String query;
  final SearchTab currentTab;
  final String currentSort;
  final List<PostView> posts;
  final List<ProfileView> actors;
  final List<StarterPackViewBasic> starterPacks;
  final String? cursor;
  final String? starterPacksCursor;
  final int? hitsTotal;
  final String? errorMessage;
  final bool isLoadingMore;
  final List<ProfileViewBasic> typeaheadActors;
  final List<SearchHistoryEntry> searchHistory;

  bool get isLoading => status == SearchStatus.loading;
  bool get hasError => status == SearchStatus.error;
  bool get hasResults => posts.isNotEmpty || actors.isNotEmpty || starterPacks.isNotEmpty;
  bool get hasMore => cursor != null || starterPacksCursor != null;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    SearchTab? currentTab,
    String? currentSort,
    List<PostView>? posts,
    List<ProfileView>? actors,
    List<StarterPackViewBasic>? starterPacks,
    String? cursor,
    String? starterPacksCursor,
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
      starterPacks: starterPacks ?? this.starterPacks,
      cursor: cursor ?? this.cursor,
      starterPacksCursor: starterPacksCursor ?? this.starterPacksCursor,
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
    starterPacks,
    cursor,
    starterPacksCursor,
    hitsTotal,
    errorMessage,
    isLoadingMore,
    typeaheadActors,
    searchHistory,
  ];
}
