import 'package:bloc_test/bloc_test.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/network/constellation_client.dart';
import 'package:lazurite/features/profile/cubit/profile_connections_cubit.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockConstellationClient extends Mock implements ConstellationClient {}

void main() {
  late MockProfileRepository repository;
  late MockConstellationClient constellationClient;

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
    constellationClient = MockConstellationClient();
  });

  group('ProfileConnectionsCubit', () {
    blocTest<ProfileConnectionsCubit, ProfileConnectionsState>(
      'loads following through the repository',
      build: () {
        when(() => repository.getFollowing(actor: 'did:plc:alice', cursor: null, limit: 100)).thenAnswer(
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
          () => repository.getFollowers(actor: 'did:plc:alice', cursor: 'next', limit: 100),
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

    blocTest<ProfileConnectionsCubit, ProfileConnectionsState>(
      'stores load-more failures separately while keeping loaded profiles',
      build: () {
        when(
          () => repository.getFollowers(actor: 'did:plc:alice', cursor: 'next', limit: 100),
        ).thenThrow(Exception('network down'));
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
        isA<ProfileConnectionsState>()
            .having((state) => state.followers.status, 'followers.status', ProfileConnectionsStatus.loaded)
            .having((state) => state.followers.isLoadingMore, 'isLoadingMore', isTrue)
            .having((state) => state.followers.loadMoreErrorMessage, 'loadMoreErrorMessage', isNull),
        isA<ProfileConnectionsState>()
            .having((state) => state.followers.status, 'followers.status', ProfileConnectionsStatus.loaded)
            .having((state) => state.followers.isLoadingMore, 'isLoadingMore', isFalse)
            .having((state) => state.followers.profiles, 'followers.profiles', [astronaut])
            .having((state) => state.followers.loadMoreErrorMessage, 'loadMoreErrorMessage', contains('network down')),
      ],
    );

    test('visible profiles use progressive search results when a query is active', () {
      final state = const ProfileConnectionsState(
        following: ProfileConnectionsTabData(
          status: ProfileConnectionsStatus.loaded,
          profiles: [gardener],
          searchStatus: ProfileConnectionsSearchStatus.complete,
          searchQuery: 'space engineer',
          searchResults: [astronaut],
          searchedCount: 2,
        ),
      ).copyWith(searchQuery: 'space engineer');

      expect(state.visibleProfilesFor(ProfileConnectionsTab.following), [astronaut]);
    });

    blocTest<ProfileConnectionsCubit, ProfileConnectionsState>(
      'progressively searches every API page using limit 100',
      build: () {
        when(
          () => repository.getFollowing(actor: 'did:plc:alice', cursor: null, limit: 100),
        ).thenAnswer((_) async => const ProfileConnectionsPage(subject: subject, profiles: [gardener], cursor: 'next'));
        when(
          () => repository.getFollowing(actor: 'did:plc:alice', cursor: 'next', limit: 100),
        ).thenAnswer((_) async => const ProfileConnectionsPage(subject: subject, profiles: [astronaut]));
        return ProfileConnectionsCubit(repository: repository, actor: 'did:plc:alice');
      },
      act: (cubit) {
        cubit.setSearchQuery('space engineer', ProfileConnectionsTab.following);
      },
      wait: const Duration(milliseconds: 350),
      expect: () => [
        isA<ProfileConnectionsState>().having((state) => state.searchQuery, 'searchQuery', 'space engineer'),
        isA<ProfileConnectionsState>().having(
          (state) => state.following.searchStatus,
          'following.searchStatus',
          ProfileConnectionsSearchStatus.searching,
        ),
        isA<ProfileConnectionsState>()
            .having(
              (state) => state.following.searchStatus,
              'following.searchStatus',
              ProfileConnectionsSearchStatus.searching,
            )
            .having((state) => state.following.searchResults, 'following.searchResults', isEmpty)
            .having((state) => state.following.searchedCount, 'following.searchedCount', 1),
        isA<ProfileConnectionsState>()
            .having(
              (state) => state.following.searchStatus,
              'following.searchStatus',
              ProfileConnectionsSearchStatus.searching,
            )
            .having((state) => state.following.searchResults, 'following.searchResults', [astronaut])
            .having((state) => state.following.searchedCount, 'following.searchedCount', 2),
        isA<ProfileConnectionsState>()
            .having(
              (state) => state.following.searchStatus,
              'following.searchStatus',
              ProfileConnectionsSearchStatus.complete,
            )
            .having((state) => state.following.searchResults, 'following.searchResults', [astronaut])
            .having((state) => state.following.searchedCount, 'following.searchedCount', 2),
      ],
      verify: (_) {
        verify(() => repository.getFollowing(actor: 'did:plc:alice', cursor: null, limit: 100)).called(1);
        verify(() => repository.getFollowing(actor: 'did:plc:alice', cursor: 'next', limit: 100)).called(1);
      },
    );

    blocTest<ProfileConnectionsCubit, ProfileConnectionsState>(
      'loads mutuals by checking followed accounts against Constellation backlinks',
      build: () {
        when(
          () => repository.getFollowing(actor: 'did:plc:alice', cursor: null, limit: 100),
        ).thenAnswer((_) async => const ProfileConnectionsPage(subject: subject, profiles: [astronaut, gardener]));
        when(
          () => constellationClient.getBacklinks(
            subject.did,
            'app.bsky.graph.follow:subject',
            limit: 100,
            cursor: null,
            dids: [astronaut.did, gardener.did],
          ),
        ).thenAnswer(
          (_) async => const (
            total: 1,
            records: [ConstellationLinkRecord(did: 'did:plc:astro', collection: 'app.bsky.graph.follow', rkey: 'abc')],
            cursor: null,
          ),
        );
        return ProfileConnectionsCubit(
          repository: repository,
          actor: 'did:plc:alice',
          constellationClient: constellationClient,
        );
      },
      act: (cubit) => cubit.loadTab(ProfileConnectionsTab.mutuals),
      expect: () => [
        isA<ProfileConnectionsState>().having(
          (state) => state.mutuals.status,
          'mutuals.status',
          ProfileConnectionsStatus.loading,
        ),
        isA<ProfileConnectionsState>()
            .having((state) => state.mutuals.status, 'mutuals.status', ProfileConnectionsStatus.loaded)
            .having((state) => state.mutuals.profiles, 'mutuals.profiles', [astronaut])
            .having((state) => state.mutuals.cursor, 'mutuals.cursor', isNull),
      ],
      verify: (_) {
        verify(
          () => constellationClient.getBacklinks(
            subject.did,
            'app.bsky.graph.follow:subject',
            limit: 100,
            cursor: null,
            dids: [astronaut.did, gardener.did],
          ),
        ).called(1);
      },
    );
  });
}
