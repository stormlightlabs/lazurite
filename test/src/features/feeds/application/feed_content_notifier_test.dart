import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_notifier.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_providers.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_content_repository.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedContentRepository extends Mock implements FeedContentRepository {}

class MockLogger extends Mock implements Logger {}

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
    test('build watches home feed content when instantiated with home URI', () async {
      const feedUri = FeedRepository.kHomeFeedUri;
      container.read(feedContentProvider(feedUri));

      await Future.delayed(Duration.zero);

      verify(
        () => mockRepository.watchFeedContent(feedKey: FeedContentRepository.kInternalHomeFeedKey),
      ).called(1);
    });

    test('build watches specific feed content when instantiated with custom URI', () async {
      const feedUri = 'at://did:example:123/app.bsky.feed.generator/custom';

      when(
        () => mockRepository.watchFeedContent(feedKey: feedUri),
      ).thenAnswer((_) => Stream.value([]));

      container.read(feedContentProvider(feedUri));

      await Future.delayed(Duration.zero);

      verify(() => mockRepository.watchFeedContent(feedKey: feedUri)).called(1);
    });

    test('refresh calls fetchAndCacheFeed with correct key for home feed', () async {
      const feedUri = FeedRepository.kHomeFeedUri;
      when(() => mockRepository.fetchAndCacheFeed(feedUri: null)).thenAnswer((_) async {});

      await container.read(feedContentProvider(feedUri).notifier).refresh();

      verify(() => mockRepository.fetchAndCacheFeed(feedUri: null)).called(1);
    });

    test('refresh calls fetchAndCacheFeed with correct key for custom feed', () async {
      const feedUri = 'at://did:example:123/app.bsky.feed.generator/custom';

      when(
        () => mockRepository.watchFeedContent(feedKey: feedUri),
      ).thenAnswer((_) => Stream.value([]));
      when(() => mockRepository.fetchAndCacheFeed(feedUri: feedUri)).thenAnswer((_) async {});

      await container.read(feedContentProvider(feedUri).notifier).refresh();

      verify(() => mockRepository.fetchAndCacheFeed(feedUri: feedUri)).called(1);
    });

    test('loadMore fetches next page using cursor', () async {
      const feedUri = FeedRepository.kHomeFeedUri;

      when(
        () => mockRepository.getCursor(FeedContentRepository.kInternalHomeFeedKey),
      ).thenAnswer((_) async => 'next_cursor');
      when(
        () => mockRepository.fetchAndCacheFeed(cursor: 'next_cursor', feedUri: null),
      ).thenAnswer((_) async {});

      await container.read(feedContentProvider(feedUri).notifier).loadMore();

      verify(() => mockRepository.getCursor(FeedContentRepository.kInternalHomeFeedKey)).called(1);
      verify(
        () => mockRepository.fetchAndCacheFeed(cursor: 'next_cursor', feedUri: null),
      ).called(1);
    });

    test('loadMore does nothing if no cursor found', () async {
      const feedUri = FeedRepository.kHomeFeedUri;

      when(
        () => mockRepository.getCursor(FeedContentRepository.kInternalHomeFeedKey),
      ).thenAnswer((_) async => null);

      await container.read(feedContentProvider(feedUri).notifier).loadMore();

      verify(() => mockRepository.getCursor(FeedContentRepository.kInternalHomeFeedKey)).called(1);
      verifyNever(
        () => mockRepository.fetchAndCacheFeed(
          cursor: any(named: 'cursor'),
          feedUri: any(named: 'feedUri'),
        ),
      );
    });

    test('clearFeedContent calls repository clearFeedContent', () async {
      const feedUri = FeedRepository.kHomeFeedUri;

      when(
        () => mockRepository.clearFeedContent(FeedContentRepository.kInternalHomeFeedKey),
      ).thenAnswer((_) async {});

      await container.read(feedContentProvider(feedUri).notifier).clearFeedContent();

      verify(
        () => mockRepository.clearFeedContent(FeedContentRepository.kInternalHomeFeedKey),
      ).called(1);
    });
  });
}
