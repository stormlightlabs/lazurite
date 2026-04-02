import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';

part 'suggested_follows_state.dart';

class SuggestedFollowsCubit extends Cubit<SuggestedFollowsState> {
  SuggestedFollowsCubit({required ProfileRepository repository})
    : _repository = repository,
      super(const SuggestedFollowsState.initial());

  final ProfileRepository _repository;

  Future<void> load(String actor) async {
    if (state.isLoading) return;

    emit(const SuggestedFollowsState.loading());

    try {
      final suggestions = await _repository.getSuggestedFollows(actor);
      emit(SuggestedFollowsState.loaded(suggestions));
    } catch (error) {
      emit(SuggestedFollowsState.error('Failed to load suggestions: $error'));
    }
  }
}
