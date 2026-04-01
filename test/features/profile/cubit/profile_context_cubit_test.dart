import 'package:atproto_core/atproto_core.dart' show AtUri;
import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/profile/cubit/profile_context_cubit.dart';
import 'package:lazurite/features/profile/data/profile_context_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileContextRepository extends Mock implements ProfileContextRepository {}

const _did = 'did:plc:alice';

ProfileView _profile(String did) => ProfileView(did: did, handle: '$did.bsky.social', indexedAt: DateTime.utc(2026));

ListView _list(String rkey) => ListView(
  uri: AtUri.parse('at://did:plc:owner/app.bsky.graph.list/$rkey'),
  cid: 'cid-$rkey',
  creator: const ProfileView(did: 'did:plc:owner', handle: 'owner.bsky.social'),
  name: 'List $rkey',
  purpose: const ListPurpose.knownValue(data: KnownListPurpose.appBskyGraphDefsCuratelist),
  indexedAt: DateTime.utc(2026),
);

void main() {
  late MockProfileContextRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileContextRepository();
  });

  ProfileContextCubit buildCubit({bool isOwnProfile = false}) {
    return ProfileContextCubit(repository: mockRepository, did: _did, isOwnProfile: isOwnProfile);
  }

  group('ProfileContextCubit', () {
    group('initial state', () {
      test('has correct did and isOwnProfile', () {
        final cubit = buildCubit(isOwnProfile: true);
        expect(cubit.state.did, _did);
        expect(cubit.state.isOwnProfile, isTrue);
        expect(cubit.state.blockedByCount, 0);
        expect(cubit.state.blockingCount, 0);
        expect(cubit.state.listsOnCount, 0);
        expect(cubit.state.blockedByStatus, ProfileContextTabStatus.initial);
        expect(cubit.state.blockingStatus, ProfileContextTabStatus.initial);
        expect(cubit.state.listsOnStatus, ProfileContextTabStatus.initial);
      });
    });

    group('init', () {
      blocTest<ProfileContextCubit, ProfileContextState>(
        'loads blockedByCount and listsOnCount in parallel',
        build: buildCubit,
        setUp: () {
          when(() => mockRepository.getBlockedByCount(_did)).thenAnswer((_) async => 42);
          when(() => mockRepository.getListsOnCount(_did)).thenAnswer((_) async => 7);
        },
        act: (cubit) => cubit.init(),
        expect: () => [
          predicate<ProfileContextState>((s) => s.blockedByCount == 42 && s.listsOnCount == 7 && s.blockingCount == 0),
        ],
      );

      blocTest<ProfileContextCubit, ProfileContextState>(
        'loads blockingCount too for own profile',
        build: () => buildCubit(isOwnProfile: true),
        setUp: () {
          when(() => mockRepository.getBlockedByCount(_did)).thenAnswer((_) async => 42);
          when(() => mockRepository.getListsOnCount(_did)).thenAnswer((_) async => 7);
          when(() => mockRepository.getBlockingCount(_did)).thenAnswer((_) async => 3);
        },
        act: (cubit) => cubit.init(),
        expect: () => [
          predicate<ProfileContextState>((s) => s.blockedByCount == 42 && s.listsOnCount == 7 && s.blockingCount == 3),
        ],
      );

      blocTest<ProfileContextCubit, ProfileContextState>(
        'preserves successful counts when one loader fails',
        build: () => buildCubit(isOwnProfile: true),
        setUp: () {
          when(() => mockRepository.getBlockedByCount(any())).thenThrow(Exception('network error'));
          when(() => mockRepository.getListsOnCount(_did)).thenAnswer((_) async => 7);
          when(() => mockRepository.getBlockingCount(_did)).thenAnswer((_) async => 3);
        },
        act: (cubit) => cubit.init(),
        expect: () => [
          predicate<ProfileContextState>((s) => s.blockedByCount == 0 && s.listsOnCount == 7 && s.blockingCount == 3),
        ],
      );
    });

    group('loadBlockedBy', () {
      final profile1 = _profile('did:plc:blocker1');
      final profile2 = _profile('did:plc:blocker2');

      blocTest<ProfileContextCubit, ProfileContextState>(
        'emits loading then loaded with profiles on success',
        build: buildCubit,
        setUp: () {
          when(() => mockRepository.getBlockedByProfiles(_did, cursor: null)).thenAnswer(
            (_) async => (
              entries: [
                BlockedByEntry.profile(profile: profile1),
                BlockedByEntry.profile(profile: profile2),
              ],
              cursor: 'next',
              total: 10,
            ),
          );
        },
        act: (cubit) => cubit.loadBlockedBy(),
        expect: () => [
          predicate<ProfileContextState>((s) => s.blockedByStatus == ProfileContextTabStatus.loading),
          predicate<ProfileContextState>(
            (s) =>
                s.blockedByStatus == ProfileContextTabStatus.loaded &&
                s.blockedByEntries.length == 2 &&
                s.blockedByCount == 10 &&
                s.blockedByCursor == 'next' &&
                s.blockedByHasMore,
          ),
        ],
      );

      blocTest<ProfileContextCubit, ProfileContextState>(
        'appends profiles on subsequent page load',
        build: buildCubit,
        seed: () => const ProfileContextState.initial(did: _did, isOwnProfile: false).copyWith(
          blockedByStatus: ProfileContextTabStatus.loaded,
          blockedByEntries: [BlockedByEntry.profile(profile: _profile('did:plc:first'))],
          blockedByCursor: 'cursor-1',
          blockedByHasMore: true,
        ),
        setUp: () {
          when(
            () => mockRepository.getBlockedByProfiles(_did, cursor: 'cursor-1'),
          ).thenAnswer((_) async => (entries: [BlockedByEntry.profile(profile: profile1)], cursor: null, total: 2));
        },
        act: (cubit) => cubit.loadBlockedBy(cursor: 'cursor-1'),
        expect: () => [
          predicate<ProfileContextState>((s) => s.blockedByStatus == ProfileContextTabStatus.loading),
          predicate<ProfileContextState>(
            (s) =>
                s.blockedByStatus == ProfileContextTabStatus.loaded &&
                s.blockedByEntries.length == 2 &&
                s.blockedByCursor == null &&
                !s.blockedByHasMore,
          ),
        ],
      );

      blocTest<ProfileContextCubit, ProfileContextState>(
        'tracks unavailable blocked-by accounts without breaking loaded state',
        build: buildCubit,
        setUp: () {
          when(() => mockRepository.getBlockedByProfiles(_did, cursor: null)).thenAnswer(
            (_) async => (
              entries: [
                BlockedByEntry.profile(
                  profile: const ProfileView(did: 'did:plc:blocker1', handle: 'did:plc:blocker1.bsky.social'),
                ),
                const BlockedByEntry.unavailable(did: 'did:plc:suspended', unavailableReason: 'Suspended account'),
              ],
              cursor: null,
              total: 2,
            ),
          );
        },
        act: (cubit) => cubit.loadBlockedBy(),
        expect: () => [
          predicate<ProfileContextState>((s) => s.blockedByStatus == ProfileContextTabStatus.loading),
          predicate<ProfileContextState>(
            (s) =>
                s.blockedByStatus == ProfileContextTabStatus.loaded &&
                s.blockedByEntries.length == 2 &&
                s.blockedByEntries.last.did == 'did:plc:suspended' &&
                s.blockedByEntries.last.unavailableReason == 'Suspended account',
          ),
        ],
      );

      blocTest<ProfileContextCubit, ProfileContextState>(
        'emits error state on failure',
        build: buildCubit,
        setUp: () {
          when(
            () => mockRepository.getBlockedByProfiles(_did, cursor: any(named: 'cursor')),
          ).thenThrow(Exception('network error'));
        },
        act: (cubit) => cubit.loadBlockedBy(),
        expect: () => [
          predicate<ProfileContextState>((s) => s.blockedByStatus == ProfileContextTabStatus.loading),
          predicate<ProfileContextState>(
            (s) =>
                s.blockedByStatus == ProfileContextTabStatus.error &&
                s.blockedByError != null &&
                s.blockedByEntries.isEmpty,
          ),
        ],
      );

      blocTest<ProfileContextCubit, ProfileContextState>(
        'is a no-op when already loading',
        build: buildCubit,
        seed: () => const ProfileContextState.initial(
          did: _did,
          isOwnProfile: false,
        ).copyWith(blockedByStatus: ProfileContextTabStatus.loading),
        act: (cubit) => cubit.loadBlockedBy(),
        expect: () => [],
      );
    });

    group('loadBlocking', () {
      final profile1 = _profile('did:plc:blocked1');

      blocTest<ProfileContextCubit, ProfileContextState>(
        'emits loading then loaded with profiles on success for own profile',
        build: () => buildCubit(isOwnProfile: true),
        setUp: () {
          when(() => mockRepository.getBlockingProfiles(_did, cursor: null)).thenAnswer(
            (_) async => (profiles: [profile1], unavailable: <UnavailableProfileRef>[], cursor: 'next', total: 1),
          );
        },
        act: (cubit) => cubit.loadBlocking(),
        expect: () => [
          predicate<ProfileContextState>((s) => s.blockingStatus == ProfileContextTabStatus.loading),
          predicate<ProfileContextState>(
            (s) =>
                s.blockingStatus == ProfileContextTabStatus.loaded &&
                s.blockingProfiles.length == 1 &&
                s.blockingCount == 1 &&
                s.blockingCursor == 'next' &&
                s.blockingHasMore,
          ),
        ],
      );

      blocTest<ProfileContextCubit, ProfileContextState>(
        'is a no-op when viewing another profile (not own)',
        build: () => buildCubit(isOwnProfile: false),
        act: (cubit) => cubit.loadBlocking(),
        expect: () => [],
      );

      blocTest<ProfileContextCubit, ProfileContextState>(
        'accumulates blockingCount across pages',
        build: () => buildCubit(isOwnProfile: true),
        seed: () => const ProfileContextState.initial(did: _did, isOwnProfile: true).copyWith(
          blockingStatus: ProfileContextTabStatus.loaded,
          blockingProfiles: [_profile('did:plc:first')],
          blockingCursor: 'cursor-1',
          blockingHasMore: true,
          blockingCount: 1,
        ),
        setUp: () {
          when(() => mockRepository.getBlockingProfiles(_did, cursor: 'cursor-1')).thenAnswer(
            (_) async => (profiles: [profile1], unavailable: <UnavailableProfileRef>[], cursor: null, total: 1),
          );
        },
        act: (cubit) => cubit.loadBlocking(cursor: 'cursor-1'),
        expect: () => [
          predicate<ProfileContextState>((s) => s.blockingStatus == ProfileContextTabStatus.loading),
          predicate<ProfileContextState>((s) => s.blockingProfiles.length == 2 && s.blockingCount == 2),
        ],
      );

      blocTest<ProfileContextCubit, ProfileContextState>(
        'does not shrink blockingCount when a known total already exists',
        build: () => buildCubit(isOwnProfile: true),
        seed: () => const ProfileContextState.initial(did: _did, isOwnProfile: true).copyWith(blockingCount: 5),
        setUp: () {
          when(() => mockRepository.getBlockingProfiles(_did, cursor: null)).thenAnswer(
            (_) async => (profiles: [profile1], unavailable: <UnavailableProfileRef>[], cursor: 'next', total: 1),
          );
        },
        act: (cubit) => cubit.loadBlocking(),
        expect: () => [
          predicate<ProfileContextState>((s) => s.blockingStatus == ProfileContextTabStatus.loading),
          predicate<ProfileContextState>((s) => s.blockingProfiles.length == 1 && s.blockingCount == 5),
        ],
      );

      blocTest<ProfileContextCubit, ProfileContextState>(
        'emits error state on failure',
        build: () => buildCubit(isOwnProfile: true),
        setUp: () {
          when(
            () => mockRepository.getBlockingProfiles(_did, cursor: any(named: 'cursor')),
          ).thenThrow(Exception('network error'));
        },
        act: (cubit) => cubit.loadBlocking(),
        expect: () => [
          predicate<ProfileContextState>((s) => s.blockingStatus == ProfileContextTabStatus.loading),
          predicate<ProfileContextState>(
            (s) => s.blockingStatus == ProfileContextTabStatus.error && s.blockingError != null,
          ),
        ],
      );

      blocTest<ProfileContextCubit, ProfileContextState>(
        'is a no-op when already loading',
        build: () => buildCubit(isOwnProfile: true),
        seed: () => const ProfileContextState.initial(
          did: _did,
          isOwnProfile: true,
        ).copyWith(blockingStatus: ProfileContextTabStatus.loading),
        act: (cubit) => cubit.loadBlocking(),
        expect: () => [],
      );
    });

    group('loadListsOn', () {
      final list1 = _list('list1');
      final list2 = _list('list2');

      blocTest<ProfileContextCubit, ProfileContextState>(
        'emits loading then loaded with lists on success',
        build: buildCubit,
        setUp: () {
          when(
            () => mockRepository.getListsOn(_did, cursor: null),
          ).thenAnswer((_) async => (lists: [list1, list2], cursor: 'next', total: 5));
        },
        act: (cubit) => cubit.loadListsOn(),
        expect: () => [
          predicate<ProfileContextState>((s) => s.listsOnStatus == ProfileContextTabStatus.loading),
          predicate<ProfileContextState>(
            (s) =>
                s.listsOnStatus == ProfileContextTabStatus.loaded &&
                s.listsOn.length == 2 &&
                s.listsOnCount == 5 &&
                s.listsOnCursor == 'next' &&
                s.listsOnHasMore,
          ),
        ],
      );

      blocTest<ProfileContextCubit, ProfileContextState>(
        'appends lists on subsequent page load',
        build: buildCubit,
        seed: () => const ProfileContextState.initial(did: _did, isOwnProfile: false).copyWith(
          listsOnStatus: ProfileContextTabStatus.loaded,
          listsOn: [_list('existing')],
          listsOnCursor: 'cursor-1',
          listsOnHasMore: true,
        ),
        setUp: () {
          when(
            () => mockRepository.getListsOn(_did, cursor: 'cursor-1'),
          ).thenAnswer((_) async => (lists: [list1], cursor: null, total: 2));
        },
        act: (cubit) => cubit.loadListsOn(cursor: 'cursor-1'),
        expect: () => [
          predicate<ProfileContextState>((s) => s.listsOnStatus == ProfileContextTabStatus.loading),
          predicate<ProfileContextState>(
            (s) =>
                s.listsOnStatus == ProfileContextTabStatus.loaded &&
                s.listsOn.length == 2 &&
                s.listsOnCursor == null &&
                !s.listsOnHasMore,
          ),
        ],
      );

      blocTest<ProfileContextCubit, ProfileContextState>(
        'emits error state on failure',
        build: buildCubit,
        setUp: () {
          when(
            () => mockRepository.getListsOn(_did, cursor: any(named: 'cursor')),
          ).thenThrow(Exception('network error'));
        },
        act: (cubit) => cubit.loadListsOn(),
        expect: () => [
          predicate<ProfileContextState>((s) => s.listsOnStatus == ProfileContextTabStatus.loading),
          predicate<ProfileContextState>(
            (s) => s.listsOnStatus == ProfileContextTabStatus.error && s.listsOnError != null,
          ),
        ],
      );

      blocTest<ProfileContextCubit, ProfileContextState>(
        'is a no-op when already loading',
        build: buildCubit,
        seed: () => const ProfileContextState.initial(
          did: _did,
          isOwnProfile: false,
        ).copyWith(listsOnStatus: ProfileContextTabStatus.loading),
        act: (cubit) => cubit.loadListsOn(),
        expect: () => [],
      );
    });

    group('ProfileContextState', () {
      test('copyWith preserves unchanged fields', () {
        final state = const ProfileContextState.initial(
          did: _did,
          isOwnProfile: true,
        ).copyWith(blockedByCount: 5, listsOnCount: 3);
        expect(state.blockedByCount, 5);
        expect(state.listsOnCount, 3);
        expect(state.blockingCount, 0);
        expect(state.did, _did);
        expect(state.isOwnProfile, isTrue);
      });

      test('copyWith clears nullable cursor with explicit null', () {
        final state = const ProfileContextState.initial(
          did: _did,
          isOwnProfile: false,
        ).copyWith(blockedByCursor: 'cursor-1');
        expect(state.blockedByCursor, 'cursor-1');

        final cleared = state.copyWith(blockedByCursor: null);
        expect(cleared.blockedByCursor, isNull);
      });

      test('copyWith clears nullable error with explicit null', () {
        final state = const ProfileContextState.initial(
          did: _did,
          isOwnProfile: false,
        ).copyWith(blockedByError: 'some error');
        expect(state.blockedByError, 'some error');

        final cleared = state.copyWith(blockedByError: null);
        expect(cleared.blockedByError, isNull);
      });

      test('props includes all fields for equality', () {
        const s1 = ProfileContextState.initial(did: _did, isOwnProfile: false);
        const s2 = ProfileContextState.initial(did: _did, isOwnProfile: false);
        expect(s1, equals(s2));

        final s3 = s1.copyWith(blockedByCount: 1);
        expect(s1, isNot(equals(s3)));
      });
    });
  });
}
