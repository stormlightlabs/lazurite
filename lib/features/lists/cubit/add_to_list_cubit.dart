import 'package:bluesky_poptart/app/bsky/graph/get_lists_with_membership.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';

part 'add_to_list_state.dart';

class AddToListCubit extends Cubit<AddToListState> {
  AddToListCubit({required ListRepository listRepository, required String currentUserDid})
    : _listRepository = listRepository,
      super(const AddToListState.initial());

  final ListRepository _listRepository;

  Future<void> load({required String targetDid}) async {
    emit(AddToListState.loading(targetDid: targetDid));

    try {
      final result = await _listRepository.getListsWithMembership(actor: targetDid);
      emit(AddToListState.loaded(targetDid: targetDid, lists: result.lists));
    } catch (error) {
      emit(AddToListState.error(message: 'Failed to load lists: $error', targetDid: targetDid));
    }
  }

  Future<void> toggleMembership(ListWithMembership entry) async {
    if (state.status != AddToListStatus.loaded) return;
    if (state.togglingUris.contains(entry.list.uri.toString())) return;

    emit(state.copyWith(togglingUris: {...state.togglingUris, entry.list.uri.toString()}));

    try {
      if (entry.listItem != null) {
        await _listRepository.removeListItem(listItemUri: entry.listItem!.uri);
      } else {
        await _listRepository.addListItem(listUri: entry.list.uri, subjectDid: state.targetDid!);
      }

      final result = await _listRepository.getListsWithMembership(actor: state.targetDid!);
      emit(AddToListState.loaded(targetDid: state.targetDid!, lists: result.lists));
    } catch (_) {
      final newTogglingUris = {...state.togglingUris}..remove(entry.list.uri.toString());
      emit(state.copyWith(togglingUris: newTogglingUris));
    }
  }
}
