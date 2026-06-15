import 'package:bluesky_poptart/app/bsky/actor/defs.dart' as app_actor;
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:characters/characters.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:poptart_core/poptart_core.dart' as atcore;

part 'group_create_state.dart';

class GroupCreateCubit extends Cubit<GroupCreateState> {
  GroupCreateCubit({required ConvoRepository convoRepository, required String currentUserDid})
    : _convoRepository = convoRepository,
      _currentUserDid = currentUserDid,
      super(const GroupCreateState());

  static const int maxNameGraphemes = 50;
  static const int maxMembers = 49;

  final ConvoRepository _convoRepository;
  final String _currentUserDid;

  void nameChanged(String name) {
    emit(state.copyWith(name: name, status: _editableStatus, errorMessage: null, createdConvo: null));
  }

  void memberAdded(app_actor.ProfileViewBasic profile) {
    if (profile.did == _currentUserDid) {
      emit(state.copyWith(status: _editableStatus, errorMessage: 'You are already included as the group owner.'));
      return;
    }
    if (state.members.any((member) => member.did == profile.did)) {
      return;
    }
    if (state.members.length >= maxMembers) {
      emit(state.copyWith(status: _editableStatus, errorMessage: 'Groups can include up to 49 invited members.'));
      return;
    }

    emit(
      state.copyWith(
        members: [...state.members, GroupCreateMember.fromProfile(profile)],
        status: _editableStatus,
        errorMessage: null,
        createdConvo: null,
      ),
    );
  }

  void memberRemoved(String did) {
    emit(
      state.copyWith(
        members: state.members.where((member) => member.did != did).toList(growable: false),
        status: _editableStatus,
        errorMessage: null,
        createdConvo: null,
      ),
    );
  }

  Future<void> createSubmitted() async {
    final validationError = state.validationError;
    if (validationError != null) {
      emit(state.copyWith(status: GroupCreateStatus.failure, errorMessage: validationError, createdConvo: null));
      return;
    }

    emit(state.copyWith(status: GroupCreateStatus.submitting, errorMessage: null, createdConvo: null));

    try {
      final convo = await _convoRepository.createGroup(
        name: state.trimmedName,
        memberDids: state.members.map((member) => member.did).toList(growable: false),
      );
      emit(state.copyWith(status: GroupCreateStatus.success, createdConvo: convo, errorMessage: null));
    } catch (error) {
      emit(
        state.copyWith(
          status: GroupCreateStatus.failure,
          errorMessage: groupCreateErrorMessage(error),
          createdConvo: null,
        ),
      );
    }
  }

  GroupCreateStatus get _editableStatus =>
      state.status == GroupCreateStatus.submitting ? GroupCreateStatus.submitting : GroupCreateStatus.editing;
}

String groupCreateErrorMessage(Object error) {
  final code = error is atcore.XRPCException ? error.response.data.error : null;
  return switch (code) {
    'BlockedActor' || 'BlockedSubject' => 'A selected member cannot be invited because of a block.',
    'UserForbidsGroups' => 'A selected member does not allow group chat invites.',
    'NotFollowedBySender' => 'A selected member only accepts group invites from people they follow.',
    'RecipientNotFound' => 'One of the selected accounts could not be found.',
    'NewAccountCannotCreateGroup' => 'New accounts cannot create group chats yet.',
    'AccountSuspended' => 'This account cannot create a group chat.',
    _ => 'Failed to create group. Check the selected members and try again.',
  };
}
