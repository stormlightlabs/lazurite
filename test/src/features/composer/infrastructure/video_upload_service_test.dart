import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/composer/infrastructure/video_upload_service.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';
import 'package:mocktail/mocktail.dart';

class MockXrpcClient extends Mock implements XrpcClient {}

class MockLogger extends Mock implements Logger {}

/// Helper to create a mock upload response
Response<Map<String, dynamic>> _mockUploadResponse({
  required Map<String, dynamic> jobStatus,
  String? path,
}) {
  return Response<Map<String, dynamic>>(
    data: {'jobStatus': jobStatus},
    statusCode: 200,
    requestOptions: RequestOptions(path: path ?? 'xrpc/app.bsky.video.uploadVideo'),
  );
}

void main() {
  late MockXrpcClient mockApi;
  late MockLogger mockLogger;
  late VideoUploadService videoUploadService;
  late File tempVideoFile;

  setUp(() async {
    mockApi = MockXrpcClient();
    mockLogger = MockLogger();
    // Use Duration.zero for fast tests
    videoUploadService = VideoUploadService(
      api: mockApi,
      logger: mockLogger,
      pollingInterval: Duration.zero,
    );

    // Mock getServiceAuth for all tests
    when(
      () => mockApi.call('com.atproto.server.getServiceAuth', body: any(named: 'body')),
    ).thenAnswer((_) async => {'token': 'test-service-auth-token'});

    final tempDir = Directory.systemTemp;
    if (await tempDir.exists()) {
      final file = File('${tempDir.path}/test_video.mp4');
      if (file.existsSync()) {
        await file.delete();
      }
      await file.writeAsBytes([0, 1, 2, 3]);
      tempVideoFile = file;
    }
  });

  tearDown(() async {
    if (await tempVideoFile.exists()) {
      await tempVideoFile.delete();
    }
  });

  group('VideoUploadService - uploadVideo', () {
    test('uploads video and returns blob', () async {
      when(
        () => mockApi.callRaw<Map<String, dynamic>>(
          'app.bsky.video.uploadVideo',
          body: any(named: 'body'),
          cancelToken: any(named: 'cancelToken'),
          headers: any(named: 'headers'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenAnswer(
        (_) async => _mockUploadResponse(
          jobStatus: {
            'jobId': 'test-job-123',
            'state': 'JOB_STATE_COMPLETED',
            'blob': {
              r'$type': 'blob',
              'ref': {r'$link': 'bafyrei...'},
              'mimeType': 'video/mp4',
              'size': 123456,
            },
          },
        ),
      );

      // Mock getJobStatus to return completed state on first call
      when(
        () => mockApi.callRaw<Map<String, dynamic>>(
          'app.bsky.video.getJobStatus',
          params: any(named: 'params'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            'jobStatus': {
              'jobId': 'test-job-123',
              'state': 'JOB_STATE_COMPLETED',
              'blob': {
                r'$type': 'blob',
                'ref': {r'$link': 'bafyrei...'},
                'mimeType': 'video/mp4',
                'size': 123456,
              },
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: 'xrpc/app.bsky.video.getJobStatus'),
        ),
      );

      final result = await videoUploadService.uploadVideo(
        filePath: tempVideoFile.path,
        mimeType: 'video/mp4',
      );

      expect(result, containsPair(r'$type', 'blob'));
      expect(result, containsPair('ref', containsPair(r'$link', 'bafyrei...')));
      expect(result, containsPair('mimeType', 'video/mp4'));
    });

    test('polls job status until completed', () async {
      var pollCount = 0;

      when(
        () => mockApi.callRaw<Map<String, dynamic>>(
          'app.bsky.video.uploadVideo',
          body: any(named: 'body'),
          cancelToken: any(named: 'cancelToken'),
          headers: any(named: 'headers'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenAnswer(
        (_) async => _mockUploadResponse(
          jobStatus: {'jobId': 'test-job-456', 'state': 'JOB_STATE_PENDING'},
        ),
      );

      when(
        () => mockApi.callRaw<Map<String, dynamic>>(
          'app.bsky.video.getJobStatus',
          params: any(named: 'params'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async {
        pollCount++;
        if (pollCount < 2) {
          return Response<Map<String, dynamic>>(
            data: {
              'jobStatus': {'jobId': 'test-job-456', 'state': 'JOB_STATE_PENDING'},
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: 'xrpc/app.bsky.video.getJobStatus'),
          );
        } else {
          return Response<Map<String, dynamic>>(
            data: {
              'jobStatus': {
                'jobId': 'test-job-456',
                'state': 'JOB_STATE_COMPLETED',
                'blob': {
                  r'$type': 'blob',
                  'ref': {r'$link': 'bafyrei...'},
                  'mimeType': 'video/mp4',
                  'size': 789012,
                },
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: 'xrpc/app.bsky.video.getJobStatus'),
          );
        }
      });

      final result = await videoUploadService.uploadVideo(
        filePath: tempVideoFile.path,
        mimeType: 'video/mp4',
      );

      expect(result, containsPair(r'$type', 'blob'));
      expect(result, containsPair('ref', containsPair(r'$link', 'bafyrei...')));
      expect(pollCount, greaterThan(1));
    });

    test('throws exception on failed job', () async {
      when(
        () => mockApi.callRaw<Map<String, dynamic>>(
          'app.bsky.video.uploadVideo',
          body: any(named: 'body'),
          cancelToken: any(named: 'cancelToken'),
          headers: any(named: 'headers'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenAnswer(
        (_) async => _mockUploadResponse(
          jobStatus: {'jobId': 'test-job-failed', 'state': 'JOB_STATE_PENDING'},
        ),
      );

      when(
        () => mockApi.callRaw<Map<String, dynamic>>(
          'app.bsky.video.getJobStatus',
          params: any(named: 'params'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            'jobStatus': {
              'jobId': 'test-job-failed',
              'state': 'JOB_STATE_FAILED',
              'error': 'Video processing error',
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: 'xrpc/app.bsky.video.getJobStatus'),
        ),
      );

      expect(
        () => videoUploadService.uploadVideo(filePath: tempVideoFile.path, mimeType: 'video/mp4'),
        throwsA(isA<VideoUploadException>()),
      );
    });

    test('throws exception on file not found', () async {
      final nonExistentFile = File('${Directory.systemTemp.path}/nonexistent.mp4');

      expect(
        () =>
            videoUploadService.uploadVideo(filePath: nonExistentFile.path, mimeType: 'video/mp4'),
        throwsA(isA<VideoUploadException>()),
      );
    });
  });

  group('VideoUploadService - cancelUpload', () {
    test('cancels active upload', () async {
      var getJobStatusCallCount = 0;
      final shouldCancel = Completer<bool>();

      when(
        () => mockApi.callRaw<Map<String, dynamic>>(
          'app.bsky.video.uploadVideo',
          body: any(named: 'body'),
          cancelToken: any(named: 'cancelToken'),
          headers: any(named: 'headers'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenAnswer(
        (_) async => _mockUploadResponse(
          jobStatus: {'jobId': 'test-job-cancel', 'state': 'JOB_STATE_PENDING'},
        ),
      );

      // Mock getJobStatus to throw DioException.cancel after first call
      when(
        () => mockApi.callRaw<Map<String, dynamic>>(
          'app.bsky.video.getJobStatus',
          params: any(named: 'params'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async {
        getJobStatusCallCount++;

        // First call returns pending, subsequent calls simulate cancellation
        if (getJobStatusCallCount == 1) {
          // Wait for the signal to cancel
          await shouldCancel.future;
        }

        // After first call, throw cancellation exception
        throw DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: 'app.bsky.video.getJobStatus'),
        );
      });

      // Start the upload in a separate future (but don't await yet)
      final uploadFuture = videoUploadService.uploadVideo(
        filePath: tempVideoFile.path,
        mimeType: 'video/mp4',
      );

      // Wait a bit for the first getJobStatus call to happen
      await Future.delayed(const Duration(milliseconds: 10));

      // Signal the mock to start throwing cancellation exceptions
      shouldCancel.complete(true);

      // Cancel the upload
      videoUploadService.cancelUpload('test-job-cancel');

      // The upload should throw a cancellation exception wrapped in upload failed
      await expectLater(
        uploadFuture,
        throwsA(
          isA<VideoUploadException>().having((e) => e.message, 'message', contains('cancelled')),
        ),
      );

      // Verify that getJobStatus was called at least once
      expect(getJobStatusCallCount, greaterThan(0));
    });

    test('does not throw when job not found', () async {
      expect(() => videoUploadService.cancelUpload('non-existent-job'), returnsNormally);
    });
  });

  group('VideoUploadService - getUploadLimits', () {
    test('returns upload limits', () async {
      when(() => mockApi.call('app.bsky.video.getUploadLimits')).thenAnswer(
        (_) async => {
          'canUpload': true,
          'remainingDailyVideos': 10,
          'remainingDailyBytes': 50000000,
        },
      );

      final result = await videoUploadService.getUploadLimits();

      expect(result, isNotNull);
      expect(result, containsPair('canUpload', true));
      expect(result, containsPair('remainingDailyVideos', 10));
    });

    test('returns null on error', () async {
      when(
        () => mockApi.call('app.bsky.video.getUploadLimits'),
      ).thenThrow(const VideoUploadException('Failed to get upload limits'));

      final result = await videoUploadService.getUploadLimits();

      expect(result, isNull);
    });
  });
}
