import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

enum VideoUploadState { uploading, processing, completed, failed }

class VideoUploadException implements Exception {
  const VideoUploadException(this.message);
  final String message;
  @override
  String toString() => 'VideoUploadException: $message';
}

class VideoUploadService {
  VideoUploadService({required XrpcClient api, required Logger logger, Duration? pollingInterval})
    : _api = api,
      _logger = logger,
      _cancelTokens = {},
      _pollingInterval = pollingInterval ?? VideoUploadService.defaultPollingInterval;

  final XrpcClient _api;
  final Logger _logger;
  final Map<String, CancelToken> _cancelTokens;
  final Duration _pollingInterval;

  static const videoServiceDid = 'did:web:video.bsky.app';
  static const defaultPollingInterval = Duration(seconds: 2);
  static const maxPollingAttempts = 30;

  void cancelUpload(String jobId) {
    final cancelToken = _cancelTokens[jobId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Upload cancelled by user');
      _cancelTokens.remove(jobId);
      _logger.debug('Cancelled upload for job: $jobId');
    }
  }

  Future<Map<String, dynamic>> getServiceAuth(String lexicon) async {
    try {
      final response = await _api.call(
        'com.atproto.server.getServiceAuth',
        body: {'aud': videoServiceDid, 'lxm': lexicon},
      );
      final token = response['token'] as String?;
      if (token == null) {
        throw const VideoUploadException('Service auth token not found in response');
      }

      return {'token': token};
    } catch (e) {
      _logger.error('Failed to get service auth for $lexicon', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadVideo({
    required String filePath,
    required String mimeType,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw VideoUploadException('Video file not found: $filePath');
    }

    final tempJobId = DateTime.now().millisecondsSinceEpoch.toString();
    final uploadCancelToken = cancelToken ?? CancelToken();
    _cancelTokens[tempJobId] = uploadCancelToken;

    try {
      final authResponse = await getServiceAuth('app.bsky.video.uploadVideo');
      final authToken = authResponse['token'] as String?;

      final formData = FormData.fromMap({'file': await MultipartFile.fromFile(filePath)});
      final response = await _api.callRaw<Map<String, dynamic>>(
        'app.bsky.video.uploadVideo',
        body: formData,
        cancelToken: uploadCancelToken,
        onSendProgress: (sent, total) {
          if (total > 0) {
            onProgress?.call(sent / total);
          }
        },
        headers: authToken != null ? {'Authorization': 'Bearer $authToken'} : null,
      );

      final jobStatus = response.data?['jobStatus'] as Map<String, dynamic>?;
      if (jobStatus == null) {
        throw const VideoUploadException('Job status not found in upload response');
      }

      final responseJobId = jobStatus['jobId'] as String?;
      if (responseJobId == null) {
        throw const VideoUploadException('Job ID not found in upload response');
      }

      _cancelTokens.remove(tempJobId);
      _cancelTokens[responseJobId] = uploadCancelToken;

      final blob = await _pollJobStatus(responseJobId);
      _cancelTokens.remove(responseJobId);
      return blob;
    } on DioException catch (e) {
      _cancelTokens.remove(tempJobId);
      if (e.type == DioExceptionType.cancel) {
        throw const VideoUploadException('Upload cancelled');
      }
      throw VideoUploadException('Upload failed: ${e.message}');
    } catch (e) {
      _cancelTokens.remove(tempJobId);
      throw VideoUploadException('Upload failed: $e');
    }
  }

  Future<Map<String, dynamic>> _pollJobStatus(String jobId) async {
    var attempts = 0;

    while (attempts < maxPollingAttempts) {
      try {
        final response = await _api.callRaw<Map<String, dynamic>>(
          'app.bsky.video.getJobStatus',
          params: {'jobId': jobId},
          cancelToken: _cancelTokens[jobId],
        );

        final jobStatus = response.data?['jobStatus'] as Map<String, dynamic>?;
        if (jobStatus == null) {
          throw const VideoUploadException('Job status not found in response');
        }

        final state = jobStatus['state'] as String?;
        if (state == 'JOB_STATE_COMPLETED') {
          final blob = jobStatus['blob'] as Map<String, dynamic>?;
          if (blob == null) {
            throw const VideoUploadException('Blob not found in completed job');
          }

          return blob;
        }

        if (state == 'JOB_STATE_FAILED') {
          final error = jobStatus['error'] as String? ?? 'Unknown error';
          throw VideoUploadException('Video processing failed: $error');
        }

        await Future.delayed(_pollingInterval);
        attempts++;
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel) {
          throw const VideoUploadException('Upload cancelled');
        }
        _logger.warning('Polling attempt $attempts failed for job $jobId: $e');
        await Future.delayed(_pollingInterval);
        attempts++;
      } catch (e) {
        _logger.warning('Polling attempt $attempts failed for job $jobId: $e');
        await Future.delayed(_pollingInterval);
        attempts++;
      }
    }

    throw const VideoUploadException('Video processing timed out');
  }

  Future<Map<String, dynamic>?> getUploadLimits() async {
    try {
      final response = await _api.call('app.bsky.video.getUploadLimits');
      return response;
    } catch (e) {
      _logger.error('Failed to get upload limits', e);
      return null;
    }
  }
}
