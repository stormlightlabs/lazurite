import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockFeedRepository mockRepository;

  setUp(() {
    mockRepository = MockFeedRepository();
  });

  ProviderContainer createContainer({bool authenticated = true}) {
    return ProviderContainer(
      overrides: [
        feedRepositoryProvider.overrideWithValue(mockRepository),
        authProvider.overrideWith(() => _FakeAuthNotifier(authenticated: authenticated)),
      ],
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
          ownerDid: 'did:plc:test',
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
          ownerDid: 'did:plc:test',
        ),
      ];

      when(() => mockRepository.watchAllFeeds(any())).thenAnswer((_) => Stream.value(feeds));

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
      when(() => mockRepository.watchAllFeeds(any())).thenAnswer((_) => Stream.value([]));

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
          ownerDid: 'did:plc:test',
        ),
      ];

      when(
        () => mockRepository.watchPinnedFeeds(any()),
      ).thenAnswer((_) => Stream.value(pinnedFeeds));

      final container = createContainer();

      final subscription = container.listen(pinnedFeedsProvider, (_, _) {});
      addTearDown(subscription.close);

      final result = await container.read(pinnedFeedsProvider.future);

      expect(result, hasLength(1));
      expect(result.first.isPinned, true);
      expect(result.first.displayName, 'Pinned Feed');
    });

    test('handles no pinned feeds', () async {
      when(() => mockRepository.watchPinnedFeeds(any())).thenAnswer((_) => Stream.value([]));

      final container = createContainer();

      final subscription = container.listen(pinnedFeedsProvider, (_, _) {});
      addTearDown(subscription.close);

      final result = await container.read(pinnedFeedsProvider.future);

      expect(result, isEmpty);
    });
  });

  group('ActiveFeed', () {
    test('updates to top pinned feed when authenticated with pinned feeds', () async {
      final pinnedFeed = SavedFeed(
        uri: 'at://did:plc:test/app.bsky.feed.generator/top-feed',
        displayName: 'Top Feed',
        description: null,
        avatar: null,
        creatorDid: 'did:plc:creator',
        likeCount: 10,
        sortOrder: 0,
        isPinned: true,
        lastSynced: DateTime.now(),
        ownerDid: 'did:plc:test',
      );

      when(
        () => mockRepository.watchPinnedFeeds(any()),
      ).thenAnswer((_) => Stream.value([pinnedFeed]));

      final container = createContainer(authenticated: true);
      final subscription = container.listen(pinnedFeedsProvider, (previous, next) {});
      addTearDown(subscription.close);

      await container.read(pinnedFeedsProvider.future);

      expect(
        container.read(activeFeedProvider),
        'at://did:plc:test/app.bsky.feed.generator/top-feed',
      );
    });

    test('initial state falls back to discover when authenticated with no pinned feeds', () async {
      when(() => mockRepository.watchPinnedFeeds(any())).thenAnswer((_) => Stream.value([]));

      final container = createContainer(authenticated: true);

      final subscription = container.listen(pinnedFeedsProvider, (previous, next) {});
      addTearDown(subscription.close);
      await container.read(pinnedFeedsProvider.future);

      expect(container.read(activeFeedProvider), FeedRepository.kDiscoverFeedUri);
    });

    test('initial state is discover feed when unauthenticated', () {
      final container = createContainer(authenticated: false);

      expect(container.read(activeFeedProvider), FeedRepository.kDiscoverFeedUri);
    });

    test('switchFeed changes active feed', () {
      final container = createContainer(authenticated: true);

      final notifier = container.read(activeFeedProvider.notifier);
      notifier.switchFeed('at://did:plc:test/app.bsky.feed.generator/custom');

      expect(
        container.read(activeFeedProvider),
        'at://did:plc:test/app.bsky.feed.generator/custom',
      );
    });

    test('switchToDiscover changes to discover feed', () {
      final container = createContainer(authenticated: true);

      final notifier = container.read(activeFeedProvider.notifier);
      notifier.switchToDiscover();

      expect(container.read(activeFeedProvider), FeedRepository.kDiscoverFeedUri);
    });

    test('resetToDefault selects top pinned feed when authenticated', () async {
      final pinnedFeed = SavedFeed(
        uri: 'at://did:plc:test/app.bsky.feed.generator/top-feed',
        displayName: 'Top Feed',
        description: null,
        avatar: null,
        creatorDid: 'did:plc:creator',
        likeCount: 10,
        sortOrder: 0,
        isPinned: true,
        lastSynced: DateTime.now(),
        ownerDid: 'did:plc:test',
      );

      when(
        () => mockRepository.watchPinnedFeeds(any()),
      ).thenAnswer((_) => Stream.value([pinnedFeed]));

      final container = createContainer(authenticated: true);
      final subscription = container.listen(pinnedFeedsProvider, (previous, next) {});
      addTearDown(subscription.close);
      await container.read(pinnedFeedsProvider.future);

      final notifier = container.read(activeFeedProvider.notifier);
      notifier.resetToDefault(isAuthenticated: true);

      expect(
        container.read(activeFeedProvider),
        'at://did:plc:test/app.bsky.feed.generator/top-feed',
      );
    });

    test('resetToDefault falls back to discover when unauthenticated', () async {
      when(() => mockRepository.watchPinnedFeeds(any())).thenAnswer((_) => Stream.value([]));

      final container = createContainer(authenticated: false);
      final subscription = container.listen(pinnedFeedsProvider, (_, _) {});
      addTearDown(subscription.close);

      final notifier = container.read(activeFeedProvider.notifier);
      notifier.resetToDefault(isAuthenticated: false);

      expect(container.read(activeFeedProvider), FeedRepository.kDiscoverFeedUri);
    });

    test('notifies listeners on feed change', () {
      final container = createContainer(authenticated: true);
      final states = <String>[];

      container.listen(activeFeedProvider, (previous, next) {
        states.add(next);
      });

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

/// Fake AuthNotifier that returns a fixed auth state.
class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier({required this.authenticated});

  final bool authenticated;

  @override
  AuthState build() {
    if (authenticated) {
      return AuthState.authenticated(
        Session(
          did: 'did:plc:test',
          scope: 'test',
          handle: 'test.bsky.social',
          accessJwt: 'test-access',
          refreshJwt: 'test-refresh',
          pdsUrl: 'https://bsky.social',
          dpopKey: {'test': 'test'},
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        ),
      );
    }
    return const AuthState.unauthenticated();
  }
}
