import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/timeline/application/timeline_notifier.dart';
import 'package:lazurite/src/features/timeline/application/timeline_providers.dart';
import 'package:lazurite/src/features/timeline/infrastructure/timeline_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class MockTimelineRepository extends Mock implements TimelineRepository {}

void main() {
  late MockTimelineRepository repository;

  setUp(() {
    repository = MockTimelineRepository();
    when(
      () => repository.watchTimeline(feedKey: any(named: 'feedKey')),
    ).thenAnswer((_) => Stream.value([]));
    when(() => repository.getCursor(any())).thenAnswer((_) async => 'cursor1');
  });

  ProviderContainer createContainer({
    ProviderContainer? parent,
    List<Override> overrides = const [],
  }) {
    final container = ProviderContainer(
      parent: parent,
      overrides: [timelineRepositoryProvider.overrideWithValue(repository), ...overrides],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('TimelineNotifier', () {
    test('initial build watches home timeline', () {
      final container = createContainer();
      container.read(timelineProvider);

      verify(() => repository.watchTimeline(feedKey: 'home')).called(1);
    });

    test('switching feed updates watched timeline', () async {
      final container = createContainer();

      container.listen(timelineProvider, (previous, next) {});

      verify(() => repository.watchTimeline(feedKey: 'home')).called(1);

      container.read(activeFeedProvider.notifier).switchFeed('custom_feed_uri');
      await container.pump();

      verify(() => repository.watchTimeline(feedKey: 'custom_feed_uri')).called(1);
    });

    test('loadMore uses cursor for active feed', () async {
      final container = createContainer();
      container.read(activeFeedProvider.notifier).switchFeed('custom_feed_uri');

      when(() => repository.getCursor('custom_feed_uri')).thenAnswer((_) async => 'next_cursor');
      when(
        () => repository.fetchAndCacheTimeline(
          cursor: any(named: 'cursor'),
          feedUri: any(named: 'feedUri'),
        ),
      ).thenAnswer((_) async => {});

      await container.read(timelineProvider.notifier).loadMore();

      verify(() => repository.getCursor('custom_feed_uri')).called(1);
      verify(
        () => repository.fetchAndCacheTimeline(cursor: 'next_cursor', feedUri: 'custom_feed_uri'),
      ).called(1);
    });

    test('feed switching preserves cursor usage', () async {
      final container = createContainer();
      container.listen(timelineProvider, (previous, next) {});
      container.read(activeFeedProvider.notifier).switchFeed('feedA');

      void stubRepo() {
        when(
          () => repository.watchTimeline(feedKey: any(named: 'feedKey')),
        ).thenAnswer((_) => Stream.value([]));
        when(() => repository.getCursor('feedA')).thenAnswer((_) async => 'cursorA');
        when(() => repository.getCursor('feedB')).thenAnswer((_) async => 'cursorB');
        when(
          () => repository.fetchAndCacheTimeline(
            cursor: any(named: 'cursor'),
            feedUri: any(named: 'feedUri'),
          ),
        ).thenAnswer((_) async => {});
      }

      stubRepo();

      await container.read(timelineProvider.notifier).loadMore();
      verify(() => repository.getCursor('feedA')).called(1);
      verify(
        () => repository.fetchAndCacheTimeline(cursor: 'cursorA', feedUri: 'feedA'),
      ).called(1);

      reset(repository);
      stubRepo();

      container.read(activeFeedProvider.notifier).switchFeed('feedB');
      await container.pump();

      await container.read(timelineProvider.notifier).loadMore();
      verify(() => repository.getCursor('feedB')).called(1);
      verify(
        () => repository.fetchAndCacheTimeline(cursor: 'cursorB', feedUri: 'feedB'),
      ).called(1);

      reset(repository);
      stubRepo();
      container.read(activeFeedProvider.notifier).switchFeed('feedA');
      await container.pump();
      await container.read(timelineProvider.notifier).loadMore();
      verify(() => repository.getCursor('feedA')).called(1);
      verify(
        () => repository.fetchAndCacheTimeline(cursor: 'cursorA', feedUri: 'feedA'),
      ).called(1);
    });
  });
}
