import 'package:bluesky/bluesky.dart';

class VideoRepository {
  VideoRepository({required Bluesky bluesky}) : _bluesky = bluesky;

  final Bluesky _bluesky;

  Future<VideoUploadLimits> getUploadLimits() async {
    final response = await _bluesky.video.getUploadLimits();
    final data = response.data;
    return VideoUploadLimits(
      canUpload: data.canUpload,
      remainingDailyVideos: data.remainingDailyVideos,
      remainingDailyBytes: data.remainingDailyBytes,
      message: data.message,
      error: data.error,
    );
  }
}

class VideoUploadLimits {
  const VideoUploadLimits({
    required this.canUpload,
    this.remainingDailyVideos,
    this.remainingDailyBytes,
    this.message,
    this.error,
  });

  final bool canUpload;
  final int? remainingDailyVideos;
  final int? remainingDailyBytes;
  final String? message;
  final String? error;
}
