import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/feed/cubit/liked_posts_sync_cubit.dart';
import 'package:lazurite/features/feed/data/liked_posts_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockLikedPostsRepository extends Mock implements LikedPostsRepository {}

const _accountDid = 'did:plc:testuser';

void main() {
  late MockLikedPostsRepository mockRepo;

  setUp(() {
    mockRepo = MockLikedPostsRepository();
  });

  LikedPostsSyncCubit buildCubit() =>
      LikedPostsSyncCubit(repository: mockRepo, accountDid: _accountDid);

  group('LikedPostsSyncCubit', () {
    group('initial state', () {
      test('is idle with no error', () {
        final cubit = buildCubit();
        expect(cubit.state.status, LikedPostsSyncStatus.idle);
        expect(cubit.state.isSyncing, isFalse);
        expect(cubit.state.errorMessage, isNull);
      });
    });

    group('sync', () {
      blocTest<LikedPostsSyncCubit, LikedPostsSyncState>(
        'emits syncing then synced on success',
        build: buildCubit,
        setUp: () {
          when(() => mockRepo.syncLikes(_accountDid)).thenAnswer((_) async {});
        },
        act: (cubit) => cubit.sync(),
        expect: () => [
          const LikedPostsSyncState(status: LikedPostsSyncStatus.syncing),
          const LikedPostsSyncState(status: LikedPostsSyncStatus.synced),
        ],
        verify: (_) => verify(() => mockRepo.syncLikes(_accountDid)).called(1),
      );

      blocTest<LikedPostsSyncCubit, LikedPostsSyncState>(
        'emits syncing then error when repository throws',
        build: buildCubit,
        setUp: () {
          when(() => mockRepo.syncLikes(_accountDid)).thenThrow(Exception('network timeout'));
        },
        act: (cubit) => cubit.sync(),
        expect: () => [
          const LikedPostsSyncState(status: LikedPostsSyncStatus.syncing),
          predicate<LikedPostsSyncState>(
            (s) => s.status == LikedPostsSyncStatus.error && s.errorMessage != null,
          ),
        ],
      );

      blocTest<LikedPostsSyncCubit, LikedPostsSyncState>(
        'is a no-op when already syncing',
        build: buildCubit,
        seed: () => const LikedPostsSyncState(status: LikedPostsSyncStatus.syncing),
        act: (cubit) => cubit.sync(),
        expect: () => [],
        verify: (_) => verifyNever(() => mockRepo.syncLikes(any())),
      );

      blocTest<LikedPostsSyncCubit, LikedPostsSyncState>(
        'can sync again after a previous sync completes',
        build: buildCubit,
        setUp: () {
          when(() => mockRepo.syncLikes(_accountDid)).thenAnswer((_) async {});
        },
        act: (cubit) async {
          await cubit.sync();
          await cubit.sync();
        },
        expect: () => [
          const LikedPostsSyncState(status: LikedPostsSyncStatus.syncing),
          const LikedPostsSyncState(status: LikedPostsSyncStatus.synced),
          const LikedPostsSyncState(status: LikedPostsSyncStatus.syncing),
          const LikedPostsSyncState(status: LikedPostsSyncStatus.synced),
        ],
        verify: (_) => verify(() => mockRepo.syncLikes(_accountDid)).called(2),
      );
    });
  });
}
