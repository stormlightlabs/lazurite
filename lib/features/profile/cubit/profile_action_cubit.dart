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

  static const Object _unset = Object();

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
    Object? followUri = _unset,
    Object? blockUri = _unset,
    bool? isLoadingFollow,
    bool? isLoadingMute,
    bool? isLoadingBlock,
    Object? error = _unset,
  }) {
    return ProfileActionState(
      actorDid: actorDid,
      isFollowing: isFollowing ?? this.isFollowing,
      isMuted: isMuted ?? this.isMuted,
      isBlocked: isBlocked ?? this.isBlocked,
      isBlockedBy: isBlockedBy ?? this.isBlockedBy,
      followUri: identical(followUri, _unset) ? this.followUri : followUri as String?,
      blockUri: identical(blockUri, _unset) ? this.blockUri : blockUri as String?,
      isLoadingFollow: isLoadingFollow ?? this.isLoadingFollow,
      isLoadingMute: isLoadingMute ?? this.isLoadingMute,
      isLoadingBlock: isLoadingBlock ?? this.isLoadingBlock,
      error: identical(error, _unset) ? this.error : error as String?,
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

  Future<void> toggleFollow() => _runUriBackedOptimisticToggle(
    isLoading: state.isLoadingFollow,
    wasActive: state.isFollowing,
    previousUri: state.followUri,
    optimisticState: (wasActive) => state.copyWith(isFollowing: !wasActive, isLoadingFollow: true, error: null),
    activate: () => _profileActionRepository.followActor(did: state.actorDid),
    deactivate: (uri) => _profileActionRepository.unfollowActor(followUri: uri),
    successState: (uri) => state.copyWith(followUri: uri, isLoadingFollow: false),
    idleState: () => state.copyWith(isLoadingFollow: false),
    rollbackState: ({required wasActive, required previousUri}) => state.copyWith(
      isFollowing: wasActive,
      followUri: previousUri,
      isLoadingFollow: false,
      error: 'Failed to ${wasActive ? 'unfollow' : 'follow'} user',
    ),
    failureLogMessage: 'Failed to toggle follow',
  );

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

  Future<void> toggleBlock() => _runUriBackedOptimisticToggle(
    isLoading: state.isLoadingBlock,
    wasActive: state.isBlocked,
    previousUri: state.blockUri,
    optimisticState: (wasActive) => state.copyWith(isBlocked: !wasActive, isLoadingBlock: true, error: null),
    activate: () => _profileActionRepository.blockActor(did: state.actorDid),
    deactivate: (uri) => _profileActionRepository.unblockActor(blockUri: uri),
    successState: (uri) => state.copyWith(blockUri: uri, isLoadingBlock: false),
    idleState: () => state.copyWith(isLoadingBlock: false),
    rollbackState: ({required wasActive, required previousUri}) => state.copyWith(
      isBlocked: wasActive,
      blockUri: previousUri,
      isLoadingBlock: false,
      error: 'Failed to ${wasActive ? 'unblock' : 'block'} user',
    ),
    failureLogMessage: 'Failed to toggle block',
  );

  Future<void> _runUriBackedOptimisticToggle({
    required bool isLoading,
    required bool wasActive,
    required String? previousUri,
    required ProfileActionState Function(bool wasActive) optimisticState,
    required Future<String> Function() activate,
    required Future<void> Function(String uri) deactivate,
    required ProfileActionState Function(String? uri) successState,
    required ProfileActionState Function() idleState,
    required ProfileActionState Function({required bool wasActive, required String? previousUri}) rollbackState,
    required String failureLogMessage,
  }) async {
    if (isLoading || state.isBlockedBy) return;

    emit(optimisticState(wasActive));

    try {
      if (wasActive) {
        if (previousUri != null) {
          await deactivate(previousUri);
          emit(successState(null));
        } else {
          emit(idleState());
        }
      } else {
        emit(successState(await activate()));
      }
    } catch (error) {
      log.e(failureLogMessage, error: error);
      emit(rollbackState(wasActive: wasActive, previousUri: previousUri));
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
