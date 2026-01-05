import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_notifier.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_providers.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_content_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedContentRepository extends Mock implements FeedContentRepository {}

class MockLogger extends Mock implements Logger {}

class FakeActiveFeed extends ActiveFeed {
  FakeActiveFeed(this._initialUri);
  final String _initialUri;

  @override
  String build() => _initialUri;
}

void main() {
  late MockFeedContentRepository mockRepository;
  late MockLogger mockLogger;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockFeedContentRepository();
    mockLogger = MockLogger();

    when(() => mockLogger.debug(any(), any())).thenReturn(null);

    container = ProviderContainer(
      overrides: [
        feedContentRepositoryProvider.overrideWithValue(mockRepository),
        loggerProvider('FeedContentNotifier').overrideWithValue(mockLogger),
        activeFeedProvider.overrideWith(() => FakeActiveFeed('home')),
      ],
    );

    registerFallbackValue('');
    when(
      () => mockRepository.watchFeedContent(feedKey: any(named: 'feedKey')),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => mockRepository.fetchAndCacheFeed(
        cursor: any(named: 'cursor'),
        feedUri: any(named: 'feedUri'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockRepository.getCursor(any())).thenAnswer((_) async => null);
    when(() => mockRepository.clearFeedContent(any())).thenAnswer((_) async {});
  });

  tearDown(() {
    container.dispose();
  });

  group('FeedContentNotifier', () {
    test('build watches home feed content by default', () async {
      container.read(feedContentProvider);

      await Future.delayed(Duration.zero);

      verify(() => mockRepository.watchFeedContent(feedKey: 'home')).called(1);
    });

    test('build watches specific feed content when activeFeed is set', () async {
      const feedUri = 'at://did:example:123/app.bsky.feed.generator/custom';

      container = ProviderContainer(
        overrides: [
          feedContentRepositoryProvider.overrideWithValue(mockRepository),
          loggerProvider('FeedContentNotifier').overrideWithValue(mockLogger),
          activeFeedProvider.overrideWith(() => FakeActiveFeed(feedUri)),
        ],
      );

      when(
        () => mockRepository.watchFeedContent(feedKey: feedUri),
      ).thenAnswer((_) => Stream.value([]));

      container.read(feedContentProvider);

      await Future.delayed(Duration.zero);

      verify(() => mockRepository.watchFeedContent(feedKey: feedUri)).called(1);
    });

    test('refresh calls fetchAndCacheFeed with correct key for home feed', () async {
      when(() => mockRepository.fetchAndCacheFeed(feedUri: null)).thenAnswer((_) async {});

      container.read(feedContentProvider);

      await container.read(feedContentProvider.notifier).refresh();

      verify(() => mockRepository.fetchAndCacheFeed(feedUri: null)).called(1);
    });

    test('refresh calls fetchAndCacheFeed with correct key for custom feed', () async {
      const feedUri = 'at://did:example:123/app.bsky.feed.generator/custom';

      container = ProviderContainer(
        overrides: [
          feedContentRepositoryProvider.overrideWithValue(mockRepository),
          loggerProvider('FeedContentNotifier').overrideWithValue(mockLogger),
          activeFeedProvider.overrideWith(() => FakeActiveFeed(feedUri)),
        ],
      );

      when(
        () => mockRepository.watchFeedContent(feedKey: feedUri),
      ).thenAnswer((_) => Stream.value([]));

      when(() => mockRepository.fetchAndCacheFeed(feedUri: feedUri)).thenAnswer((_) async {});

      container.read(feedContentProvider);

      await container.read(feedContentProvider.notifier).refresh();

      verify(() => mockRepository.fetchAndCacheFeed(feedUri: feedUri)).called(1);
    });

    test('loadMore fetches next page using cursor', () async {
      when(() => mockRepository.getCursor('home')).thenAnswer((_) async => 'next_cursor');
      when(
        () => mockRepository.fetchAndCacheFeed(cursor: 'next_cursor', feedUri: null),
      ).thenAnswer((_) async {});

      container.read(feedContentProvider);

      await container.read(feedContentProvider.notifier).loadMore();

      verify(() => mockRepository.getCursor('home')).called(1);
      verify(
        () => mockRepository.fetchAndCacheFeed(cursor: 'next_cursor', feedUri: null),
      ).called(1);
    });

    test('loadMore does nothing if no cursor found', () async {
      when(() => mockRepository.getCursor('home')).thenAnswer((_) async => null);

      container.read(feedContentProvider);

      await container.read(feedContentProvider.notifier).loadMore();

      verify(() => mockRepository.getCursor('home')).called(1);
      verifyNever(
        () => mockRepository.fetchAndCacheFeed(
          cursor: any(named: 'cursor'),
          feedUri: any(named: 'feedUri'),
        ),
      );
    });

    test('clearFeedContent calls repository clearFeedContent', () async {
      when(() => mockRepository.clearFeedContent('home')).thenAnswer((_) async {});

      container.read(feedContentProvider);

      await container.read(feedContentProvider.notifier).clearFeedContent();

      verify(() => mockRepository.clearFeedContent('home')).called(1);
    });
  });
}
