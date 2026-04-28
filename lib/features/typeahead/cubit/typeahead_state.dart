import 'package:equatable/equatable.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';

const _errorUnset = Object();

class TypeaheadState extends Equatable {
  const TypeaheadState({this.results = const [], this.isLoading = false, this.error});

  final List<TypeaheadResult> results;
  final bool isLoading;
  final String? error;

  TypeaheadState copyWith({List<TypeaheadResult>? results, bool? isLoading, Object? error = _errorUnset}) {
    return TypeaheadState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _errorUnset) ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [results, isLoading, error];
}
