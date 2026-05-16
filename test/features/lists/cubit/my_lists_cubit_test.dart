import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:poptart_core/poptart_core.dart' show AtUri, Blob, BlobRef;
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/graph/defs.dart';
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

  final newListUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.list/new-list');

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
      'createList creates the list and refreshes',
      build: () => MyListsCubit(listRepository: mockListRepository),
      seed: () => MyListsState.loaded(actor: actor, lists: [curationList], cursor: null, hasMore: false),
      setUp: () {
        when(
          () => mockListRepository.createList(
            userDid: actor,
            name: 'New List',
            purpose: 'app.bsky.graph.defs#curatelist',
            description: any(named: 'description'),
            avatarBlob: any(named: 'avatarBlob'),
          ),
        ).thenAnswer((_) async => newListUri);
        when(
          () => mockListRepository.getLists(
            actor: actor,
            cursor: any(named: 'cursor'),
            limit: 50,
            includeReference: any(named: 'includeReference'),
          ),
        ).thenAnswer((_) async => ListsResult(lists: [curationList, moderationList], cursor: null));
      },
      act: (cubit) => cubit.createList(userDid: actor, name: 'New List', purpose: 'app.bsky.graph.defs#curatelist'),
      expect: () => [
        predicate<MyListsState>((state) => state.isRefreshing),
        predicate<MyListsState>((state) => !state.isRefreshing && state.lists.length == 2),
      ],
    );

    test('createList returns the new list URI', () async {
      final cubit = MyListsCubit(listRepository: mockListRepository);

      when(
        () => mockListRepository.createList(
          userDid: actor,
          name: 'New List',
          purpose: 'app.bsky.graph.defs#curatelist',
          description: any(named: 'description'),
          avatarBlob: any(named: 'avatarBlob'),
        ),
      ).thenAnswer((_) async => newListUri);

      final result = await cubit.createList(
        userDid: actor,
        name: 'New List',
        purpose: 'app.bsky.graph.defs#curatelist',
      );

      expect(result, newListUri);
    });

    test('createList uploads avatar when bytes provided', () async {
      final cubit = MyListsCubit(listRepository: mockListRepository);
      const avatar = Blob(
        ref: BlobRef(link: 'bafkreiavatarblob'),
        mimeType: 'image/jpeg',
        size: 3,
      );

      when(
        () => mockListRepository.uploadListAvatar(
          bytes: any(named: 'bytes'),
          mimeType: any(named: 'mimeType'),
        ),
      ).thenAnswer((_) async => avatar);
      when(
        () => mockListRepository.createList(
          userDid: actor,
          name: 'With Avatar',
          purpose: 'app.bsky.graph.defs#modlist',
          description: any(named: 'description'),
          avatarBlob: avatar,
        ),
      ).thenAnswer((_) async => newListUri);

      final result = await cubit.createList(
        userDid: actor,
        name: 'With Avatar',
        purpose: 'app.bsky.graph.defs#modlist',
        avatarBytes: [1, 2, 3],
      );

      expect(result, newListUri);
      verify(() => mockListRepository.uploadListAvatar(bytes: [1, 2, 3], mimeType: 'image/jpeg')).called(1);
    });

    test('createList returns null on failure', () async {
      final cubit = MyListsCubit(listRepository: mockListRepository);

      when(
        () => mockListRepository.createList(
          userDid: actor,
          name: any(named: 'name'),
          purpose: any(named: 'purpose'),
          description: any(named: 'description'),
          avatarBlob: any(named: 'avatarBlob'),
        ),
      ).thenThrow(Exception('network error'));

      final result = await cubit.createList(userDid: actor, name: 'Broken', purpose: 'app.bsky.graph.defs#curatelist');

      expect(result, isNull);
    });

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

    test('ignores completed load responses after the cubit is closed', () async {
      final cubit = MyListsCubit(listRepository: mockListRepository);
      final pendingResult = Completer<ListsResult>();

      when(
        () => mockListRepository.getLists(
          actor: actor,
          cursor: any(named: 'cursor'),
          limit: 50,
          includeReference: any(named: 'includeReference'),
        ),
      ).thenAnswer((_) => pendingResult.future);

      final loadFuture = cubit.load(actor: actor);
      await Future<void>.delayed(Duration.zero);
      await cubit.close();
      pendingResult.complete(ListsResult(lists: [curationList], cursor: null));
      await loadFuture;

      expect(cubit.isClosed, isTrue);
    });

    test('keeps the newest load result when responses arrive out of order', () async {
      final cubit = MyListsCubit(listRepository: mockListRepository);
      const newerActor = 'did:plc:newer';
      final newerList = _buildList(
        uri: AtUri.parse('at://did:plc:newer/app.bsky.graph.list/newer'),
        purpose: KnownListPurpose.appBskyGraphDefsCuratelist,
        name: 'Newest',
      );

      final firstResult = Completer<ListsResult>();
      final secondResult = Completer<ListsResult>();

      when(
        () => mockListRepository.getLists(
          actor: actor,
          cursor: any(named: 'cursor'),
          limit: 50,
          includeReference: any(named: 'includeReference'),
        ),
      ).thenAnswer((_) => firstResult.future);
      when(
        () => mockListRepository.getLists(
          actor: newerActor,
          cursor: any(named: 'cursor'),
          limit: 50,
          includeReference: any(named: 'includeReference'),
        ),
      ).thenAnswer((_) => secondResult.future);

      final olderLoad = cubit.load(actor: actor);
      final newerLoad = cubit.load(actor: newerActor);

      secondResult.complete(ListsResult(lists: [newerList], cursor: null));
      await newerLoad;
      firstResult.complete(ListsResult(lists: [curationList], cursor: null));
      await olderLoad;

      expect(cubit.state.status, MyListsStatus.loaded);
      expect(cubit.state.actor, newerActor);
      expect(cubit.state.lists, [newerList]);
    });
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
