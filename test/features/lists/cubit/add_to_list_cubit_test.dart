import 'package:atproto_core/atproto_core.dart' show AtUri;
import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:bluesky/app_bsky_graph_getlistswithmembership.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/lists/cubit/add_to_list_cubit.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockListRepository extends Mock implements ListRepository {}

void main() {
  late MockListRepository mockRepo;

  final listUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.list/list-1');
  final listItemUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.listitem/item-1');

  final listView = ListView(
    uri: listUri,
    cid: 'cid-list',
    creator: const ProfileView(did: 'did:plc:creator', handle: 'creator.bsky.social'),
    name: 'My Feed',
    purpose: const ListPurpose.knownValue(data: KnownListPurpose.appBskyGraphDefsCuratelist),
    indexedAt: DateTime.utc(2026, 3, 21),
  );

  final listItem = ListItemView(
    uri: listItemUri,
    subject: const ProfileView(did: 'did:plc:target', handle: 'target.bsky.social'),
  );

  final entryWithMember = ListWithMembership(list: listView, listItem: listItem);
  final entryWithoutMember = ListWithMembership(list: listView);

  setUpAll(() {
    registerFallbackValue(AtUri.parse('at://did:plc:fallback/app.bsky.graph.list/fallback'));
    registerFallbackValue(AtUri.parse('at://did:plc:fallback/app.bsky.graph.listitem/fallback'));
  });

  setUp(() {
    mockRepo = MockListRepository();
  });

  group('AddToListCubit', () {
    blocTest<AddToListCubit, AddToListState>(
      'load emits loading then loaded with membership data',
      build: () => AddToListCubit(listRepository: mockRepo, currentUserDid: 'did:plc:me'),
      setUp: () {
        when(
          () => mockRepo.getListsWithMembership(
            actor: 'did:plc:target',
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => ListsWithMembershipResult(lists: [entryWithMember]));
      },
      act: (cubit) => cubit.load(targetDid: 'did:plc:target'),
      expect: () => [
        const AddToListState.loading(targetDid: 'did:plc:target'),
        AddToListState.loaded(targetDid: 'did:plc:target', lists: [entryWithMember]),
      ],
    );

    blocTest<AddToListCubit, AddToListState>(
      'load emits error when repository throws',
      build: () => AddToListCubit(listRepository: mockRepo, currentUserDid: 'did:plc:me'),
      setUp: () {
        when(
          () => mockRepo.getListsWithMembership(
            actor: any(named: 'actor'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('network error'));
      },
      act: (cubit) => cubit.load(targetDid: 'did:plc:target'),
      expect: () => [
        const AddToListState.loading(targetDid: 'did:plc:target'),
        predicate<AddToListState>((s) => s.status == AddToListStatus.error && s.errorMessage != null),
      ],
    );

    blocTest<AddToListCubit, AddToListState>(
      'toggleMembership removes member when listItem is present',
      build: () => AddToListCubit(listRepository: mockRepo, currentUserDid: 'did:plc:me'),
      seed: () => AddToListState.loaded(targetDid: 'did:plc:target', lists: [entryWithMember]),
      setUp: () {
        when(() => mockRepo.removeListItem(listItemUri: listItemUri)).thenAnswer((_) async {});
        when(
          () => mockRepo.getListsWithMembership(
            actor: 'did:plc:target',
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => ListsWithMembershipResult(lists: [entryWithoutMember]));
      },
      act: (cubit) => cubit.toggleMembership(entryWithMember),
      expect: () => [
        predicate<AddToListState>((s) => s.togglingUris.contains(listUri.toString())),
        predicate<AddToListState>((s) => s.togglingUris.isEmpty && s.lists.single.listItem == null),
      ],
      verify: (_) => verify(() => mockRepo.removeListItem(listItemUri: listItemUri)).called(1),
    );

    blocTest<AddToListCubit, AddToListState>(
      'toggleMembership adds member when listItem is absent',
      build: () => AddToListCubit(listRepository: mockRepo, currentUserDid: 'did:plc:me'),
      seed: () => AddToListState.loaded(targetDid: 'did:plc:target', lists: [entryWithoutMember]),
      setUp: () {
        when(
          () => mockRepo.addListItem(listUri: listUri, subjectDid: 'did:plc:target'),
        ).thenAnswer((_) async => listItemUri.toString());
        when(
          () => mockRepo.getListsWithMembership(
            actor: 'did:plc:target',
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => ListsWithMembershipResult(lists: [entryWithMember]));
      },
      act: (cubit) => cubit.toggleMembership(entryWithoutMember),
      expect: () => [
        predicate<AddToListState>((s) => s.togglingUris.contains(listUri.toString())),
        predicate<AddToListState>((s) => s.togglingUris.isEmpty && s.lists.single.listItem != null),
      ],
      verify: (_) => verify(() => mockRepo.addListItem(listUri: listUri, subjectDid: 'did:plc:target')).called(1),
    );

    blocTest<AddToListCubit, AddToListState>(
      'toggleMembership clears toggling URI on failure',
      build: () => AddToListCubit(listRepository: mockRepo, currentUserDid: 'did:plc:me'),
      seed: () => AddToListState.loaded(targetDid: 'did:plc:target', lists: [entryWithMember]),
      setUp: () {
        when(() => mockRepo.removeListItem(listItemUri: listItemUri)).thenThrow(Exception('network error'));
      },
      act: (cubit) => cubit.toggleMembership(entryWithMember),
      expect: () => [
        predicate<AddToListState>((s) => s.togglingUris.contains(listUri.toString())),
        predicate<AddToListState>((s) => s.togglingUris.isEmpty),
      ],
    );
  });
}
