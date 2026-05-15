import 'package:poptart_core/poptart_core.dart' show AtUri;
import 'package:bluesky_poptart/app/bsky/graph/defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';

part 'starter_pack_event.dart';
part 'starter_pack_state.dart';

class StarterPackBloc extends Bloc<StarterPackEvent, StarterPackState> {
  StarterPackBloc({required StarterPackRepository starterPackRepository})
    : _starterPackRepository = starterPackRepository,
      super(const StarterPackState.initial()) {
    on<StarterPackRequested>(_onStarterPackRequested);
    on<StarterPackCreated>(_onStarterPackCreated);
    on<StarterPackUpdated>(_onStarterPackUpdated);
    on<StarterPackDeleted>(_onStarterPackDeleted);
    on<MemberAdded>(_onMemberAdded);
    on<MemberRemoved>(_onMemberRemoved);
    on<FollowAllRequested>(_onFollowAllRequested);
  }

  final StarterPackRepository _starterPackRepository;

  Future<void> _onStarterPackRequested(StarterPackRequested event, Emitter<StarterPackState> emit) async {
    emit(StarterPackState.loading(packUri: event.starterPackUri));

    try {
      final starterPack = await _starterPackRepository.getStarterPack(starterPackUri: event.starterPackUri);

      emit(StarterPackState.loaded(packUri: event.starterPackUri, starterPack: starterPack));
    } catch (error) {
      emit(StarterPackState.error(message: 'Failed to load starter pack: $error', packUri: event.starterPackUri));
    }
  }

  Future<void> _onStarterPackCreated(StarterPackCreated event, Emitter<StarterPackState> emit) async {
    emit(const StarterPackState.loading());

    try {
      final packUri = await _starterPackRepository.createStarterPack(
        userDid: event.userDid,
        name: event.name,
        description: event.description,
        memberDids: event.memberDids,
        feedUris: event.feedUris,
      );

      final starterPack = await _starterPackRepository.getStarterPack(starterPackUri: packUri);

      emit(StarterPackState.loaded(packUri: packUri, starterPack: starterPack));
    } catch (error) {
      emit(StarterPackState.error(message: 'Failed to create starter pack: $error'));
    }
  }

  Future<void> _onStarterPackUpdated(StarterPackUpdated event, Emitter<StarterPackState> emit) async {
    final packUri = state.packUri;
    final refListUri = state.starterPack?.list?.uri;

    if (state.status != StarterPackStatus.loaded || packUri == null || refListUri == null || state.isMutating) {
      return;
    }

    emit(state.copyWith(isMutating: true, errorMessage: null));

    try {
      await _starterPackRepository.updateStarterPack(
        packUri: packUri,
        referenceListUri: refListUri,
        name: event.name,
        description: event.description,
        feedUris: event.feedUris,
      );

      await _reloadPack(emit, packUri: packUri, errorPrefix: 'Failed to update starter pack');
    } catch (error) {
      emit(state.copyWith(isMutating: false, errorMessage: 'Failed to update starter pack: $error'));
    }
  }

  Future<void> _onStarterPackDeleted(StarterPackDeleted event, Emitter<StarterPackState> emit) async {
    final packUri = state.packUri;
    final refListUri = state.starterPack?.list?.uri;

    if (state.status != StarterPackStatus.loaded || packUri == null || refListUri == null || state.isMutating) {
      return;
    }

    emit(state.copyWith(isMutating: true, errorMessage: null));

    try {
      await _starterPackRepository.deleteStarterPack(
        packUri: packUri,
        referenceListUri: refListUri,
        userDid: event.userDid,
      );

      emit(const StarterPackState.deleted());
    } catch (error) {
      emit(state.copyWith(isMutating: false, errorMessage: 'Failed to delete starter pack: $error'));
    }
  }

  Future<void> _onMemberAdded(MemberAdded event, Emitter<StarterPackState> emit) async {
    final packUri = state.packUri;
    final refListUri = state.starterPack?.list?.uri;

    if (state.status != StarterPackStatus.loaded || packUri == null || refListUri == null || state.isMutating) {
      return;
    }

    await _runMutation(
      emit,
      packUri: packUri,
      action: () => _starterPackRepository.addMember(listUri: refListUri, subjectDid: event.subjectDid),
      errorPrefix: 'Failed to add member',
    );
  }

  Future<void> _onMemberRemoved(MemberRemoved event, Emitter<StarterPackState> emit) async {
    final packUri = state.packUri;

    if (state.status != StarterPackStatus.loaded || packUri == null || state.isMutating) {
      return;
    }

    await _runMutation(
      emit,
      packUri: packUri,
      action: () => _starterPackRepository.removeMember(listItemUri: event.listItemUri),
      errorPrefix: 'Failed to remove member',
    );
  }

  Future<void> _onFollowAllRequested(FollowAllRequested event, Emitter<StarterPackState> emit) async {
    final refListUri = state.starterPack?.list?.uri;

    if (state.status != StarterPackStatus.loaded || refListUri == null || state.isFollowingAll) {
      return;
    }

    emit(state.copyWith(isFollowingAll: true, errorMessage: null, followedCount: null));

    try {
      final count = await _starterPackRepository.followAll(referenceListUri: refListUri);
      emit(state.copyWith(isFollowingAll: false, followedCount: count));
    } catch (error) {
      emit(state.copyWith(isFollowingAll: false, errorMessage: 'Failed to follow members: $error'));
    }
  }

  Future<void> _runMutation(
    Emitter<StarterPackState> emit, {
    required AtUri packUri,
    required Future<void> Function() action,
    required String errorPrefix,
  }) async {
    emit(state.copyWith(isMutating: true, errorMessage: null));

    try {
      await action();
      await _reloadPack(emit, packUri: packUri, errorPrefix: errorPrefix);
    } catch (error) {
      emit(state.copyWith(isMutating: false, errorMessage: '$errorPrefix: $error'));
    }
  }

  Future<void> _reloadPack(
    Emitter<StarterPackState> emit, {
    required AtUri packUri,
    required String errorPrefix,
  }) async {
    try {
      final starterPack = await _starterPackRepository.getStarterPack(starterPackUri: packUri);
      emit(StarterPackState.loaded(packUri: packUri, starterPack: starterPack));
    } catch (error) {
      emit(state.copyWith(isMutating: false, isRefreshing: false, errorMessage: '$errorPrefix: $error'));
    }
  }
}
