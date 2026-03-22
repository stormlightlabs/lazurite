import 'package:atproto_core/atproto_core.dart' show AtUri;
import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/starter_packs/cubit/actor_starter_packs_cubit.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockStarterPackRepository extends Mock implements StarterPackRepository {}

void main() {
  late MockStarterPackRepository mockRepository;

  const actor = 'did:plc:creator';

  final packUri1 = AtUri.parse('at://did:plc:creator/app.bsky.graph.starterpack/pack-1');
  final packUri2 = AtUri.parse('at://did:plc:creator/app.bsky.graph.starterpack/pack-2');

  setUp(() {
    mockRepository = MockStarterPackRepository();
  });

  group('ActorStarterPacksCubit', () {
    final pack1 = _buildStarterPackViewBasic(uri: packUri1, name: 'Pack One');
    final pack2 = _buildStarterPackViewBasic(uri: packUri2, name: 'Pack Two');

    blocTest<ActorStarterPacksCubit, ActorStarterPacksState>(
      'loads starter packs for an actor',
      build: () => ActorStarterPacksCubit(starterPackRepository: mockRepository),
      setUp: () {
        when(
          () => mockRepository.getActorStarterPacks(
            actor: actor,
            cursor: any(named: 'cursor'),
            limit: 25,
          ),
        ).thenAnswer((_) async => ActorStarterPacksResult(starterPacks: [pack1, pack2], cursor: 'cursor-1'));
      },
      act: (cubit) => cubit.load(actor: actor, limit: 25),
      expect: () => [
        const ActorStarterPacksState.loading(actor: actor, limit: 25),
        predicate<ActorStarterPacksState>(
          (state) =>
              state.status == ActorStarterPacksStatus.loaded &&
              state.starterPacks.length == 2 &&
              state.cursor == 'cursor-1' &&
              state.hasMore,
        ),
      ],
    );

    blocTest<ActorStarterPacksCubit, ActorStarterPacksState>(
      'emits error when load fails',
      build: () => ActorStarterPacksCubit(starterPackRepository: mockRepository),
      setUp: () {
        when(
          () => mockRepository.getActorStarterPacks(
            actor: any(named: 'actor'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('network error'));
      },
      act: (cubit) => cubit.load(actor: actor),
      expect: () => [
        const ActorStarterPacksState.loading(actor: actor),
        predicate<ActorStarterPacksState>(
          (state) => state.status == ActorStarterPacksStatus.error && state.errorMessage != null,
        ),
      ],
    );

    blocTest<ActorStarterPacksCubit, ActorStarterPacksState>(
      'refreshes the current starter pack collection',
      build: () => ActorStarterPacksCubit(starterPackRepository: mockRepository),
      seed: () => ActorStarterPacksState.loaded(actor: actor, starterPacks: [pack1], cursor: 'cursor-1', hasMore: true),
      setUp: () {
        when(
          () => mockRepository.getActorStarterPacks(
            actor: actor,
            cursor: any(named: 'cursor'),
            limit: 50,
          ),
        ).thenAnswer((_) async => ActorStarterPacksResult(starterPacks: [pack1, pack2], cursor: null));
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [
        predicate<ActorStarterPacksState>((state) => state.isRefreshing),
        predicate<ActorStarterPacksState>(
          (state) => !state.isRefreshing && state.starterPacks.length == 2 && !state.hasMore,
        ),
      ],
    );

    blocTest<ActorStarterPacksCubit, ActorStarterPacksState>(
      'refresh is a no-op when actor is null',
      build: () => ActorStarterPacksCubit(starterPackRepository: mockRepository),
      act: (cubit) => cubit.refresh(),
      expect: () => [],
    );

    blocTest<ActorStarterPacksCubit, ActorStarterPacksState>(
      'refresh emits error when fetch fails',
      build: () => ActorStarterPacksCubit(starterPackRepository: mockRepository),
      seed: () => ActorStarterPacksState.loaded(actor: actor, starterPacks: [pack1], cursor: null, hasMore: false),
      setUp: () {
        when(
          () => mockRepository.getActorStarterPacks(
            actor: any(named: 'actor'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('network error'));
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [
        predicate<ActorStarterPacksState>((state) => state.isRefreshing),
        predicate<ActorStarterPacksState>((state) => !state.isRefreshing && state.errorMessage != null),
      ],
    );

    blocTest<ActorStarterPacksCubit, ActorStarterPacksState>(
      'loads more pages appending to existing list',
      build: () => ActorStarterPacksCubit(starterPackRepository: mockRepository),
      seed: () => ActorStarterPacksState.loaded(actor: actor, starterPacks: [pack1], cursor: 'cursor-1', hasMore: true),
      setUp: () {
        when(
          () => mockRepository.getActorStarterPacks(actor: actor, cursor: 'cursor-1', limit: 50),
        ).thenAnswer((_) async => ActorStarterPacksResult(starterPacks: [pack2], cursor: null));
      },
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        predicate<ActorStarterPacksState>((state) => state.isLoadingMore),
        predicate<ActorStarterPacksState>(
          (state) => !state.isLoadingMore && state.starterPacks.length == 2 && !state.hasMore,
        ),
      ],
    );

    blocTest<ActorStarterPacksCubit, ActorStarterPacksState>(
      'loadMore is a no-op when no cursor',
      build: () => ActorStarterPacksCubit(starterPackRepository: mockRepository),
      seed: () => ActorStarterPacksState.loaded(actor: actor, starterPacks: [pack1], cursor: null, hasMore: false),
      act: (cubit) => cubit.loadMore(),
      expect: () => [],
    );

    blocTest<ActorStarterPacksCubit, ActorStarterPacksState>(
      'loadMore is a no-op when already loading more',
      build: () => ActorStarterPacksCubit(starterPackRepository: mockRepository),
      seed: () => ActorStarterPacksState.loaded(
        actor: actor,
        starterPacks: [pack1],
        cursor: 'cursor-1',
        hasMore: true,
        isLoadingMore: true,
      ),
      act: (cubit) => cubit.loadMore(),
      expect: () => [],
    );

    blocTest<ActorStarterPacksCubit, ActorStarterPacksState>(
      'loadMore stops pagination when fetch fails',
      build: () => ActorStarterPacksCubit(starterPackRepository: mockRepository),
      seed: () => ActorStarterPacksState.loaded(actor: actor, starterPacks: [pack1], cursor: 'cursor-1', hasMore: true),
      setUp: () {
        when(
          () => mockRepository.getActorStarterPacks(
            actor: any(named: 'actor'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('network error'));
      },
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        predicate<ActorStarterPacksState>((state) => state.isLoadingMore),
        predicate<ActorStarterPacksState>((state) => !state.isLoadingMore && !state.hasMore),
      ],
    );
  });
}

StarterPackViewBasic _buildStarterPackViewBasic({required AtUri uri, required String name}) {
  return StarterPackViewBasic(
    uri: uri,
    cid: 'cid-${uri.rkey}',
    record: <String, dynamic>{
      r'$type': 'app.bsky.graph.starterpack',
      'name': name,
      'list': 'at://did:plc:creator/app.bsky.graph.list/ref',
      'createdAt': '2026-03-22T00:00:00.000Z',
    },
    creator: const ProfileViewBasic(did: 'did:plc:creator', handle: 'creator.bsky.social'),
    indexedAt: DateTime.utc(2026, 3, 22),
  );
}
