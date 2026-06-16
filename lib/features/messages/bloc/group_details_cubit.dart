import 'package:bluesky_poptart/chat/bsky/actor/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:bluesky_poptart/chat/bsky/group/defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/l10n/app_localizations.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:poptart_core/poptart_core.dart' as atcore;

part 'group_details_state.dart';

class GroupDetailsCubit extends Cubit<GroupDetailsState> {
  GroupDetailsCubit({
    required ConvoRepository convoRepository,
    required String convoId,
    required String currentUserDid,
    required AppLocalizations l10n,
    ConvoView? initialConvo,
  }) : _convoRepository = convoRepository,
       _convoId = convoId,
       _currentUserDid = currentUserDid,
       _l10n = l10n,
       super(GroupDetailsState(convo: initialConvo));

  final ConvoRepository _convoRepository;
  final String _convoId;
  final String _currentUserDid;
  final AppLocalizations _l10n;

  Future<void> load() async {
    emit(state.copyWith(status: GroupDetailsStatus.loading, errorMessage: null));
    try {
      final convo = await _convoRepository.getConvo(_convoId);
      final page = await _convoRepository.getConvoMembers(_convoId);
      emit(
        state.copyWith(
          status: GroupDetailsStatus.loaded,
          convo: convo,
          members: page.members,
          cursor: page.cursor,
          hasMore: page.cursor != null,
          errorMessage: null,
        ),
      );
      if (state.canManage(_currentUserDid)) {
        await loadJoinRequests();
      }
    } catch (error) {
      emit(state.copyWith(status: GroupDetailsStatus.error, errorMessage: _l10n.errorFailedToLoadGroupDetails));
    }
  }

