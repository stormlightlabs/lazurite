import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/embedding/embedding_service.dart';
import 'package:lazurite/features/search/data/search_scope.dart';
import 'package:lazurite/features/search/data/semantic_search_repository.dart';
import 'package:lazurite/features/search/data/semantic_search_result.dart';

export 'package:lazurite/features/search/data/search_scope.dart';

enum SemanticSearchStatus { initial, searching, loaded, error, unavailable }

class SemanticSearchState extends Equatable {
  const SemanticSearchState({
    this.status = SemanticSearchStatus.initial,
    this.results = const [],
    this.query = '',
    this.scope = SearchScope.both,
    this.errorMessage,
  });

  final SemanticSearchStatus status;
  final List<SemanticSearchResult> results;
  final String query;
  final SearchScope scope;
  final String? errorMessage;

  SemanticSearchState copyWith({
    SemanticSearchStatus? status,
    List<SemanticSearchResult>? results,
    String? query,
    SearchScope? scope,
    String? errorMessage,
  }) => SemanticSearchState(
    status: status ?? this.status,
    results: results ?? this.results,
    query: query ?? this.query,
    scope: scope ?? this.scope,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, results, query, scope, errorMessage];
}

/// Cubit for on-device semantic (vector) search over saved and liked posts.
///
/// Exposes a [search] method with a 500 ms debounce, a [setScope] method to
/// filter results by source, and a [clearResults] method to reset state.
///
/// The initial state is [SemanticSearchStatus.unavailable] when the
/// [EmbeddingService] is not available (e.g. model failed to load).
class SemanticSearchCubit extends Cubit<SemanticSearchState> {
  SemanticSearchCubit({
    required SemanticSearchRepository repository,
    required EmbeddingService embeddingService,
    required String accountDid,
    int maxResults = 20,
    Duration debounceDuration = const Duration(milliseconds: 500),
  }) : _repository = repository,
       _embeddingService = embeddingService,
       _accountDid = accountDid,
       _maxResults = maxResults,
       _debounceDuration = debounceDuration,
       super(
         embeddingService.isAvailable
             ? const SemanticSearchState()
             : const SemanticSearchState(status: SemanticSearchStatus.unavailable),
       );

  final SemanticSearchRepository _repository;
  final EmbeddingService _embeddingService;
  final String _accountDid;
  int _maxResults;
  final Duration _debounceDuration;
  Timer? _debounce;

  /// Update the maximum number of results returned per search.
  void setMaxResults(int maxResults) => _maxResults = maxResults;

  /// Queue a search for [query], debounced by [_debounceDuration].
  ///
  /// An empty query clears results immediately without waiting for the debounce.
  /// A no-op when the embedding service is unavailable.
  void search(String query) {
    if (!_embeddingService.isAvailable) {
      emit(const SemanticSearchState(status: SemanticSearchStatus.unavailable));
      return;
    }
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      emit(SemanticSearchState(scope: state.scope));
      return;
    }
    _debounce = Timer(_debounceDuration, () => unawaited(_doSearch(query)));
  }

  /// Change the search scope and immediately re-run the current query.
  Future<void> setScope(SearchScope scope) async {
    if (state.scope == scope) return;
    emit(state.copyWith(scope: scope));
    if (state.query.trim().isNotEmpty && _embeddingService.isAvailable) {
      _debounce?.cancel();
      await _doSearch(state.query);
    }
  }

  /// Reset to the initial state, preserving the current scope.
  void clearResults() {
    _debounce?.cancel();
    emit(SemanticSearchState(scope: state.scope));
  }

  Future<void> _doSearch(String query) async {
    emit(state.copyWith(status: SemanticSearchStatus.searching, query: query));
    try {
      final source = switch (state.scope) {
        SearchScope.saved => 'saved',
        SearchScope.liked => 'liked',
        SearchScope.both => null,
      };
      final results = await _repository.search(query, _accountDid, source: source, maxResults: _maxResults);
      if (isClosed) return;
      emit(state.copyWith(status: SemanticSearchStatus.loaded, results: results));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: SemanticSearchStatus.error, errorMessage: 'Search failed: $e'));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
