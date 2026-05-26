import 'package:poptart_core/poptart_core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';

class PostActionState extends Equatable {
  const PostActionState({
    required this.postUri,
    this.isLiked = false,
    this.isReposted = false,
    this.likeCount = 0,
    this.repostCount = 0,
    this.likeUri,
    this.repostUri,
    this.isLoadingLike = false,
    this.isLoadingRepost = false,
    this.isDeleted = false,
    this.error,
  });

  /// Sentinel used by copyWith to distinguish "keep existing value" from
  /// an explicit null assignment for nullable fields.
  static const Object _unset = Object();

  final String postUri;
  final bool isLiked;
  final bool isReposted;
  final int likeCount;
  final int repostCount;
  final String? likeUri;
  final String? repostUri;
  final bool isLoadingLike;
  final bool isLoadingRepost;
  final bool isDeleted;
  final String? error;

  PostActionState copyWith({
    bool? isLiked,
    bool? isReposted,
    int? likeCount,
    int? repostCount,
    Object? likeUri = _unset,
    Object? repostUri = _unset,
    bool? isLoadingLike,
    bool? isLoadingRepost,
    bool? isDeleted,
    Object? error = _unset,
  }) => PostActionState(
    postUri: postUri,
    isLiked: isLiked ?? this.isLiked,
    isReposted: isReposted ?? this.isReposted,
    likeCount: likeCount ?? this.likeCount,
    repostCount: repostCount ?? this.repostCount,
    likeUri: identical(likeUri, _unset) ? this.likeUri : likeUri as String?,
    repostUri: identical(repostUri, _unset) ? this.repostUri : repostUri as String?,
    isLoadingLike: isLoadingLike ?? this.isLoadingLike,
    isLoadingRepost: isLoadingRepost ?? this.isLoadingRepost,
    isDeleted: isDeleted ?? this.isDeleted,
    error: identical(error, _unset) ? this.error : error as String?,
  );

  @override
  List<Object?> get props => [
    postUri,
    isLiked,
    isReposted,
    likeCount,
    repostCount,
    likeUri,
    repostUri,
    isLoadingLike,
    isLoadingRepost,
    isDeleted,
    error,
  ];
}

class PostActionCubit extends Cubit<PostActionState> {
  PostActionCubit({
    required PostActionRepository postActionRepository,
    required String postUri,
    required String postCid,
    bool isLiked = false,
    bool isReposted = false,
    int likeCount = 0,
    int repostCount = 0,
    String? likeUri,
    String? repostUri,
    PostActionCache? cache,
  }) : _postActionRepository = postActionRepository,
       _postCid = postCid,
       _cache = cache,
       super(
         _buildInitialState(
           postUri: postUri,
           isLiked: isLiked,
           isReposted: isReposted,
           likeCount: likeCount,
           repostCount: repostCount,
           likeUri: likeUri,
           repostUri: repostUri,
           cache: cache,
         ),
       );

  final PostActionRepository _postActionRepository;
  final String _postCid;
  final PostActionCache? _cache;

  static PostActionState _buildInitialState({
    required String postUri,
    required bool isLiked,
    required bool isReposted,
    required int likeCount,
    required int repostCount,
    String? likeUri,
    String? repostUri,
    PostActionCache? cache,
  }) {
    final cached = cache?.read(postUri);
    if (cached != null) {
      return PostActionState(
        postUri: postUri,
        isLiked: cached.isLiked,
        isReposted: cached.isReposted,
        likeCount: cached.likeCount,
        repostCount: cached.repostCount,
        likeUri: cached.likeUri,
        repostUri: cached.repostUri,
      );
    }
    return PostActionState(
      postUri: postUri,
      isLiked: isLiked,
      isReposted: isReposted,
      likeCount: likeCount,
      repostCount: repostCount,
      likeUri: likeUri,
      repostUri: repostUri,
    );
  }

  void _persistToCache() => _cache?.write(state);

