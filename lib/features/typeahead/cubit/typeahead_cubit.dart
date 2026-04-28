import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/typeahead/cubit/typeahead_state.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';

class TypeaheadCubit extends Cubit<TypeaheadState> {
  TypeaheadCubit({
    required TypeaheadRepository repository,
    Duration debounceDuration = const Duration(milliseconds: 300),
  }) : _repository = repository,
       _debounceDuration = debounceDuration,
       super(const TypeaheadState());

  final TypeaheadRepository _repository;
  final Duration _debounceDuration;

  Timer? _debounceTimer;
  int _requestId = 0;

  void onQueryChanged(String query) {
    final normalizedQuery = query.trim();

    _debounceTimer?.cancel();
    _requestId++;

    if (normalizedQuery.isEmpty) {
      emit(const TypeaheadState());
      return;
    }

    final requestId = _requestId;
    _debounceTimer = Timer(_debounceDuration, () {
      unawaited(_runSearch(requestId: requestId, query: normalizedQuery));
    });
  }

  void clear() {
    _debounceTimer?.cancel();
    _requestId++;

    if (state == const TypeaheadState()) {
      return;
    }

    emit(const TypeaheadState());
  }

  Future<void> _runSearch({required int requestId, required String query}) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final results = await _repository.search(query: query);
      if (!_isActiveRequest(requestId)) {
        return;
      }

      emit(TypeaheadState(results: results));
    } catch (_) {
      if (!_isActiveRequest(requestId)) {
        return;
      }

      emit(const TypeaheadState(error: 'Failed to load suggestions'));
    }
  }

  bool _isActiveRequest(int requestId) => requestId == _requestId;

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
