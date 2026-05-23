import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/feed/data/similar_posts_repository.dart';

/// Loading phases for the similar-posts section.
///
/// The section starts idle so thread rendering never waits on the graph lookup.
/// A user tap moves it to [loading], and pagination uses [loadingMore] while
/// preserving already-rendered posts.
enum SimilarPostsStatus { idle, loading, loaded, loadingMore, error }

class SimilarPostsState extends Equatable {
  const SimilarPostsState({
    this.status = SimilarPostsStatus.idle,
    this.posts = const <PostView>[],
    this.cursor,
    this.error,
  });

  final SimilarPostsStatus status;
  final List<PostView> posts;
  final String? cursor;
  final String? error;

  bool get hasMore => cursor != null && cursor!.isNotEmpty;

  @override
  List<Object?> get props => [status, posts, cursor, error];
}

/// Coordinates the opt-in similar-posts UI with [SimilarPostsRepository].
///
/// The cubit deliberately exposes explicit load methods instead of loading in
/// its constructor. That keeps network work behind the "Show similar posts" UI
/// affordance and avoids adding overhead to every thread open.
class SimilarPostsCubit extends Cubit<SimilarPostsState> {
  SimilarPostsCubit({required SimilarPostsRepository repository})
    : _repository = repository,
      super(const SimilarPostsState());

  final SimilarPostsRepository _repository;
  String? _postUri;

  Future<void> load(String postUri) async {
    final normalizedPostUri = postUri.trim();
    if (normalizedPostUri.isEmpty) return;

    _postUri = normalizedPostUri;
    emit(const SimilarPostsState(status: SimilarPostsStatus.loading));
    try {
      final page = await _repository.getSimilarPosts(postUri: normalizedPostUri);
      emit(SimilarPostsState(status: SimilarPostsStatus.loaded, posts: page.posts, cursor: page.cursor));
    } catch (error, stackTrace) {
      log.w('Failed to load similar posts for $normalizedPostUri', error: error, stackTrace: stackTrace);
      emit(const SimilarPostsState(status: SimilarPostsStatus.error, error: 'Similar posts are unavailable.'));
    }
  }

  Future<void> loadMore() async {
    final postUri = _postUri;
    final cursor = state.cursor;
    if (postUri == null || cursor == null || cursor.isEmpty || state.status == SimilarPostsStatus.loadingMore) {
      return;
    }

    final existing = state.posts;
    emit(SimilarPostsState(status: SimilarPostsStatus.loadingMore, posts: existing, cursor: cursor));
    try {
      final page = await _repository.getSimilarPosts(postUri: postUri, cursor: cursor);
      final seen = existing.map((post) => post.uri.toString()).toSet();
      final merged = <PostView>[
        ...existing,
        for (final post in page.posts)
          if (seen.add(post.uri.toString())) post,
      ];
      emit(SimilarPostsState(status: SimilarPostsStatus.loaded, posts: merged, cursor: page.cursor));
    } catch (error, stackTrace) {
      log.w('Failed to load more similar posts for $postUri', error: error, stackTrace: stackTrace);
      emit(SimilarPostsState(status: SimilarPostsStatus.loaded, posts: existing, cursor: cursor));
    }
  }
}
