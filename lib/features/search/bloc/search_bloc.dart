import 'dart:async';

import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/search/data/post_search_filters.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';

part 'search_state.dart';

class SearchBlocConfig extends Equatable {
  const SearchBlocConfig.global({this.initialTab = SearchTab.posts, this.initialSort = 'top'})
    : postsOnly = false,
      fixedPostAuthor = null,
      enableHistory = true;

  const SearchBlocConfig.profileScoped({required this.fixedPostAuthor})
    : postsOnly = true,
      enableHistory = false,
      initialTab = SearchTab.posts,
      initialSort = 'latest';

  final bool postsOnly;
  final String? fixedPostAuthor;
  final bool enableHistory;
  final SearchTab initialTab;
  final String initialSort;

  @override
  List<Object?> get props => [postsOnly, fixedPostAuthor, enableHistory, initialTab, initialSort];
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required SearchRepository searchRepository,
    required TypeaheadRepository typeaheadRepository,
    required AppDatabase database,
    required String accountDid,
    SearchBlocConfig config = const SearchBlocConfig.global(),
  }) : _searchRepository = searchRepository,
       _typeaheadRepository = typeaheadRepository,
       _database = database,
       _accountDid = accountDid,
       _config = config,
       super(
         const SearchState.initial().copyWith(
           currentTab: config.initialTab,
           currentSort: config.initialSort == 'latest' ? 'latest' : 'top',
           postFilters: config.fixedPostAuthor == null
               ? const PostSearchFilters()
               : PostSearchFilters(author: config.fixedPostAuthor),
         ),
       ) {
    on<QuerySubmitted>(_onQuerySubmitted);
    on<SearchTabChanged>(_onSearchTabChanged);
    on<SearchSortChanged>(_onSearchSortChanged);
    on<PostFiltersChanged>(_onPostFiltersChanged);
    on<LoadMoreRequested>(_onLoadMoreRequested);
    on<TypeaheadRequested>(_onTypeaheadRequested);
    on<TypeaheadResultsLoaded>(_onTypeaheadResultsLoaded);
    on<HistoryLoaded>(_onHistoryLoaded);
    on<HistoryEntryDeleted>(_onHistoryEntryDeleted);
    on<HistoryCleared>(_onHistoryCleared);
    on<QueryCleared>(_onQueryCleared);

    if (_config.enableHistory) {
      add(const HistoryLoaded());
    }

    if (_shouldAutoLoadProfileScopedPosts) {
      add(const QuerySubmitted(query: ''));
    }
  }

  final SearchRepository _searchRepository;
  final TypeaheadRepository _typeaheadRepository;
  final AppDatabase _database;
  final String _accountDid;
  final SearchBlocConfig _config;
  Timer? _debounceTimer;

  bool get _shouldAutoLoadProfileScopedPosts =>
      _config.postsOnly && (_config.fixedPostAuthor?.trim().isNotEmpty ?? false);

  SearchState _freshInitialState() {
    return const SearchState.initial().copyWith(
      currentTab: _config.initialTab,
      currentSort: _config.initialSort == 'latest' ? 'latest' : 'top',
      postFilters: _config.fixedPostAuthor == null
          ? const PostSearchFilters()
          : PostSearchFilters(author: _config.fixedPostAuthor),
      searchHistory: _config.enableHistory ? state.searchHistory : const <SearchHistoryEntry>[],
    );
  }

  Future<void> _onQuerySubmitted(QuerySubmitted event, Emitter<SearchState> emit) async {
    final query = event.query.trim();
    final currentTab = state.currentTab;

    if (currentTab == SearchTab.posts) {
      await _executePostSearch(query: query, emit: emit);
      return;
    }

    if (query.isEmpty) {
      emit(_freshInitialState());
      if (_config.enableHistory) {
        add(const HistoryLoaded());
      }
      return;
    }

    final currentSort = state.currentSort;

    if (currentTab == SearchTab.actors) {
      emit(SearchState.loadingActors(query: query).copyWith(postFilters: state.postFilters));

      try {
        final result = await _searchRepository.searchActors(query: query, limit: 50);
        if (_config.enableHistory) {
          await _database.addSearchHistoryEntry(query: query, type: 'actors', accountDid: _accountDid);
        }
        final history = _config.enableHistory
            ? await _database.getSearchHistory(_accountDid, limit: 50)
            : const <SearchHistoryEntry>[];

        emit(
          SearchState.loadedActors(
            query: query,
            actors: result.actors,
            cursor: result.cursor,
          ).copyWith(searchHistory: history, postFilters: state.postFilters),
        );
      } catch (error) {
        emit(
          SearchState.error(
            query: query,
            message: 'Failed to search actors: $error',
            tab: currentTab,
            sort: currentSort,
            postFilters: state.postFilters,
          ),
        );
      }
      return;
    }

    if (currentTab == SearchTab.feeds) {
      emit(SearchState.loadingFeeds(query: query).copyWith(postFilters: state.postFilters));

      try {
        final result = await _searchRepository.searchFeedGenerators(query: query, limit: 25);
        if (_config.enableHistory) {
          await _database.addSearchHistoryEntry(query: query, type: 'feeds', accountDid: _accountDid);
        }
        final history = _config.enableHistory
            ? await _database.getSearchHistory(_accountDid, limit: 50)
            : const <SearchHistoryEntry>[];

        emit(
          SearchState.loadedFeeds(
            query: query,
            feeds: result.feeds,
            cursor: result.cursor,
          ).copyWith(searchHistory: history, postFilters: state.postFilters),
        );
      } catch (error) {
        emit(
          SearchState.error(
            query: query,
            message: 'Failed to search feeds: $error',
            tab: currentTab,
            sort: currentSort,
            postFilters: state.postFilters,
          ),
        );
      }
      return;
    }

    emit(
      SearchState.loadedStarterPacks(query: query, starterPacks: const [], starterPacksCursor: null).copyWith(
        searchHistory: state.searchHistory,
        typeaheadActors: state.typeaheadActors,
        postFilters: state.postFilters,
      ),
    );
  }

  Future<void> _executePostSearch({
    required String query,
    required Emitter<SearchState> emit,
    bool loadMore = false,
  }) async {
    final currentSort = state.currentSort;
    final cursor = loadMore ? state.cursor : null;

    try {
      final request = PostSearchRequest(
        query: query,
        sort: currentSort,
        filters: state.postFilters,
        cursor: cursor,
        limit: 50,
      ).normalized(fixedAuthor: _config.fixedPostAuthor);

      if (loadMore) {
        if (state.cursor == null || state.isLoadingMore) {
          return;
        }
        emit(state.copyWith(isLoadingMore: true, errorMessage: null));
      } else {
        emit(
          SearchState.loadingPosts(query: query, sort: currentSort, postFilters: request.filters).copyWith(
            currentTab: SearchTab.posts,
            searchHistory: state.searchHistory,
            typeaheadActors: state.typeaheadActors,
          ),
        );
      }

      final result = await _searchRepository.searchPosts(
        query: request.query,
        sort: request.sort,
        filters: request.filters,
        cursor: request.cursor,
        limit: request.limit,
      );

      final posts = loadMore ? [...state.posts, ...result.posts] : result.posts;

      List<SearchHistoryEntry> history = state.searchHistory;
      if (!loadMore && _config.enableHistory && request.query.isNotEmpty) {
        await _database.addSearchHistoryEntry(query: request.query, type: 'posts', accountDid: _accountDid);
        history = await _database.getSearchHistory(_accountDid, limit: 50);
      }

      emit(
        SearchState.loadedPosts(
          query: request.query,
          sort: request.sort,
          postFilters: request.filters,
          posts: posts,
          cursor: result.cursor,
          hitsTotal: result.hitsTotal,
        ).copyWith(searchHistory: history, typeaheadActors: state.typeaheadActors, isLoadingMore: false),
      );
    } on PostSearchValidationException catch (error) {
      if (loadMore) {
        emit(state.copyWith(isLoadingMore: false));
        return;
      }
      emit(
        SearchState.error(
          query: query,
          message: error.message,
          tab: SearchTab.posts,
          sort: currentSort,
          postFilters: state.postFilters,
        ).copyWith(searchHistory: state.searchHistory, typeaheadActors: state.typeaheadActors),
      );
    } catch (error) {
      if (loadMore) {
        emit(state.copyWith(isLoadingMore: false));
        return;
      }
      emit(
        SearchState.error(
          query: query,
          message: 'Failed to search posts: $error',
          tab: SearchTab.posts,
          sort: currentSort,
          postFilters: state.postFilters,
        ).copyWith(searchHistory: state.searchHistory, typeaheadActors: state.typeaheadActors),
      );
    }
  }

  Future<void> _onSearchTabChanged(SearchTabChanged event, Emitter<SearchState> emit) async {
    if (_config.postsOnly || state.currentTab == event.tab) {
      return;
    }

    emit(state.copyWith(currentTab: event.tab));

    if (state.query.isNotEmpty || (event.tab == SearchTab.posts && !state.postFilters.isEmpty)) {
      add(QuerySubmitted(query: state.query));
    }
  }

  Future<void> _onSearchSortChanged(SearchSortChanged event, Emitter<SearchState> emit) async {
    if (state.currentSort == event.sort) return;

    emit(state.copyWith(currentSort: event.sort));

    if (state.currentTab == SearchTab.posts && (state.query.isNotEmpty || !state.postFilters.isEmpty)) {
      add(QuerySubmitted(query: state.query));
    }
  }

  Future<void> _onPostFiltersChanged(PostFiltersChanged event, Emitter<SearchState> emit) async {
    try {
      final resolved = event.filters.normalized(fixedAuthor: _config.fixedPostAuthor);
      emit(state.copyWith(postFilters: resolved));

      if (state.currentTab == SearchTab.posts && (state.query.isNotEmpty || !resolved.isEmpty)) {
        add(QuerySubmitted(query: state.query));
      }
    } on PostSearchValidationException catch (error) {
      emit(
        SearchState.error(
          query: state.query,
          message: error.message,
          tab: SearchTab.posts,
          sort: state.currentSort,
          postFilters: state.postFilters,
        ).copyWith(searchHistory: state.searchHistory, typeaheadActors: state.typeaheadActors),
      );
    }
  }

  Future<void> _onLoadMoreRequested(LoadMoreRequested event, Emitter<SearchState> emit) async {
    if (state.isLoadingMore) return;

    if (state.currentTab == SearchTab.starterPacks) {
      return;
    }

    if (state.currentTab == SearchTab.feeds) {
      if (state.cursor == null) return;

      emit(state.copyWith(isLoadingMore: true));

      try {
        final result = await _searchRepository.searchFeedGenerators(
          query: state.query,
          cursor: state.cursor,
          limit: 25,
        );
        emit(
          SearchState.loadedFeeds(
            query: state.query,
            feeds: [...state.feeds, ...result.feeds],
            cursor: result.cursor,
          ).copyWith(
            searchHistory: state.searchHistory,
            typeaheadActors: state.typeaheadActors,
            postFilters: state.postFilters,
          ),
        );
      } catch (error) {
        emit(state.copyWith(isLoadingMore: false));
      }
      return;
    }

    if (state.currentTab == SearchTab.posts) {
      await _executePostSearch(query: state.query, emit: emit, loadMore: true);
      return;
    }

    if (state.cursor == null) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final result = await _searchRepository.searchActors(query: state.query, cursor: state.cursor, limit: 50);
      emit(state.copyWith(actors: [...state.actors, ...result.actors], cursor: result.cursor, isLoadingMore: false));
    } catch (error) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onTypeaheadRequested(TypeaheadRequested event, Emitter<SearchState> emit) async {
    final query = event.query.trim();

    _debounceTimer?.cancel();

    if (!query.startsWith('@')) {
      emit(state.copyWith(typeaheadActors: []));
      return;
    }

    final handleQuery = query.substring(1).trim();
    if (handleQuery.isEmpty) {
      emit(state.copyWith(typeaheadActors: []));
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      add(TypeaheadResultsLoaded(query: handleQuery));
    });
  }

  Future<void> _onTypeaheadResultsLoaded(TypeaheadResultsLoaded event, Emitter<SearchState> emit) async {
    try {
      final results = await _typeaheadRepository.search(query: event.query, limit: 5);
      final actors = results.map((result) => result.toProfileViewBasic()).toList(growable: false);
      emit(state.copyWith(typeaheadActors: actors));
    } catch (_) {
      emit(state.copyWith(typeaheadActors: []));
    }
  }

  Future<void> _onHistoryLoaded(HistoryLoaded event, Emitter<SearchState> emit) async {
    if (!_config.enableHistory) {
      emit(state.copyWith(searchHistory: []));
      return;
    }
    final entries = await _database.getSearchHistory(_accountDid, limit: 50);
    emit(state.copyWith(searchHistory: entries));
  }

  Future<void> _onHistoryEntryDeleted(HistoryEntryDeleted event, Emitter<SearchState> emit) async {
    if (!_config.enableHistory) {
      return;
    }
    await _database.deleteSearchHistoryEntry(event.id);
    final entries = await _database.getSearchHistory(_accountDid, limit: 50);
    emit(state.copyWith(searchHistory: entries));
  }

  Future<void> _onHistoryCleared(HistoryCleared event, Emitter<SearchState> emit) async {
    if (!_config.enableHistory) {
      return;
    }
    await _database.clearSearchHistory(_accountDid);
    emit(state.copyWith(searchHistory: []));
  }

  void _onQueryCleared(QueryCleared event, Emitter<SearchState> emit) {
    emit(_freshInitialState());
    if (_shouldAutoLoadProfileScopedPosts) {
      add(const QuerySubmitted(query: ''));
      return;
    }
    if (_config.enableHistory) {
      add(const HistoryLoaded());
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class QuerySubmitted extends SearchEvent {
  const QuerySubmitted({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class SearchTabChanged extends SearchEvent {
  const SearchTabChanged({required this.tab});

  final SearchTab tab;

  @override
  List<Object?> get props => [tab];
}

class SearchSortChanged extends SearchEvent {
  const SearchSortChanged({required this.sort});

  final String sort;

  @override
  List<Object?> get props => [sort];
}

class PostFiltersChanged extends SearchEvent {
  const PostFiltersChanged({required this.filters});

  final PostSearchFilters filters;

  @override
  List<Object?> get props => [filters];
}

class LoadMoreRequested extends SearchEvent {
  const LoadMoreRequested();
}

class TypeaheadRequested extends SearchEvent {
  const TypeaheadRequested({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class TypeaheadResultsLoaded extends SearchEvent {
  const TypeaheadResultsLoaded({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class HistoryLoaded extends SearchEvent {
  const HistoryLoaded();
}

class HistoryEntryDeleted extends SearchEvent {
  const HistoryEntryDeleted({required this.id});

  final int id;

  @override
  List<Object?> get props => [id];
}

class HistoryCleared extends SearchEvent {
  const HistoryCleared();
}

class QueryCleared extends SearchEvent {
  const QueryCleared();
}
