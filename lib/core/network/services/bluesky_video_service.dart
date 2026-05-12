part of '../poptart_client_adapter.dart';

class BlueskyVideoService {
  BlueskyVideoService._(this._client);

  static const _videoServiceDid = 'did:web:video.bsky.app';

  final PoptartClient _client;

  Future<XRPCResponse<JobStatus>> uploadVideo({
    required Uint8List bytes,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(appBskyVideoUploadVideo, headers: $headers, service: $service, input: bytes);
  }

  Future<XRPCResponse<VideoGetJobStatusOutput>> getJobStatus({
    required String jobId,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyVideoGetJobStatus,
      headers: $headers,
      service: $service,
      parameters: VideoGetJobStatusInput(jobId: jobId),
    );
  }

  Future<XRPCResponse<VideoGetUploadLimitsOutput>> getUploadLimits({Map<String, String>? $headers, String? $service}) {
    return _client.call(appBskyVideoGetUploadLimits, headers: $headers, service: $service);
  }

  Future<XRPCResponse<ServerGetServiceAuthOutput>> getUploadLimitsAuth({
    int? exp,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return AtProtoServerService._(_client).getServiceAuth(
      aud: _videoServiceDid,
      exp: exp,
      lxm: 'app.bsky.video.getUploadLimits',
      $headers: $headers,
      $service: $service,
    );
  }

  Future<XRPCResponse<VideoGetUploadLimitsOutput>> getUploadLimitsWithAuthToken(String authToken, {String? $service}) {
    return getUploadLimits($headers: {'Authorization': 'Bearer $authToken'}, $service: $service);
  }
}
