import 'dart:async';

import 'package:atproto_core/atproto_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_post.dart' hide ReplyRef;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_layout.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/compose/presentation/compose_route_args.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/profile/presentation/profile_screen.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/shared/presentation/widgets/app_screen_entrance.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState> implements ProfileBloc {}

class MockFeedBloc extends MockBloc<FeedEvent, FeedState> implements FeedBloc {}

class MockProfileActionRepository extends Mock implements ProfileActionRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

class MockPostActionRepository extends Mock implements PostActionRepository {}

class MockSavedPostsCubit extends MockCubit<SavedPostsState> implements SavedPostsCubit {}

class MockPostActionCache extends Mock implements PostActionCache {}

class MockListRepository extends Mock implements ListRepository {}

void main() {
  late MockAuthBloc authBloc;
  late MockProfileBloc profileBloc;
  late MockFeedBloc feedBloc;
  late MockSettingsCubit settingsCubit;
  late MockConnectivityCubit connectivityCubit;
  late MockProfileRepository profileRepository;

  const tokens = AuthTokens(
    accessToken: 'access',
    refreshToken: 'refresh',
    did: 'did:plc:me',
    handle: 'me.bsky.social',
  );

  final profile = ProfileViewDetailed(
    did: 'did:plc:me',
    handle: 'me.bsky.social',
    displayName: 'River Tam',
    description: 'Signal and signal boost.',
    pronouns: 'she/her',
    website: 'river.example',
    followersCount: 1200,
    followsCount: 64,
    postsCount: 512,
    createdAt: DateTime.utc(2024, 3, 1),
  );

  SettingsState defaultSettingsState() => const SettingsState(
    themePalette: AppThemePalette.oxocarbon,
    themeVariant: AppThemeVariant.dark,
    useSystemTheme: false,
    feedLayout: FeedLayout.card,
  );

  SettingsState settingsStateWith(FeedLayout architecture) => SettingsState(
    themePalette: AppThemePalette.oxocarbon,
    themeVariant: AppThemeVariant.dark,
    useSystemTheme: false,
    feedLayout: architecture,
  );

  setUp(() {
    authBloc = MockAuthBloc();
    profileBloc = MockProfileBloc();
    feedBloc = MockFeedBloc();
    settingsCubit = MockSettingsCubit();
    connectivityCubit = MockConnectivityCubit();
    profileRepository = MockProfileRepository();

    when(() => authBloc.state).thenReturn(const AuthState.authenticated(tokens));
    when(() => profileBloc.state).thenReturn(ProfileState.loaded(profile: profile));
    when(() => feedBloc.state).thenReturn(
      const FeedState.loaded(actor: 'did:plc:me', posts: [], filter: FeedFilter.postsNoReplies, hasMore: false),
    );
    when(() => settingsCubit.state).thenReturn(defaultSettingsState());
    when(() => connectivityCubit.state).thenReturn(const ConnectivityState.online());

    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.authenticated(tokens));
    whenListen(profileBloc, const Stream<ProfileState>.empty(), initialState: ProfileState.loaded(profile: profile));
    whenListen(
      feedBloc,
      const Stream<FeedState>.empty(),
      initialState: const FeedState.loaded(
        actor: 'did:plc:me',
        posts: [],
        filter: FeedFilter.postsNoReplies,
        hasMore: false,
      ),
    );
    whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: defaultSettingsState());
    whenListen(
      connectivityCubit,
      const Stream<ConnectivityState>.empty(),
      initialState: const ConnectivityState.online(),
    );
  });

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<ProfileBloc>.value(value: profileBloc),
        BlocProvider<FeedBloc>.value(value: feedBloc),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
        BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
      ],
      child: const MaterialApp(home: ProfileScreen()),
    );
  }

  /// Sets the test viewport to a tall size so that the full profile header
  /// (cover + summary + tab bar) fits within the viewport.
  void useLargeScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('loads posts filter by default and renders the required profile fields', (tester) async {
    useLargeScreen(tester);
    await tester.pumpWidget(buildSubject());

    expect(find.byType(AppScreenEntrance), findsOneWidget);
    verify(() => profileBloc.add(const ProfileLoadRequested(actor: 'did:plc:me'))).called(1);
    verify(
      () => feedBloc.add(const FeedLoadRequested(actor: 'did:plc:me', filter: FeedFilter.postsNoReplies)),
    ).called(1);

    expect(find.text('RIVER TAM'), findsOneWidget);
    expect(find.text('@me.bsky.social'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText().contains('Signal and signal boost.'),
      ),
      findsOneWidget,
    );
    expect(find.text('she/her'), findsOneWidget);
    expect(find.text('river.example'), findsOneWidget);
    expect(find.text('Joined March 2024'), findsOneWidget);
  });

  testWidgets('app bar always shows the profile display name', (tester) async {
    useLargeScreen(tester);
    await tester.pumpWidget(buildSubject());

    expect(find.text('River Tam'), findsOneWidget);
  });

  testWidgets('shows separate Bookmarks and Liked buttons on own profile', (tester) async {
    useLargeScreen(tester);
    await tester.pumpWidget(buildSubject());

    expect(find.text('Bookmarks'), findsOneWidget);
    expect(find.text('Liked'), findsOneWidget);
  });

  testWidgets('tapping following stat opens connections screen on following tab', (tester) async {
    useLargeScreen(tester);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<ProfileBloc>.value(value: profileBloc),
              BlocProvider<FeedBloc>.value(value: feedBloc),
              BlocProvider<SettingsCubit>.value(value: settingsCubit),
              BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
            ],
            child: const ProfileScreen(),
          ),
        ),
        GoRoute(
          path: '/profile/:actor/connections',
          builder: (context, state) =>
              Scaffold(body: Text([state.uri.queryParameters['tab'], state.pathParameters['actor']].join(' '))),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('profile_following_stat')));
    await tester.pumpAndSettle();

    expect(find.text('following me.bsky.social'), findsOneWidget);

    router.dispose();
  });

  testWidgets('does not show Bookmarks/Liked buttons on other profiles', (tester) async {
    useLargeScreen(tester);
    const otherProfile = ProfileViewDetailed(
      did: 'did:plc:other',
      handle: 'other.bsky.social',
      displayName: 'Other User',
    );
    when(() => profileBloc.state).thenReturn(const ProfileState.loaded(profile: otherProfile));
    whenListen(
      profileBloc,
      const Stream<ProfileState>.empty(),
      initialState: const ProfileState.loaded(profile: otherProfile),
    );

    final mockProfileActionRepository = MockProfileActionRepository();

    final widget = MultiRepositoryProvider(
      providers: [RepositoryProvider<ProfileActionRepository>.value(value: mockProfileActionRepository)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<ProfileBloc>.value(value: profileBloc),
          BlocProvider<FeedBloc>.value(value: feedBloc),
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
          BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
        ],
        child: const MaterialApp(home: ProfileScreen(actor: 'did:plc:other', showBackButton: true)),
      ),
    );

    await tester.pumpWidget(widget);

    expect(find.text('Bookmarks'), findsNothing);
    expect(find.text('Liked'), findsNothing);
  });

  testWidgets('maps tabs to the expected server filters', (tester) async {
    useLargeScreen(tester);
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('REPLIES'));
    await tester.pump();

    verify(
      () => feedBloc.add(const FeedLoadRequested(actor: 'did:plc:me', filter: FeedFilter.postsWithReplies)),
    ).called(1);

    await tester.tap(find.text('MEDIA'));
    await tester.pump();

    verify(
      () => feedBloc.add(const FeedLoadRequested(actor: 'did:plc:me', filter: FeedFilter.postsWithMedia)),
    ).called(1);
  });

  testWidgets('switching feed tabs does not trigger an extra profile reload', (tester) async {
    useLargeScreen(tester);
    await tester.pumpWidget(buildSubject());

    verify(() => profileBloc.add(const ProfileLoadRequested(actor: 'did:plc:me'))).called(1);

    await tester.tap(find.text('REPLIES'));
    await tester.pump();
    await tester.tap(find.text('QUOTES'));
    await tester.pump();
    await tester.tap(find.text('REPOSTS'));
    await tester.pump();

    verifyNever(() => profileBloc.add(const ProfileLoadRequested(actor: 'did:plc:me')));
  });

  testWidgets('other profiles show a suggested follows tab with loaded suggestions', (tester) async {
    useLargeScreen(tester);
    const otherProfile = ProfileViewDetailed(
      did: 'did:plc:other',
      handle: 'other.bsky.social',
      displayName: 'Other User',
    );
    final suggestions = [
      const ProfileView(did: 'did:plc:suggested', handle: 'suggested.bsky.social', displayName: 'Suggested User'),
    ];
    final mockProfileActionRepository = MockProfileActionRepository();

    when(() => profileBloc.state).thenReturn(const ProfileState.loaded(profile: otherProfile));
    whenListen(
      profileBloc,
      const Stream<ProfileState>.empty(),
      initialState: const ProfileState.loaded(profile: otherProfile),
    );
    when(() => feedBloc.state).thenReturn(
      const FeedState.loaded(actor: 'did:plc:other', posts: [], filter: FeedFilter.postsNoReplies, hasMore: false),
    );
    whenListen(
      feedBloc,
      const Stream<FeedState>.empty(),
      initialState: const FeedState.loaded(
        actor: 'did:plc:other',
        posts: [],
        filter: FeedFilter.postsNoReplies,
        hasMore: false,
      ),
    );
    when(() => profileRepository.getSuggestedFollows('did:plc:other')).thenAnswer((_) async => suggestions);

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ProfileRepository>.value(value: profileRepository),
          RepositoryProvider<ProfileActionRepository>.value(value: mockProfileActionRepository),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<ProfileBloc>.value(value: profileBloc),
            BlocProvider<FeedBloc>.value(value: feedBloc),
            BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
          ],
          child: const MaterialApp(home: ProfileScreen(actor: 'did:plc:other', showBackButton: true)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SUGGESTED'), findsOneWidget);
    expect(find.text('LIKED'), findsOneWidget);

    await tester.ensureVisible(find.text('SUGGESTED'));
    await tester.tap(find.text('SUGGESTED'));
    await tester.pumpAndSettle();

    verify(() => profileRepository.getSuggestedFollows('did:plc:other')).called(1);
    expect(find.text('Suggested User'), findsOneWidget);
  });

  testWidgets('compose FAB on other profiles prefills the mentioned handle', (tester) async {
    useLargeScreen(tester);
    const otherProfile = ProfileViewDetailed(
      did: 'did:plc:other',
      handle: 'other.bsky.social',
      displayName: 'Other User',
    );
    when(() => profileBloc.state).thenReturn(const ProfileState.loaded(profile: otherProfile));
    whenListen(
      profileBloc,
      const Stream<ProfileState>.empty(),
      initialState: const ProfileState.loaded(profile: otherProfile),
    );
    when(() => feedBloc.state).thenReturn(
      const FeedState.loaded(actor: 'did:plc:other', posts: [], filter: FeedFilter.postsNoReplies, hasMore: false),
    );
    whenListen(
      feedBloc,
      const Stream<FeedState>.empty(),
      initialState: const FeedState.loaded(
        actor: 'did:plc:other',
        posts: [],
        filter: FeedFilter.postsNoReplies,
        hasMore: false,
      ),
    );
    final mockProfileActionRepository = MockProfileActionRepository();

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiRepositoryProvider(
            providers: [RepositoryProvider<ProfileActionRepository>.value(value: mockProfileActionRepository)],
            child: MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: authBloc),
                BlocProvider<ProfileBloc>.value(value: profileBloc),
                BlocProvider<FeedBloc>.value(value: feedBloc),
                BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
                BlocProvider<SettingsCubit>.value(value: settingsCubit),
              ],
              child: const ProfileScreen(actor: 'did:plc:other', showBackButton: true),
            ),
          ),
        ),
        GoRoute(
          path: '/compose',
          builder: (context, state) {
            final args = state.extra as ComposeRouteArgs?;
            return Scaffold(body: Text(args?.initialText ?? ''));
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('profile-jump-top-fab')), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-compose-fab')), findsOneWidget);
    expect(
      tester.widget<FloatingActionButton>(find.byKey(const ValueKey('profile-compose-fab'))).heroTag,
      'profile-compose-fab',
    );

    await tester.tap(find.byKey(const ValueKey('profile-compose-fab')));
    await tester.pumpAndSettle();

    expect(find.text('@other.bsky.social '), findsOneWidget);

    router.dispose();
  });

  group('Profile header', () {
    testWidgets('avatar is square (no CircleAvatar)', (tester) async {
      useLargeScreen(tester);
      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircleAvatar), findsNothing);
      expect(find.byKey(const ValueKey('profile_square_avatar')), findsOneWidget);
    });

    testWidgets('display name is rendered uppercase', (tester) async {
      useLargeScreen(tester);
      await tester.pumpWidget(buildSubject());

      expect(find.text('RIVER TAM'), findsOneWidget);
      expect(find.text('River Tam'), findsOneWidget);
    });

    testWidgets('handle is shown with @ prefix', (tester) async {
      useLargeScreen(tester);
      await tester.pumpWidget(buildSubject());

      expect(find.text('@me.bsky.social'), findsOneWidget);
    });

    testWidgets('bio is shown', (tester) async {
      useLargeScreen(tester);
      await tester.pumpWidget(buildSubject());
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RichText && widget.text.toPlainText().contains('Signal and signal boost.'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('stats row is rendered in a bordered container', (tester) async {
      useLargeScreen(tester);
      await tester.pumpWidget(buildSubject());
      expect(find.byKey(const ValueKey('profile_stats_row')), findsOneWidget);
    });

    testWidgets('does not render the profile info card in the feed', (tester) async {
      useLargeScreen(tester);
      await tester.pumpWidget(buildSubject());

      expect(find.byKey(const ValueKey('profile_info_card')), findsNothing);
    });

    testWidgets('stat values are shown as formatted counts', (tester) async {
      useLargeScreen(tester);
      await tester.pumpWidget(buildSubject());

      expect(find.text('1.2K'), findsWidgets);
      expect(find.text('64'), findsOneWidget);
    });

    testWidgets('stat labels are uppercase', (tester) async {
      useLargeScreen(tester);
      await tester.pumpWidget(buildSubject());

      expect(find.text('FOLLOWING'), findsOneWidget);
      expect(find.text('FOLLOWERS'), findsOneWidget);
      expect(find.text('POSTS'), findsAtLeastNWidgets(1));
    });

    testWidgets('cover section is present', (tester) async {
      useLargeScreen(tester);
      await tester.pumpWidget(buildSubject());

      expect(find.byKey(const ValueKey('profile_square_avatar')), findsOneWidget);
    });

    testWidgets('pulling from the cover area refreshes profile and feed when no banner exists', (tester) async {
      useLargeScreen(tester);
      await tester.pumpWidget(buildSubject());

      await tester.drag(find.byKey(const ValueKey('profile_cover_refresh_zone')), const Offset(0, 320));
      await tester.pumpAndSettle();

      verify(() => profileBloc.add(const ProfileRefreshRequested())).called(1);
      verify(() => feedBloc.add(const FeedRefreshRequested())).called(1);
    });

    testWidgets('pulling from the cover image refreshes profile and feed when banner exists', (tester) async {
      useLargeScreen(tester);
      const profileWithBanner = ProfileViewDetailed(
        did: 'did:plc:me',
        handle: 'me.bsky.social',
        displayName: 'River Tam',
        banner: 'https://example.com/banner.jpg',
      );
      when(() => profileBloc.state).thenReturn(const ProfileState.loaded(profile: profileWithBanner));
      whenListen(
        profileBloc,
        const Stream<ProfileState>.empty(),
        initialState: const ProfileState.loaded(profile: profileWithBanner),
      );

      await tester.pumpWidget(buildSubject());

      await tester.drag(find.byKey(const ValueKey('profile_cover_refresh_zone')), const Offset(0, 320));
      await tester.pumpAndSettle();

      verify(() => profileBloc.add(const ProfileRefreshRequested())).called(1);
      verify(() => feedBloc.add(const FeedRefreshRequested())).called(1);
    });

    testWidgets('pulling from profile header details area refreshes profile and feed', (tester) async {
      useLargeScreen(tester);
      await tester.pumpWidget(buildSubject());

      await tester.drag(find.text('RIVER TAM'), const Offset(0, 320));
      await tester.pumpAndSettle();

      verify(() => profileBloc.add(const ProfileRefreshRequested())).called(1);
      verify(() => feedBloc.add(const FeedRefreshRequested())).called(1);
    });
  });

  group('Tab bar', () {
    testWidgets('tab labels are uppercase', (tester) async {
      useLargeScreen(tester);
      await tester.pumpWidget(buildSubject());

      expect(find.text('REPLIES'), findsOneWidget);
      expect(find.text('MEDIA'), findsOneWidget);
    });

    testWidgets('original-case tab labels are not shown', (tester) async {
      useLargeScreen(tester);
      await tester.pumpWidget(buildSubject());

      expect(find.text('Replies'), findsNothing);
      expect(find.text('Media'), findsNothing);
    });

    testWidgets('does not throw when suggested tab visibility toggles with profile changes', (tester) async {
      useLargeScreen(tester);
      const otherProfile = ProfileViewDetailed(
        did: 'did:plc:other',
        handle: 'other.bsky.social',
        displayName: 'Other User',
      );
      final mockProfileActionRepository = MockProfileActionRepository();
      final streamController = StreamController<ProfileState>.broadcast();
      addTearDown(streamController.close);

      when(() => profileBloc.state).thenReturn(ProfileState.loaded(profile: profile));
      whenListen(profileBloc, streamController.stream, initialState: ProfileState.loaded(profile: profile));

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [RepositoryProvider<ProfileActionRepository>.value(value: mockProfileActionRepository)],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<ProfileBloc>.value(value: profileBloc),
              BlocProvider<FeedBloc>.value(value: feedBloc),
              BlocProvider<SettingsCubit>.value(value: settingsCubit),
              BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
            ],
            child: const MaterialApp(home: ProfileScreen()),
          ),
        ),
      );
      await tester.pump();

      streamController.add(const ProfileState.loaded(profile: otherProfile));
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);

      streamController.add(ProfileState.loaded(profile: profile));
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('Feed layout switching', () {
    FeedViewPost makePost(String id) {
      final record = FeedPostRecord(text: 'Post $id', createdAt: DateTime.utc(2026, 3, 1));
      return FeedViewPost(
        post: PostView(
          uri: AtUri('at://did:plc:me/app.bsky.feed.post/$id'),
          cid: 'cid-$id',
          author: const ProfileViewBasic(did: 'did:plc:me', handle: 'me.bsky.social', displayName: 'River Tam'),
          record: record.toJson(),
          indexedAt: DateTime.utc(2026, 3, 1),
        ),
      );
    }

    final posts = List.generate(3, (i) => makePost('$i'));

    FeedState feedStateWith(List<FeedViewPost> p) =>
        FeedState.loaded(actor: 'did:plc:me', posts: p, filter: FeedFilter.postsNoReplies, hasMore: false);

    FeedViewPost makeReplyWithParent(String id) {
      final parentRecord = FeedPostRecord(text: 'Parent $id', createdAt: DateTime.utc(2026, 3, 1));
      final parentPost = PostView(
        uri: AtUri('at://did:plc:parent/app.bsky.feed.post/parent-$id'),
        cid: 'cid-parent-$id',
        author: const ProfileViewBasic(did: 'did:plc:parent', handle: 'parent.bsky.social', displayName: 'Parent User'),
        record: parentRecord.toJson(),
        indexedAt: DateTime.utc(2026, 3, 1),
      );
      final replyRecord = FeedPostRecord(text: 'Reply $id', createdAt: DateTime.utc(2026, 3, 1, 0, 5), reply: null);

      return FeedViewPost(
        post: PostView(
          uri: AtUri('at://did:plc:me/app.bsky.feed.post/reply-$id'),
          cid: 'cid-reply-$id',
          author: const ProfileViewBasic(did: 'did:plc:me', handle: 'me.bsky.social', displayName: 'River Tam'),
          record: {
            ...replyRecord.toJson(),
            'reply': {
              r'$type': 'app.bsky.feed.post#replyRef',
              'root': {'uri': parentPost.uri.toString(), 'cid': parentPost.cid},
              'parent': {'uri': parentPost.uri.toString(), 'cid': parentPost.cid},
            },
          },
          indexedAt: DateTime.utc(2026, 3, 1, 0, 5),
        ),
        reply: ReplyRef(
          root: UReplyRefRoot.postView(data: parentPost),
          parent: UReplyRefParent.postView(data: parentPost),
        ),
      );
    }

    /// Builds the profile screen with [posts] in the feed and the given SettingsCubit controlling layout mode.
    Widget buildWithPosts(WidgetTester tester, MockSettingsCubit settCubit) {
      useLargeScreen(tester);

      final mockPostActionRepo = MockPostActionRepository();
      final mockSavedPostsCubit = MockSavedPostsCubit();
      final mockPostActionCache = MockPostActionCache();

      when(() => mockSavedPostsCubit.state).thenReturn(const SavedPostsState());
      whenListen(mockSavedPostsCubit, const Stream<SavedPostsState>.empty());

      when(() => feedBloc.state).thenReturn(feedStateWith(posts));
      whenListen(feedBloc, const Stream<FeedState>.empty(), initialState: feedStateWith(posts));

      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<PostActionRepository>.value(value: mockPostActionRepo),
          RepositoryProvider<PostActionCache>.value(value: mockPostActionCache),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<ProfileBloc>.value(value: profileBloc),
            BlocProvider<FeedBloc>.value(value: feedBloc),
            BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
            BlocProvider<SettingsCubit>.value(value: settCubit),
            BlocProvider<SavedPostsCubit>.value(value: mockSavedPostsCubit),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
    }

    testWidgets('compact mode shows compact feed cards without metadata info card', (tester) async {
      final cubit = MockSettingsCubit();
      when(() => cubit.state).thenReturn(settingsStateWith(FeedLayout.compact));
      whenListen(cubit, const Stream<SettingsState>.empty(), initialState: settingsStateWith(FeedLayout.compact));

      await tester.pumpWidget(buildWithPosts(tester, cubit));
      await tester.pump();

      expect(find.byKey(const ValueKey('profile_compact_feed')), findsOneWidget);
      expect(find.byKey(const ValueKey('profile_info_card')), findsNothing);
      expect(find.byKey(const ValueKey('profile_compact_card_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('profile_compact_card_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('profile_compact_card_2')), findsOneWidget);
    });

    testWidgets('card mode does not show compact feed keys or metadata info card', (tester) async {
      final cubit = MockSettingsCubit();
      when(() => cubit.state).thenReturn(settingsStateWith(FeedLayout.card));
      whenListen(cubit, const Stream<SettingsState>.empty(), initialState: settingsStateWith(FeedLayout.card));

      await tester.pumpWidget(buildWithPosts(tester, cubit));
      await tester.pump();

      expect(find.byKey(const ValueKey('profile_compact_feed')), findsNothing);
      expect(find.byKey(const ValueKey('profile_info_card')), findsNothing);
      expect(find.byKey(const ValueKey('profile_compact_card_0')), findsNothing);
    });

    testWidgets('switching from compact to card removes compact feed without re-fetch', (tester) async {
      final cubit = MockSettingsCubit();
      final streamCtrl = StreamController<SettingsState>.broadcast();

      when(() => cubit.state).thenReturn(settingsStateWith(FeedLayout.compact));
      when(() => cubit.stream).thenAnswer((_) => streamCtrl.stream);

      await tester.pumpWidget(buildWithPosts(tester, cubit));
      await tester.pump();

      expect(find.byKey(const ValueKey('profile_compact_feed')), findsOneWidget);
      expect(find.byKey(const ValueKey('profile_info_card')), findsNothing);

      when(() => cubit.state).thenReturn(settingsStateWith(FeedLayout.card));
      streamCtrl.add(settingsStateWith(FeedLayout.card));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('profile_compact_feed')), findsNothing);
      expect(find.byKey(const ValueKey('profile_info_card')), findsNothing);

      verifyNever(() => feedBloc.add(const FeedRefreshRequested()));

      await streamCtrl.close();
    });

    testWidgets('replies tab renders parent + reply thread-style pair', (tester) async {
      final cubit = MockSettingsCubit();
      when(() => cubit.state).thenReturn(settingsStateWith(FeedLayout.compact));
      whenListen(cubit, const Stream<SettingsState>.empty(), initialState: settingsStateWith(FeedLayout.compact));

      final replyPost = makeReplyWithParent('1');
      final repliesState = FeedState.loaded(
        actor: 'did:plc:me',
        posts: [replyPost],
        filter: FeedFilter.postsWithReplies,
        hasMore: false,
      );
      when(() => feedBloc.state).thenReturn(repliesState);
      whenListen(feedBloc, const Stream<FeedState>.empty(), initialState: repliesState);

      useLargeScreen(tester);
      final mockPostActionRepo = MockPostActionRepository();
      final mockSavedPostsCubit = MockSavedPostsCubit();
      final mockPostActionCache = MockPostActionCache();
      when(() => mockSavedPostsCubit.state).thenReturn(const SavedPostsState());
      whenListen(mockSavedPostsCubit, const Stream<SavedPostsState>.empty());

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<PostActionRepository>.value(value: mockPostActionRepo),
            RepositoryProvider<PostActionCache>.value(value: mockPostActionCache),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<ProfileBloc>.value(value: profileBloc),
              BlocProvider<FeedBloc>.value(value: feedBloc),
              BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
              BlocProvider<SettingsCubit>.value(value: cubit),
              BlocProvider<SavedPostsCubit>.value(value: mockSavedPostsCubit),
            ],
            child: const MaterialApp(home: ProfileScreen()),
          ),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(find.text('REPLIES'));
      await tester.tap(find.text('REPLIES'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Parent 1', findRichText: true), findsWidgets);
      expect(find.text('Reply 1', findRichText: true), findsOneWidget);
    });
  });

  group('Lists tab', () {
    late MockListRepository listRepository;

    setUp(() {
      listRepository = MockListRepository();
      when(
        () => listRepository.getLists(
          actor: any(named: 'actor'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const ListsResult(lists: []));
    });

    testWidgets('shows LISTS tab label', (tester) async {
      useLargeScreen(tester);
      await tester.pumpWidget(buildSubject());

      expect(find.text('LISTS'), findsOneWidget);
    });

    testWidgets('shows empty state when navigating to LISTS tab', (tester) async {
      useLargeScreen(tester);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<ProfileBloc>.value(value: profileBloc),
            BlocProvider<FeedBloc>.value(value: feedBloc),
            BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
          ],
          child: MultiRepositoryProvider(
            providers: [RepositoryProvider<ListRepository>.value(value: listRepository)],
            child: const MaterialApp(home: ProfileScreen()),
          ),
        ),
      );

      await tester.tap(find.text('LISTS'));
      await tester.pumpAndSettle();

      expect(find.text('No lists yet'), findsOneWidget);
    });
  });

  group('Add to list', () {
    testWidgets('overflow menu shows Add to list option for other profiles', (tester) async {
      useLargeScreen(tester);
      const otherProfile = ProfileViewDetailed(
        did: 'did:plc:other',
        handle: 'other.bsky.social',
        displayName: 'Other User',
      );
      when(() => profileBloc.state).thenReturn(const ProfileState.loaded(profile: otherProfile));
      whenListen(
        profileBloc,
        const Stream<ProfileState>.empty(),
        initialState: const ProfileState.loaded(profile: otherProfile),
      );
      when(() => feedBloc.state).thenReturn(
        const FeedState.loaded(actor: 'did:plc:other', posts: [], filter: FeedFilter.postsNoReplies, hasMore: false),
      );
      whenListen(
        feedBloc,
        const Stream<FeedState>.empty(),
        initialState: const FeedState.loaded(
          actor: 'did:plc:other',
          posts: [],
          filter: FeedFilter.postsNoReplies,
          hasMore: false,
        ),
      );

      final mockProfileActionRepository = MockProfileActionRepository();

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [RepositoryProvider<ProfileActionRepository>.value(value: mockProfileActionRepository)],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<ProfileBloc>.value(value: profileBloc),
              BlocProvider<FeedBloc>.value(value: feedBloc),
              BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
              BlocProvider<SettingsCubit>.value(value: settingsCubit),
            ],
            child: const MaterialApp(home: ProfileScreen(actor: 'did:plc:other', showBackButton: true)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Add to list'), findsOneWidget);
    });
  });

  group('Suggested Follows overflow menu', () {
    testWidgets('other profile overflow menu shows Suggested Follows option', (tester) async {
      useLargeScreen(tester);
      const otherProfile = ProfileViewDetailed(
        did: 'did:plc:other',
        handle: 'other.bsky.social',
        displayName: 'Other User',
      );
      when(() => profileBloc.state).thenReturn(const ProfileState.loaded(profile: otherProfile));
      whenListen(
        profileBloc,
        const Stream<ProfileState>.empty(),
        initialState: const ProfileState.loaded(profile: otherProfile),
      );
      when(() => feedBloc.state).thenReturn(
        const FeedState.loaded(actor: 'did:plc:other', posts: [], filter: FeedFilter.postsNoReplies, hasMore: false),
      );
      whenListen(
        feedBloc,
        const Stream<FeedState>.empty(),
        initialState: const FeedState.loaded(
          actor: 'did:plc:other',
          posts: [],
          filter: FeedFilter.postsNoReplies,
          hasMore: false,
        ),
      );

      final mockProfileActionRepository = MockProfileActionRepository();

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [RepositoryProvider<ProfileActionRepository>.value(value: mockProfileActionRepository)],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<ProfileBloc>.value(value: profileBloc),
              BlocProvider<FeedBloc>.value(value: feedBloc),
              BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
              BlocProvider<SettingsCubit>.value(value: settingsCubit),
            ],
            child: const MaterialApp(home: ProfileScreen(actor: 'did:plc:other', showBackButton: true)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();

      expect(find.text('Suggested Follows'), findsOneWidget);
    });

    testWidgets('own profile overflow menu does NOT show Suggested Follows option', (tester) async {
      useLargeScreen(tester);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Suggested Follows'), findsNothing);
      expect(find.text('Clean Follows'), findsOneWidget);
    });
  });

  group('Own profile overflow menu', () {
    testWidgets('Clean Follows option navigates to clean follows screen', (tester) async {
      useLargeScreen(tester);

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: authBloc),
                BlocProvider<ProfileBloc>.value(value: profileBloc),
                BlocProvider<FeedBloc>.value(value: feedBloc),
                BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
                BlocProvider<SettingsCubit>.value(value: settingsCubit),
              ],
              child: const ProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/settings/clean-follows',
            builder: (context, state) => const Scaffold(body: Text('clean')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clean Follows'));
      await tester.pumpAndSettle();

      expect(find.text('clean'), findsOneWidget);

      router.dispose();
    });
  });

  group('Profile post search action', () {
    testWidgets('search icon navigates to profile-scoped post search route', (tester) async {
      useLargeScreen(tester);
      const otherProfile = ProfileViewDetailed(
        did: 'did:plc:other',
        handle: 'other.bsky.social',
        displayName: 'Other User',
      );
      when(() => profileBloc.state).thenReturn(const ProfileState.loaded(profile: otherProfile));
      whenListen(
        profileBloc,
        const Stream<ProfileState>.empty(),
        initialState: const ProfileState.loaded(profile: otherProfile),
      );
      when(() => feedBloc.state).thenReturn(
        const FeedState.loaded(actor: 'did:plc:other', posts: [], filter: FeedFilter.postsNoReplies, hasMore: false),
      );
      whenListen(
        feedBloc,
        const Stream<FeedState>.empty(),
        initialState: const FeedState.loaded(
          actor: 'did:plc:other',
          posts: [],
          filter: FeedFilter.postsNoReplies,
          hasMore: false,
        ),
      );

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => MultiRepositoryProvider(
              providers: [RepositoryProvider<ProfileActionRepository>.value(value: MockProfileActionRepository())],
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<AuthBloc>.value(value: authBloc),
                  BlocProvider<ProfileBloc>.value(value: profileBloc),
                  BlocProvider<FeedBloc>.value(value: feedBloc),
                  BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
                  BlocProvider<SettingsCubit>.value(value: settingsCubit),
                ],
                child: const ProfileScreen(actor: 'did:plc:other', showBackButton: true),
              ),
            ),
          ),
          GoRoute(
            path: '/profile/:actor/search-posts',
            builder: (context, state) => Text('search:${state.pathParameters['actor']}'),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('profile_search_posts_button')));
      await tester.pumpAndSettle();

      expect(find.text('search:other.bsky.social'), findsOneWidget);

      router.dispose();
    });
  });
}
