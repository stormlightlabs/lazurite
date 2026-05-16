import 'package:poptart_core/poptart_core.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';

part 'list_feed_event.dart';
part 'list_feed_state.dart';

class ListFeedBloc extends Bloc<ListFeedEvent, ListFeedState> {
  ListFeedBloc({required ListRepository listRepository})
    : _listRepository = listRepository,
      super(const ListFeedState.initial()) {
    on<ListFeedRequested>(_onListFeedRequested);
    on<ListFeedLoadMoreRequested>(_onListFeedLoadMoreRequested);
    on<ListFeedRefreshed>(_onListFeedRefreshed);
  }

  final ListRepository _listRepository;

  Future<void> _onListFeedRequested(ListFeedRequested event, Emitter<ListFeedState> emit) async {
    emit(ListFeedState.loading(listUri: event.listUri));

    try {
      final result = await _listRepository.getListFeed(listUri: event.listUri, limit: event.limit);

      emit(
        ListFeedState.loaded(
          listUri: event.listUri,
          posts: result.posts,
          cursor: result.cursor,
          hasMore: result.cursor != null,
        ),
      );
    } catch (error) {
      emit(ListFeedState.error('Failed to load list feed: $error', listUri: event.listUri));
    }
  }

  Future<void> _onListFeedLoadMoreRequested(ListFeedLoadMoreRequested event, Emitter<ListFeedState> emit) async {
    if (state.status != ListFeedStatus.loaded || state.listUri == null || state.cursor == null || state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    try {
      final result = await _listRepository.getListFeed(
        listUri: state.listUri!,
        cursor: state.cursor,
        limit: event.limit,
      );

      emit(
        state.copyWith(
          posts: [...state.posts, ...result.posts],
          cursor: result.cursor,
          hasMore: result.cursor != null,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false, hasMore: false));
    }
  }

  Future<void> _onListFeedRefreshed(ListFeedRefreshed event, Emitter<ListFeedState> emit) async {
    if (state.status != ListFeedStatus.loaded || state.listUri == null) {
      return;
    }

    emit(state.copyWith(isRefreshing: true));

    try {
      final result = await _listRepository.getListFeed(listUri: state.listUri!, limit: event.limit);

      emit(
        state.copyWith(posts: result.posts, cursor: result.cursor, hasMore: result.cursor != null, isRefreshing: false),
      );
    } catch (_) {
      emit(state.copyWith(isRefreshing: false));
    }
  }
}
