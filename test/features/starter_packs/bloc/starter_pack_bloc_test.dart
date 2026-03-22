import 'package:atproto_core/atproto_core.dart' show AtUri;
import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/starter_packs/bloc/starter_pack_bloc.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockStarterPackRepository extends Mock implements StarterPackRepository {}

void main() {
  late MockStarterPackRepository mockRepository;

  final packUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.starterpack/pack-1');
  final refListUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.list/ref-list-1');
  final itemUri = AtUri.parse('at://did:plc:creator/app.bsky.graph.listitem/item-1');

  setUpAll(() {
    registerFallbackValue(AtUri.parse('at://did:plc:fallback/app.bsky.graph.starterpack/fallback'));
    registerFallbackValue(AtUri.parse('at://did:plc:fallback/app.bsky.graph.list/fallback'));
    registerFallbackValue(AtUri.parse('at://did:plc:fallback/app.bsky.graph.listitem/fallback'));
  });

  setUp(() {
    mockRepository = MockStarterPackRepository();
  });

  group('StarterPackBloc', () {
    final starterPack = _buildStarterPackView(packUri: packUri, refListUri: refListUri);

    blocTest<StarterPackBloc, StarterPackState>(
      'loads a starter pack',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      setUp: () {
        when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => starterPack);
      },
      act: (bloc) => bloc.add(StarterPackRequested(starterPackUri: packUri)),
      expect: () => [
        StarterPackState.loading(packUri: packUri),
        StarterPackState.loaded(packUri: packUri, starterPack: starterPack),
      ],
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'emits error when load fails',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      setUp: () {
        when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenThrow(Exception('network error'));
      },
      act: (bloc) => bloc.add(StarterPackRequested(starterPackUri: packUri)),
      expect: () => [
        StarterPackState.loading(packUri: packUri),
        predicate<StarterPackState>((state) => state.status == StarterPackStatus.error && state.errorMessage != null),
      ],
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'creates a starter pack and emits loaded state',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      setUp: () {
        when(
          () => mockRepository.createStarterPack(
            userDid: 'did:plc:creator',
            name: 'My Pack',
            description: any(named: 'description'),
            memberDids: any(named: 'memberDids'),
            feedUris: any(named: 'feedUris'),
          ),
        ).thenAnswer((_) async => packUri);
        when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => starterPack);
      },
      act: (bloc) => bloc.add(const StarterPackCreated(userDid: 'did:plc:creator', name: 'My Pack')),
      expect: () => [
        const StarterPackState.loading(),
        StarterPackState.loaded(packUri: packUri, starterPack: starterPack),
      ],
      verify: (_) {
        verify(
          () => mockRepository.createStarterPack(
            userDid: 'did:plc:creator',
            name: 'My Pack',
            description: any(named: 'description'),
            memberDids: any(named: 'memberDids'),
            feedUris: any(named: 'feedUris'),
          ),
        ).called(1);
      },
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'creates a starter pack with members and feeds',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      setUp: () {
        when(
          () => mockRepository.createStarterPack(
            userDid: 'did:plc:creator',
            name: 'Full Pack',
            description: 'A description',
            memberDids: ['did:plc:member-1', 'did:plc:member-2'],
            feedUris: any(named: 'feedUris'),
          ),
        ).thenAnswer((_) async => packUri);
        when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => starterPack);
      },
      act: (bloc) => bloc.add(
        const StarterPackCreated(
          userDid: 'did:plc:creator',
          name: 'Full Pack',
          description: 'A description',
          memberDids: ['did:plc:member-1', 'did:plc:member-2'],
        ),
      ),
      expect: () => [
        const StarterPackState.loading(),
        StarterPackState.loaded(packUri: packUri, starterPack: starterPack),
      ],
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'emits error when create fails',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      setUp: () {
        when(
          () => mockRepository.createStarterPack(
            userDid: any(named: 'userDid'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            memberDids: any(named: 'memberDids'),
            feedUris: any(named: 'feedUris'),
          ),
        ).thenThrow(Exception('network error'));
      },
      act: (bloc) => bloc.add(const StarterPackCreated(userDid: 'did:plc:creator', name: 'My Pack')),
      expect: () => [
        const StarterPackState.loading(),
        predicate<StarterPackState>((state) => state.status == StarterPackStatus.error && state.errorMessage != null),
      ],
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'updates a starter pack and reloads',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      seed: () => StarterPackState.loaded(packUri: packUri, starterPack: starterPack),
      setUp: () {
        when(
          () => mockRepository.updateStarterPack(
            packUri: packUri,
            referenceListUri: refListUri,
            name: 'Updated Name',
            description: any(named: 'description'),
            feedUris: any(named: 'feedUris'),
          ),
        ).thenAnswer((_) async {});
        when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => starterPack);
      },
      act: (bloc) => bloc.add(const StarterPackUpdated(name: 'Updated Name')),
      expect: () => [
        predicate<StarterPackState>((state) => state.isMutating && !state.isRefreshing),
        predicate<StarterPackState>((state) => !state.isMutating && state.status == StarterPackStatus.loaded),
      ],
      verify: (_) {
        verify(
          () => mockRepository.updateStarterPack(
            packUri: packUri,
            referenceListUri: refListUri,
            name: 'Updated Name',
            description: any(named: 'description'),
            feedUris: any(named: 'feedUris'),
          ),
        ).called(1);
      },
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'StarterPackUpdated emits error when update fails',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      seed: () => StarterPackState.loaded(packUri: packUri, starterPack: starterPack),
      setUp: () {
        when(
          () => mockRepository.updateStarterPack(
            packUri: any(named: 'packUri'),
            referenceListUri: any(named: 'referenceListUri'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            feedUris: any(named: 'feedUris'),
          ),
        ).thenThrow(Exception('network error'));
      },
      act: (bloc) => bloc.add(const StarterPackUpdated(name: 'Updated Name')),
      expect: () => [
        predicate<StarterPackState>((state) => state.isMutating && state.errorMessage == null),
        predicate<StarterPackState>((state) => !state.isMutating && state.errorMessage != null),
      ],
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'StarterPackUpdated is a no-op when not loaded',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      act: (bloc) => bloc.add(const StarterPackUpdated(name: 'Updated Name')),
      expect: () => [],
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'StarterPackUpdated is a no-op when ref list is missing',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      seed: () => StarterPackState.loaded(
        packUri: packUri,
        starterPack: _buildStarterPackView(packUri: packUri, refListUri: null),
      ),
      act: (bloc) => bloc.add(const StarterPackUpdated(name: 'Updated Name')),
      expect: () => [],
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'StarterPackUpdated is a no-op when a mutation is in progress',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      seed: () => StarterPackState.loaded(packUri: packUri, starterPack: starterPack, isMutating: true),
      act: (bloc) => bloc.add(const StarterPackUpdated(name: 'Updated Name')),
      expect: () => [],
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'deletes the starter pack and its reference list',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      seed: () => StarterPackState.loaded(packUri: packUri, starterPack: starterPack),
      setUp: () {
        when(
          () => mockRepository.deleteStarterPack(
            packUri: packUri,
            referenceListUri: refListUri,
            userDid: 'did:plc:creator',
          ),
        ).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const StarterPackDeleted(userDid: 'did:plc:creator')),
      expect: () => [
        predicate<StarterPackState>((state) => state.isMutating),
        predicate<StarterPackState>((state) => state.status == StarterPackStatus.deleted),
      ],
      verify: (_) {
        verify(
          () => mockRepository.deleteStarterPack(
            packUri: packUri,
            referenceListUri: refListUri,
            userDid: 'did:plc:creator',
          ),
        ).called(1);
      },
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'StarterPackDeleted emits error when delete fails',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      seed: () => StarterPackState.loaded(packUri: packUri, starterPack: starterPack),
      setUp: () {
        when(
          () => mockRepository.deleteStarterPack(
            packUri: any(named: 'packUri'),
            referenceListUri: any(named: 'referenceListUri'),
            userDid: any(named: 'userDid'),
          ),
        ).thenThrow(Exception('network error'));
      },
      act: (bloc) => bloc.add(const StarterPackDeleted(userDid: 'did:plc:creator')),
      expect: () => [
        predicate<StarterPackState>((state) => state.isMutating && state.errorMessage == null),
        predicate<StarterPackState>((state) => !state.isMutating && state.errorMessage != null),
      ],
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'StarterPackDeleted is a no-op when not loaded',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      act: (bloc) => bloc.add(const StarterPackDeleted(userDid: 'did:plc:creator')),
      expect: () => [],
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'adds a member and reloads',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      seed: () => StarterPackState.loaded(packUri: packUri, starterPack: starterPack),
      setUp: () {
        when(
          () => mockRepository.addMember(listUri: refListUri, subjectDid: 'did:plc:new-member'),
        ).thenAnswer((_) async => itemUri.toString());
        when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => starterPack);
      },
      act: (bloc) => bloc.add(const MemberAdded(subjectDid: 'did:plc:new-member')),
      expect: () => [
        predicate<StarterPackState>((state) => state.isMutating && !state.isRefreshing),
        predicate<StarterPackState>((state) => !state.isMutating && state.status == StarterPackStatus.loaded),
      ],
      verify: (_) {
        verify(() => mockRepository.addMember(listUri: refListUri, subjectDid: 'did:plc:new-member')).called(1);
      },
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'MemberAdded emits error when addMember fails',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      seed: () => StarterPackState.loaded(packUri: packUri, starterPack: starterPack),
      setUp: () {
        when(
          () => mockRepository.addMember(
            listUri: any(named: 'listUri'),
            subjectDid: any(named: 'subjectDid'),
          ),
        ).thenThrow(Exception('network error'));
      },
      act: (bloc) => bloc.add(const MemberAdded(subjectDid: 'did:plc:new-member')),
      expect: () => [
        predicate<StarterPackState>((state) => state.isMutating && state.errorMessage == null),
        predicate<StarterPackState>((state) => !state.isMutating && state.errorMessage != null),
      ],
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'MemberAdded is a no-op when not loaded',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      act: (bloc) => bloc.add(const MemberAdded(subjectDid: 'did:plc:new-member')),
      expect: () => [],
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'MemberAdded is a no-op when ref list is missing',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      seed: () => StarterPackState.loaded(
        packUri: packUri,
        starterPack: _buildStarterPackView(packUri: packUri, refListUri: null),
      ),
      act: (bloc) => bloc.add(const MemberAdded(subjectDid: 'did:plc:new-member')),
      expect: () => [],
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'MemberAdded is a no-op when a mutation is in progress',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      seed: () => StarterPackState.loaded(packUri: packUri, starterPack: starterPack, isMutating: true),
      act: (bloc) => bloc.add(const MemberAdded(subjectDid: 'did:plc:new-member')),
      expect: () => [],
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'removes a member and reloads',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      seed: () => StarterPackState.loaded(packUri: packUri, starterPack: starterPack),
      setUp: () {
        when(() => mockRepository.removeMember(listItemUri: itemUri)).thenAnswer((_) async {});
        when(() => mockRepository.getStarterPack(starterPackUri: packUri)).thenAnswer((_) async => starterPack);
      },
      act: (bloc) => bloc.add(MemberRemoved(listItemUri: itemUri)),
      expect: () => [
        predicate<StarterPackState>((state) => state.isMutating && !state.isRefreshing),
        predicate<StarterPackState>((state) => !state.isMutating && state.status == StarterPackStatus.loaded),
      ],
      verify: (_) {
        verify(() => mockRepository.removeMember(listItemUri: itemUri)).called(1);
      },
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'MemberRemoved emits error when removeMember fails',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      seed: () => StarterPackState.loaded(packUri: packUri, starterPack: starterPack),
      setUp: () {
        when(
          () => mockRepository.removeMember(listItemUri: any(named: 'listItemUri')),
        ).thenThrow(Exception('network error'));
      },
      act: (bloc) => bloc.add(MemberRemoved(listItemUri: itemUri)),
      expect: () => [
        predicate<StarterPackState>((state) => state.isMutating && state.errorMessage == null),
        predicate<StarterPackState>((state) => !state.isMutating && state.errorMessage != null),
      ],
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'MemberRemoved is a no-op when not loaded',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      act: (bloc) => bloc.add(MemberRemoved(listItemUri: itemUri)),
      expect: () => [],
    );

    blocTest<StarterPackBloc, StarterPackState>(
      'MemberRemoved is a no-op when a mutation is in progress',
      build: () => StarterPackBloc(starterPackRepository: mockRepository),
      seed: () => StarterPackState.loaded(packUri: packUri, starterPack: starterPack, isMutating: true),
      act: (bloc) => bloc.add(MemberRemoved(listItemUri: itemUri)),
      expect: () => [],
    );
  });
}

StarterPackView _buildStarterPackView({required AtUri packUri, AtUri? refListUri}) {
  final listViewBasic = refListUri == null
      ? null
      : ListViewBasic(
          uri: refListUri,
          cid: 'cid-ref-list',
          name: 'Starter Pack Members',
          purpose: const ListPurpose.knownValue(data: KnownListPurpose.appBskyGraphDefsReferencelist),
        );

  return StarterPackView(
    uri: packUri,
    cid: 'cid-pack',
    record: const {
      r'$type': 'app.bsky.graph.starterpack',
      'name': 'My Starter Pack',
      'list': 'at://did:plc:creator/app.bsky.graph.list/ref-list-1',
      'createdAt': '2026-03-22T00:00:00.000Z',
    },
    creator: const ProfileViewBasic(did: 'did:plc:creator', handle: 'creator.bsky.social'),
    list: listViewBasic,
    indexedAt: DateTime.utc(2026, 3, 22),
  );
}
