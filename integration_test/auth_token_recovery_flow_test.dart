import 'dart:async';

import 'package:atproto_core/atproto_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/feed/presentation/home_feed_screen.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_card_with_actions.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

class MockFeedPreferencesCubit extends MockCubit<FeedPreferencesState> implements FeedPreferencesCubit {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSavedPostsCubit extends MockCubit<SavedPostsState> implements SavedPostsCubit {}

class MockPostActionRepository extends Mock implements PostActionRepository {}

class _FakeFeedData {
  _FakeFeedData({required this.feed, this.cursor});

  final List<FeedViewPost> feed;
  final String? cursor;
}

class _FakeFeedResponse {
  _FakeFeedResponse(this.data);

  final _FakeFeedData data;
}

class _HandlerFeedApi {
  _HandlerFeedApi({required this.getTimelineHandler});

  final Future<_FakeFeedResponse> Function({String? cursor, int? limit, Map<String, String>? headers})
  getTimelineHandler;

  Future<_FakeFeedResponse> getTimeline({String? cursor, int? limit, Map<String, String>? $headers}) {
    return getTimelineHandler(cursor: cursor, limit: limit, headers: $headers);
  }
}

class _FakeBluesky {
  _FakeBluesky(this.feed);

  final dynamic feed;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const homeFeedState = FeedPreferencesState.loaded(
    feeds: [
      SavedFeed(
        id: 'timeline',
        type: SavedFeedType.knownValue(data: KnownSavedFeedType.timeline),
        value: 'timeline',
        pinned: true,
      ),
    ],
  );

  SettingsState settingsState(FeedLayout architecture) => SettingsState(
    themePalette: AppThemePalette.oxocarbon,
    themeVariant: AppThemeVariant.dark,
    useSystemTheme: false,
    feedLayout: architecture,
  );

  testWidgets('home feed recovers from expired token unauthorized response', (tester) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final feedPreferencesCubit = MockFeedPreferencesCubit();
    final connectivityCubit = MockConnectivityCubit();
    final settingsCubit = MockSettingsCubit();
    final authBloc = MockAuthBloc();
    final savedPostsCubit = MockSavedPostsCubit();
    final postActionRepository = MockPostActionRepository();

    when(() => feedPreferencesCubit.state).thenReturn(homeFeedState);
    whenListen(feedPreferencesCubit, const Stream<FeedPreferencesState>.empty(), initialState: homeFeedState);

    when(() => connectivityCubit.state).thenReturn(const ConnectivityState.online());
    whenListen(
      connectivityCubit,
      const Stream<ConnectivityState>.empty(),
      initialState: const ConnectivityState.online(),
    );

    when(() => settingsCubit.state).thenReturn(settingsState(FeedLayout.card));
    whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: settingsState(FeedLayout.card));

    const authState = AuthState.authenticated(
      AuthTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        did: 'did:plc:test',
        handle: 'test.bsky.social',
      ),
    );
    when(() => authBloc.state).thenReturn(authState);
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: authState);

    const savedPostsState = SavedPostsState(status: SavedPostsStatus.loaded);
    when(() => savedPostsCubit.state).thenReturn(savedPostsState);
    whenListen(savedPostsCubit, const Stream<SavedPostsState>.empty(), initialState: savedPostsState);

    var primaryTimelineCalls = 0;
    var fallbackTimelineCalls = 0;
    var authRecoveryCalls = 0;

    final primaryFeedApi = _HandlerFeedApi(
      getTimelineHandler: ({String? cursor, int? limit, Map<String, String>? headers}) async {
        primaryTimelineCalls += 1;
        throw _unauthorizedException('app.bsky.feed.getTimeline');
      },
    );

    final fallbackFeedApi = _HandlerFeedApi(
      getTimelineHandler: ({String? cursor, int? limit, Map<String, String>? headers}) async {
        fallbackTimelineCalls += 1;
        return _FakeFeedResponse(_FakeFeedData(feed: [_post(1)], cursor: null));
      },
    );

    final repository = FeedRepository(
      bluesky: _FakeBluesky(primaryFeedApi),
      database: database,
      accountDid: 'did:plc:test',
      onUnauthorized: () async {
        authRecoveryCalls += 1;
        return _freshTokens();
      },
      blueskyClientFactory: (_) => _FakeBluesky(fallbackFeedApi),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<FeedRepository>.value(value: repository),
            RepositoryProvider<PostActionRepository>.value(value: postActionRepository),
            RepositoryProvider<PostActionCache>(create: (_) => PostActionCache()),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<SettingsCubit>.value(value: settingsCubit),
              BlocProvider<FeedPreferencesCubit>.value(value: feedPreferencesCubit),
              BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
              BlocProvider<SavedPostsCubit>.value(value: savedPostsCubit),
            ],
            child: const HomeFeedScreen(),
          ),
        ),
      ),
    );

    await tester.pump();

    await _pumpUntil(
      tester,
      condition: () => find.byType(PostCardWithActions).evaluate().isNotEmpty,
      timeout: const Duration(seconds: 5),
    );

    expect(primaryTimelineCalls, 1);
    expect(authRecoveryCalls, 1);
    expect(fallbackTimelineCalls, 1);
    expect(find.byType(PostCardWithActions), findsOneWidget);
    expect(find.textContaining('Failed to load feed'), findsNothing);
  });
}

Future<void> _pumpUntil(
  WidgetTester tester, {
  required bool Function() condition,
  Duration timeout = const Duration(seconds: 3),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for condition in integration test');
    }
    await tester.pump(const Duration(milliseconds: 50));
  }
}

FeedViewPost _post(int index) {
  final timestamp = DateTime.utc(2026, 5, 4, 12).subtract(Duration(minutes: index));
  final did = 'did:plc:author$index';
  return FeedViewPost(
    post: PostView(
      uri: AtUri('at://$did/app.bsky.feed.post/$index'),
      cid: 'cid-$index',
      author: ProfileViewBasic(did: did, handle: 'author$index.bsky.social'),
      record: {
        r'$type': 'app.bsky.feed.post',
        'text': 'Recovered post $index',
        'createdAt': timestamp.toIso8601String(),
      },
      indexedAt: timestamp,
    ),
  );
}

AuthTokens _freshTokens() {
  final now = DateTime.now().toUtc();
  return AuthTokens(
    accessToken: 'fresh-access-token',
    refreshToken: 'fresh-refresh-token',
    expiresAt: now.add(const Duration(hours: 1)),
    did: 'did:plc:test',
    handle: 'test.bsky.social',
    service: 'bsky.social',
  );
}

UnauthorizedException _unauthorizedException(String methodId) {
  return UnauthorizedException(
    XRPCResponse(
      headers: const {},
      status: HttpStatus.unauthorized,
      request: XRPCRequest(method: HttpMethod.get, url: Uri.https('bsky.social', '/xrpc/$methodId')),
      rateLimit: RateLimit.unlimited(),
      data: const XRPCError(error: 'Unauthorized', message: 'exp claim timestamp check failed'),
    ),
  );
}
