import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';

export 'package:lazurite/features/feed/data/feed_repository.dart' show FeedFilter;

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc({required FeedRepository feedRepository})
    : _feedRepository = feedRepository,
      super(const FeedState.initial()) {
    on<FeedLoadRequested>(_onFeedLoadRequested);
    on<FeedLoadMoreRequested>(_onFeedLoadMoreRequested);
    on<FeedRefreshRequested>(_onFeedRefreshRequested);
  }

  final FeedRepository _feedRepository;

  Future<void> _onFeedLoadRequested(FeedLoadRequested event, Emitter<FeedState> emit) async {
    emit(FeedState.loading(actor: event.actor, filter: event.filter));

    try {
      final result = await _feedRepository.getAuthorFeed(actor: event.actor, filter: event.filter, limit: event.limit);

      emit(
        FeedState.loaded(
          actor: event.actor,
          posts: result.posts,
          cursor: result.cursor,
          filter: event.filter,
          hasMore: result.cursor != null,
        ),
      );
    } catch (error) {
      emit(FeedState.error('Failed to load feed: $error', actor: event.actor, filter: event.filter));
    }
  }

  Future<void> _onFeedLoadMoreRequested(FeedLoadMoreRequested event, Emitter<FeedState> emit) async {
    if (state.status != FeedStatus.loaded || state.actor == null || state.cursor == null || state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    try {
      final result = await _feedRepository.getAuthorFeed(
        actor: state.actor!,
        filter: state.filter,
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
    } catch (error) {
      emit(state.copyWith(isLoadingMore: false, hasMore: false));
    }
  }

  Future<void> _onFeedRefreshRequested(FeedRefreshRequested event, Emitter<FeedState> emit) async {
    if (state.status != FeedStatus.loaded || state.actor == null) {
      return;
    }

    emit(state.copyWith(isRefreshing: true));

    try {
      final result = await _feedRepository.getAuthorFeed(actor: state.actor!, filter: state.filter, limit: 50);

      emit(
        state.copyWith(posts: result.posts, cursor: result.cursor, hasMore: result.cursor != null, isRefreshing: false),
      );
    } catch (error) {
      emit(state.copyWith(isRefreshing: false));
    }
  }
}
