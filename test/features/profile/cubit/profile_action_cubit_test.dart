import 'package:atproto/com_atproto_moderation_defs.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/profile/cubit/profile_action_cubit.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileActionRepository extends Mock implements ProfileActionRepository {}

void main() {
  late MockProfileActionRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(AtUri.parse('at://did:plc:test/app.bsky.feed.post/fallback'));
    registerFallbackValue(const ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonSpam));
  });

  setUp(() {
    mockRepository = MockProfileActionRepository();
  });

  const testActorDid = 'did:plc:testuser123';
  const testFollowUri = 'at://did:plc:test/app.bsky.graph.follow/follow456';
  const testBlockUri = 'at://did:plc:test/app.bsky.graph.block/block789';
  const testPostUri = 'at://did:plc:other/app.bsky.feed.post/abc123';
  const testCid = 'bafyreie5cvv4hhpwo4y6x4f4m6fsq3xrm5f3p5vzum5h5uv5x5x5x5x5x5';

  group('ProfileActionCubit', () {
    test('initial state has correct values', () {
      final cubit = ProfileActionCubit(profileActionRepository: mockRepository, actorDid: testActorDid);

      expect(cubit.state.actorDid, testActorDid);
      expect(cubit.state.isFollowing, isFalse);
      expect(cubit.state.isMuted, isFalse);
      expect(cubit.state.isBlocked, isFalse);
      expect(cubit.state.isBlockedBy, isFalse);
      expect(cubit.state.canShowActions, isTrue);
      expect(cubit.state.isLoadingFollow, isFalse);
      expect(cubit.state.isLoadingMute, isFalse);
      expect(cubit.state.isLoadingBlock, isFalse);
    });

    test('initial state respects provided values', () {
      final cubit = ProfileActionCubit(
        profileActionRepository: mockRepository,
        actorDid: testActorDid,
        isFollowing: true,
        isMuted: true,
        isBlocked: true,
        isBlockedBy: false,
        followUri: testFollowUri,
        blockUri: testBlockUri,
      );

      expect(cubit.state.isFollowing, isTrue);
      expect(cubit.state.isMuted, isTrue);
      expect(cubit.state.isBlocked, isTrue);
      expect(cubit.state.followUri, testFollowUri);
      expect(cubit.state.blockUri, testBlockUri);
    });

    test('canShowActions returns false when blockedBy', () {
      final cubit = ProfileActionCubit(
        profileActionRepository: mockRepository,
        actorDid: testActorDid,
        isBlockedBy: true,
      );

      expect(cubit.state.canShowActions, isFalse);
    });

    group('toggleFollow', () {
      blocTest<ProfileActionCubit, ProfileActionState>(
        'emits loading state then following state when following',
        build: () {
          when(() => mockRepository.followActor(did: testActorDid)).thenAnswer((_) async => testFollowUri);
          return ProfileActionCubit(profileActionRepository: mockRepository, actorDid: testActorDid);
        },
        act: (cubit) => cubit.toggleFollow(),
        expect: () => [
          isA<ProfileActionState>()
              .having((s) => s.isFollowing, 'isFollowing', isTrue)
              .having((s) => s.isLoadingFollow, 'isLoadingFollow', isTrue)
              .having((s) => s.error, 'error', isNull),
          isA<ProfileActionState>()
              .having((s) => s.isFollowing, 'isFollowing', isTrue)
              .having((s) => s.followUri, 'followUri', testFollowUri)
              .having((s) => s.isLoadingFollow, 'isLoadingFollow', isFalse),
        ],
      );

      blocTest<ProfileActionCubit, ProfileActionState>(
        'emits loading state then unfollowed state when unfollowing',
        build: () {
          when(() => mockRepository.unfollowActor(followUri: testFollowUri)).thenAnswer((_) async {});
          return ProfileActionCubit(
            profileActionRepository: mockRepository,
            actorDid: testActorDid,
            isFollowing: true,
            followUri: testFollowUri,
          );
        },
        act: (cubit) => cubit.toggleFollow(),
        expect: () => [
          isA<ProfileActionState>()
              .having((s) => s.isFollowing, 'isFollowing', isFalse)
              .having((s) => s.isLoadingFollow, 'isLoadingFollow', isTrue),
          isA<ProfileActionState>()
              .having((s) => s.isFollowing, 'isFollowing', isFalse)
              .having((s) => s.isLoadingFollow, 'isLoadingFollow', isFalse),
        ],
      );

      blocTest<ProfileActionCubit, ProfileActionState>(
        'rolls back state on follow failure',
        build: () {
          when(() => mockRepository.followActor(did: testActorDid)).thenThrow(Exception('Network error'));
          return ProfileActionCubit(profileActionRepository: mockRepository, actorDid: testActorDid);
        },
        act: (cubit) => cubit.toggleFollow(),
        expect: () => [
          isA<ProfileActionState>()
              .having((s) => s.isFollowing, 'isFollowing', isTrue)
              .having((s) => s.isLoadingFollow, 'isLoadingFollow', isTrue),
          isA<ProfileActionState>()
              .having((s) => s.isFollowing, 'isFollowing', isFalse)
              .having((s) => s.isLoadingFollow, 'isLoadingFollow', isFalse)
              .having((s) => s.error, 'error', 'Failed to follow user'),
        ],
      );

      blocTest<ProfileActionCubit, ProfileActionState>(
        'does nothing when blocked by user',
        build: () =>
            ProfileActionCubit(profileActionRepository: mockRepository, actorDid: testActorDid, isBlockedBy: true),
        act: (cubit) => cubit.toggleFollow(),
        expect: () => [],
      );

      blocTest<ProfileActionCubit, ProfileActionState>(
        'does nothing when already loading',
        build: () => ProfileActionCubit(profileActionRepository: mockRepository, actorDid: testActorDid),
        seed: () => const ProfileActionState(actorDid: testActorDid, isLoadingFollow: true),
        act: (cubit) => cubit.toggleFollow(),
        expect: () => [],
      );
    });

    group('toggleMute', () {
      blocTest<ProfileActionCubit, ProfileActionState>(
        'emits loading state then muted state when muting',
        build: () {
          when(() => mockRepository.muteActor(did: testActorDid)).thenAnswer((_) async {});
          return ProfileActionCubit(profileActionRepository: mockRepository, actorDid: testActorDid);
        },
        act: (cubit) => cubit.toggleMute(),
        expect: () => [
          isA<ProfileActionState>()
              .having((s) => s.isMuted, 'isMuted', isTrue)
              .having((s) => s.isLoadingMute, 'isLoadingMute', isTrue),
          isA<ProfileActionState>()
              .having((s) => s.isMuted, 'isMuted', isTrue)
              .having((s) => s.isLoadingMute, 'isLoadingMute', isFalse),
        ],
      );

      blocTest<ProfileActionCubit, ProfileActionState>(
        'emits loading state then unmuted state when unmuting',
        build: () {
          when(() => mockRepository.unmuteActor(did: testActorDid)).thenAnswer((_) async {});
          return ProfileActionCubit(profileActionRepository: mockRepository, actorDid: testActorDid, isMuted: true);
        },
        act: (cubit) => cubit.toggleMute(),
        expect: () => [
          isA<ProfileActionState>()
              .having((s) => s.isMuted, 'isMuted', isFalse)
              .having((s) => s.isLoadingMute, 'isLoadingMute', isTrue),
          isA<ProfileActionState>()
              .having((s) => s.isMuted, 'isMuted', isFalse)
              .having((s) => s.isLoadingMute, 'isLoadingMute', isFalse),
        ],
      );

      blocTest<ProfileActionCubit, ProfileActionState>(
        'rolls back state on mute failure',
        build: () {
          when(() => mockRepository.muteActor(did: testActorDid)).thenThrow(Exception('Network error'));
          return ProfileActionCubit(profileActionRepository: mockRepository, actorDid: testActorDid);
        },
        act: (cubit) => cubit.toggleMute(),
        expect: () => [
          isA<ProfileActionState>()
              .having((s) => s.isMuted, 'isMuted', isTrue)
              .having((s) => s.isLoadingMute, 'isLoadingMute', isTrue),
          isA<ProfileActionState>()
              .having((s) => s.isMuted, 'isMuted', isFalse)
              .having((s) => s.isLoadingMute, 'isLoadingMute', isFalse)
              .having((s) => s.error, 'error', 'Failed to mute user'),
        ],
      );
    });

    group('toggleBlock', () {
      blocTest<ProfileActionCubit, ProfileActionState>(
        'emits loading state then blocked state when blocking',
        build: () {
          when(() => mockRepository.blockActor(did: testActorDid)).thenAnswer((_) async => testBlockUri);
          return ProfileActionCubit(profileActionRepository: mockRepository, actorDid: testActorDid);
        },
        act: (cubit) => cubit.toggleBlock(),
        expect: () => [
          isA<ProfileActionState>()
              .having((s) => s.isBlocked, 'isBlocked', isTrue)
              .having((s) => s.isLoadingBlock, 'isLoadingBlock', isTrue),
          isA<ProfileActionState>()
              .having((s) => s.isBlocked, 'isBlocked', isTrue)
              .having((s) => s.blockUri, 'blockUri', testBlockUri)
              .having((s) => s.isLoadingBlock, 'isLoadingBlock', isFalse),
        ],
      );

      blocTest<ProfileActionCubit, ProfileActionState>(
        'emits loading state then unblocked state when unblocking',
        build: () {
          when(() => mockRepository.unblockActor(blockUri: testBlockUri)).thenAnswer((_) async {});
          return ProfileActionCubit(
            profileActionRepository: mockRepository,
            actorDid: testActorDid,
            isBlocked: true,
            blockUri: testBlockUri,
          );
        },
        act: (cubit) => cubit.toggleBlock(),
        expect: () => [
          isA<ProfileActionState>()
              .having((s) => s.isBlocked, 'isBlocked', isFalse)
              .having((s) => s.isLoadingBlock, 'isLoadingBlock', isTrue),
          isA<ProfileActionState>()
              .having((s) => s.isBlocked, 'isBlocked', isFalse)
              .having((s) => s.isLoadingBlock, 'isLoadingBlock', isFalse),
        ],
      );

      blocTest<ProfileActionCubit, ProfileActionState>(
        'rolls back state on block failure',
        build: () {
          when(() => mockRepository.blockActor(did: testActorDid)).thenThrow(Exception('Network error'));
          return ProfileActionCubit(profileActionRepository: mockRepository, actorDid: testActorDid);
        },
        act: (cubit) => cubit.toggleBlock(),
        expect: () => [
          isA<ProfileActionState>()
              .having((s) => s.isBlocked, 'isBlocked', isTrue)
              .having((s) => s.isLoadingBlock, 'isLoadingBlock', isTrue),
          isA<ProfileActionState>()
              .having((s) => s.isBlocked, 'isBlocked', isFalse)
              .having((s) => s.isLoadingBlock, 'isLoadingBlock', isFalse)
              .having((s) => s.error, 'error', 'Failed to block user'),
        ],
      );
    });

    group('reportPost', () {
      blocTest<ProfileActionCubit, ProfileActionState>(
        'returns report ID on success',
        build: () {
          when(
            () => mockRepository.reportPost(
              postUri: any(named: 'postUri'),
              cid: any(named: 'cid'),
              reasonType: any(named: 'reasonType'),
              reason: any(named: 'reason'),
            ),
          ).thenAnswer((_) async => 'report_123');
          return ProfileActionCubit(profileActionRepository: mockRepository, actorDid: testActorDid);
        },
        act: (cubit) async {
          final result = await cubit.reportPost(
            postUri: AtUri.parse(testPostUri),
            cid: testCid,
            reasonType: const ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonSpam),
          );
          expect(result, 'report_123');
        },
        verify: (_) {
          verify(
            () => mockRepository.reportPost(
              postUri: any(named: 'postUri'),
              cid: testCid,
              reasonType: any(named: 'reasonType'),
              reason: null,
            ),
          ).called(1);
        },
      );

      blocTest<ProfileActionCubit, ProfileActionState>(
        'returns null and emits error on failure',
        build: () {
          when(
            () => mockRepository.reportPost(
              postUri: any(named: 'postUri'),
              cid: any(named: 'cid'),
              reasonType: any(named: 'reasonType'),
              reason: any(named: 'reason'),
            ),
          ).thenThrow(Exception('Network error'));
          return ProfileActionCubit(profileActionRepository: mockRepository, actorDid: testActorDid);
        },
        act: (cubit) async {
          final result = await cubit.reportPost(
            postUri: AtUri.parse(testPostUri),
            cid: testCid,
            reasonType: const ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonSpam),
          );
          expect(result, isNull);
        },
        expect: () => [isA<ProfileActionState>().having((s) => s.error, 'error', 'Failed to report post')],
      );
    });

    group('reportActor', () {
      blocTest<ProfileActionCubit, ProfileActionState>(
        'returns report ID on success',
        build: () {
          when(
            () => mockRepository.reportActor(
              did: testActorDid,
              reasonType: any(named: 'reasonType'),
              reason: any(named: 'reason'),
            ),
          ).thenAnswer((_) async => 'report_456');
          return ProfileActionCubit(profileActionRepository: mockRepository, actorDid: testActorDid);
        },
        act: (cubit) async {
          final result = await cubit.reportActor(
            reasonType: const ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonViolation),
            reason: 'Inappropriate content',
          );
          expect(result, 'report_456');
        },
      );

      blocTest<ProfileActionCubit, ProfileActionState>(
        'returns null and emits error on failure',
        build: () {
          when(
            () => mockRepository.reportActor(
              did: testActorDid,
              reasonType: any(named: 'reasonType'),
              reason: any(named: 'reason'),
            ),
          ).thenThrow(Exception('Network error'));
          return ProfileActionCubit(profileActionRepository: mockRepository, actorDid: testActorDid);
        },
        act: (cubit) async {
          final result = await cubit.reportActor(
            reasonType: const ReasonType.knownValue(data: KnownReasonType.comAtprotoModerationDefsReasonViolation),
          );
          expect(result, isNull);
        },
        expect: () => [isA<ProfileActionState>().having((s) => s.error, 'error', 'Failed to report user')],
      );
    });

    group('ProfileActionState', () {
      test('props includes all fields', () {
        const state1 = ProfileActionState(
          actorDid: testActorDid,
          isFollowing: true,
          isMuted: true,
          isBlocked: false,
          isBlockedBy: true,
          followUri: testFollowUri,
          blockUri: testBlockUri,
          isLoadingFollow: true,
          isLoadingMute: false,
          isLoadingBlock: true,
          error: 'test error',
        );

        const state2 = ProfileActionState(
          actorDid: testActorDid,
          isFollowing: true,
          isMuted: true,
          isBlocked: false,
          isBlockedBy: true,
          followUri: testFollowUri,
          blockUri: testBlockUri,
          isLoadingFollow: true,
          isLoadingMute: false,
          isLoadingBlock: true,
          error: 'test error',
        );

        expect(state1, equals(state2));
      });

      test('copyWith creates new instance with updated values', () {
        const state = ProfileActionState(actorDid: testActorDid, isFollowing: false);

        final copied = state.copyWith(isFollowing: true, followUri: testFollowUri);

        expect(copied.isFollowing, isTrue);
        expect(copied.followUri, testFollowUri);
        expect(copied.actorDid, testActorDid);
      });
    });
  });
}
