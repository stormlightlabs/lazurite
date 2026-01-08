import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_notifier.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_providers.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_content_repository.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_repository.dart';
import 'package:lazurite/src/features/settings/application/muted_word_filter_provider.dart';
import 'package:lazurite/src/features/settings/application/settings_providers.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockFeedContentRepository mockRepository;
  late MockLogger mockLogger;

  ProviderContainer createContainer({bool authenticated = true}) {
    return ProviderContainer(
      overrides: [
        feedContentRepositoryProvider.overrideWithValue(mockRepository),
        loggerProvider('FeedContentNotifier').overrideWithValue(mockLogger),
        mutedWordFilterServiceProvider.overrideWith((ref) => null),
        feedViewPrefProvider.overrideWith((ref) => Stream.value(FeedViewPref.defaultPref)),
        authProvider.overrideWith(() => _FakeAuthNotifier(authenticated: authenticated)),
      ],
    );
  }

  setUp(() {
    mockRepository = MockFeedContentRepository();
    mockLogger = MockLogger();

    when(() => mockLogger.debug(any(), any())).thenReturn(null);

    registerFallbackValue('');
    when(
      () => mockRepository.watchFeedContent(
        feedKey: any(named: 'feedKey'),
        ownerDid: any(named: 'ownerDid'),
      ),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => mockRepository.fetchAndCacheFeed(
        cursor: any(named: 'cursor'),
        feedUri: any(named: 'feedUri'),
        ownerDid: any(named: 'ownerDid'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockRepository.getCursor(any(), any())).thenAnswer((_) async => null);
    when(() => mockRepository.clearFeedContent(any(), any())).thenAnswer((_) async {});
  });

  group('FeedContentNotifier', () {
    test('build watches home feed content when instantiated with home URI', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      const feedUri = FeedRepository.kHomeFeedUri;
      container.read(feedContentProvider(feedUri));

      await Future.delayed(Duration.zero);

      verify(
        () => mockRepository.watchFeedContent(
          feedKey: FeedContentRepository.kInternalHomeFeedKey,
          ownerDid: any(named: 'ownerDid'),
        ),
      ).called(1);
    });

    test('build watches specific feed content when instantiated with custom URI', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      const feedUri = 'at://did:example:123/app.bsky.feed.generator/custom';

      when(
        () => mockRepository.watchFeedContent(
          feedKey: feedUri,
          ownerDid: any(named: 'ownerDid'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      container.read(feedContentProvider(feedUri));

      await Future.delayed(Duration.zero);

      verify(
        () => mockRepository.watchFeedContent(
          feedKey: feedUri,
          ownerDid: any(named: 'ownerDid'),
        ),
      ).called(1);
    });

    test('build maps following feed to internal home key', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      const feedUri = FeedRepository.kFollowingFeedUri;
      container.read(feedContentProvider(feedUri));

      await Future.delayed(Duration.zero);

      verify(
        () => mockRepository.watchFeedContent(
          feedKey: FeedContentRepository.kInternalHomeFeedKey,
          ownerDid: any(named: 'ownerDid'),
        ),
      ).called(1);
    });

    test('refresh calls fetchAndCacheFeed with correct key for home feed', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      const feedUri = FeedRepository.kHomeFeedUri;
      when(
        () => mockRepository.fetchAndCacheFeed(feedUri: null, ownerDid: any(named: 'ownerDid')),
      ).thenAnswer((_) async {});

      await container.read(feedContentProvider(feedUri).notifier).refresh();

      verify(
        () => mockRepository.fetchAndCacheFeed(feedUri: null, ownerDid: any(named: 'ownerDid')),
      ).called(1);
    });

    test('refresh calls fetchAndCacheFeed with correct key for custom feed', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      const feedUri = 'at://did:example:123/app.bsky.feed.generator/custom';

      when(
        () => mockRepository.watchFeedContent(
          feedKey: feedUri,
          ownerDid: any(named: 'ownerDid'),
        ),
      ).thenAnswer((_) => Stream.value([]));
      when(
        () => mockRepository.fetchAndCacheFeed(
          feedUri: feedUri,
          ownerDid: any(named: 'ownerDid'),
        ),
      ).thenAnswer((_) async {});

      await container.read(feedContentProvider(feedUri).notifier).refresh();

      verify(
        () => mockRepository.fetchAndCacheFeed(
          feedUri: feedUri,
          ownerDid: any(named: 'ownerDid'),
        ),
      ).called(1);
    });

    test('loadMore fetches next page using cursor', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      const feedUri = FeedRepository.kHomeFeedUri;

      when(
        () => mockRepository.getCursor(FeedContentRepository.kInternalHomeFeedKey, any()),
      ).thenAnswer((_) async => 'next_cursor');
      when(
        () => mockRepository.fetchAndCacheFeed(
          cursor: 'next_cursor',
          feedUri: null,
          ownerDid: any(named: 'ownerDid'),
        ),
      ).thenAnswer((_) async {});

      await container.read(feedContentProvider(feedUri).notifier).loadMore();

      verify(
        () => mockRepository.getCursor(FeedContentRepository.kInternalHomeFeedKey, any()),
      ).called(1);
      verify(
        () => mockRepository.fetchAndCacheFeed(
          cursor: 'next_cursor',
          feedUri: null,
          ownerDid: any(named: 'ownerDid'),
        ),
      ).called(1);
    });

    test('loadMore does nothing if no cursor found', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      const feedUri = FeedRepository.kHomeFeedUri;

      when(
        () => mockRepository.getCursor(FeedContentRepository.kInternalHomeFeedKey, any()),
      ).thenAnswer((_) async => null);

      await container.read(feedContentProvider(feedUri).notifier).loadMore();

      verify(
        () => mockRepository.getCursor(FeedContentRepository.kInternalHomeFeedKey, any()),
      ).called(1);
      verifyNever(
        () => mockRepository.fetchAndCacheFeed(
          cursor: any(named: 'cursor'),
          feedUri: any(named: 'feedUri'),
          ownerDid: any(named: 'ownerDid'),
        ),
      );
    });

    test('clearFeedContent calls repository clearFeedContent', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      const feedUri = FeedRepository.kHomeFeedUri;

      when(
        () => mockRepository.clearFeedContent(FeedContentRepository.kInternalHomeFeedKey, any()),
      ).thenAnswer((_) async {});

      await container.read(feedContentProvider(feedUri).notifier).clearFeedContent();

      verify(
        () => mockRepository.clearFeedContent(FeedContentRepository.kInternalHomeFeedKey, any()),
      ).called(1);
    });

    test('refresh skips timeline feeds when unauthenticated', () async {
      final container = createContainer(authenticated: false);
      addTearDown(container.dispose);

      const feedUri = FeedRepository.kFollowingFeedUri;
      await container.read(feedContentProvider(feedUri).notifier).refresh();

      verifyNever(
        () => mockRepository.fetchAndCacheFeed(
          cursor: any(named: 'cursor'),
          feedUri: any(named: 'feedUri'),
          ownerDid: any(named: 'ownerDid'),
        ),
      );
    });
  });
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier({required this.authenticated});

  final bool authenticated;

  @override
  AuthState build() {
    if (authenticated) {
      return AuthState.authenticated(
        Session(
          did: 'did:plc:test',
          scope: 'test',
          handle: 'test.bsky.social',
          accessJwt: 'access',
          refreshJwt: 'refresh',
          pdsUrl: 'https://bsky.social',
          dpopKey: {'kty': 'OKP'},
          expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        ),
      );
    }

    return const AuthState.unauthenticated();
  }
}
