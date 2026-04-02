import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/settings/data/video_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockVideoRepository extends Mock implements VideoRepository {}

void main() {
  late MockVideoRepository mockRepository;

  setUp(() {
    mockRepository = MockVideoRepository();
  });

  group('VideoRepository.getUploadLimits', () {
    test('returns limits when canUpload is true', () async {
      when(() => mockRepository.getUploadLimits()).thenAnswer(
        (_) async =>
            const VideoUploadLimits(canUpload: true, remainingDailyVideos: 10, remainingDailyBytes: 1024 * 1024 * 500),
      );

      final result = await mockRepository.getUploadLimits();

      expect(result.canUpload, isTrue);
      expect(result.remainingDailyVideos, 10);
      expect(result.remainingDailyBytes, 1024 * 1024 * 500);
      expect(result.message, isNull);
      expect(result.error, isNull);
    });

    test('returns limits with message and error when canUpload is false', () async {
      when(() => mockRepository.getUploadLimits()).thenAnswer(
        (_) async => const VideoUploadLimits(
          canUpload: false,
          remainingDailyVideos: 0,
          remainingDailyBytes: 0,
          message: 'Daily limit reached',
          error: 'DAILY_LIMIT_EXCEEDED',
        ),
      );

      final result = await mockRepository.getUploadLimits();

      expect(result.canUpload, isFalse);
      expect(result.message, 'Daily limit reached');
      expect(result.error, 'DAILY_LIMIT_EXCEEDED');
    });

    test('returns limits with all optional fields null', () async {
      when(() => mockRepository.getUploadLimits()).thenAnswer((_) async => const VideoUploadLimits(canUpload: true));

      final result = await mockRepository.getUploadLimits();

      expect(result.canUpload, isTrue);
      expect(result.remainingDailyVideos, isNull);
      expect(result.remainingDailyBytes, isNull);
    });

    test('propagates exceptions', () async {
      when(() => mockRepository.getUploadLimits()).thenThrow(Exception('auth error'));

      expect(() => mockRepository.getUploadLimits(), throwsException);
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