  Future<void> loadMoreMembers() async {
    if (state.status != GroupDetailsStatus.loaded || !state.hasMore || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));
    try {
      final page = await _convoRepository.getConvoMembers(_convoId, cursor: state.cursor);
      emit(
        state.copyWith(
          members: [...state.members, ...page.members],
          cursor: page.cursor,
          hasMore: page.cursor != null,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false, hasMore: false));
    }
  }

  Future<void> renameGroup(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _mutate(() => _convoRepository.editGroupName(_convoId, trimmed));
  }

  Future<void> addMember(String did) async => await _mutate(() => _convoRepository.addGroupMembers(_convoId, [did]));

  Future<void> removeMember(String did) async {
    if (did == _currentUserDid) return;
    await _mutate(() => _convoRepository.removeGroupMembers(_convoId, [did]));
  }

  Future<void> leaveGroup() async {
    emit(state.copyWith(isMutating: true, errorMessage: null, leaveSucceeded: false));
    try {
      await _convoRepository.leaveConvo(_convoId);
      emit(state.copyWith(isMutating: false, leaveSucceeded: true));
    } catch (error) {
      emit(state.copyWith(isMutating: false, errorMessage: _groupDetailsErrorMessage(error, _l10n)));
    }
  }

  Future<void> createJoinLink({required JoinRule joinRule, required bool requireApproval}) async {
    await _mutateJoinLink(
      () => _convoRepository.createJoinLink(convoId: _convoId, joinRule: joinRule, requireApproval: requireApproval),
    );
  }

  Future<void> editJoinLink({required JoinRule joinRule, required bool requireApproval}) async {
    await _mutateJoinLink(
      () => _convoRepository.editJoinLink(convoId: _convoId, joinRule: joinRule, requireApproval: requireApproval),
    );
  }

  Future<void> enableJoinLink() async => await _mutateJoinLink(() => _convoRepository.enableJoinLink(_convoId));

  Future<void> disableJoinLink() async => await _mutateJoinLink(() => _convoRepository.disableJoinLink(_convoId));

  Future<void> loadJoinRequests() async {
    if (state.isLoadingJoinRequests) return;
    emit(state.copyWith(isLoadingJoinRequests: true, errorMessage: null));
    try {
      final page = await _convoRepository.listJoinRequests(_convoId);
      await _convoRepository.updateJoinRequestsRead(_convoId);
      emit(
        state.copyWith(
          joinRequests: page.requests,
          joinRequestsCursor: page.cursor,
          hasMoreJoinRequests: page.cursor != null,
          isLoadingJoinRequests: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoadingJoinRequests: false, errorMessage: _groupDetailsErrorMessage(error, _l10n)));
    }
  }

  Future<void> loadMoreJoinRequests() async {
    if (!state.hasMoreJoinRequests || state.isLoadingJoinRequests) return;
    emit(state.copyWith(isLoadingJoinRequests: true));
    try {
      final page = await _convoRepository.listJoinRequests(_convoId, cursor: state.joinRequestsCursor);
      emit(
        state.copyWith(
          joinRequests: [...state.joinRequests, ...page.requests],
          joinRequestsCursor: page.cursor,
          hasMoreJoinRequests: page.cursor != null,
          isLoadingJoinRequests: false,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoadingJoinRequests: false, hasMoreJoinRequests: false));
    }
  }

  Future<void> approveJoinRequest(String memberDid) async {
    await _mutate(() => _convoRepository.approveJoinRequest(_convoId, memberDid));
    await loadJoinRequests();
  }

  Future<void> rejectJoinRequest(String memberDid) async {
    emit(state.copyWith(isMutating: true, errorMessage: null));
    try {
      await _convoRepository.rejectJoinRequest(_convoId, memberDid);
      await loadJoinRequests();
      emit(state.copyWith(isMutating: false, errorMessage: null));
    } catch (error) {
      emit(state.copyWith(isMutating: false, errorMessage: _groupDetailsErrorMessage(error, _l10n)));
    }
  }

  Future<void> _mutateJoinLink(Future<JoinLinkView> Function() mutation) async {
    emit(state.copyWith(isMutating: true, errorMessage: null));
    try {
      final joinLink = await mutation();
      final refreshed = await _convoRepository.getConvo(_convoId);
      final group = refreshed.kind?.groupConvo;
      final convo = group == null
          ? refreshed
          : refreshed.copyWith(
              kind: UConvoViewKind.groupConvo(data: group.copyWith(joinLink: joinLink)),
            );
      emit(state.copyWith(convo: convo, isMutating: false, errorMessage: null));
    } catch (error) {
      emit(state.copyWith(isMutating: false, errorMessage: _groupDetailsErrorMessage(error, _l10n)));
    }
  }

  Future<void> _mutate(Future<ConvoView> Function() mutation) async {
    emit(state.copyWith(isMutating: true, errorMessage: null));
    try {
      final convo = await mutation();
      final page = await _convoRepository.getConvoMembers(_convoId);
      emit(
        state.copyWith(
          status: GroupDetailsStatus.loaded,
          convo: convo,
          members: page.members,
          cursor: page.cursor,
          hasMore: page.cursor != null,
          isMutating: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isMutating: false, errorMessage: _groupDetailsErrorMessage(error, _l10n)));
    }
  }
}

String _groupDetailsErrorMessage(Object error, AppLocalizations l10n) {
  final code = error is atcore.XRPCException ? error.response.data.error : null;
  return switch (code) {
    'InsufficientRole' => l10n.errorGroupDetailsInsufficientRole,
    'OwnerCannotLeave' => l10n.errorGroupDetailsOwnerCannotLeave,
    'BlockedActor' || 'BlockedSubject' => l10n.errorGroupDetailsBlockedActor,
    'UserForbidsGroups' => l10n.errorGroupDetailsUserForbidsGroups,
    'NotFollowedBySender' => l10n.errorGroupDetailsNotFollowedBySender,
    'RecipientNotFound' => l10n.errorGroupDetailsRecipientNotFound,
    'JoinLinkNotFound' => l10n.errorGroupDetailsJoinLinkNotFound,
    'JoinLinkDisabled' => l10n.errorGroupDetailsJoinLinkDisabled,
    'InvalidJoinRequest' => l10n.errorGroupDetailsInvalidJoinRequest,
    _ => l10n.errorGroupDetailsUpdateFailed,
  };
}
