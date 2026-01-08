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
import 'package:lazurite/src/features/feeds/presentation/screens/feed_management_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/mocks.dart';

class MockAllFeedsNotifier extends AllFeedsNotifier {
  MockAllFeedsNotifier(this._initialData);

  final List<SavedFeedData> _initialData;

  @override
  Stream<List<SavedFeedData>> build() {
    return Stream.value(_initialData);
  }
}

void main() {
  testWidgets('FeedManagementScreen lists saved feeds and allows actions', (tester) async {
    final mockRepository = MockFeedRepository();
    final mockDatabase = MockAppDatabase();
    final session = Session(
      did: 'did:web:test',
      handle: 'handle',
      pdsUrl: 'https://pds',
      accessJwt: 'access',
      refreshJwt: 'refresh',
      scope: 'scope',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      dpopKey: const <String, dynamic>{},
    );

    final kFeeds = [
      SavedFeedData(
        uri: 'at://did:1/feed/saved1',
        displayName: 'Saved 1',
        creatorDid: 'did:1',
        likeCount: 0,
        sortOrder: 0,
        isPinned: true,
        lastSynced: DateTime.now(),
      ),
      SavedFeedData(
        uri: 'at://did:1/feed/saved2',
        displayName: 'Saved 2',
        creatorDid: 'did:1',
        likeCount: 0,
        sortOrder: 1,
        isPinned: false,
        lastSynced: DateTime.now(),
      ),
    ];

    when(
      () => mockRepository.saveFeed(any(), any(), pin: any(named: 'pin')),
    ).thenAnswer((_) async => {});
    when(() => mockRepository.removeFeed(any(), any())).thenAnswer((_) async => {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allFeedsProvider.overrideWith(() => MockAllFeedsNotifier(kFeeds)),
          feedRepositoryProvider.overrideWithValue(mockRepository),
          appDatabaseProvider.overrideWithValue(mockDatabase),
          authProvider.overrideWith(() => _TestAuthNotifier(session)),
          feedSyncControllerProvider.overrideWith((ref) {}),
          feedContentCleanupControllerProvider.overrideWith((ref) {}),
          hasPendingSyncProvider.overrideWith((ref) => Stream.value(false)),
        ],
        child: const MaterialApp(home: FeedManagementScreen()),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Saved 1'), findsOneWidget);
    expect(find.text('Pinned'), findsOneWidget);
    expect(find.text('Saved 2'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);

    await tester.tap(find.widgetWithIcon(IconButton, Icons.push_pin).first);
    verify(
      () => mockRepository.saveFeed('at://did:1/feed/saved1', session.did, pin: false),
    ).called(1);

    final deleteButtons = find.widgetWithIcon(IconButton, Icons.delete_outline);
    await tester.tap(deleteButtons.last);

    verify(() => mockRepository.removeFeed('at://did:1/feed/saved2', session.did)).called(1);
  });

  testWidgets('FeedManagementScreen renders drag handles for reordering', (tester) async {
    final mockRepository = MockFeedRepository();
    final mockDatabase = MockAppDatabase();
    final session = Session(
      did: 'did:web:test',
      handle: 'handle',
      pdsUrl: 'https://pds',
      accessJwt: 'access',
      refreshJwt: 'refresh',
      scope: 'scope',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      dpopKey: const <String, dynamic>{},
    );

    final kFeeds = [
      SavedFeedData(
        uri: 'at://did:1/feed/saved1',
        displayName: 'Feed 1',
        creatorDid: 'did:1',
        likeCount: 0,
        sortOrder: 0,
        isPinned: false,
        lastSynced: DateTime.now(),
      ),
      SavedFeedData(
        uri: 'at://did:1/feed/saved2',
        displayName: 'Feed 2',
        creatorDid: 'did:1',
        likeCount: 0,
        sortOrder: 1,
        isPinned: false,
        lastSynced: DateTime.now(),
      ),
    ];

    when(
      () => mockRepository.saveFeed(any(), any(), pin: any(named: 'pin')),
    ).thenAnswer((_) async => {});
    when(() => mockRepository.removeFeed(any(), any())).thenAnswer((_) async => {});
    when(() => mockRepository.reorderFeeds(any(), any())).thenAnswer((_) async => {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allFeedsProvider.overrideWith(() => MockAllFeedsNotifier(kFeeds)),
          feedRepositoryProvider.overrideWithValue(mockRepository),
          appDatabaseProvider.overrideWithValue(mockDatabase),
          authProvider.overrideWith(() => _TestAuthNotifier(session)),
          feedSyncControllerProvider.overrideWith((ref) {}),
          feedContentCleanupControllerProvider.overrideWith((ref) {}),
          hasPendingSyncProvider.overrideWith((ref) => Stream.value(false)),
        ],
        child: const MaterialApp(home: FeedManagementScreen()),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
    expect(find.byType(ListTile), findsNWidgets(2));
  });
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._session);

  final Session _session;

  @override
  AuthState build() => AuthState.authenticated(_session);
}