  Future<void> toggleLike() => _runOptimisticToggle(
    isLoading: state.isLoadingLike,
    wasActive: state.isLiked,
    previousCount: state.likeCount,
    previousUri: state.likeUri,
    optimisticState: ({required wasActive, required previousCount}) => state.copyWith(
      isLiked: !wasActive,
      likeCount: wasActive ? previousCount - 1 : previousCount + 1,
      isLoadingLike: true,
      error: null,
    ),
    activate: () => _postActionRepository.likePost(uri: AtUri.parse(state.postUri), cid: _postCid),
    deactivate: (uri) => _postActionRepository.unlikePost(likeUri: uri),
    successState: (uri) => state.copyWith(likeUri: uri, isLoadingLike: false),
    idleState: () => state.copyWith(isLoadingLike: false),
    rollbackState: ({required wasActive, required previousCount, required previousUri}) => state.copyWith(
      isLiked: wasActive,
      likeCount: previousCount,
      likeUri: previousUri,
      isLoadingLike: false,
      error: 'Failed to ${wasActive ? 'unlike' : 'like'} post',
    ),
    failureLogMessage: 'Failed to toggle like',
  );

  Future<void> toggleRepost() => _runOptimisticToggle(
    isLoading: state.isLoadingRepost,
    wasActive: state.isReposted,
    previousCount: state.repostCount,
    previousUri: state.repostUri,
    optimisticState: ({required wasActive, required previousCount}) => state.copyWith(
      isReposted: !wasActive,
      repostCount: wasActive ? previousCount - 1 : previousCount + 1,
      isLoadingRepost: true,
      error: null,
    ),
    activate: () => _postActionRepository.repostPost(uri: AtUri.parse(state.postUri), cid: _postCid),
    deactivate: (uri) => _postActionRepository.unrepostPost(repostUri: uri),
    successState: (uri) => state.copyWith(repostUri: uri, isLoadingRepost: false),
    idleState: () => state.copyWith(isLoadingRepost: false),
    rollbackState: ({required wasActive, required previousCount, required previousUri}) => state.copyWith(
      isReposted: wasActive,
      repostCount: previousCount,
      repostUri: previousUri,
      isLoadingRepost: false,
      error: 'Failed to ${wasActive ? 'unrepost' : 'repost'} post',
    ),
    failureLogMessage: 'Failed to toggle repost',
  );

  Future<void> _runOptimisticToggle({
    required bool isLoading,
    required bool wasActive,
    required int previousCount,
    required String? previousUri,
    required PostActionState Function({required bool wasActive, required int previousCount}) optimisticState,
    required Future<String> Function() activate,
    required Future<void> Function(String uri) deactivate,
    required PostActionState Function(String? uri) successState,
    required PostActionState Function() idleState,
    required PostActionState Function({
      required bool wasActive,
      required int previousCount,
      required String? previousUri,
    })
    rollbackState,
    required String failureLogMessage,
  }) async {
    if (isLoading) return;

    emit(optimisticState(wasActive: wasActive, previousCount: previousCount));

    try {
      if (wasActive) {
        if (previousUri != null) {
          await deactivate(previousUri);
          emit(successState(null));
        } else {
          emit(idleState());
        }
      } else {
        emit(successState(await activate()));
      }
    } catch (error) {
      log.e(failureLogMessage, error: error);
      emit(rollbackState(wasActive: wasActive, previousCount: previousCount, previousUri: previousUri));
    } finally {
      _persistToCache();
    }
  }

  Future<void> deletePost() async {
    try {
      await _postActionRepository.deletePost(postUri: state.postUri);
      emit(state.copyWith(isDeleted: true));
    } catch (error) {
      log.e('Failed to delete post', error: error);
      emit(state.copyWith(error: 'Failed to delete post'));
    }
  }

  void clearError() {
    if (state.error == null) return;
    emit(
      PostActionState(
        postUri: state.postUri,
        isLiked: state.isLiked,
        isReposted: state.isReposted,
        likeCount: state.likeCount,
        repostCount: state.repostCount,
        likeUri: state.likeUri,
        repostUri: state.repostUri,
        isLoadingLike: state.isLoadingLike,
        isLoadingRepost: state.isLoadingRepost,
        isDeleted: state.isDeleted,
        error: null,
      ),
    );
  }
}
