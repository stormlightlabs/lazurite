import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/feed/data/post_thread_repository.dart';

enum PostThreadStatus { loading, loaded, error }

class PostThreadState extends Equatable {
  const PostThreadState({this.status = PostThreadStatus.loading, this.thread, this.error});

  final PostThreadStatus status;
  final ThreadViewPost? thread;
  final String? error;

  @override
  List<Object?> get props => [status, thread, error];
}

class PostThreadCubit extends Cubit<PostThreadState> {
  PostThreadCubit({required PostThreadRepository postThreadRepository})
    : _postThreadRepository = postThreadRepository,
      super(const PostThreadState());

  final PostThreadRepository _postThreadRepository;

  Future<void> load(String uri) async {
    emit(const PostThreadState(status: PostThreadStatus.loading));
    try {
      final thread = await _postThreadRepository.getPostThread(uri);
      emit(PostThreadState(status: PostThreadStatus.loaded, thread: thread));
    } catch (error) {
      log.e('Failed to load thread', error: error);
      emit(const PostThreadState(status: PostThreadStatus.error, error: 'Failed to load thread'));
    }
  }
}
