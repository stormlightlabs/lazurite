import 'package:atproto_core/atproto_core.dart' show AtUri;
import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/search/bloc/search_bloc.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late MockSearchRepository mockRepository;
  late MockAppDatabase mockDatabase;

  final samplePost = PostView(
    uri: const AtUri('at://did:plc:author/app.bsky.feed.post/abc'),
    cid: 'cid-post',
    author: const ProfileViewBasic(did: 'did:plc:author', handle: 'author.bsky.social'),
    record: const {r'$type': 'app.bsky.feed.post', 'text': 'Hello world', 'createdAt': '2026-01-01T00:00:00.000Z'},
    indexedAt: DateTime.utc(2026, 1, 1),
  );

  final sampleActor = ProfileView(
    did: 'did:plc:actor',
    handle: 'actor.bsky.social',
    indexedAt: DateTime.utc(2026, 1, 1),
  );

  final sampleStarterPack = StarterPackViewBasic(
    uri: AtUri.parse('at://did:plc:creator/app.bsky.graph.starterpack/pack-1'),
    cid: 'cid-pack-1',
    record: const {
      r'$type': 'app.bsky.graph.starterpack',
      'name': 'Test Starter Pack',
      'list': 'at://did:plc:creator/app.bsky.graph.list/list-1',
      'createdAt': '2026-01-01T00:00:00.000Z',
    },
    creator: const ProfileViewBasic(did: 'did:plc:creator', handle: 'creator.bsky.social'),
    indexedAt: DateTime.utc(2026, 1, 1),
  );

  setUp(() {
    mockRepository = MockSearchRepository();
    mockDatabase = MockAppDatabase();

    when(() => mockDatabase.getSearchHistory(any(), limit: any(named: 'limit'))).thenAnswer((_) async => []);
    when(
      () => mockDatabase.addSearchHistoryEntry(
        query: any(named: 'query'),
        type: any(named: 'type'),
        accountDid: any(named: 'accountDid'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockRepository.searchPosts(
        query: any(named: 'query'),
        sort: any(named: 'sort'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => SearchPostsResult(posts: []));
    when(
      () => mockRepository.searchActors(
        query: any(named: 'query'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => SearchActorsResult(actors: []));
    when(
      () => mockRepository.searchStarterPacks(
        query: any(named: 'query'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => SearchStarterPacksResult(starterPacks: []));
  });

  SearchBloc buildBloc() =>
      SearchBloc(searchRepository: mockRepository, database: mockDatabase, accountDid: 'did:plc:test');

  group('SearchTab enum', () {
    test('has posts, actors, and starterPacks values', () {
      expect(SearchTab.values, containsAll([SearchTab.posts, SearchTab.actors, SearchTab.starterPacks]));
    });

    test('SearchTabLabel returns correct labels', () {
      expect(SearchTab.posts.label, 'Posts');
      expect(SearchTab.actors.label, 'People');
      expect(SearchTab.starterPacks.label, 'Starter Packs');
    });
  });

  group('SearchState starter packs fields', () {
    test('initial state has empty starterPacks and null starterPacksCursor', () {
      const state = SearchState.initial();
      expect(state.starterPacks, isEmpty);
      expect(state.starterPacksCursor, isNull);
    });

    test('loadingStarterPacks sets correct tab and status', () {
      const state = SearchState.loadingStarterPacks(query: 'test');
      expect(state.status, SearchStatus.loading);
      expect(state.currentTab, SearchTab.starterPacks);
      expect(state.query, 'test');
    });

    test('loadedStarterPacks sets packs and cursor', () {
      final pack = sampleStarterPack;
      final state = SearchState.loadedStarterPacks(query: 'test', starterPacks: [pack], starterPacksCursor: 'cursor-1');
      expect(state.status, SearchStatus.loaded);
      expect(state.currentTab, SearchTab.starterPacks);
      expect(state.starterPacks, [pack]);
      expect(state.starterPacksCursor, 'cursor-1');
    });

    test('hasResults is true when starterPacks non-empty', () {
      final state = SearchState.loadedStarterPacks(query: 'test', starterPacks: [sampleStarterPack]);
      expect(state.hasResults, isTrue);
    });

    test('hasMore is true when starterPacksCursor is non-null', () {
      final state = SearchState.loadedStarterPacks(
        query: 'test',
        starterPacks: [sampleStarterPack],
        starterPacksCursor: 'next',
      );
      expect(state.hasMore, isTrue);
    });

    test('copyWith preserves starterPacks and starterPacksCursor', () {
      const base = SearchState.initial();
      final updated = base.copyWith(starterPacks: [sampleStarterPack], starterPacksCursor: 'cursor-x');
      expect(updated.starterPacks, [sampleStarterPack]);
      expect(updated.starterPacksCursor, 'cursor-x');
    });
  });

  group('QuerySubmitted - starterPacks tab', () {
    blocTest<SearchBloc, SearchState>(
      'searches starter packs when starterPacks tab is active',
      build: buildBloc,
      seed: () => const SearchState.initial().copyWith(currentTab: SearchTab.starterPacks),
      setUp: () {
        when(
          () => mockRepository.searchStarterPacks(
            query: 'flutter',
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => SearchStarterPacksResult(starterPacks: [sampleStarterPack], cursor: 'c1'));
      },
      act: (bloc) => bloc.add(const QuerySubmitted(query: 'flutter')),
      expect: () => [
        predicate<SearchState>(
          (s) => s.status == SearchStatus.loading && s.currentTab == SearchTab.starterPacks && s.query == 'flutter',
        ),
        predicate<SearchState>(
          (s) =>
              s.status == SearchStatus.loaded &&
              s.currentTab == SearchTab.starterPacks &&
              s.starterPacks.length == 1 &&
              s.starterPacksCursor == 'c1',
        ),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits error when starterPacks search fails',
      build: buildBloc,
      seed: () => const SearchState.initial().copyWith(currentTab: SearchTab.starterPacks),
      setUp: () {
        when(
          () => mockRepository.searchStarterPacks(
            query: any(named: 'query'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('network error'));
      },
      act: (bloc) => bloc.add(const QuerySubmitted(query: 'fail')),
      expect: () => [
        predicate<SearchState>((s) => s.status == SearchStatus.loading),
        predicate<SearchState>((s) => s.status == SearchStatus.error && s.errorMessage != null),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'does not add search history entry for starterPacks tab',
      build: buildBloc,
      seed: () => const SearchState.initial().copyWith(currentTab: SearchTab.starterPacks),
      act: (bloc) => bloc.add(const QuerySubmitted(query: 'flutter')),
      verify: (_) {
        verifyNever(
          () => mockDatabase.addSearchHistoryEntry(
            query: any(named: 'query'),
            type: any(named: 'type'),
            accountDid: any(named: 'accountDid'),
          ),
        );
      },
    );
  });

  group('SearchTabChanged', () {
    blocTest<SearchBloc, SearchState>(
      'switches to starterPacks tab and re-searches when query present',
      build: buildBloc,
      seed: () => SearchState.loadedPosts(query: 'flutter', sort: 'top', posts: [samplePost], cursor: null),
      setUp: () {
        when(
          () => mockRepository.searchStarterPacks(
            query: 'flutter',
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => SearchStarterPacksResult(starterPacks: [sampleStarterPack]));
      },
      act: (bloc) => bloc.add(const SearchTabChanged(tab: SearchTab.starterPacks)),
      expect: () => [
        predicate<SearchState>((s) => s.currentTab == SearchTab.starterPacks),
        predicate<SearchState>((s) => s.status == SearchStatus.loading && s.currentTab == SearchTab.starterPacks),
        predicate<SearchState>((s) => s.status == SearchStatus.loaded && s.starterPacks.length == 1),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'switches from starterPacks tab to posts tab and re-searches',
      build: buildBloc,
      seed: () => SearchState.loadedStarterPacks(query: 'flutter', starterPacks: [sampleStarterPack]),
      setUp: () {
        when(
          () => mockRepository.searchPosts(
            query: 'flutter',
            sort: any(named: 'sort'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => SearchPostsResult(posts: [samplePost]));
      },
      act: (bloc) => bloc.add(const SearchTabChanged(tab: SearchTab.posts)),
      expect: () => [
        predicate<SearchState>((s) => s.currentTab == SearchTab.posts),
        predicate<SearchState>((s) => s.status == SearchStatus.loading && s.currentTab == SearchTab.posts),
        predicate<SearchState>((s) => s.status == SearchStatus.loaded && s.posts.length == 1),
      ],
    );
  });

  group('LoadMoreRequested - starterPacks tab', () {
    blocTest<SearchBloc, SearchState>(
      'loads more starter packs using starterPacksCursor',
      build: buildBloc,
      seed: () => SearchState.loadedStarterPacks(
        query: 'flutter',
        starterPacks: [sampleStarterPack],
        starterPacksCursor: 'cursor-page-1',
      ),
      setUp: () {
        final secondPack = StarterPackViewBasic(
          uri: AtUri.parse('at://did:plc:creator/app.bsky.graph.starterpack/pack-2'),
          cid: 'cid-pack-2',
          record: const {
            r'$type': 'app.bsky.graph.starterpack',
            'name': 'Another Pack',
            'list': 'at://did:plc:creator/app.bsky.graph.list/list-2',
            'createdAt': '2026-01-01T00:00:00.000Z',
          },
          creator: const ProfileViewBasic(did: 'did:plc:creator', handle: 'creator.bsky.social'),
          indexedAt: DateTime.utc(2026, 1, 1),
        );
        when(
          () => mockRepository.searchStarterPacks(
            query: 'flutter',
            cursor: 'cursor-page-1',
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => SearchStarterPacksResult(starterPacks: [secondPack], cursor: null));
      },
      act: (bloc) => bloc.add(const LoadMoreRequested()),
      expect: () => [
        predicate<SearchState>((s) => s.isLoadingMore),
        predicate<SearchState>((s) => !s.isLoadingMore && s.starterPacks.length == 2 && s.starterPacksCursor == null),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'does not load more when starterPacksCursor is null',
      build: buildBloc,
      seed: () =>
          SearchState.loadedStarterPacks(query: 'flutter', starterPacks: [sampleStarterPack], starterPacksCursor: null),
      act: (bloc) => bloc.add(const LoadMoreRequested()),
      expect: () => [],
    );

    blocTest<SearchBloc, SearchState>(
      'handles load more error gracefully',
      build: buildBloc,
      seed: () => SearchState.loadedStarterPacks(
        query: 'flutter',
        starterPacks: [sampleStarterPack],
        starterPacksCursor: 'cursor-1',
      ),
      setUp: () {
        when(
          () => mockRepository.searchStarterPacks(
            query: any(named: 'query'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('network error'));
      },
      act: (bloc) => bloc.add(const LoadMoreRequested()),
      expect: () => [
        predicate<SearchState>((s) => s.isLoadingMore),
        predicate<SearchState>((s) => !s.isLoadingMore && s.starterPacks.length == 1),
      ],
    );
  });

  group('Existing tab behavior unaffected', () {
    blocTest<SearchBloc, SearchState>(
      'searches posts when posts tab is active',
      build: buildBloc,
      setUp: () {
        when(
          () => mockRepository.searchPosts(
            query: 'hello',
            sort: any(named: 'sort'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => SearchPostsResult(posts: [samplePost], cursor: 'c1'));
      },
      act: (bloc) => bloc.add(const QuerySubmitted(query: 'hello')),
      expect: () => [
        predicate<SearchState>((s) => s.status == SearchStatus.loading && s.currentTab == SearchTab.posts),
        predicate<SearchState>((s) => s.status == SearchStatus.loaded && s.posts.length == 1),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'searches actors when actors tab is active',
      build: buildBloc,
      seed: () => const SearchState.initial().copyWith(currentTab: SearchTab.actors),
      setUp: () {
        when(
          () => mockRepository.searchActors(
            query: 'alice',
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => SearchActorsResult(actors: [sampleActor]));
      },
      act: (bloc) => bloc.add(const QuerySubmitted(query: 'alice')),
      expect: () => [
        predicate<SearchState>((s) => s.status == SearchStatus.loading && s.currentTab == SearchTab.actors),
        predicate<SearchState>((s) => s.status == SearchStatus.loaded && s.actors.length == 1),
      ],
    );
  });
}
