import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/search/data/search_repository.dart';

enum TopicSort {
  top,
  latest;

  String get apiValue => name;

  String get label => switch (this) {
    TopicSort.top => 'Top',
    TopicSort.latest => 'Latest',
  };
}

enum TopicTimelineStatus { initial, loading, loaded, error }

class TopicTimeline extends Equatable {
  const TopicTimeline._({
    required this.status,
    this.posts = const [],
    this.cursor,
    this.errorMessage,
    this.isLoadingMore = false,
  });

  const TopicTimeline.initial() : this._(status: TopicTimelineStatus.initial);

  final TopicTimelineStatus status;
  final List<PostView> posts;
  final String? cursor;
  final String? errorMessage;
  final bool isLoadingMore;

  bool get isLoading => status == TopicTimelineStatus.loading;
  bool get hasError => status == TopicTimelineStatus.error;

  static const Object _unset = Object();

  TopicTimeline copyWith({
    TopicTimelineStatus? status,
    List<PostView>? posts,
    Object? cursor = _unset,
    Object? errorMessage = _unset,
    bool? isLoadingMore,
  }) {
    return TopicTimeline._(
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

class TopicState extends Equatable {
  const TopicState({
    required this.topic,
    this.displayName,
    this.currentSort = TopicSort.top,
    this.topTimeline = const TopicTimeline.initial(),
    this.latestTimeline = const TopicTimeline.initial(),
  });

  final String topic;
  final String? displayName;
  final TopicSort currentSort;
  final TopicTimeline topTimeline;
  final TopicTimeline latestTimeline;

  TopicTimeline get currentTimeline {
    return currentSort == TopicSort.top ? topTimeline : latestTimeline;
  }

  bool get isMissingTopic => topic.isEmpty;

  TopicState copyWith({
    String? topic,
    Object? displayName = TopicTimeline._unset,
    TopicSort? currentSort,
    TopicTimeline? topTimeline,
    TopicTimeline? latestTimeline,
  }) {
    return TopicState(
      topic: topic ?? this.topic,
      displayName: identical(displayName, TopicTimeline._unset) ? this.displayName : displayName as String?,
      currentSort: currentSort ?? this.currentSort,
      topTimeline: topTimeline ?? this.topTimeline,
      latestTimeline: latestTimeline ?? this.latestTimeline,
    );
  }

  @override
  List<Object?> get props => [topic, displayName, currentSort, topTimeline, latestTimeline];
}

class TopicCubit extends Cubit<TopicState> {
  TopicCubit({required SearchRepository searchRepository, required String topic})
    : _searchRepository = searchRepository,
      super(TopicState(topic: topic.trim()));

  final SearchRepository _searchRepository;

  Future<void> initialize() async {
    if (state.isMissingTopic) {
      return;
    }
    await _load(sort: TopicSort.top, refresh: true);
  }

  Future<void> switchSort(TopicSort sort) async {
    if (state.currentSort == sort) {
      return;
    }
    emit(state.copyWith(currentSort: sort));

    final timeline = _timelineFor(sort, state);
    if (timeline.status == TopicTimelineStatus.initial) {
      await _load(sort: sort, refresh: true);
    }
  }

  Future<void> refreshCurrent() async {
    await _load(sort: state.currentSort, refresh: true);
  }

  Future<void> loadMoreCurrent() async {
    await _load(sort: state.currentSort, loadMore: true);
  }

  Future<void> _load({required TopicSort sort, bool refresh = false, bool loadMore = false}) async {
    if (state.isMissingTopic) {
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
      if (refresh || timeline.status == TopicTimelineStatus.initial || timeline.hasError) {
        _setTimeline(
          sort,
          timeline.copyWith(
            status: TopicTimelineStatus.loading,
            posts: refresh ? const [] : timeline.posts,
            cursor: refresh ? null : timeline.cursor,
            errorMessage: null,
            isLoadingMore: false,
          ),
        );
      }
    }

    try {
      final result = await _searchRepository.searchTopicPosts(
        topic: state.topic,
        sort: sort.apiValue,
        cursor: loadMore ? timeline.cursor : null,
        limit: 25,
      );

      final mergedPosts = loadMore ? [...timeline.posts, ...result.posts] : result.posts;
      final nameFromResult = result.topicName?.trim();
      final nextDisplayName = (nameFromResult == null || nameFromResult.isEmpty) ? state.displayName : nameFromResult;

      _setTimeline(
        sort,
        TopicTimeline._(
          status: TopicTimelineStatus.loaded,
          posts: mergedPosts,
          cursor: result.cursor,
          errorMessage: null,
          isLoadingMore: false,
        ),
      );

      if (nextDisplayName != state.displayName) {
        emit(state.copyWith(displayName: nextDisplayName));
      }
    } catch (_) {
      if (loadMore) {
        _setTimeline(
          sort,
          timeline.copyWith(
            status: timeline.posts.isEmpty ? TopicTimelineStatus.error : TopicTimelineStatus.loaded,
            errorMessage: timeline.posts.isEmpty ? 'Failed to load posts.' : null,
            isLoadingMore: false,
          ),
        );
        return;
      }

      _setTimeline(
        sort,
        TopicTimeline._(
          status: TopicTimelineStatus.error,
          posts: timeline.posts,
          cursor: timeline.cursor,
          errorMessage: 'Failed to load posts.',
          isLoadingMore: false,
        ),
      );
    }
  }

  TopicTimeline _timelineFor(TopicSort sort, TopicState sourceState) {
    return sort == TopicSort.top ? sourceState.topTimeline : sourceState.latestTimeline;
  }

  void _setTimeline(TopicSort sort, TopicTimeline timeline) {
    if (sort == TopicSort.top) {
      emit(state.copyWith(topTimeline: timeline));
    } else {
      emit(state.copyWith(latestTimeline: timeline));
    }
  }
}
