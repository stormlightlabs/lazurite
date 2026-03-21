import 'package:atproto_core/atproto_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/lists/bloc/list_bloc.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockListRepository extends Mock implements ListRepository {}

void main() {
  late MockListRepository mockListRepository;

  final listUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.list/list-1');
  final blockUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.listblock/block-1');
  final firstItemUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.listitem/item-1');
  final secondItemUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.listitem/item-2');

  setUpAll(() {
    registerFallbackValue(AtUri.parse('at://did:plc:fallback/app.bsky.graph.list/fallback'));
    registerFallbackValue(AtUri.parse('at://did:plc:fallback/app.bsky.graph.listitem/fallback'));
    registerFallbackValue(AtUri.parse('at://did:plc:fallback/app.bsky.graph.listblock/fallback'));
  });

  setUp(() {
    mockListRepository = MockListRepository();
  });

  group('ListBloc', () {
    final initialList = _buildListView(listUri: listUri);
    final blockedList = _buildListView(listUri: listUri, blockUri: blockUri);
    final firstItem = _buildListItem(uri: firstItemUri, did: 'did:plc:member-1', handle: 'member1.bsky.social');
    final secondItem = _buildListItem(uri: secondItemUri, did: 'did:plc:member-2', handle: 'member2.bsky.social');

    blocTest<ListBloc, ListState>(
      'loads a list and its members',
      build: () => ListBloc(listRepository: mockListRepository),
      setUp: () {
        when(
          () => mockListRepository.getList(
            listUri: listUri,
            cursor: any(named: 'cursor'),
            limit: 25,
          ),
        ).thenAnswer((_) async => ListDetailResult(list: initialList, items: [firstItem], cursor: 'cursor-1'));
      },
      act: (bloc) => bloc.add(ListRequested(listUri: listUri, limit: 25)),
      expect: () => [
        ListState.loading(listUri: listUri, limit: 25),
        ListState.loaded(
          listUri: listUri,
          list: initialList,
          items: [firstItem],
          cursor: 'cursor-1',
          hasMore: true,
          limit: 25,
        ),
      ],
    );

    blocTest<ListBloc, ListState>(
      'refreshes the active list',
      build: () => ListBloc(listRepository: mockListRepository),
      seed: () =>
          ListState.loaded(listUri: listUri, list: initialList, items: [firstItem], cursor: 'cursor-1', hasMore: true),
      setUp: () {
        when(
          () => mockListRepository.getList(
            listUri: listUri,
            cursor: any(named: 'cursor'),
            limit: 50,
          ),
        ).thenAnswer((_) async => ListDetailResult(list: initialList, items: [firstItem, secondItem], cursor: null));
      },
      act: (bloc) => bloc.add(const ListRefreshed()),
      expect: () => [
        predicate<ListState>((state) => state.isRefreshing && !state.isMutating),
        predicate<ListState>((state) => state.items.length == 2 && !state.isRefreshing && !state.hasMore),
      ],
    );

    blocTest<ListBloc, ListState>(
      'adds a member and rehydrates the list',
      build: () => ListBloc(listRepository: mockListRepository),
      seed: () =>
          ListState.loaded(listUri: listUri, list: initialList, items: [firstItem], cursor: null, hasMore: false),
      setUp: () {
        when(
          () => mockListRepository.addListItem(listUri: listUri, subjectDid: 'did:plc:member-2'),
        ).thenAnswer((_) async => secondItemUri.toString());
        when(
          () => mockListRepository.getList(
            listUri: listUri,
            cursor: any(named: 'cursor'),
            limit: 50,
          ),
        ).thenAnswer((_) async => ListDetailResult(list: initialList, items: [firstItem, secondItem], cursor: null));
      },
      act: (bloc) => bloc.add(const ListItemAdded(subjectDid: 'did:plc:member-2')),
      expect: () => [
        predicate<ListState>((state) => state.isMutating && !state.isRefreshing),
        predicate<ListState>((state) => !state.isMutating && state.items.length == 2),
      ],
      verify: (_) {
        verify(() => mockListRepository.addListItem(listUri: listUri, subjectDid: 'did:plc:member-2')).called(1);
      },
    );

    blocTest<ListBloc, ListState>(
      'removes a member and rehydrates the list',
      build: () => ListBloc(listRepository: mockListRepository),
      seed: () => ListState.loaded(
        listUri: listUri,
        list: initialList,
        items: [firstItem, secondItem],
        cursor: null,
        hasMore: false,
      ),
      setUp: () {
        when(() => mockListRepository.removeListItem(listItemUri: secondItemUri)).thenAnswer((_) async {});
        when(
          () => mockListRepository.getList(
            listUri: listUri,
            cursor: any(named: 'cursor'),
            limit: 50,
          ),
        ).thenAnswer((_) async => ListDetailResult(list: initialList, items: [firstItem], cursor: null));
      },
      act: (bloc) => bloc.add(ListItemRemoved(listItemUri: secondItemUri)),
      expect: () => [
        predicate<ListState>((state) => state.isMutating),
        predicate<ListState>((state) => !state.isMutating && state.items.length == 1),
      ],
    );

    blocTest<ListBloc, ListState>(
      'mutes and unmutes the active list',
      build: () => ListBloc(listRepository: mockListRepository),
      seed: () =>
          ListState.loaded(listUri: listUri, list: initialList, items: [firstItem], cursor: null, hasMore: false),
      setUp: () {
        when(() => mockListRepository.muteList(listUri: listUri)).thenAnswer((_) async {});
        when(() => mockListRepository.unmuteList(listUri: listUri)).thenAnswer((_) async {});
        when(
          () => mockListRepository.getList(
            listUri: listUri,
            cursor: any(named: 'cursor'),
            limit: 50,
          ),
        ).thenAnswer(
          (_) async => ListDetailResult(
            list: _buildListView(listUri: listUri, isMuted: true),
            items: [firstItem],
            cursor: null,
          ),
        );
      },
      act: (bloc) async {
        bloc.add(const ListMuted());
        await Future<void>.delayed(Duration.zero);
        when(
          () => mockListRepository.getList(
            listUri: listUri,
            cursor: any(named: 'cursor'),
            limit: 50,
          ),
        ).thenAnswer((_) async => ListDetailResult(list: initialList, items: [firstItem], cursor: null));
        bloc.add(const ListUnmuted());
      },
      expect: () => [
        predicate<ListState>((state) => state.isMutating),
        predicate<ListState>((state) => state.list?.viewer?.isMuted ?? false),
        predicate<ListState>((state) => state.isMutating),
        predicate<ListState>((state) => !(state.list?.viewer?.isMuted ?? false)),
      ],
    );

    blocTest<ListBloc, ListState>(
      'blocks and unblocks the active list',
      build: () => ListBloc(listRepository: mockListRepository),
      seed: () =>
          ListState.loaded(listUri: listUri, list: initialList, items: [firstItem], cursor: null, hasMore: false),
      setUp: () {
        when(() => mockListRepository.blockList(listUri: listUri)).thenAnswer((_) async => blockUri.toString());
        when(() => mockListRepository.unblockList(blockUri: blockUri)).thenAnswer((_) async {});
        when(
          () => mockListRepository.getList(
            listUri: listUri,
            cursor: any(named: 'cursor'),
            limit: 50,
          ),
        ).thenAnswer((_) async => ListDetailResult(list: blockedList, items: [firstItem], cursor: null));
      },
      act: (bloc) async {
        bloc.add(const ListBlocked());
        await Future<void>.delayed(Duration.zero);
        when(
          () => mockListRepository.getList(
            listUri: listUri,
            cursor: any(named: 'cursor'),
            limit: 50,
          ),
        ).thenAnswer((_) async => ListDetailResult(list: initialList, items: [firstItem], cursor: null));
        bloc.add(const ListUnblocked());
      },
      expect: () => [
        predicate<ListState>((state) => state.isMutating),
        predicate<ListState>((state) => state.list?.viewer?.blocked == blockUri),
        predicate<ListState>((state) => state.isMutating),
        predicate<ListState>((state) => state.list?.viewer?.blocked == null),
      ],
    );
  });
}

ListView _buildListView({required AtUri listUri, bool isMuted = false, AtUri? blockUri}) {
  return ListView(
    uri: listUri,
    cid: 'cid-list',
    creator: const ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social'),
    name: 'Core List',
    purpose: const ListPurpose.knownValue(data: KnownListPurpose.appBskyGraphDefsCuratelist),
    viewer: ListViewerState(muted: isMuted, blocked: blockUri),
    indexedAt: DateTime.utc(2026, 3, 21),
  );
}

ListItemView _buildListItem({required AtUri uri, required String did, required String handle}) {
  return ListItemView(
    uri: uri,
    subject: ProfileView(did: did, handle: handle),
  );
}
