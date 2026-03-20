import 'dart:async';

import 'package:atproto_core/atproto_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/core/theme/feed_architecture.dart';
import 'package:lazurite/core/theme/ui_density.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/compose/presentation/compose_route_args.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/cubit/post_action_cache.dart';
import 'package:lazurite/features/feed/cubit/saved_posts_cubit.dart';
import 'package:lazurite/features/feed/data/post_action_repository.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:lazurite/features/profile/presentation/profile_screen.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState> implements ProfileBloc {}

class MockFeedBloc extends MockBloc<FeedEvent, FeedState> implements FeedBloc {}

class MockProfileActionRepository extends Mock implements ProfileActionRepository {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

class MockPostActionRepository extends Mock implements PostActionRepository {}

class MockSavedPostsCubit extends MockCubit<SavedPostsState> implements SavedPostsCubit {}

class MockPostActionCache extends Mock implements PostActionCache {}

void main() {
  late MockAuthBloc authBloc;
  late MockProfileBloc profileBloc;
  late MockFeedBloc feedBloc;
  late MockSettingsCubit settingsCubit;

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
    uiDensity: UiDensity.standard,
    feedArchitecture: FeedArchitecture.grid,
  );

  SettingsState settingsStateWith(FeedArchitecture architecture) => SettingsState(
    themePalette: AppThemePalette.oxocarbon,
    themeVariant: AppThemeVariant.dark,
    useSystemTheme: false,
    uiDensity: UiDensity.standard,
    feedArchitecture: architecture,
  );

  setUp(() {
    authBloc = MockAuthBloc();
    profileBloc = MockProfileBloc();
    feedBloc = MockFeedBloc();
    settingsCubit = MockSettingsCubit();

    when(() => authBloc.state).thenReturn(const AuthState.authenticated(tokens));
    when(() => profileBloc.state).thenReturn(ProfileState.loaded(profile: profile));
    when(() => feedBloc.state).thenReturn(
      const FeedState.loaded(actor: 'did:plc:me', posts: [], filter: FeedFilter.postsNoReplies, hasMore: false),
    );
    when(() => settingsCubit.state).thenReturn(defaultSettingsState());

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
  });

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<ProfileBloc>.value(value: profileBloc),
        BlocProvider<FeedBloc>.value(value: feedBloc),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
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

    verify(() => profileBloc.add(const ProfileLoadRequested(actor: 'did:plc:me'))).called(1);
    verify(
      () => feedBloc.add(const FeedLoadRequested(actor: 'did:plc:me', filter: FeedFilter.postsNoReplies)),
    ).called(1);

    expect(find.text('RIVER TAM'), findsOneWidget);
    expect(find.text('@me.bsky.social'), findsOneWidget);
    expect(find.text('Signal and signal boost.'), findsOneWidget);
    expect(find.text('she/her'), findsOneWidget);
    expect(find.text('river.example'), findsOneWidget);
    expect(find.text('Joined March 2024'), findsOneWidget);
  });

  testWidgets('app bar always shows the profile display name', (tester) async {
    useLargeScreen(tester);
    await tester.pumpWidget(buildSubject());

    expect(find.text('River Tam'), findsOneWidget);
  });

  testWidgets('shows Saved Posts button on own profile', (tester) async {
    useLargeScreen(tester);
    await tester.pumpWidget(buildSubject());

    expect(find.text('Saved Posts'), findsOneWidget);
  });

  testWidgets('does not show Saved Posts button on other profiles', (tester) async {
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
        ],
        child: const MaterialApp(home: ProfileScreen(actor: 'did:plc:other', showBackButton: true)),
      ),
    );

    await tester.pumpWidget(widget);

    expect(find.text('Saved Posts'), findsNothing);
  });

  testWidgets('maps tabs to the expected server filters', (tester) async {
    useLargeScreen(tester);
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('REPLIES'));
    await tester.pump();

    verify(
      () => feedBloc.add(const FeedLoadRequested(actor: 'did:plc:me', filter: FeedFilter.postsAndAuthorThreads)),
    ).called(1);

    await tester.tap(find.text('MEDIA'));
    await tester.pump();

    verify(
      () => feedBloc.add(const FeedLoadRequested(actor: 'did:plc:me', filter: FeedFilter.postsWithMedia)),
    ).called(1);
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

    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
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
      expect(find.text('Signal and signal boost.'), findsOneWidget);
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

    /// Builds the profile screen with [posts] in the feed and the given
    /// [settCubit] controlling layout mode.
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
            BlocProvider<SettingsCubit>.value(value: settCubit),
            BlocProvider<SavedPostsCubit>.value(value: mockSavedPostsCubit),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
    }

    testWidgets('grid mode shows centered large grid cards without the metadata info card', (tester) async {
      final cubit = MockSettingsCubit();
      when(() => cubit.state).thenReturn(settingsStateWith(FeedArchitecture.grid));
      whenListen(cubit, const Stream<SettingsState>.empty(), initialState: settingsStateWith(FeedArchitecture.grid));

      await tester.pumpWidget(buildWithPosts(tester, cubit));
      await tester.pump();

      expect(find.byKey(const ValueKey('profile_grid_feed')), findsOneWidget);
      expect(find.byKey(const ValueKey('profile_info_card')), findsNothing);
      expect(find.byKey(const ValueKey('profile_large_card_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('profile_large_card_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('profile_large_card_2')), findsOneWidget);
    });

    testWidgets('linear mode does not show the large grid card feed or metadata info card', (tester) async {
      final cubit = MockSettingsCubit();
      when(() => cubit.state).thenReturn(settingsStateWith(FeedArchitecture.linear));
      whenListen(cubit, const Stream<SettingsState>.empty(), initialState: settingsStateWith(FeedArchitecture.linear));

      await tester.pumpWidget(buildWithPosts(tester, cubit));
      await tester.pump();

      expect(find.byKey(const ValueKey('profile_grid_feed')), findsNothing);
      expect(find.byKey(const ValueKey('profile_info_card')), findsNothing);
      expect(find.byKey(const ValueKey('profile_large_card_0')), findsNothing);
    });

    testWidgets('switching from grid to linear removes the large grid feed without re-fetch', (tester) async {
      final cubit = MockSettingsCubit();
      final streamCtrl = StreamController<SettingsState>.broadcast();

      when(() => cubit.state).thenReturn(settingsStateWith(FeedArchitecture.grid));
      when(() => cubit.stream).thenAnswer((_) => streamCtrl.stream);

      await tester.pumpWidget(buildWithPosts(tester, cubit));
      await tester.pump();

      expect(find.byKey(const ValueKey('profile_grid_feed')), findsOneWidget);
      expect(find.byKey(const ValueKey('profile_info_card')), findsNothing);

      when(() => cubit.state).thenReturn(settingsStateWith(FeedArchitecture.linear));
      streamCtrl.add(settingsStateWith(FeedArchitecture.linear));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('profile_grid_feed')), findsNothing);
      expect(find.byKey(const ValueKey('profile_info_card')), findsNothing);

      verifyNever(() => feedBloc.add(const FeedRefreshRequested()));

      await streamCtrl.close();
    });
  });
}
