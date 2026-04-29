import 'dart:async';

import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';

part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required SearchRepository searchRepository,
    required TypeaheadRepository typeaheadRepository,
    required AppDatabase database,
    required String accountDid,
  }) : _searchRepository = searchRepository,
       _typeaheadRepository = typeaheadRepository,
       _database = database,
       _accountDid = accountDid,
       super(const SearchState.initial()) {
    on<QuerySubmitted>(_onQuerySubmitted);
    on<SearchTabChanged>(_onSearchTabChanged);
    on<SearchSortChanged>(_onSearchSortChanged);
    on<LoadMoreRequested>(_onLoadMoreRequested);
    on<TypeaheadRequested>(_onTypeaheadRequested);
    on<TypeaheadResultsLoaded>(_onTypeaheadResultsLoaded);
    on<HistoryLoaded>(_onHistoryLoaded);
    on<HistoryEntryDeleted>(_onHistoryEntryDeleted);
    on<HistoryCleared>(_onHistoryCleared);
    on<QueryCleared>(_onQueryCleared);

    add(const HistoryLoaded());
  }

  final SearchRepository _searchRepository;
  final TypeaheadRepository _typeaheadRepository;
  final AppDatabase _database;
  final String _accountDid;
  Timer? _debounceTimer;

  Future<void> _onQuerySubmitted(QuerySubmitted event, Emitter<SearchState> emit) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const SearchState.initial());
      add(const HistoryLoaded());
      return;
    }

    final currentTab = state.currentTab;
    final currentSort = state.currentSort;

    if (currentTab == SearchTab.posts) {
      emit(SearchState.loadingPosts(query: query, sort: currentSort));

      try {
        final result = await _searchRepository.searchPosts(query: query, sort: currentSort, limit: 50);
        await _database.addSearchHistoryEntry(query: query, type: 'posts', accountDid: _accountDid);
        final history = await _database.getSearchHistory(_accountDid, limit: 50);

        emit(
          SearchState.loadedPosts(
            query: query,
            sort: currentSort,
            posts: result.posts,
            cursor: result.cursor,
            hitsTotal: result.hitsTotal,
          ).copyWith(searchHistory: history),
        );
      } catch (error) {
        emit(
          SearchState.error(
            query: query,
            message: 'Failed to search posts: $error',
            tab: currentTab,
            sort: currentSort,
          ),
        );
      }
    } else if (currentTab == SearchTab.actors) {
      emit(SearchState.loadingActors(query: query));

      try {
        final result = await _searchRepository.searchActors(query: query, limit: 50);
        await _database.addSearchHistoryEntry(query: query, type: 'actors', accountDid: _accountDid);
        final history = await _database.getSearchHistory(_accountDid, limit: 50);

        emit(
          SearchState.loadedActors(
            query: query,
            actors: result.actors,
            cursor: result.cursor,
          ).copyWith(searchHistory: history),
        );
      } catch (error) {
        emit(
          SearchState.error(
            query: query,
            message: 'Failed to search actors: $error',
            tab: currentTab,
            sort: currentSort,
          ),
        );
      }
    } else if (currentTab == SearchTab.feeds) {
      emit(SearchState.loadingFeeds(query: query));

      try {
        final result = await _searchRepository.searchFeedGenerators(query: query, limit: 25);
        await _database.addSearchHistoryEntry(query: query, type: 'feeds', accountDid: _accountDid);
        final history = await _database.getSearchHistory(_accountDid, limit: 50);

        emit(
          SearchState.loadedFeeds(
            query: query,
            feeds: result.feeds,
            cursor: result.cursor,
          ).copyWith(searchHistory: history),
        );
      } catch (error) {
        emit(
          SearchState.error(
            query: query,
            message: 'Failed to search feeds: $error',
            tab: currentTab,
            sort: currentSort,
          ),
        );
      }
    } else {
      emit(
        SearchState.loadedStarterPacks(
          query: query,
          starterPacks: const [],
          starterPacksCursor: null,
        ).copyWith(searchHistory: state.searchHistory, typeaheadActors: state.typeaheadActors),
      );
    }
  }

  Future<void> _onSearchTabChanged(SearchTabChanged event, Emitter<SearchState> emit) async {
    if (state.currentTab == event.tab) return;

    emit(state.copyWith(currentTab: event.tab));

    if (state.query.isNotEmpty) {
      add(QuerySubmitted(query: state.query));
    }
  }

  Future<void> _onSearchSortChanged(SearchSortChanged event, Emitter<SearchState> emit) async {
    if (state.currentSort == event.sort) return;

    emit(state.copyWith(currentSort: event.sort));

    if (state.query.isNotEmpty && state.currentTab == SearchTab.posts) {
      add(QuerySubmitted(query: state.query));
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
          ).copyWith(searchHistory: state.searchHistory, typeaheadActors: state.typeaheadActors),
        );
      } catch (error) {
        emit(state.copyWith(isLoadingMore: false));
      }
      return;
    }

    if (state.cursor == null) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      if (state.currentTab == SearchTab.posts) {
        final result = await _searchRepository.searchPosts(
          query: state.query,
          sort: state.currentSort,
          cursor: state.cursor,
          limit: 50,
        );

        emit(state.copyWith(posts: [...state.posts, ...result.posts], cursor: result.cursor, isLoadingMore: false));
      } else {
        final result = await _searchRepository.searchActors(query: state.query, cursor: state.cursor, limit: 50);

        emit(state.copyWith(actors: [...state.actors, ...result.actors], cursor: result.cursor, isLoadingMore: false));
      }
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
    final entries = await _database.getSearchHistory(_accountDid, limit: 50);
    emit(state.copyWith(searchHistory: entries));
  }

  Future<void> _onHistoryEntryDeleted(HistoryEntryDeleted event, Emitter<SearchState> emit) async {
    await _database.deleteSearchHistoryEntry(event.id);
    final entries = await _database.getSearchHistory(_accountDid, limit: 50);
    emit(state.copyWith(searchHistory: entries));
  }

  Future<void> _onHistoryCleared(HistoryCleared event, Emitter<SearchState> emit) async {
    await _database.clearSearchHistory(_accountDid);
    emit(state.copyWith(searchHistory: []));
  }

  void _onQueryCleared(QueryCleared event, Emitter<SearchState> emit) {
    emit(const SearchState.initial());
    add(const HistoryLoaded());
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
