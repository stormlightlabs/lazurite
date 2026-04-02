part of 'suggested_follows_cubit.dart';

enum SuggestedFollowsStatus { initial, loading, loaded, error }

class SuggestedFollowsState extends Equatable {
  const SuggestedFollowsState._({required this.status, this.suggestions = const [], this.errorMessage});

  const SuggestedFollowsState.initial() : this._(status: SuggestedFollowsStatus.initial);

  const SuggestedFollowsState.loading() : this._(status: SuggestedFollowsStatus.loading);

  const SuggestedFollowsState.loaded(List<ProfileView> suggestions)
    : this._(status: SuggestedFollowsStatus.loaded, suggestions: suggestions);

  const SuggestedFollowsState.error(String message)
    : this._(status: SuggestedFollowsStatus.error, errorMessage: message);

  final SuggestedFollowsStatus status;
  final List<ProfileView> suggestions;
  final String? errorMessage;

  bool get isLoading => status == SuggestedFollowsStatus.loading;
  bool get hasError => status == SuggestedFollowsStatus.error;
  bool get isEmpty => status == SuggestedFollowsStatus.loaded && suggestions.isEmpty;

  @override
  List<Object?> get props => [status, suggestions, errorMessage];
}
