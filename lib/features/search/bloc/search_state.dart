part of 'search_bloc.dart';

enum SearchTab { posts, actors, feeds, starterPacks }

extension SearchTabLabel on SearchTab {
  String get label => switch (this) {
    SearchTab.posts => 'Posts',
    SearchTab.actors => 'People',
    SearchTab.feeds => 'Feeds',
    SearchTab.starterPacks => 'Starter Packs',
  };
}

enum SearchSort {
  top,
  latest;

  factory SearchSort.fromString(String value) => switch (value) {
    'top' => SearchSort.top,
    _ => SearchSort.latest,
  };
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
    this.feeds = const [],
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

  const SearchState.loadingFeeds({required String query})
    : this._(status: SearchStatus.loading, query: query, currentTab: SearchTab.feeds);

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

  const SearchState.loadedFeeds({required String query, required List<GeneratorView> feeds, String? cursor})
    : this._(status: SearchStatus.loaded, query: query, currentTab: SearchTab.feeds, feeds: feeds, cursor: cursor);

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

  const SearchState.error({required String query, required String message, required SearchTab tab, String sort = 'top'})
    : this._(status: SearchStatus.error, query: query, currentTab: tab, currentSort: sort, errorMessage: message);

  static const Object _unset = Object();

  final SearchStatus status;
  final String query;
  final SearchTab currentTab;
  final String currentSort;
  final List<PostView> posts;
  final List<ProfileView> actors;
  final List<GeneratorView> feeds;
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
  bool get hasResults => posts.isNotEmpty || actors.isNotEmpty || feeds.isNotEmpty || starterPacks.isNotEmpty;
  bool get hasMore => cursor != null || starterPacksCursor != null;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    SearchTab? currentTab,
    String? currentSort,
    List<PostView>? posts,
    List<ProfileView>? actors,
    List<GeneratorView>? feeds,
    List<StarterPackViewBasic>? starterPacks,
    Object? cursor = _unset,
    Object? starterPacksCursor = _unset,
    Object? hitsTotal = _unset,
    Object? errorMessage = _unset,
    bool? isLoadingMore,
    List<ProfileViewBasic>? typeaheadActors,
    List<SearchHistoryEntry>? searchHistory,
  }) => SearchState._(
    status: status ?? this.status,
    query: query ?? this.query,
    currentTab: currentTab ?? this.currentTab,
    currentSort: currentSort ?? this.currentSort,
    posts: posts ?? this.posts,
    actors: actors ?? this.actors,
    feeds: feeds ?? this.feeds,
    starterPacks: starterPacks ?? this.starterPacks,
    cursor: identical(cursor, _unset) ? this.cursor : cursor as String?,
    starterPacksCursor: identical(starterPacksCursor, _unset) ? this.starterPacksCursor : starterPacksCursor as String?,
    hitsTotal: identical(hitsTotal, _unset) ? this.hitsTotal : hitsTotal as int?,
    errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    typeaheadActors: typeaheadActors ?? this.typeaheadActors,
    searchHistory: searchHistory ?? this.searchHistory,
  );

  @override
  List<Object?> get props => [
    status,
    query,
    currentTab,
    currentSort,
    posts,
    actors,
    feeds,
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
