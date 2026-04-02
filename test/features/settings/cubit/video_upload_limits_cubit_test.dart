import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/settings/cubit/video_upload_limits_cubit.dart';
import 'package:lazurite/features/settings/data/video_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockVideoRepository extends Mock implements VideoRepository {}

const _canUploadLimits = VideoUploadLimits(canUpload: true, remainingDailyVideos: 5, remainingDailyBytes: 524288000);
const _cannotUploadLimits = VideoUploadLimits(
  canUpload: false,
  remainingDailyVideos: 0,
  remainingDailyBytes: 0,
  error: 'DAILY_LIMIT_EXCEEDED',
  message: 'Daily limit reached',
);

void main() {
  late MockVideoRepository mockRepository;

  setUp(() {
    mockRepository = MockVideoRepository();
  });

  VideoUploadLimitsCubit buildCubit() => VideoUploadLimitsCubit(repository: mockRepository);

  group('VideoUploadLimitsCubit', () {
    group('initial state', () {
      test('has initial status and null limits', () {
        final cubit = buildCubit();
        expect(cubit.state.status, VideoUploadLimitsStatus.initial);
        expect(cubit.state.limits, isNull);
        expect(cubit.state.errorMessage, isNull);
        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.hasError, isFalse);
      });
    });

    group('fetch', () {
      blocTest<VideoUploadLimitsCubit, VideoUploadLimitsState>(
        'emits loading then loaded with limits when canUpload is true',
        build: buildCubit,
        setUp: () {
          when(() => mockRepository.getUploadLimits()).thenAnswer((_) async => _canUploadLimits);
        },
        act: (cubit) => cubit.fetch(),
        expect: () => [
          const VideoUploadLimitsState.loading(),
          predicate<VideoUploadLimitsState>(
            (s) =>
                s.status == VideoUploadLimitsStatus.loaded &&
                s.limits != null &&
                s.limits!.canUpload == true &&
                s.limits!.remainingDailyVideos == 5,
          ),
        ],
      );

      blocTest<VideoUploadLimitsCubit, VideoUploadLimitsState>(
        'emits loaded with canUpload false and error/message fields',
        build: buildCubit,
        setUp: () {
          when(() => mockRepository.getUploadLimits()).thenAnswer((_) async => _cannotUploadLimits);
        },
        act: (cubit) => cubit.fetch(),
        expect: () => [
          const VideoUploadLimitsState.loading(),
          predicate<VideoUploadLimitsState>(
            (s) =>
                s.status == VideoUploadLimitsStatus.loaded &&
                s.limits != null &&
                s.limits!.canUpload == false &&
                s.limits!.error == 'DAILY_LIMIT_EXCEEDED' &&
                s.limits!.message == 'Daily limit reached',
          ),
        ],
      );

      blocTest<VideoUploadLimitsCubit, VideoUploadLimitsState>(
        'emits error when repository throws',
        build: buildCubit,
        setUp: () {
          when(() => mockRepository.getUploadLimits()).thenThrow(Exception('auth failure'));
        },
        act: (cubit) => cubit.fetch(),
        expect: () => [
          const VideoUploadLimitsState.loading(),
          predicate<VideoUploadLimitsState>((s) => s.status == VideoUploadLimitsStatus.error && s.errorMessage != null),
        ],
      );

      blocTest<VideoUploadLimitsCubit, VideoUploadLimitsState>(
        'is a no-op when already loading',
        build: buildCubit,
        seed: () => const VideoUploadLimitsState.loading(),
        setUp: () {
          when(() => mockRepository.getUploadLimits()).thenAnswer((_) async => _canUploadLimits);
        },
        act: (cubit) => cubit.fetch(),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockRepository.getUploadLimits());
        },
      );

      blocTest<VideoUploadLimitsCubit, VideoUploadLimitsState>(
        'loaded state exposes limits with optional null fields',
        build: buildCubit,
        setUp: () {
          when(
            () => mockRepository.getUploadLimits(),
          ).thenAnswer((_) async => const VideoUploadLimits(canUpload: true));
        },
        act: (cubit) => cubit.fetch(),
        expect: () => [
          const VideoUploadLimitsState.loading(),
          predicate<VideoUploadLimitsState>(
            (s) =>
                s.status == VideoUploadLimitsStatus.loaded &&
                s.limits!.remainingDailyVideos == null &&
                s.limits!.remainingDailyBytes == null,
          ),
        ],
      );
    });
  });
}
