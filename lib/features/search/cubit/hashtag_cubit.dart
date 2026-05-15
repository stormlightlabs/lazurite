import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/search/data/search_repository.dart';

enum HashtagSort {
  top,
  latest;

  String get apiValue => name;

  String get label => switch (this) {
    HashtagSort.top => 'Top',
    HashtagSort.latest => 'Latest',
  };
}

enum HashtagTimelineStatus { initial, loading, loaded, error }

class HashtagTimeline extends Equatable {
  const HashtagTimeline._({
    required this.status,
    this.posts = const [],
    this.cursor,
    this.errorMessage,
    this.isLoadingMore = false,
  });

  const HashtagTimeline.initial() : this._(status: HashtagTimelineStatus.initial);

  final HashtagTimelineStatus status;
  final List<PostView> posts;
  final String? cursor;
  final String? errorMessage;
  final bool isLoadingMore;

  bool get isLoading => status == HashtagTimelineStatus.loading;
  bool get hasError => status == HashtagTimelineStatus.error;

  static const Object _unset = Object();

  HashtagTimeline copyWith({
    HashtagTimelineStatus? status,
    List<PostView>? posts,
    Object? cursor = _unset,
    Object? errorMessage = _unset,
    bool? isLoadingMore,
  }) {
    return HashtagTimeline._(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      cursor: identical(cursor, _unset) ? this.cursor : cursor as String?,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [status, posts, cursor, errorMessage, isLoadingMore];
}

class HashtagState extends Equatable {
  const HashtagState({
    required this.tag,
    this.currentSort = HashtagSort.top,
    this.topTimeline = const HashtagTimeline.initial(),
    this.latestTimeline = const HashtagTimeline.initial(),
  });

  final String tag;
  final HashtagSort currentSort;
  final HashtagTimeline topTimeline;
  final HashtagTimeline latestTimeline;

  HashtagTimeline get currentTimeline {
    return currentSort == HashtagSort.top ? topTimeline : latestTimeline;
  }

  bool get isMissingTag => tag.isEmpty;

  HashtagState copyWith({
    String? tag,
    HashtagSort? currentSort,
    HashtagTimeline? topTimeline,
    HashtagTimeline? latestTimeline,
  }) {
    return HashtagState(
      tag: tag ?? this.tag,
      currentSort: currentSort ?? this.currentSort,
      topTimeline: topTimeline ?? this.topTimeline,
      latestTimeline: latestTimeline ?? this.latestTimeline,
    );
  }

  @override
  List<Object?> get props => [tag, currentSort, topTimeline, latestTimeline];
}

class HashtagCubit extends Cubit<HashtagState> {
  HashtagCubit({required SearchRepository searchRepository, required String tag})
    : _searchRepository = searchRepository,
      super(HashtagState(tag: tag));

  final SearchRepository _searchRepository;

  Future<void> initialize() async {
    if (state.isMissingTag) {
      return;
    }
    await _load(sort: HashtagSort.top, refresh: true);
  }

  Future<void> switchSort(HashtagSort sort) async {
    if (state.currentSort == sort) {
      return;
    }

    emit(state.copyWith(currentSort: sort));

    final timeline = _timelineFor(sort, state);
    if (timeline.status == HashtagTimelineStatus.initial) {
      await _load(sort: sort, refresh: true);
    }
  }

  Future<void> refreshCurrent() async {
    await _load(sort: state.currentSort, refresh: true);
  }

  Future<void> loadMoreCurrent() async {
    await _load(sort: state.currentSort, loadMore: true);
  }

  Future<void> _load({required HashtagSort sort, bool refresh = false, bool loadMore = false}) async {
    if (state.isMissingTag) {
      return;
    }

    final timeline = _timelineFor(sort, state);

    if (loadMore) {
      if (timeline.isLoadingMore || timeline.cursor == null || timeline.isLoading) {
        return;
      }
      _setTimeline(sort, timeline.copyWith(isLoadingMore: true, errorMessage: null));
    } else {
      if (timeline.isLoading) {
        return;
      }

      if (refresh || timeline.status == HashtagTimelineStatus.initial || timeline.hasError) {
        _setTimeline(
          sort,
          timeline.copyWith(
            status: HashtagTimelineStatus.loading,
            posts: refresh ? const [] : timeline.posts,
            cursor: refresh ? null : timeline.cursor,
            errorMessage: null,
            isLoadingMore: false,
          ),
        );
      }
    }

    try {
      final result = await _searchRepository.searchPosts(
        query: '#${state.tag}',
        sort: sort.apiValue,
        cursor: loadMore ? timeline.cursor : null,
        limit: 50,
      );

      final mergedPosts = loadMore ? [...timeline.posts, ...result.posts] : result.posts;

      _setTimeline(
        sort,
        HashtagTimeline._(
          status: HashtagTimelineStatus.loaded,
          posts: mergedPosts,
          cursor: result.cursor,
          errorMessage: null,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      if (loadMore) {
        _setTimeline(
          sort,
          timeline.copyWith(
            status: timeline.posts.isEmpty ? HashtagTimelineStatus.error : HashtagTimelineStatus.loaded,
            errorMessage: timeline.posts.isEmpty ? 'Failed to load posts.' : null,
            isLoadingMore: false,
          ),
        );
        return;
      }

      _setTimeline(
        sort,
        HashtagTimeline._(
          status: HashtagTimelineStatus.error,
          posts: timeline.posts,
          cursor: timeline.cursor,
          errorMessage: 'Failed to load posts.',
          isLoadingMore: false,
        ),
      );
    }
  }

  HashtagTimeline _timelineFor(HashtagSort sort, HashtagState sourceState) {
    return sort == HashtagSort.top ? sourceState.topTimeline : sourceState.latestTimeline;
  }

  void _setTimeline(HashtagSort sort, HashtagTimeline timeline) {
    if (sort == HashtagSort.top) {
      emit(state.copyWith(topTimeline: timeline));
    } else {
      emit(state.copyWith(latestTimeline: timeline));
    }
  }
}
