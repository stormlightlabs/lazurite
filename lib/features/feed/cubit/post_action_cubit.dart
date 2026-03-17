import 'package:atproto_core/atproto_core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
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
    this.error,
  });

  final String postUri;
  final bool isLiked;
  final bool isReposted;
  final int likeCount;
  final int repostCount;
  final String? likeUri;
  final String? repostUri;
  final bool isLoadingLike;
  final bool isLoadingRepost;
  final String? error;

  PostActionState copyWith({
    bool? isLiked,
    bool? isReposted,
    int? likeCount,
    int? repostCount,
    String? likeUri,
    String? repostUri,
    bool? isLoadingLike,
    bool? isLoadingRepost,
    String? error,
  }) {
    return PostActionState(
      postUri: postUri,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
      likeCount: likeCount ?? this.likeCount,
      repostCount: repostCount ?? this.repostCount,
      likeUri: likeUri ?? this.likeUri,
      repostUri: repostUri ?? this.repostUri,
      isLoadingLike: isLoadingLike ?? this.isLoadingLike,
      isLoadingRepost: isLoadingRepost ?? this.isLoadingRepost,
      error: error ?? this.error,
    );
  }

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
  }) : _postActionRepository = postActionRepository,
       _postCid = postCid,
       super(
         PostActionState(
           postUri: postUri,
           isLiked: isLiked,
           isReposted: isReposted,
           likeCount: likeCount,
           repostCount: repostCount,
           likeUri: likeUri,
           repostUri: repostUri,
         ),
       );

  final PostActionRepository _postActionRepository;
  final String _postCid;

  Future<void> toggleLike() async {
    if (state.isLoadingLike) return;

    final wasLiked = state.isLiked;
    final previousLikeCount = state.likeCount;
    final previousLikeUri = state.likeUri;

    emit(
      state.copyWith(
        isLiked: !wasLiked,
        likeCount: wasLiked ? previousLikeCount - 1 : previousLikeCount + 1,
        isLoadingLike: true,
        error: null,
      ),
    );

    try {
      if (wasLiked) {
        if (previousLikeUri != null) {
          await _postActionRepository.unlikePost(likeUri: previousLikeUri);
          emit(state.copyWith(likeUri: null, isLoadingLike: false));
        } else {
          emit(state.copyWith(isLoadingLike: false));
        }
      } else {
        final newLikeUri = await _postActionRepository.likePost(uri: AtUri.parse(state.postUri), cid: _postCid);
        emit(state.copyWith(likeUri: newLikeUri, isLoadingLike: false));
      }
    } catch (error) {
      log.e('Failed to toggle like', error: error);

      emit(
        state.copyWith(
          isLiked: wasLiked,
          likeCount: previousLikeCount,
          likeUri: previousLikeUri,
          isLoadingLike: false,
          error: 'Failed to ${wasLiked ? 'unlike' : 'like'} post',
        ),
      );
    }
  }

  Future<void> toggleRepost() async {
    if (state.isLoadingRepost) return;

    final wasReposted = state.isReposted;
    final previousRepostCount = state.repostCount;
    final previousRepostUri = state.repostUri;

    emit(
      state.copyWith(
        isReposted: !wasReposted,
        repostCount: wasReposted ? previousRepostCount - 1 : previousRepostCount + 1,
        isLoadingRepost: true,
        error: null,
      ),
    );

    try {
      if (wasReposted) {
        if (previousRepostUri != null) {
          await _postActionRepository.unrepostPost(repostUri: previousRepostUri);
          emit(state.copyWith(repostUri: null, isLoadingRepost: false));
        } else {
          emit(state.copyWith(isLoadingRepost: false));
        }
      } else {
        final newRepostUri = await _postActionRepository.repostPost(uri: AtUri.parse(state.postUri), cid: _postCid);
        emit(state.copyWith(repostUri: newRepostUri, isLoadingRepost: false));
      }
    } catch (error) {
      log.e('Failed to toggle repost', error: error);

      emit(
        state.copyWith(
          isReposted: wasReposted,
          repostCount: previousRepostCount,
          repostUri: previousRepostUri,
          isLoadingRepost: false,
          error: 'Failed to ${wasReposted ? 'unrepost' : 'repost'} post',
        ),
      );
    }
  }

  Future<void> deletePost() async {
    try {
      await _postActionRepository.deletePost(postUri: state.postUri);
    } catch (error) {
      log.e('Failed to delete post', error: error);
      emit(state.copyWith(error: 'Failed to delete post'));
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
