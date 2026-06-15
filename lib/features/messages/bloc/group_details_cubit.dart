import 'package:bluesky_poptart/chat/bsky/actor/defs.dart';
import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:poptart_core/poptart_core.dart' as atcore;

part 'group_details_state.dart';

class GroupDetailsCubit extends Cubit<GroupDetailsState> {
  GroupDetailsCubit({
    required ConvoRepository convoRepository,
    required String convoId,
    required String currentUserDid,
    ConvoView? initialConvo,
  }) : _convoRepository = convoRepository,
       _convoId = convoId,
       _currentUserDid = currentUserDid,
       super(GroupDetailsState(convo: initialConvo));

  final ConvoRepository _convoRepository;
  final String _convoId;
  final String _currentUserDid;

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
    } catch (error) {
      emit(state.copyWith(status: GroupDetailsStatus.error, errorMessage: 'Failed to load group details.'));
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

  Future<void> addMember(String did) async {
    await _mutate(() => _convoRepository.addGroupMembers(_convoId, [did]));
  }

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
      emit(state.copyWith(isMutating: false, errorMessage: _groupDetailsErrorMessage(error)));
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
      emit(state.copyWith(isMutating: false, errorMessage: _groupDetailsErrorMessage(error)));
    }
  }
}

String _groupDetailsErrorMessage(Object error) {
  final code = error is atcore.XRPCException ? error.response.data.error : null;
  return switch (code) {
    'InsufficientRole' => 'You do not have permission to change this group.',
    'OwnerCannotLeave' => 'Transfer ownership before leaving this group.',
    'BlockedActor' || 'BlockedSubject' => 'That member cannot be added because of a block.',
    'UserForbidsGroups' => 'That member does not allow group chat invites.',
    'NotFollowedBySender' => 'That member only accepts group invites from people they follow.',
    'RecipientNotFound' => 'That account could not be found.',
    _ => 'Group update failed. Try again.',
  };
}
