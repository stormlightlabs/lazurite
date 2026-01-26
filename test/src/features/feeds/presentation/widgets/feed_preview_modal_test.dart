import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_providers.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/feed_preview_modal.dart';
import 'package:lazurite/src/features/settings/application/label_filter_provider.dart';
import 'package:lazurite/src/features/settings/application/muted_word_filter_provider.dart';
import 'package:lazurite/src/features/settings/application/settings_providers.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/mocks.dart';

void main() {
  const ownerDid = 'did:web:tester';
  late MockFeedRepository mockFeedRepository;
  late MockFeedContentRepository mockFeedContentRepository;
  late Session testSession;

  setUp(() {
    mockFeedRepository = MockFeedRepository();
    mockFeedContentRepository = MockFeedContentRepository();
    testSession = Session(
      did: ownerDid,
      handle: 'handle',
      pdsUrl: 'https://pds',
      accessJwt: 'access',
      refreshJwt: 'refresh',
      scope: 'scope',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      dpopKey: const <String, dynamic>{},
    );
  });

  testWidgets('FeedPreviewModal displays info and posts', (tester) async {
    const feedUri = 'at://did:1/feed/test';
    const displayName = 'Test Feed';
    const description = 'A test feed description';

    final posts = [
      FeedPost(
        post: Post(
          uri: 'at://did:2/app.bsky.feed.post/1',
          cid: 'cid1',
          authorDid: 'did:2',
          record: '{}',
          indexedAt: DateTime.now(),
          replyCount: 0,
          repostCount: 0,
          likeCount: 0,
          quoteCount: 0,
          bookmarkCount: 0,
          viewerBookmarked: false,
          viewerThreadMuted: false,
          viewerReplyDisabled: false,
        ),
        author: const Profile(did: 'did:2', handle: 'handle2', displayName: 'Author 2'),
        reason: null,
      ),
    ];

    when(
      () => mockFeedContentRepository.watchFeedContent(
        feedKey: any(named: 'feedKey'),
        ownerDid: ownerDid,
      ),
    ).thenAnswer((_) => Stream.value(posts));
    when(
      () => mockFeedContentRepository.fetchAndCacheFeed(feedUri: feedUri, ownerDid: ownerDid),
    ).thenAnswer((_) async {});
    when(() => mockFeedRepository.watchAllFeeds(ownerDid)).thenAnswer((_) => Stream.value([]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedRepositoryProvider.overrideWithValue(mockFeedRepository),
          feedContentRepositoryProvider.overrideWithValue(mockFeedContentRepository),
          authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
          labelFilterServiceProvider.overrideWith((ref) => null),
          mutedWordFilterServiceProvider.overrideWith((ref) => null),
          feedViewPrefProvider.overrideWith((ref) => Stream.value(FeedViewPref.defaultPref)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: FeedPreviewModal(
              feedUri: feedUri,
              displayName: displayName,
              description: description,
              creatorHandle: 'creator',
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(displayName), findsOneWidget);
    expect(find.text(description), findsOneWidget);
    expect(find.text('@creator'), findsOneWidget);
    expect(find.text('Author 2'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('Save button in FeedPreviewModal calls repository', (tester) async {
    const feedUri = 'at://did:1/feed/test';

    when(
      () => mockFeedContentRepository.watchFeedContent(
        feedKey: any(named: 'feedKey'),
        ownerDid: ownerDid,
      ),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => mockFeedContentRepository.fetchAndCacheFeed(feedUri: feedUri, ownerDid: ownerDid),
    ).thenAnswer((_) async {});
    when(() => mockFeedRepository.watchAllFeeds(ownerDid)).thenAnswer((_) => Stream.value([]));
    when(
      () => mockFeedRepository.saveFeed(any(), ownerDid, pin: any(named: 'pin')),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedRepositoryProvider.overrideWithValue(mockFeedRepository),
          feedContentRepositoryProvider.overrideWithValue(mockFeedContentRepository),
          authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
          labelFilterServiceProvider.overrideWith((ref) => null),
          mutedWordFilterServiceProvider.overrideWith((ref) => null),
          feedViewPrefProvider.overrideWith((ref) => Stream.value(FeedViewPref.defaultPref)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: FeedPreviewModal(feedUri: feedUri, displayName: 'Test'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Save'));
    await tester.pump();

    verify(() => mockFeedRepository.saveFeed(feedUri, ownerDid, pin: false)).called(1);
  });
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._session);

  final Session _session;

  @override
  AuthState build() => AuthState.authenticated(_session);
}
