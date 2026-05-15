import 'package:bluesky_poptart/app/bsky/graph/defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';

part 'actor_starter_packs_state.dart';

class ActorStarterPacksCubit extends Cubit<ActorStarterPacksState> {
  ActorStarterPacksCubit({required StarterPackRepository starterPackRepository})
    : _starterPackRepository = starterPackRepository,
      super(const ActorStarterPacksState.initial());

  final StarterPackRepository _starterPackRepository;

  Future<void> load({required String actor, int limit = 50}) async {
    emit(ActorStarterPacksState.loading(actor: actor, limit: limit));

    try {
      final result = await _starterPackRepository.getActorStarterPacks(actor: actor, limit: limit);
      emit(
        ActorStarterPacksState.loaded(
          actor: actor,
          starterPacks: result.starterPacks,
          cursor: result.cursor,
          hasMore: result.cursor != null,
          limit: limit,
        ),
      );
    } catch (error) {
      emit(ActorStarterPacksState.error(message: 'Failed to load starter packs: $error', actor: actor, limit: limit));
    }
  }

  Future<void> refresh() async {
    if (state.actor == null) {
      return;
    }

    emit(state.copyWith(isRefreshing: true, errorMessage: null));

    try {
      final result = await _starterPackRepository.getActorStarterPacks(actor: state.actor!, limit: state.limit);
      emit(
        ActorStarterPacksState.loaded(
          actor: state.actor!,
          starterPacks: result.starterPacks,
          cursor: result.cursor,
          hasMore: result.cursor != null,
          limit: state.limit,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isRefreshing: false, errorMessage: 'Failed to refresh starter packs: $error'));
    }
  }

  Future<void> loadMore() async {
    if (state.status != ActorStarterPacksStatus.loaded ||
        state.actor == null ||
        state.cursor == null ||
        state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    try {
      final result = await _starterPackRepository.getActorStarterPacks(
        actor: state.actor!,
        cursor: state.cursor,
        limit: state.limit,
      );

      emit(
        state.copyWith(
          starterPacks: [...state.starterPacks, ...result.starterPacks],
          cursor: result.cursor,
          hasMore: result.cursor != null,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false, hasMore: false));
    }
  }
}
