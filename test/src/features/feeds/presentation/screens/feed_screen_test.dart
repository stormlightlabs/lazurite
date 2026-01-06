import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_providers.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_content_repository.dart';
import 'package:lazurite/src/features/feeds/presentation/screens/feed_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedContentRepository extends Mock implements FeedContentRepository {}

class MockPinnedFeedsNotifier extends Mock implements PinnedFeedsNotifier {
  @override
  Stream<List<SavedFeedData>> build() => Stream.value([]);
}

void main() {
  late MockFeedContentRepository mockContentRepository;

  setUp(() {
    mockContentRepository = MockFeedContentRepository();

    when(() => mockContentRepository.cleanupCache()).thenAnswer((_) async {});
    when(() => mockContentRepository.getCursor(any())).thenAnswer((_) async => null);
    when(
      () => mockContentRepository.watchFeedContent(feedKey: any(named: 'feedKey')),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => mockContentRepository.fetchAndCacheFeed(feedUri: any(named: 'feedUri')),
    ).thenAnswer((_) async {});
  });

  testWidgets('FeedScreen loads content for active feed', (tester) async {
    const activeFeed = 'at://did:1/feed/home';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeFeedProvider.overrideWithValue(activeFeed),
          feedContentRepositoryProvider.overrideWithValue(mockContentRepository),
          pinnedFeedsProvider.overrideWith(() => MockPinnedFeedsNotifier()),
        ],
        child: const MaterialApp(home: FeedScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(Duration.zero);
    verify(() => mockContentRepository.fetchAndCacheFeed(feedUri: activeFeed)).called(1);
  });

  testWidgets('FeedScreen refresh triggers fetch', (tester) async {
    const activeFeed = 'at://did:1/feed/home';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeFeedProvider.overrideWithValue(activeFeed),
          feedContentRepositoryProvider.overrideWithValue(mockContentRepository),
          pinnedFeedsProvider.overrideWith(() => MockPinnedFeedsNotifier()),
        ],
        child: const MaterialApp(home: FeedScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(Duration.zero);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    verify(() => mockContentRepository.fetchAndCacheFeed(feedUri: activeFeed)).called(2);
  });
}
