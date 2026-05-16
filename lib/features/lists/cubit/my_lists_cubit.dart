import 'package:poptart_core/poptart_core.dart' show AtUri, Blob;
import 'package:bluesky_poptart/app/bsky/graph/defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';

part 'my_lists_state.dart';

class MyListsCubit extends Cubit<MyListsState> {
  MyListsCubit({required ListRepository listRepository})
    : _listRepository = listRepository,
      super(const MyListsState.initial());

  final ListRepository _listRepository;
  int _requestId = 0;

  Future<void> load({required String actor, int limit = 50}) async {
    final requestId = _beginRequest();
    _emitIfOpen(MyListsState.loading(actor: actor, limit: limit));

    try {
      final result = await _listRepository.getLists(actor: actor, limit: limit);
      if (!_isCurrentRequest(requestId)) {
        return;
      }
      _emitIfOpen(
        MyListsState.loaded(
          actor: actor,
          lists: result.lists,
          cursor: result.cursor,
          hasMore: result.cursor != null,
          limit: limit,
        ),
      );
    } catch (error) {
      if (!_isCurrentRequest(requestId)) {
        return;
      }
      _emitIfOpen(MyListsState.error(message: 'Failed to load lists: $error', actor: actor, limit: limit));
    }
  }

  Future<void> refresh() async {
    final actor = state.actor;
    if (actor == null) {
      return;
    }
    final limit = state.limit;
    final requestId = _beginRequest();

    _emitIfOpen(state.copyWith(isRefreshing: true, errorMessage: null));

    try {
      final result = await _listRepository.getLists(actor: actor, limit: limit);
      if (!_isCurrentRequest(requestId)) {
        return;
      }
      _emitIfOpen(
        MyListsState.loaded(
          actor: actor,
          lists: result.lists,
          cursor: result.cursor,
          hasMore: result.cursor != null,
          limit: limit,
        ),
      );
    } catch (error) {
      if (!_isCurrentRequest(requestId)) {
        return;
      }
      _emitIfOpen(state.copyWith(isRefreshing: false, errorMessage: 'Failed to refresh lists: $error'));
    }
  }

  Future<AtUri?> createList({
    required String userDid,
    required String name,
    required String purpose,
    String? description,
    List<int>? avatarBytes,
    String avatarMimeType = 'image/jpeg',
  }) async {
    try {
      Blob? avatarBlob;
      if (avatarBytes != null) {
        avatarBlob = await _listRepository.uploadListAvatar(bytes: avatarBytes, mimeType: avatarMimeType);
      }

      final listUri = await _listRepository.createList(
        userDid: userDid,
        name: name,
        purpose: purpose,
        description: description,
        avatarBlob: avatarBlob,
      );

      if (state.status == MyListsStatus.loaded) {
        await refresh();
      }

      return listUri;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadMore() async {
    if (state.status != MyListsStatus.loaded || state.actor == null || state.cursor == null || state.isLoadingMore) {
      return;
    }

    final actor = state.actor!;
    final cursor = state.cursor;
    final limit = state.limit;
    final lists = state.lists;
    final requestId = _beginRequest();

    _emitIfOpen(state.copyWith(isLoadingMore: true));

    try {
      final result = await _listRepository.getLists(actor: actor, cursor: cursor, limit: limit);
      if (!_isCurrentRequest(requestId)) {
        return;
      }

      _emitIfOpen(
        state.copyWith(
          lists: [...lists, ...result.lists],
          cursor: result.cursor,
          hasMore: result.cursor != null,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      if (!_isCurrentRequest(requestId)) {
        return;
      }
      _emitIfOpen(state.copyWith(isLoadingMore: false, hasMore: false));
    }
  }

  int _beginRequest() {
    _requestId += 1;
    return _requestId;
  }

  bool _isCurrentRequest(int requestId) => !isClosed && requestId == _requestId;

  void _emitIfOpen(MyListsState nextState) {
    if (isClosed) {
      return;
    }
    emit(nextState);
  }
}
