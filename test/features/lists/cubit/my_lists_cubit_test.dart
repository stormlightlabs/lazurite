import 'package:bloc_test/bloc_test.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/lists/cubit/my_lists_cubit.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockListRepository extends Mock implements ListRepository {}

void main() {
  late MockListRepository mockListRepository;

  const actor = 'did:plc:creator';
  final curationListUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.list/curation');
  final moderationListUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.list/moderation');
  final referenceListUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.list/reference');

  setUp(() {
    mockListRepository = MockListRepository();
  });

  group('MyListsCubit', () {
    final curationList = _buildList(
      uri: curationListUri,
      purpose: KnownListPurpose.appBskyGraphDefsCuratelist,
      name: 'Curation',
    );
    final moderationList = _buildList(
      uri: moderationListUri,
      purpose: KnownListPurpose.appBskyGraphDefsModlist,
      name: 'Moderation',
    );
    final referenceList = _buildList(
      uri: referenceListUri,
      purpose: KnownListPurpose.appBskyGraphDefsReferencelist,
      name: 'Reference',
    );

    blocTest<MyListsCubit, MyListsState>(
      'loads and categorises lists',
      build: () => MyListsCubit(listRepository: mockListRepository),
      setUp: () {
        when(
          () => mockListRepository.getLists(
            actor: actor,
            cursor: any(named: 'cursor'),
            limit: 25,
            includeReference: any(named: 'includeReference'),
          ),
        ).thenAnswer((_) async => ListsResult(lists: [curationList, moderationList], cursor: 'cursor-1'));
      },
      act: (cubit) => cubit.load(actor: actor, limit: 25),
      expect: () => [
        const MyListsState.loading(actor: actor, limit: 25),
        predicate<MyListsState>(
          (state) =>
              state.status == MyListsStatus.loaded &&
              state.curationLists.length == 1 &&
              state.moderationLists.length == 1 &&
              state.referenceLists.isEmpty &&
              state.cursor == 'cursor-1',
        ),
      ],
    );

    blocTest<MyListsCubit, MyListsState>(
      'refreshes the current list collection',
      build: () => MyListsCubit(listRepository: mockListRepository),
      seed: () => MyListsState.loaded(actor: actor, lists: [curationList], cursor: 'cursor-1', hasMore: true),
      setUp: () {
        when(
          () => mockListRepository.getLists(
            actor: actor,
            cursor: any(named: 'cursor'),
            limit: 50,
            includeReference: any(named: 'includeReference'),
          ),
        ).thenAnswer((_) async => ListsResult(lists: [curationList, moderationList], cursor: null));
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [
        predicate<MyListsState>((state) => state.isRefreshing),
        predicate<MyListsState>((state) => !state.isRefreshing && state.lists.length == 2 && !state.hasMore),
      ],
    );

    blocTest<MyListsCubit, MyListsState>(
      'loads more pages for the active actor',
      build: () => MyListsCubit(listRepository: mockListRepository),
      seed: () => MyListsState.loaded(actor: actor, lists: [curationList], cursor: 'cursor-1', hasMore: true),
      setUp: () {
        when(
          () => mockListRepository.getLists(
            actor: actor,
            cursor: 'cursor-1',
            limit: 50,
            includeReference: any(named: 'includeReference'),
          ),
        ).thenAnswer((_) async => ListsResult(lists: [moderationList, referenceList], cursor: null));
      },
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        predicate<MyListsState>((state) => state.isLoadingMore),
        predicate<MyListsState>(
          (state) => !state.isLoadingMore && state.lists.length == 3 && state.referenceLists.single == referenceList,
        ),
      ],
    );
  });
}

ListView _buildList({required AtUri uri, required KnownListPurpose purpose, required String name}) {
  return ListView(
    uri: uri,
    cid: 'cid-${uri.rkey}',
    creator: const ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social'),
    name: name,
    purpose: ListPurpose.knownValue(data: purpose),
    indexedAt: DateTime.utc(2026, 3, 21),
  );
}
