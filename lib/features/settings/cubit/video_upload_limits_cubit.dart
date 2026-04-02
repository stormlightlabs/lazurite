import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/settings/data/video_repository.dart';

part 'video_upload_limits_state.dart';

class VideoUploadLimitsCubit extends Cubit<VideoUploadLimitsState> {
  VideoUploadLimitsCubit({required VideoRepository repository})
    : _repository = repository,
      super(const VideoUploadLimitsState.initial());

  final VideoRepository _repository;

  Future<void> fetch() async {
    if (state.isLoading) return;

    emit(const VideoUploadLimitsState.loading());

    try {
      final limits = await _repository.getUploadLimits();
      emit(VideoUploadLimitsState.loaded(limits));
    } catch (error) {
      emit(VideoUploadLimitsState.error('Failed to load upload limits: $error'));
    }
  }
}
