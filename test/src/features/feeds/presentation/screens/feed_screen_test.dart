import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_providers.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/presentation/screens/feed_screen.dart';
import 'package:lazurite/src/features/settings/application/muted_word_filter_provider.dart';
import 'package:lazurite/src/features/settings/application/settings_providers.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/mocks.dart';

void main() {
  const ownerDid = 'did:web:tester';
  late MockFeedContentRepository mockContentRepository;

  setUp(() {
    mockContentRepository = MockFeedContentRepository();

    when(() => mockContentRepository.cleanupCache(ownerDid)).thenAnswer((_) async {});
    when(() => mockContentRepository.getCursor(any(), ownerDid)).thenAnswer((_) async => null);
    when(
      () => mockContentRepository.watchFeedContent(
        feedKey: any(named: 'feedKey'),
        ownerDid: ownerDid,
      ),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => mockContentRepository.fetchAndCacheFeed(
        feedUri: any(named: 'feedUri'),
        ownerDid: ownerDid,
      ),
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
          mutedWordFilterServiceProvider.overrideWith((ref) => null),
          feedViewPrefProvider.overrideWith((ref) => Stream.value(FeedViewPref.defaultPref)),
        ],
        child: const MaterialApp(home: FeedScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(Duration.zero);
    verify(
      () => mockContentRepository.fetchAndCacheFeed(feedUri: activeFeed, ownerDid: ownerDid),
    ).called(1);
  });

  testWidgets('FeedScreen refresh triggers fetch', (tester) async {
    const activeFeed = 'at://did:1/feed/home';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeFeedProvider.overrideWithValue(activeFeed),
          feedContentRepositoryProvider.overrideWithValue(mockContentRepository),
          pinnedFeedsProvider.overrideWith(() => MockPinnedFeedsNotifier()),
          mutedWordFilterServiceProvider.overrideWith((ref) => null),
          feedViewPrefProvider.overrideWith((ref) => Stream.value(FeedViewPref.defaultPref)),
        ],
        child: const MaterialApp(home: FeedScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(Duration.zero);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    verify(
      () => mockContentRepository.fetchAndCacheFeed(feedUri: activeFeed, ownerDid: ownerDid),
    ).called(2);
  });
}
