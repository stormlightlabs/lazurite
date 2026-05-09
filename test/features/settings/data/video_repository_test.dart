import 'package:flutter_test/flutter_test.dart';
import 'package:poptart_lex/app/bsky/video/get_upload_limits.dart';
import 'package:lazurite/features/settings/data/video_repository.dart';

class FakeVideoUploadLimitsApi implements VideoUploadLimitsApi {
  FakeVideoUploadLimitsApi({
    this.getUploadLimitsHandler,
    this.getUploadLimitsAuthTokenHandler,
    this.getUploadLimitsWithAuthTokenHandler,
  });

  Future<VideoGetUploadLimitsOutput> Function()? getUploadLimitsHandler;
  Future<String> Function()? getUploadLimitsAuthTokenHandler;
  Future<VideoGetUploadLimitsOutput> Function(String authToken)? getUploadLimitsWithAuthTokenHandler;

  @override
  Future<VideoGetUploadLimitsOutput> getUploadLimits() {
    final handler = getUploadLimitsHandler;
    if (handler == null) {
      throw UnimplementedError('getUploadLimitsHandler was not set');
    }
    return handler();
  }

  @override
  Future<String> getUploadLimitsAuthToken() {
    final handler = getUploadLimitsAuthTokenHandler;
    if (handler == null) {
      throw UnimplementedError('getUploadLimitsAuthTokenHandler was not set');
    }
    return handler();
  }

  @override
  Future<VideoGetUploadLimitsOutput> getUploadLimitsWithAuthToken(String authToken) {
    final handler = getUploadLimitsWithAuthTokenHandler;
    if (handler == null) {
      throw UnimplementedError('getUploadLimitsWithAuthTokenHandler was not set');
    }
    return handler(authToken);
  }
}

void main() {
  group('VideoRepository.getUploadLimits', () {
    test('returns limits when canUpload is true', () async {
      final api = FakeVideoUploadLimitsApi(
        getUploadLimitsHandler: () async =>
            const VideoGetUploadLimitsOutput(canUpload: true, remainingDailyVideos: 10, remainingDailyBytes: 500000000),
      );
      final repository = VideoRepository(api: api);
      final result = await repository.getUploadLimits();

      expect(result.canUpload, isTrue);
      expect(result.remainingDailyVideos, 10);
      expect(result.remainingDailyBytes, 500000000);
      expect(result.message, isNull);
      expect(result.error, isNull);
    });

    test('retries with service-auth token when direct limits request fails', () async {
      final api = FakeVideoUploadLimitsApi(
        getUploadLimitsHandler: () async => throw Exception('invalid token'),
        getUploadLimitsAuthTokenHandler: () async => 'service-auth-token',
        getUploadLimitsWithAuthTokenHandler: (authToken) async {
          expect(authToken, 'service-auth-token');
          return const VideoGetUploadLimitsOutput(
            canUpload: false,
            remainingDailyVideos: 0,
            remainingDailyBytes: 0,
            message: 'Daily limit reached',
            error: 'DAILY_LIMIT_EXCEEDED',
          );
        },
      );
      final repository = VideoRepository(api: api);
      final result = await repository.getUploadLimits();

      expect(result.canUpload, isFalse);
      expect(result.remainingDailyVideos, 0);
      expect(result.remainingDailyBytes, 0);
      expect(result.message, 'Daily limit reached');
      expect(result.error, 'DAILY_LIMIT_EXCEEDED');
    });

    test('rethrows the original error when direct and fallback requests fail', () async {
      final api = FakeVideoUploadLimitsApi(
        getUploadLimitsHandler: () async => throw Exception('invalid token'),
        getUploadLimitsAuthTokenHandler: () async => throw Exception('service auth unavailable'),
      );
      final repository = VideoRepository(api: api);

      await expectLater(repository.getUploadLimits(), throwsA(isA<Exception>()));
    });
  });

  group('VideoUploadLimits', () {
    test('holds all fields', () {
      const limits = VideoUploadLimits(
        canUpload: true,
        remainingDailyVideos: 5,
        remainingDailyBytes: 1000,
        message: 'ok',
        error: null,
      );
      expect(limits.canUpload, isTrue);
      expect(limits.remainingDailyVideos, 5);
      expect(limits.remainingDailyBytes, 1000);
      expect(limits.message, 'ok');
      expect(limits.error, isNull);
    });
  });
}
