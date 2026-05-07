import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/profile/cubit/profile_connections_cubit.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository repository;

  const subject = ProfileView(did: 'did:plc:alice', handle: 'alice.bsky.social');
  const astronaut = ProfileView(
    did: 'did:plc:astro',
    handle: 'astro.bsky.social',
    displayName: 'Lina Orbit',
    description: 'Space systems engineer',
  );
  const gardener = ProfileView(
    did: 'did:plc:garden',
    handle: 'garden.bsky.social',
    displayName: 'Moss Vale',
    description: 'Native plant notes',
  );

  setUp(() {
    repository = MockProfileRepository();
  });

  group('ProfileConnectionsCubit', () {
    blocTest<ProfileConnectionsCubit, ProfileConnectionsState>(
      'loads following through the repository',
      build: () {
        when(() => repository.getFollowing(actor: 'did:plc:alice', cursor: null, limit: 50)).thenAnswer(
          (_) async => const ProfileConnectionsPage(subject: subject, profiles: [astronaut], cursor: 'next'),
        );
        return ProfileConnectionsCubit(repository: repository, actor: 'did:plc:alice');
      },
      act: (cubit) => cubit.loadTab(ProfileConnectionsTab.following),
      expect: () => [
        isA<ProfileConnectionsState>().having(
          (state) => state.following.status,
          'following.status',
          ProfileConnectionsStatus.loading,
        ),
        isA<ProfileConnectionsState>()
            .having((state) => state.following.status, 'following.status', ProfileConnectionsStatus.loaded)
            .having((state) => state.following.profiles, 'following.profiles', [astronaut])
            .having((state) => state.following.cursor, 'following.cursor', 'next'),
      ],
    );

    blocTest<ProfileConnectionsCubit, ProfileConnectionsState>(
      'loads more followers using the stored cursor',
      build: () {
        when(
          () => repository.getFollowers(actor: 'did:plc:alice', cursor: 'next', limit: 50),
        ).thenAnswer((_) async => const ProfileConnectionsPage(subject: subject, profiles: [gardener]));
        return ProfileConnectionsCubit(repository: repository, actor: 'did:plc:alice');
      },
      seed: () => const ProfileConnectionsState(
        followers: ProfileConnectionsTabData(
          status: ProfileConnectionsStatus.loaded,
          profiles: [astronaut],
          cursor: 'next',
        ),
      ),
      act: (cubit) => cubit.loadMore(ProfileConnectionsTab.followers),
      expect: () => [
        isA<ProfileConnectionsState>().having((state) => state.followers.isLoadingMore, 'isLoadingMore', isTrue),
        isA<ProfileConnectionsState>()
            .having((state) => state.followers.isLoadingMore, 'isLoadingMore', isFalse)
            .having((state) => state.followers.profiles, 'followers.profiles', [astronaut, gardener])
            .having((state) => state.followers.cursor, 'followers.cursor', isNull),
      ],
    );

    test('fuzzy filters by handle, name, and description', () {
      final state = const ProfileConnectionsState(
        following: ProfileConnectionsTabData(status: ProfileConnectionsStatus.loaded, profiles: [astronaut, gardener]),
      ).copyWith(searchQuery: 'space engineer');

      expect(state.visibleProfilesFor(ProfileConnectionsTab.following), [astronaut]);
    });
  });
}
