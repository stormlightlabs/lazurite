import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_providers.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/presentation/screens/feed_discovery_screen.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/feed_preview_modal.dart';
import 'package:lazurite/src/features/settings/application/label_filter_provider.dart';
import 'package:lazurite/src/features/settings/application/muted_word_filter_provider.dart';
import 'package:lazurite/src/features/settings/application/settings_providers.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/mocks.dart';

void main() {
  testWidgets('FeedDiscoveryScreen displays trending feeds and allows saving', (tester) async {
    final mockRepository = MockFeedRepository();
    const activeFeed = 'at://did:1/feed/home';

    final kTrendingFeeds = [
      {
        'uri': 'at://did:1/feed/trending1',
        'displayName': 'Trending 1',
        'description': 'Description 1',
        'avatar': null,
        'creator': {'handle': 'user1'},
        'likeCount': 100,
      },
      {
        'uri': 'at://did:1/feed/trending2',
        'displayName': 'Trending 2',
        'description': 'Description 2',
        'creator': {'handle': 'user2'},
        'likeCount': 50,
      },
    ];

    when(
      () => mockRepository.discoverFeeds(
        limit: any(named: 'limit'),
        query: any(named: 'query'),
      ),
    ).thenAnswer((_) async => kTrendingFeeds);

    when(
      () => mockRepository.saveFeed(any(), any(), pin: any(named: 'pin')),
    ).thenAnswer((_) async => {});
    when(() => mockRepository.watchAllFeeds(any())).thenAnswer((_) async* {
      yield [];
    });

    final mockContentRepository = MockFeedContentRepository();
    when(
      () => mockContentRepository.watchFeedContent(
        feedKey: any(named: 'feedKey'),
        ownerDid: any(named: 'ownerDid'),
      ),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => mockContentRepository.fetchAndCacheFeed(
        feedUri: any(named: 'feedUri'),
        ownerDid: any(named: 'ownerDid'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockRepository.watchAllFeeds(any())).thenAnswer((_) => Stream.value([]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedRepositoryProvider.overrideWithValue(mockRepository),
          feedContentRepositoryProvider.overrideWithValue(mockContentRepository),
          activeFeedProvider.overrideWithValue(activeFeed),
          pinnedFeedsProvider.overrideWith(() => MockPinnedFeedsNotifier()),
          labelFilterServiceProvider.overrideWith((ref) => null),
          mutedWordFilterServiceProvider.overrideWith((ref) => null),
          feedViewPrefProvider.overrideWith((ref) => Stream.value(FeedViewPref.defaultPref)),
        ],
        child: const MaterialApp(home: FeedDiscoveryScreen()),
      ),
    );

    await tester.pump();
    await tester.pump();
    expect(find.text('Trending 1'), findsOneWidget);
    expect(find.textContaining('@user1'), findsOneWidget);
    expect(find.text('Trending 2'), findsOneWidget);

    await tester.tap(find.text('Trending 1'));
    await tester.pumpAndSettle();

    expect(find.byType(FeedPreviewModal), findsOneWidget);
    expect(find.text('Trending 1'), findsNWidgets(2));
    expect(find.text('Save'), findsOneWidget);
  });
}
