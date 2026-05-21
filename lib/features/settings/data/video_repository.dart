import 'package:bluesky_poptart/app/bsky/video/get_upload_limits.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/unauthorized_recovery_runner.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

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

final class RecoveringVideoUploadLimitsApi implements VideoUploadLimitsApi {
  RecoveringVideoUploadLimitsApi({
    required VideoUploadLimitsApi initialApi,
    required Future<AuthTokens?> Function()? onUnauthorized,
    required VideoUploadLimitsApi? Function(AuthTokens tokens) apiFactory,
  }) {
    _authRecovery = UnauthorizedRecoveryRunner<VideoUploadLimitsApi>(
      initialClient: initialApi,
      onUnauthorized: onUnauthorized,
      clientFactory: apiFactory,
    );
  }

  late final UnauthorizedRecoveryRunner<VideoUploadLimitsApi> _authRecovery;

  @override
  Future<VideoGetUploadLimitsOutput> getUploadLimits() {
    return _authRecovery.run((api) => api.getUploadLimits());
  }

  @override
  Future<String> getUploadLimitsAuthToken() {
    return _authRecovery.run((api) => api.getUploadLimitsAuthToken());
  }

  @override
  Future<VideoGetUploadLimitsOutput> getUploadLimitsWithAuthToken(String authToken) {
    return _authRecovery.run((api) => api.getUploadLimitsWithAuthToken(authToken));
  }
}

class VideoRepository {
  VideoRepository({
    Bluesky? bluesky,
    VideoUploadLimitsApi? api,
    Future<AuthTokens?> Function()? onUnauthorized,
    VideoUploadLimitsApi? Function(AuthTokens tokens)? apiFactory,
  }) : assert(bluesky != null || api != null, 'Provide either bluesky or api'),
       _api = onUnauthorized == null
           ? api ?? BlueskyVideoUploadLimitsApi(bluesky: bluesky!)
           : RecoveringVideoUploadLimitsApi(
               initialApi: api ?? BlueskyVideoUploadLimitsApi(bluesky: bluesky!),
               onUnauthorized: onUnauthorized,
               apiFactory:
                   apiFactory ??
                   (tokens) {
                     final refreshedBluesky = createBlueskyClient(tokens);
                     return refreshedBluesky == null ? null : BlueskyVideoUploadLimitsApi(bluesky: refreshedBluesky);
                   },
             );

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
      } catch (fallbackError, fallbackStackTrace) {
        log.d(
          'Video upload limits fallback failed; rethrowing original limits request error',
          error: fallbackError,
          stackTrace: fallbackStackTrace,
        );
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
