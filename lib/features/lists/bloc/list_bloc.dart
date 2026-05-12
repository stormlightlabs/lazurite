import 'package:poptart_core/poptart_core.dart' show AtUri, Blob;
import 'package:poptart_lex/app/bsky/graph/defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';

part 'list_event.dart';
part 'list_state.dart';

class ListBloc extends Bloc<ListEvent, ListState> {
  ListBloc({required ListRepository listRepository})
    : _listRepository = listRepository,
      super(const ListState.initial()) {
    on<ListRequested>(_onListRequested);
    on<ListRefreshed>(_onListRefreshed);
    on<ListItemAdded>(_onListItemAdded);
    on<ListItemRemoved>(_onListItemRemoved);
    on<ListMuted>(_onListMuted);
    on<ListUnmuted>(_onListUnmuted);
    on<ListBlocked>(_onListBlocked);
    on<ListUnblocked>(_onListUnblocked);
    on<ListUpdated>(_onListUpdated);
    on<ListDeleted>(_onListDeleted);
  }

  final ListRepository _listRepository;

  Future<void> _onListRequested(ListRequested event, Emitter<ListState> emit) async {
    emit(ListState.loading(listUri: event.listUri, limit: event.limit));

    try {
      final result = await _listRepository.getList(listUri: event.listUri, limit: event.limit);

      emit(
        ListState.loaded(
          listUri: event.listUri,
          list: result.list,
          items: result.items,
          cursor: result.cursor,
          hasMore: result.cursor != null,
          limit: event.limit,
        ),
      );
    } catch (error) {
      emit(ListState.error(message: 'Failed to load list: $error', listUri: event.listUri, limit: event.limit));
    }
  }

  Future<void> _onListRefreshed(ListRefreshed event, Emitter<ListState> emit) async {
    if (state.listUri == null) {
      return;
    }

    await _reloadList(emit, isRefreshing: true, errorPrefix: 'Failed to refresh list');
  }

  Future<void> _onListItemAdded(ListItemAdded event, Emitter<ListState> emit) async {
    if (state.listUri == null || state.isMutating) {
      return;
    }

    await _runMutation(
      emit,
      action: () => _listRepository.addListItem(listUri: state.listUri!, subjectDid: event.subjectDid),
      errorPrefix: 'Failed to add member',
    );
  }

  Future<void> _onListItemRemoved(ListItemRemoved event, Emitter<ListState> emit) async {
    if (state.listUri == null || state.isMutating) {
      return;
    }

    await _runMutation(
      emit,
      action: () => _listRepository.removeListItem(listItemUri: event.listItemUri),
      errorPrefix: 'Failed to remove member',
    );
  }

  Future<void> _onListMuted(ListMuted event, Emitter<ListState> emit) async {
    if (state.listUri == null || state.isMutating) {
      return;
    }

    await _runMutation(
      emit,
      action: () => _listRepository.muteList(listUri: state.listUri!),
      errorPrefix: 'Failed to mute list',
    );
  }

  Future<void> _onListUnmuted(ListUnmuted event, Emitter<ListState> emit) async {
    if (state.listUri == null || state.isMutating) {
      return;
    }

    await _runMutation(
      emit,
      action: () => _listRepository.unmuteList(listUri: state.listUri!),
      errorPrefix: 'Failed to unmute list',
    );
  }

  Future<void> _onListBlocked(ListBlocked event, Emitter<ListState> emit) async {
    if (state.listUri == null || state.isMutating) {
      return;
    }

    await _runMutation(
      emit,
      action: () => _listRepository.blockList(listUri: state.listUri!),
      errorPrefix: 'Failed to block list',
    );
  }

  Future<void> _onListUnblocked(ListUnblocked event, Emitter<ListState> emit) async {
    final blockUri = state.list?.viewer?.blocked;
    if (blockUri == null || state.isMutating) {
      return;
    }

    await _runMutation(
      emit,
      action: () => _listRepository.unblockList(blockUri: blockUri),
      errorPrefix: 'Failed to unblock list',
    );
  }

  Future<void> _onListUpdated(ListUpdated event, Emitter<ListState> emit) async {
    if (state.status != ListStatus.loaded || state.listUri == null || state.isMutating || state.list == null) {
      return;
    }

    emit(state.copyWith(isMutating: true, errorMessage: null));

    try {
      Blob? avatarBlob;
      if (event.avatarBytes != null) {
        avatarBlob = await _listRepository.uploadListAvatar(bytes: event.avatarBytes!, mimeType: event.avatarMimeType);
      }

      await _listRepository.updateList(
        listUri: state.listUri!,
        userDid: event.userDid,
        name: event.name,
        purpose: state.list!.purpose.toJson(),
        description: event.description,
        avatarBlob: avatarBlob,
      );

      await _reloadList(emit, isRefreshing: false, isMutating: true, errorPrefix: 'Failed to update list');
    } catch (error) {
      emit(state.copyWith(isMutating: false, errorMessage: 'Failed to update list: $error'));
    }
  }

  Future<void> _onListDeleted(ListDeleted event, Emitter<ListState> emit) async {
    if (state.status != ListStatus.loaded || state.listUri == null || state.isMutating) {
      return;
    }

    emit(state.copyWith(isMutating: true, errorMessage: null));

    try {
      await _listRepository.deleteList(listUri: state.listUri!, userDid: event.userDid);
      emit(const ListState.deleted());
    } catch (error) {
      emit(state.copyWith(isMutating: false, errorMessage: 'Failed to delete list: $error'));
    }
  }

  Future<void> _runMutation(
    Emitter<ListState> emit, {
    required Future<void> Function() action,
    required String errorPrefix,
  }) async {
    if (state.status != ListStatus.loaded || state.listUri == null) {
      return;
    }

    emit(state.copyWith(isMutating: true, errorMessage: null));

    try {
      await action();
      await _reloadList(emit, isRefreshing: false, isMutating: true, errorPrefix: errorPrefix);
    } catch (error) {
      emit(state.copyWith(isMutating: false, errorMessage: '$errorPrefix: $error'));
    }
  }

  Future<void> _reloadList(
    Emitter<ListState> emit, {
    required bool isRefreshing,
    required String errorPrefix,
    bool isMutating = false,
  }) async {
    final listUri = state.listUri;
    if (listUri == null) {
      return;
    }

    emit(state.copyWith(isRefreshing: isRefreshing, isMutating: isMutating, errorMessage: null));

    try {
      final result = await _listRepository.getList(listUri: listUri, limit: state.limit);
      emit(
        ListState.loaded(
          listUri: listUri,
          list: result.list,
          items: result.items,
          cursor: result.cursor,
          hasMore: result.cursor != null,
          limit: state.limit,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isRefreshing: false, isMutating: false, errorMessage: '$errorPrefix: $error'));
    }
  }
}
