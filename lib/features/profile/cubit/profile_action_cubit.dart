import 'package:poptart_lex/com/atproto/moderation/defs.dart';
import 'package:poptart_core/poptart_core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';

class ProfileActionState extends Equatable {
  const ProfileActionState({
    required this.actorDid,
    this.isFollowing = false,
    this.isMuted = false,
    this.isBlocked = false,
    this.isBlockedBy = false,
    this.followUri,
    this.blockUri,
    this.isLoadingFollow = false,
    this.isLoadingMute = false,
    this.isLoadingBlock = false,
    this.error,
  });

  final String actorDid;
  final bool isFollowing;
  final bool isMuted;
  final bool isBlocked;
  final bool isBlockedBy;
  final String? followUri;
  final String? blockUri;
  final bool isLoadingFollow;
  final bool isLoadingMute;
  final bool isLoadingBlock;
  final String? error;

  bool get canShowActions => !isBlockedBy;

  ProfileActionState copyWith({
    bool? isFollowing,
    bool? isMuted,
    bool? isBlocked,
    bool? isBlockedBy,
    String? followUri,
    String? blockUri,
    bool? isLoadingFollow,
    bool? isLoadingMute,
    bool? isLoadingBlock,
    String? error,
  }) {
    return ProfileActionState(
      actorDid: actorDid,
      isFollowing: isFollowing ?? this.isFollowing,
      isMuted: isMuted ?? this.isMuted,
      isBlocked: isBlocked ?? this.isBlocked,
      isBlockedBy: isBlockedBy ?? this.isBlockedBy,
      followUri: followUri ?? this.followUri,
      blockUri: blockUri ?? this.blockUri,
      isLoadingFollow: isLoadingFollow ?? this.isLoadingFollow,
      isLoadingMute: isLoadingMute ?? this.isLoadingMute,
      isLoadingBlock: isLoadingBlock ?? this.isLoadingBlock,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    actorDid,
    isFollowing,
    isMuted,
    isBlocked,
    isBlockedBy,
    followUri,
    blockUri,
    isLoadingFollow,
    isLoadingMute,
    isLoadingBlock,
    error,
  ];
}

class ProfileActionCubit extends Cubit<ProfileActionState> {
  ProfileActionCubit({
    required ProfileActionRepository profileActionRepository,
    required String actorDid,
    bool isFollowing = false,
    bool isMuted = false,
    bool isBlocked = false,
    bool isBlockedBy = false,
    String? followUri,
    String? blockUri,
  }) : _profileActionRepository = profileActionRepository,
       super(
         ProfileActionState(
           actorDid: actorDid,
           isFollowing: isFollowing,
           isMuted: isMuted,
           isBlocked: isBlocked,
           isBlockedBy: isBlockedBy,
           followUri: followUri,
           blockUri: blockUri,
         ),
       );

  final ProfileActionRepository _profileActionRepository;

  Future<void> toggleFollow() async {
    if (state.isLoadingFollow || state.isBlockedBy) return;

    final wasFollowing = state.isFollowing;
    final previousFollowUri = state.followUri;

    emit(state.copyWith(isFollowing: !wasFollowing, isLoadingFollow: true, error: null));

    try {
      if (wasFollowing) {
        if (previousFollowUri != null) {
          await _profileActionRepository.unfollowActor(followUri: previousFollowUri);
          emit(state.copyWith(followUri: null, isLoadingFollow: false));
        } else {
          emit(state.copyWith(isLoadingFollow: false));
        }
      } else {
        final newFollowUri = await _profileActionRepository.followActor(did: state.actorDid);
        emit(state.copyWith(followUri: newFollowUri, isLoadingFollow: false));
      }
    } catch (error) {
      log.e('Failed to toggle follow', error: error);

      emit(
        state.copyWith(
          isFollowing: wasFollowing,
          followUri: previousFollowUri,
          isLoadingFollow: false,
          error: 'Failed to ${wasFollowing ? 'unfollow' : 'follow'} user',
        ),
      );
    }
  }

  Future<void> toggleMute() async {
    if (state.isLoadingMute || state.isBlockedBy) return;

    final wasMuted = state.isMuted;
    emit(state.copyWith(isMuted: !wasMuted, isLoadingMute: true, error: null));

    try {
      if (wasMuted) {
        await _profileActionRepository.unmuteActor(did: state.actorDid);
      } else {
        await _profileActionRepository.muteActor(did: state.actorDid);
      }
      emit(state.copyWith(isLoadingMute: false));
    } catch (error) {
      log.e('Failed to toggle mute', error: error);

      emit(
        state.copyWith(
          isMuted: wasMuted,
          isLoadingMute: false,
          error: 'Failed to ${wasMuted ? 'unmute' : 'mute'} user',
        ),
      );
    }
  }

  Future<void> toggleBlock() async {
    if (state.isLoadingBlock || state.isBlockedBy) return;

    final wasBlocked = state.isBlocked;
    final previousBlockUri = state.blockUri;

    emit(state.copyWith(isBlocked: !wasBlocked, isLoadingBlock: true, error: null));

    try {
      if (wasBlocked) {
        if (previousBlockUri != null) {
          await _profileActionRepository.unblockActor(blockUri: previousBlockUri);
          emit(state.copyWith(blockUri: null, isLoadingBlock: false));
        } else {
          emit(state.copyWith(isLoadingBlock: false));
        }
      } else {
        final newBlockUri = await _profileActionRepository.blockActor(did: state.actorDid);
        emit(state.copyWith(blockUri: newBlockUri, isLoadingBlock: false));
      }
    } catch (error) {
      log.e('Failed to toggle block', error: error);

      emit(
        state.copyWith(
          isBlocked: wasBlocked,
          blockUri: previousBlockUri,
          isLoadingBlock: false,
          error: 'Failed to ${wasBlocked ? 'unblock' : 'block'} user',
        ),
      );
    }
  }

  Future<String?> reportPost({
    required AtUri postUri,
    required String cid,
    required ReasonType reasonType,
    String? reason,
  }) async {
    try {
      final reportId = await _profileActionRepository.reportPost(
        postUri: postUri,
        cid: cid,
        reasonType: reasonType,
        reason: reason,
      );
      return reportId;
    } catch (error) {
      log.e('Failed to report post', error: error);
      emit(state.copyWith(error: 'Failed to report post'));
      return null;
    }
  }

  Future<String?> reportActor({required ReasonType reasonType, String? reason}) async {
    try {
      final reportId = await _profileActionRepository.reportActor(
        did: state.actorDid,
        reasonType: reasonType,
        reason: reason,
      );
      return reportId;
    } catch (error) {
      log.e('Failed to report actor', error: error);
      emit(state.copyWith(error: 'Failed to report user'));
      return null;
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
