import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(const ProfileState.initial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileRefreshRequested>(_onProfileRefreshRequested);
  }

  final ProfileRepository _profileRepository;

  Future<void> _onProfileLoadRequested(ProfileLoadRequested event, Emitter<ProfileState> emit) async {
    emit(const ProfileState.loading());

    try {
      final profile = await _profileRepository.getProfile(event.actor);
      emit(ProfileState.loaded(profile: profile));
    } catch (error) {
      emit(ProfileState.error('Failed to load profile: $error'));
    }
  }

  Future<void> _onProfileRefreshRequested(ProfileRefreshRequested event, Emitter<ProfileState> emit) async {
    if (state.status != ProfileStatus.loaded || state.profile == null) {
      return;
    }

    final currentProfile = state.profile!;
    emit(state.copyWith(isRefreshing: true));

    try {
      final actor = currentProfile.handle.isNotEmpty ? currentProfile.handle : currentProfile.did;
      final profile = await _profileRepository.getProfile(actor);
      emit(ProfileState.loaded(profile: profile));
    } catch (error) {
      emit(state.copyWith(isRefreshing: false));
    }
  }
}
