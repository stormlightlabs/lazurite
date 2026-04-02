part of 'video_upload_limits_cubit.dart';

enum VideoUploadLimitsStatus { initial, loading, loaded, error }

class VideoUploadLimitsState extends Equatable {
  const VideoUploadLimitsState._({required this.status, this.limits, this.errorMessage});

  const VideoUploadLimitsState.initial() : this._(status: VideoUploadLimitsStatus.initial);

  const VideoUploadLimitsState.loading() : this._(status: VideoUploadLimitsStatus.loading);

  const VideoUploadLimitsState.loaded(VideoUploadLimits limits)
    : this._(status: VideoUploadLimitsStatus.loaded, limits: limits);

  const VideoUploadLimitsState.error(String message)
    : this._(status: VideoUploadLimitsStatus.error, errorMessage: message);

  final VideoUploadLimitsStatus status;
  final VideoUploadLimits? limits;
  final String? errorMessage;

  bool get isLoading => status == VideoUploadLimitsStatus.loading;
  bool get hasError => status == VideoUploadLimitsStatus.error;

  @override
  List<Object?> get props => [status, limits, errorMessage];
}
