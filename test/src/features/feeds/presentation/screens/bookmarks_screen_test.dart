import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_providers.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_content_repository.dart';
import 'package:lazurite/src/features/feeds/presentation/screens/bookmarks_screen.dart';
import 'package:lazurite/src/features/settings/application/muted_word_filter_provider.dart';
import 'package:lazurite/src/features/settings/application/settings_providers.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/mocks.dart';

class MockFeedContentRepository extends Mock implements FeedContentRepository {}

void main() {
  const ownerDid = 'did:plc:test';
  late MockFeedContentRepository mockRepository;
  late MockLogger mockLogger;

  setUpAll(() {
    registerFallbackValue('');
    registerFallbackValue(const Offset(0, 0));
  });

  setUp(() {
    mockRepository = MockFeedContentRepository();
    mockLogger = MockLogger();

    when(() => mockLogger.debug(any(), any())).thenReturn(null);
    when(() => mockLogger.info(any(), any())).thenReturn(null);
    when(() => mockLogger.error(any(), any(), any())).thenReturn(null);
    when(() => mockRepository.getCursor(any(), any())).thenAnswer((_) async => null);
    when(
      () => mockRepository.fetchAndCacheFeed(
        cursor: any(named: 'cursor'),
        feedUri: any(named: 'feedUri'),
        ownerDid: any(named: 'ownerDid'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockRepository.cleanupCache(any())).thenAnswer((_) async {});
  });

  Widget buildSubject() {
    return ProviderScope(
      overrides: [
        feedContentRepositoryProvider.overrideWithValue(mockRepository),
        authProvider.overrideWith(() => _FakeAuthNotifier(ownerDid: ownerDid)),
        feedViewPrefProvider.overrideWith((ref) => Stream.value(FeedViewPref.defaultPref)),
        mutedWordFilterServiceProvider.overrideWith((ref) => null),
        loggerProvider('FeedContentNotifier').overrideWithValue(mockLogger),
        loggerProvider('BookmarksScreen').overrideWithValue(mockLogger),
      ],
      child: const MaterialApp(home: BookmarksScreen()),
    );
  }

  testWidgets('BookmarksScreen renders list of bookmarks', (tester) async {
    final bookmarks = [
      FeedPost(
        post: const Post(
          uri: 'at://test/post/1',
          cid: 'cid1',
          authorDid: 'did:plc:author',
          record: '{"text": "Hello Bookmark"}',
          indexedAt: null,
          replyCount: 0,
          repostCount: 0,
          likeCount: 0,
          quoteCount: 0,
          bookmarkCount: 0,
          viewerBookmarked: true,
          viewerThreadMuted: false,
          viewerReplyDisabled: false,
        ),
        author: const Profile(did: 'did:plc:author', handle: 'author'),
      ),
    ];

    when(
      () => mockRepository.watchFeedContent(
        feedKey: any(named: 'feedKey'),
        ownerDid: any(named: 'ownerDid'),
      ),
    ).thenAnswer((_) => Stream.value(bookmarks));

    when(
      () => mockRepository.fetchBookmarks(ownerDid: any(named: 'ownerDid')),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Bookmarks'), findsOneWidget);
    expect(find.text('Hello Bookmark'), findsOneWidget);

    verify(() => mockRepository.fetchBookmarks(ownerDid: ownerDid)).called(1);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier({required this.ownerDid});

  final String ownerDid;

  @override
  AuthState build() {
    return AuthState.authenticated(
      Session(
        did: ownerDid,
        handle: 'test.handle',
        pdsUrl: 'https://bsky.social',
        accessJwt: 'jwt',
        refreshJwt: 'refresh',
        scope: 'test',
        dpopKey: const {'kty': 'OKP'},
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
  }
}
