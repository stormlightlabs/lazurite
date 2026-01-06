import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

void main() {
  late MockFeedRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockFeedRepository();
    container = ProviderContainer(
      overrides: [feedRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('FeedSearch', () {
    test('initial state loads popular feeds', () async {
      when(() => mockRepository.discoverFeeds(query: null)).thenAnswer(
        (_) async => [
          {'displayName': 'Feed 1'},
        ],
      );

      final sub = container.listen(feedSearchProvider, (_, _) {});

      await container.pump();

      expect(container.read(feedSearchProvider).isLoading, true);

      await Future.delayed(Duration.zero);

      final state = container.read(feedSearchProvider);
      expect(state.results.length, 1);
      expect(state.results.first['displayName'], 'Feed 1');
      expect(state.isLoading, false);
      sub.close();
    });

    test('search updates query and debounces', () async {
      when(() => mockRepository.discoverFeeds(query: 'test')).thenAnswer((_) async => []);

      final sub = container.listen(feedSearchProvider, (_, _) {});
      final notifier = container.read(feedSearchProvider.notifier);

      await container.pump();
      await Future.delayed(Duration.zero);
      reset(mockRepository);
      when(
        () => mockRepository.discoverFeeds(query: any(named: 'query')),
      ).thenAnswer((_) async => []);

      notifier.setQuery('tes');
      expect(container.read(feedSearchProvider).query, 'tes');

      verifyNever(() => mockRepository.discoverFeeds(query: any(named: 'query')));

      notifier.setQuery('test');
      expect(container.read(feedSearchProvider).query, 'test');

      await Future.delayed(const Duration(milliseconds: 600));

      verify(() => mockRepository.discoverFeeds(query: 'test')).called(1);
      sub.close();
    });

    test('filtering and sorting', () {
      const state = FeedSearchState(
        results: [
          {'displayName': 'A Feed', 'description': 'desc', 'likeCount': 10},
          {'displayName': 'B Feed', 'description': 'desc', 'likeCount': 20},
        ],
      );

      final filtered = state.filteredResults;
      expect(filtered.first['displayName'], 'B Feed');

      final sortedState = state.copyWith(sortBy: FeedSortOption.name);
      expect(sortedState.filteredResults.first['displayName'], 'A Feed');

      final filteredState = state.copyWith(localFilter: 'A Feed');
      expect(filteredState.filteredResults.length, 1);
      expect(filteredState.filteredResults.first['displayName'], 'A Feed');
    });
  });
}
