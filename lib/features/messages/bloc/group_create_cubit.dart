import 'package:bluesky_poptart/app/bsky/actor/defs.dart' as app_actor;
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:characters/characters.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/l10n/app_localizations.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:poptart_core/poptart_core.dart' as atcore;

part 'group_create_state.dart';

class GroupCreateCubit extends Cubit<GroupCreateState> {
  GroupCreateCubit({
    required ConvoRepository convoRepository,
    required String currentUserDid,
    required AppLocalizations l10n,
  }) : _convoRepository = convoRepository,
       _currentUserDid = currentUserDid,
       _l10n = l10n,
       super(const GroupCreateState());

  static const int maxNameGraphemes = 50;
  static const int maxMembers = 49;

  final ConvoRepository _convoRepository;
  final String _currentUserDid;
  final AppLocalizations _l10n;

  void nameChanged(String name) {
    emit(state.copyWith(name: name, status: _editableStatus, errorMessage: null, createdConvo: null));
  }

  void memberAdded(app_actor.ProfileViewBasic profile) {
    if (profile.did == _currentUserDid) {
      emit(state.copyWith(status: _editableStatus, errorMessage: _l10n.errorGroupOwnerAlreadyIncluded));
      return;
    }
    if (state.members.any((member) => member.did == profile.did)) {
      return;
    }
    if (state.members.length >= maxMembers) {
      emit(state.copyWith(status: _editableStatus, errorMessage: _l10n.errorGroupMemberLimit));
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
    final validationIssue = state.validationIssue;
    if (validationIssue != null) {
      emit(
        state.copyWith(
          status: GroupCreateStatus.failure,
          errorMessage: validationIssue.message(_l10n),
          createdConvo: null,
        ),
      );
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
          errorMessage: groupCreateErrorMessage(error, _l10n),
          createdConvo: null,
        ),
      );
    }
  }

  GroupCreateStatus get _editableStatus =>
      state.status == GroupCreateStatus.submitting ? GroupCreateStatus.submitting : GroupCreateStatus.editing;
}

String groupCreateErrorMessage(Object error, AppLocalizations l10n) {
  final code = error is atcore.XRPCException ? error.response.data.error : null;
  return switch (code) {
    'BlockedActor' || 'BlockedSubject' => l10n.errorGroupCreateBlockedActor,
    'UserForbidsGroups' => l10n.errorGroupCreateUserForbidsGroups,
    'NotFollowedBySender' => l10n.errorGroupCreateNotFollowedBySender,
    'RecipientNotFound' => l10n.errorGroupCreateRecipientNotFound,
    'NewAccountCannotCreateGroup' => l10n.errorGroupCreateNewAccount,
    'AccountSuspended' => l10n.errorGroupCreateAccountSuspended,
    _ => l10n.errorGroupCreateFailed,
  };
}
