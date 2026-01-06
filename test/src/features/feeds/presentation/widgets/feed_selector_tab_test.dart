import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_cleanup_controller.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/application/feed_sync_controller.dart';
import 'package:lazurite/src/features/feeds/application/sync_status_provider.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/feed_selector_tab.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:mocktail/mocktail.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockPinnedFeedsNotifier extends PinnedFeedsNotifier {
  MockPinnedFeedsNotifier(this._initialData);
  final List<SavedFeedData> _initialData;

  @override
  Stream<List<SavedFeedData>> build() {
    return Stream.value(_initialData);
  }
}

/// Fake AuthNotifier for testing.
class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier({required this.authenticated});

  final bool authenticated;

  @override
  AuthState build() {
    if (authenticated) {
      return AuthState.authenticated(
        Session(
          did: 'did:plc:test',
          handle: 'test.bsky.social',
          accessJwt: 'test-access',
          refreshJwt: 'test-refresh',
          pdsUrl: 'https://bsky.social',
          dpopKey: {'test': 'test'},
          scope: 'test',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        ),
      );
    }
    return const AuthState.unauthenticated();
  }
}

void main() {
  testWidgets('FeedSelectorTab displays feeds for authenticated users', (tester) async {
    final mockDatabase = MockAppDatabase();

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
        overrides: [
          pinnedFeedsProvider.overrideWith(() => MockPinnedFeedsNotifier(kFeeds)),
          appDatabaseProvider.overrideWithValue(mockDatabase),
          feedSyncControllerProvider.overrideWith((ref) {}),
          feedContentCleanupControllerProvider.overrideWith((ref) {}),
          hasPendingSyncProvider.overrideWith((ref) => Stream.value(false)),
          authProvider.overrideWith(() => FakeAuthNotifier(authenticated: true)),
        ],
        child: const MaterialApp(home: Scaffold(body: FeedSelectorTab())),
      ),
    );

    await tester.pump();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);

    final homeChip = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Home'));
    expect(homeChip.selected, isTrue);

    final discoverChip = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Discover'));
    expect(discoverChip.selected, isFalse);

    await tester.tap(find.text('Discover'));
    await tester.pump();

    final discoverChipAfter = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Discover'),
    );
    expect(discoverChipAfter.selected, isTrue);

    final homeChipAfter = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Home'));
    expect(homeChipAfter.selected, isFalse);
  });

  testWidgets('FeedSelectorTab shows only Discover for unauthenticated users', (tester) async {
    final mockDatabase = MockAppDatabase();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(mockDatabase),
          authProvider.overrideWith(() => FakeAuthNotifier(authenticated: false)),
        ],
        child: const MaterialApp(home: Scaffold(body: FeedSelectorTab())),
      ),
    );

    await tester.pump();

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.byIcon(Icons.tune), findsNothing);
  });
}
