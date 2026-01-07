import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/domain/post.dart';
import 'package:lazurite/src/core/utils/pagination.dart';
import 'package:lazurite/src/features/search/application/search_providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockSearchRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockSearchRepository();

    container = ProviderContainer(
      overrides: [searchRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('SearchNotifier', () {
    test('build does not search if query is empty', () async {
      await container.read(searchProvider('').future);
      verifyZeroInteractions(mockRepository);
    });

    test('build performs search for non-empty query', () async {
      const query = 'test query';
      const expectedResult = PaginatedResult<Post>(items: <Post>[], cursor: 'next_cursor');

      when(() => mockRepository.saveRecentSearch(query)).thenAnswer((_) async {});
      when(
        () => mockRepository.searchPosts(query, cursor: null),
      ).thenAnswer((_) async => expectedResult);

      await container.read(searchProvider(query).future);

      verify(() => mockRepository.saveRecentSearch(query)).called(1);
      verify(() => mockRepository.searchPosts(query, cursor: null)).called(1);
    });

    test('loadMore fetches next page', () async {
      const query = 'test query';
      final firstPage = PaginatedResult<Post>(
        items: [
          Post(
            uri: 'uri1',
            cid: 'cid1',
            text: 'text1',
            author: const Author(did: 'did1', handle: 'handle1'),
            indexedAt: DateTime.now(),
          ),
        ],
        cursor: 'next_cursor',
      );
      final secondPage = PaginatedResult<Post>(
        items: [
          Post(
            uri: 'uri2',
            cid: 'cid2',
            text: 'text2',
            author: const Author(did: 'did2', handle: 'handle2'),
            indexedAt: DateTime.now(),
          ),
        ],
        cursor: 'final_cursor',
      );

      when(() => mockRepository.saveRecentSearch(query)).thenAnswer((_) async {});
      when(
        () => mockRepository.searchPosts(query, cursor: null),
      ).thenAnswer((_) async => firstPage);
      when(
        () => mockRepository.searchPosts(query, cursor: 'next_cursor'),
      ).thenAnswer((_) async => secondPage);

      final notifier = container.read(searchProvider(query).notifier);
      await container.read(searchProvider(query).future);

      await notifier.loadMore();

      final state = await container.read(searchProvider(query).future);
      expect(state.length, 2);

      verify(() => mockRepository.searchPosts(query, cursor: 'next_cursor')).called(1);
    });

    test('loadMore does nothing if hasMore is false', () async {
      const query = 'test query';
      const singlePage = PaginatedResult<Post>(items: [], cursor: null);

      when(() => mockRepository.saveRecentSearch(query)).thenAnswer((_) async {});
      when(
        () => mockRepository.searchPosts(query, cursor: null),
      ).thenAnswer((_) async => singlePage);

      final notifier = container.read(searchProvider(query).notifier);
      await container.read(searchProvider(query).future);

      await notifier.loadMore();

      verify(() => mockRepository.searchPosts(query, cursor: null)).called(1);
      verifyNever(() => mockRepository.searchPosts(query, cursor: any(named: 'cursor')));
    });

    test('refresh resets cursor and re-searches', () async {
      const query = 'test query';
      const result = PaginatedResult<Post>(items: [], cursor: 'new_cursor');

      when(() => mockRepository.saveRecentSearch(query)).thenAnswer((_) async {});
      when(() => mockRepository.searchPosts(query, cursor: null)).thenAnswer((_) async => result);

      final notifier = container.read(searchProvider(query).notifier);
      await container.read(searchProvider(query).future);

      await notifier.refresh();

      verify(() => mockRepository.searchPosts(query, cursor: null)).called(2);
    });
  });
}
