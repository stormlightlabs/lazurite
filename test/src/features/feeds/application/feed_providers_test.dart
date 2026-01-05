import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

void main() {
  late MockFeedRepository mockRepository;

  setUp(() {
    mockRepository = MockFeedRepository();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [feedRepositoryProvider.overrideWithValue(mockRepository)],
    );
  }

  group('AllFeedsNotifier', () {
    test('streams all feeds from repository', () async {
      final feeds = [
        SavedFeed(
          uri: 'at://did:plc:test/app.bsky.feed.generator/feed1',
          displayName: 'Feed 1',
          description: 'First feed',
          avatar: null,
          creatorDid: 'did:plc:creator',
          likeCount: 10,
          sortOrder: 0,
          isPinned: false,
          lastSynced: DateTime.now(),
        ),
        SavedFeed(
          uri: 'at://did:plc:test/app.bsky.feed.generator/feed2',
          displayName: 'Feed 2',
          description: null,
          avatar: null,
          creatorDid: 'did:plc:creator2',
          likeCount: 5,
          sortOrder: 1,
          isPinned: true,
          lastSynced: DateTime.now(),
        ),
      ];

      when(() => mockRepository.watchAllFeeds()).thenAnswer((_) => Stream.value(feeds));

      final container = createContainer();

      final subscription = container.listen(allFeedsProvider, (_, _) {});
      addTearDown(subscription.close);

      final result = await container.read(allFeedsProvider.future);

      expect(result, hasLength(2));
      expect(result.first.displayName, 'Feed 1');
      expect(result.first.uri, 'at://did:plc:test/app.bsky.feed.generator/feed1');
      expect(result[1].displayName, 'Feed 2');
      expect(result[1].isPinned, true);
    });

    test('handles empty feed list', () async {
      when(() => mockRepository.watchAllFeeds()).thenAnswer((_) => Stream.value([]));

      final container = createContainer();

      final subscription = container.listen(allFeedsProvider, (_, _) {});
      addTearDown(subscription.close);

      final result = await container.read(allFeedsProvider.future);

      expect(result, isEmpty);
    });
  });

  group('PinnedFeedsNotifier', () {
    test('streams only pinned feeds', () async {
      final pinnedFeeds = [
        SavedFeed(
          uri: 'at://did:plc:test/app.bsky.feed.generator/pinned1',
          displayName: 'Pinned Feed',
          description: null,
          avatar: null,
          creatorDid: 'did:plc:creator',
          likeCount: 20,
          sortOrder: 0,
          isPinned: true,
          lastSynced: DateTime.now(),
        ),
      ];

      when(() => mockRepository.watchPinnedFeeds()).thenAnswer((_) => Stream.value(pinnedFeeds));

      final container = createContainer();

      final subscription = container.listen(pinnedFeedsProvider, (_, _) {});
      addTearDown(subscription.close);

      final result = await container.read(pinnedFeedsProvider.future);

      expect(result, hasLength(1));
      expect(result.first.isPinned, true);
      expect(result.first.displayName, 'Pinned Feed');
    });

    test('handles no pinned feeds', () async {
      when(() => mockRepository.watchPinnedFeeds()).thenAnswer((_) => Stream.value([]));

      final container = createContainer();

      final subscription = container.listen(pinnedFeedsProvider, (_, _) {});
      addTearDown(subscription.close);

      final result = await container.read(pinnedFeedsProvider.future);

      expect(result, isEmpty);
    });
  });

  group('ActiveFeed', () {
    test('initial state is home feed', () {
      final container = createContainer();

      expect(container.read(activeFeedProvider), FeedRepository.kHomeFeedUri);
    });

    test('switchFeed changes active feed', () {
      final container = createContainer();

      final notifier = container.read(activeFeedProvider.notifier);
      notifier.switchFeed('at://did:plc:test/app.bsky.feed.generator/custom');

      expect(container.read(activeFeedProvider), 'at://did:plc:test/app.bsky.feed.generator/custom');
    });

    test('switchToHome changes to home feed', () {
      final container = createContainer();

      final notifier = container.read(activeFeedProvider.notifier);
      notifier.switchFeed('at://did:plc:test/app.bsky.feed.generator/custom');
      expect(container.read(activeFeedProvider), 'at://did:plc:test/app.bsky.feed.generator/custom');

      notifier.switchToHome();
      expect(container.read(activeFeedProvider), FeedRepository.kHomeFeedUri);
    });

    test('switchToDiscover changes to discover feed', () {
      final container = createContainer();

      final notifier = container.read(activeFeedProvider.notifier);
      notifier.switchToDiscover();

      expect(container.read(activeFeedProvider), FeedRepository.kDiscoverFeedUri);
    });

    test('notifies listeners on feed change', () {
      final container = createContainer();
      final states = <String>[];

      container.listen(
        activeFeedProvider,
        (previous, next) {
          states.add(next);
        },
      );

      final notifier = container.read(activeFeedProvider.notifier);
      notifier.switchFeed('at://did:plc:test/app.bsky.feed.generator/feed1');
      notifier.switchFeed('at://did:plc:test/app.bsky.feed.generator/feed2');

      expect(states, [
        'at://did:plc:test/app.bsky.feed.generator/feed1',
        'at://did:plc:test/app.bsky.feed.generator/feed2',
      ]);
    });
  });
}
