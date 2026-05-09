import 'package:poptart_lex/app/bsky/video/get_upload_limits.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';

abstract interface class VideoUploadLimitsApi {
  Future<VideoGetUploadLimitsOutput> getUploadLimits();

  Future<String> getUploadLimitsAuthToken();

  Future<VideoGetUploadLimitsOutput> getUploadLimitsWithAuthToken(String authToken);
}

final class BlueskyVideoUploadLimitsApi implements VideoUploadLimitsApi {
  const BlueskyVideoUploadLimitsApi({required Bluesky bluesky}) : _bluesky = bluesky;

  final Bluesky _bluesky;

  @override
  Future<VideoGetUploadLimitsOutput> getUploadLimits() async {
    final response = await _bluesky.video.getUploadLimits();
    return response.data;
  }

  @override
  Future<String> getUploadLimitsAuthToken() async {
    final auth = await _bluesky.video.getUploadLimitsAuth();
    return auth.data.token;
  }

  @override
  Future<VideoGetUploadLimitsOutput> getUploadLimitsWithAuthToken(String authToken) async {
    final response = await _bluesky.video.getUploadLimitsWithAuthToken(authToken);
    return response.data;
  }
}

class VideoRepository {
  VideoRepository({Bluesky? bluesky, VideoUploadLimitsApi? api})
    : assert(bluesky != null || api != null, 'Provide either bluesky or api'),
      _api = api ?? BlueskyVideoUploadLimitsApi(bluesky: bluesky!);

  final VideoUploadLimitsApi _api;

  Future<VideoUploadLimits> getUploadLimits() async {
    try {
      final limits = await _api.getUploadLimits();
      return _mapLimits(limits);
    } catch (error, stackTrace) {
      try {
        final authToken = await _api.getUploadLimitsAuthToken();
        final limits = await _api.getUploadLimitsWithAuthToken(authToken);
        return _mapLimits(limits);
      } catch (_) {
        Error.throwWithStackTrace(error, stackTrace);
      }
    }
  }

  VideoUploadLimits _mapLimits(VideoGetUploadLimitsOutput data) {
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
