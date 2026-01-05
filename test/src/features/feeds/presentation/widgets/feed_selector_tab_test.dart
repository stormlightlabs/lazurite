import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/feed_selector_tab.dart';

class MockPinnedFeedsNotifier extends PinnedFeedsNotifier {
  final List<SavedFeedData> _initialData;
  MockPinnedFeedsNotifier(this._initialData);

  @override
  Stream<List<SavedFeedData>> build() {
    return Stream.value(_initialData);
  }
}

void main() {
  testWidgets('FeedSelectorTab displays feeds and allows switching', (tester) async {
    final kFeeds = [
      SavedFeedData(
        uri: 'home',
        displayName: 'Home',
        creatorDid: 'did:1',
        likeCount: 0,
        sortOrder: 0,
        isPinned: true,
        lastSynced: DateTime.now(),
      ),
      SavedFeedData(
        uri: 'at://did:1/feed/discover',
        displayName: 'Discover',
        creatorDid: 'did:1',
        likeCount: 0,
        sortOrder: 1,
        isPinned: true,
        lastSynced: DateTime.now(),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [pinnedFeedsProvider.overrideWith(() => MockPinnedFeedsNotifier(kFeeds))],
        child: const MaterialApp(home: Scaffold(body: FeedSelectorTab())),
      ),
    );

    await tester.pump();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);

    final homeChip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Home'));
    expect(homeChip.selected, isTrue);

    final discoverChip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Discover'));
    expect(discoverChip.selected, isFalse);

    await tester.tap(find.text('Discover'));
    await tester.pump();

    final discoverChipAfter = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Discover'),
    );
    expect(discoverChipAfter.selected, isTrue);

    final homeChipAfter = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Home'));
    expect(homeChipAfter.selected, isFalse);
  });
}
