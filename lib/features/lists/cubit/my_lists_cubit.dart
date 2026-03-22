import 'package:atproto_core/atproto_core.dart' show AtUri, BlobRef;
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';

part 'my_lists_state.dart';

class MyListsCubit extends Cubit<MyListsState> {
  MyListsCubit({required ListRepository listRepository})
    : _listRepository = listRepository,
      super(const MyListsState.initial());

  final ListRepository _listRepository;

  Future<void> load({required String actor, int limit = 50}) async {
    emit(MyListsState.loading(actor: actor, limit: limit));

    try {
      final result = await _listRepository.getLists(actor: actor, limit: limit);
      emit(
        MyListsState.loaded(
          actor: actor,
          lists: result.lists,
          cursor: result.cursor,
          hasMore: result.cursor != null,
          limit: limit,
        ),
      );
    } catch (error) {
      emit(MyListsState.error(message: 'Failed to load lists: $error', actor: actor, limit: limit));
    }
  }

  Future<void> refresh() async {
    if (state.actor == null) {
      return;
    }

    emit(state.copyWith(isRefreshing: true, errorMessage: null));

    try {
      final result = await _listRepository.getLists(actor: state.actor!, limit: state.limit);
      emit(
        MyListsState.loaded(
          actor: state.actor!,
          lists: result.lists,
          cursor: result.cursor,
          hasMore: result.cursor != null,
          limit: state.limit,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isRefreshing: false, errorMessage: 'Failed to refresh lists: $error'));
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
      BlobRef? avatarBlob;
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

    emit(state.copyWith(isLoadingMore: true));

    try {
      final result = await _listRepository.getLists(actor: state.actor!, cursor: state.cursor, limit: state.limit);

      emit(
        state.copyWith(
          lists: [...state.lists, ...result.lists],
          cursor: result.cursor,
          hasMore: result.cursor != null,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false, hasMore: false));
    }
  }
}
