import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/post.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/router/app_router.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/presentation/oauth_callback_screen.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/feed/data/post_thread_repository.dart';
import 'package:lazurite/features/feed/presentation/media/image_viewer_route_args.dart';
import 'package:lazurite/features/feed/presentation/media/video_player_route_args.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/public/data/public_content_repository.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poptart_core/poptart_core.dart' as atcore;

import '../../helpers/fixtures/feed.dart';
import '../../helpers/fixtures/auth.dart';
import '../../helpers/connectivity_helpers.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockFeedPreferencesCubit extends MockCubit<FeedPreferencesState> implements FeedPreferencesCubit {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState> implements ProfileBloc {}

class MockFeedBloc extends MockBloc<FeedEvent, FeedState> implements FeedBloc {}

class MockFeedRepository extends Mock implements FeedRepository {}

class MockPostThreadRepository extends Mock implements PostThreadRepository {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

class MockAccountSwitcherCubit extends MockCubit<AccountSwitcherState> implements AccountSwitcherCubit {}

class MockUnreadCountCubit extends MockCubit<UnreadCountState> implements UnreadCountCubit {}

class MockConvoListBloc extends MockBloc<ConvoListEvent, ConvoListState> implements ConvoListBloc {}

class MockNotificationRepository extends Mock implements NotificationRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockProfileActionRepository extends Mock implements ProfileActionRepository {}

class MockSearchRepository extends Mock implements SearchRepository {}

class MockTypeaheadRepository extends Mock implements TypeaheadRepository {}

class MockAppDatabase extends Mock implements AppDatabase {}

class FakePublicContentRepository implements PublicContentRepository {
  const FakePublicContentRepository();

  @override
  Future<PublicDiscoverResult> loadDiscover({String? cursor, int limit = 25}) async {
    return PublicDiscoverResult(
      feeds: [for (var index = 0; index < 36; index += 1) _feed('discover-$index')],
      cursor: cursor == null ? 'next' : null,
    );
  }

  @override
  Future<PublicFeedsResult> loadFeeds({String? cursor, int limit = 25}) async {
    return PublicFeedsResult(
      feeds: [for (var index = 0; index < 36; index += 1) _feed('suggested-$index')],
      cursor: cursor == null ? 'next' : null,
    );
  }

  @override
  Future<PublicFeedsResult> searchFeeds({required String query, String? cursor, int limit = 25}) async {
    return PublicFeedsResult(feeds: [_feed(query)], cursor: null);
  }

  static GeneratorView _feed(String rkey) {
    return GeneratorView(
      uri: atcore.AtUri.parse('at://did:plc:feed/app.bsky.feed.generator/$rkey'),
      cid: 'cid-$rkey',
      did: 'did:web:feeds.example',
      creator: const ProfileView(did: 'did:plc:feed', handle: 'feeds.example', displayName: 'Feeds'),
      displayName: 'Feed $rkey',
      indexedAt: DateTime.utc(2026, 5, 18),
    );
  }
}

void main() {
  late MockAuthBloc authBloc;
  late MockFeedPreferencesCubit feedPreferencesCubit;
  late MockProfileBloc profileBloc;
  late MockFeedBloc feedBloc;
  late MockFeedRepository feedRepository;
  late MockPostThreadRepository postThreadRepository;
  late MockSettingsCubit settingsCubit;
  late MockConnectivityCubit connectivityCubit;
  late MockAccountSwitcherCubit accountSwitcherCubit;
  late MockUnreadCountCubit unreadCountCubit;
  late MockConvoListBloc convoListBloc;
  late MockNotificationRepository notificationRepository;
  late MockProfileRepository profileRepository;
  late MockProfileActionRepository profileActionRepository;
  late MockSearchRepository searchRepository;
  late MockTypeaheadRepository typeaheadRepository;
  late MockAppDatabase database;
  late StreamController<AuthState> authController;
  late AuthState currentAuthState;

  final tokens = testRiverTokens();

  final profile = ProfileViewDetailed(
    did: 'did:plc:me',
    handle: 'me.bsky.social',
    displayName: 'River Tam',
    followersCount: 12,
    followsCount: 8,
    postsCount: 3,
    createdAt: DateTime.utc(2024, 3, 1),
  );

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com/oauth/callback'));
    registerFallbackValue(FeedFilter.postsNoReplies);
  });

  setUp(() {
    authBloc = MockAuthBloc();
    feedPreferencesCubit = MockFeedPreferencesCubit();
    profileBloc = MockProfileBloc();
    feedBloc = MockFeedBloc();
    feedRepository = MockFeedRepository();
    postThreadRepository = MockPostThreadRepository();
    settingsCubit = MockSettingsCubit();
    connectivityCubit = MockConnectivityCubit();
    accountSwitcherCubit = MockAccountSwitcherCubit();
    unreadCountCubit = MockUnreadCountCubit();
    convoListBloc = MockConvoListBloc();
    notificationRepository = MockNotificationRepository();
    profileRepository = MockProfileRepository();
    profileActionRepository = MockProfileActionRepository();
    searchRepository = MockSearchRepository();
    typeaheadRepository = MockTypeaheadRepository();
    database = MockAppDatabase();
    authController = StreamController<AuthState>.broadcast();
    currentAuthState = AuthState.authenticated(tokens);

    when(() => authBloc.state).thenAnswer((_) => currentAuthState);
    when(() => authBloc.handleOAuthRedirectUri(any())).thenAnswer((_) async => false);
    when(() => feedPreferencesCubit.state).thenReturn(const FeedPreferencesState.loaded(feeds: []));
    when(() => profileBloc.state).thenReturn(ProfileState.loaded(profile: profile));
    when(() => feedBloc.state).thenReturn(
      const FeedState.loaded(actor: 'did:plc:me', posts: [], filter: FeedFilter.postsNoReplies, hasMore: false),
    );
    when(() => settingsCubit.state).thenReturn(
      const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      ),
    );
    when(() => settingsCubit.setAppViewProvider(any())).thenAnswer((_) async {});
    stubConnectivityCubit(connectivityCubit);
    when(() => accountSwitcherCubit.state).thenReturn(const AccountSwitcherState.ready(accounts: []));
    when(() => accountSwitcherCubit.loadAccounts()).thenAnswer((_) async {});
    when(() => unreadCountCubit.state).thenReturn(const UnreadCountState(0));
    when(() => convoListBloc.state).thenReturn(const ConvoListState.loaded(convos: [], cursor: null, hasMore: false));
    when(() => notificationRepository.getUnreadCount()).thenAnswer((_) async => 0);
    when(() => profileRepository.getProfile(any())).thenAnswer((invocation) async {
      final actor = invocation.positionalArguments.first as String;
      if (actor == tokens.did || actor == tokens.handle || actor == 'me') {
        return profile;
      }

      return ProfileViewDetailed(
        did: actor.startsWith('did:') ? actor : 'did:plc:$actor',
        handle: actor.startsWith('did:') ? 'alice.bsky.social' : actor,
        displayName: 'Alice',
        followersCount: 2,
        followsCount: 3,
        postsCount: 5,
      );
    });
    when(
      () => feedRepository.getAuthorFeed(
        actor: any(named: 'actor'),
        filter: any(named: 'filter'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => FeedResult(posts: []));

    whenListen(authBloc, authController.stream, initialState: currentAuthState);
    whenListen(
      feedPreferencesCubit,
      const Stream<FeedPreferencesState>.empty(),
      initialState: const FeedPreferencesState.loaded(feeds: []),
    );
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
    whenListen(
      settingsCubit,
      const Stream<SettingsState>.empty(),
      initialState: const SettingsState(
        themePalette: AppThemePalette.oxocarbon,
        themeVariant: AppThemeVariant.dark,
        useSystemTheme: false,
      ),
    );
    whenListen(
      connectivityCubit,
      const Stream<ConnectivityState>.empty(),
      initialState: const ConnectivityState.online(),
    );
    whenListen(
      accountSwitcherCubit,
      const Stream<AccountSwitcherState>.empty(),
      initialState: const AccountSwitcherState.ready(accounts: []),
    );
    whenListen(unreadCountCubit, const Stream<UnreadCountState>.empty(), initialState: const UnreadCountState(0));
    whenListen(
      convoListBloc,
      const Stream<ConvoListState>.empty(),
      initialState: const ConvoListState.loaded(convos: [], cursor: null, hasMore: false),
    );
  });

  tearDown(() async {
    await authController.close();
  });

  Widget buildSubjectWithRouter(GoRouter router, {ThemeData? theme}) => MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: authBloc),
      BlocProvider<FeedPreferencesCubit>.value(value: feedPreferencesCubit),
      BlocProvider<ProfileBloc>.value(value: profileBloc),
      BlocProvider<FeedBloc>.value(value: feedBloc),
      BlocProvider<SettingsCubit>.value(value: settingsCubit),
      BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
      BlocProvider<AccountSwitcherCubit>.value(value: accountSwitcherCubit),
      BlocProvider<UnreadCountCubit>.value(value: unreadCountCubit),
      BlocProvider<ConvoListBloc>.value(value: convoListBloc),
    ],
    child: RepositoryProvider<NotificationRepository>(
      create: (_) => notificationRepository,
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SearchRepository>.value(value: searchRepository),
          RepositoryProvider<TypeaheadRepository>.value(value: typeaheadRepository),
          RepositoryProvider<AppDatabase>.value(value: database),
          RepositoryProvider<ProfileRepository>.value(value: profileRepository),
          RepositoryProvider<ProfileActionRepository>.value(value: profileActionRepository),
          RepositoryProvider<FeedRepository>.value(value: feedRepository),
          RepositoryProvider<PublicContentRepository>.value(value: const FakePublicContentRepository()),
          RepositoryProvider<String>.value(value: tokens.did),
        ],
        child: MaterialApp.router(theme: theme, routerConfig: router),
      ),
    ),
  );

  Widget buildSubject() => buildSubjectWithRouter(AppRouter(authBloc: authBloc).router);

  Future<void> tapProfileBottomTab(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.person_outline).last);
    await tester.pumpAndSettle();
  }

  Future<void> tapAtExplorerBottomTab(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.explore_outlined).last);
    await tester.pumpAndSettle();
  }

  testWidgets('opens the side menu and switches authenticated branches', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byTooltip('Open menu'), findsOneWidget);
    expect(find.text('No feeds pinned'), findsOneWidget);

    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();

    expect(find.text('Lazurite'), findsOneWidget);
    expect(find.text('NEW POST'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('LOG OUT'), 200, scrollable: find.byType(Scrollable).last);
    expect(find.text('LOG OUT'), findsOneWidget);

    await tester.tap(find.text('PROFILE').last);
    await tester.pumpAndSettle();

    expect(find.text('RIVER TAM'), findsOneWidget);

    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SETTINGS').last);
    await tester.pumpAndSettle();

    expect(find.text('APPEARANCE'), findsOneWidget);
  });

  testWidgets('bottom navigation bar shows 5 tabs with hidden labels', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.destinations.length, 5);
    expect(navBar.labelBehavior, NavigationDestinationLabelBehavior.alwaysHide);

    final destinations = navBar.destinations.cast<NavigationDestination>();
    expect(destinations.map((d) => d.label), ['Home', 'Search', 'AT Explorer', 'Alerts', 'Profile']);
    expect(destinations.any((d) => d.label == 'MESSAGES'), isFalse);
    expect(destinations.any((d) => d.label == 'SETTINGS'), isFalse);
  });

  testWidgets('bottom navigation bar height is 80', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.height, 80);
  });

  testWidgets('Android back pops nested route before tab-root policy', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SETTINGS').last);
    await tester.pumpAndSettle();

    expect(find.text('APPEARANCE'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('No feeds pinned'), findsOneWidget);
    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.selectedIndex, 0);
  });

  testWidgets('profile search action opens profile-scoped post search route', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tapProfileBottomTab(tester);

    await tester.tap(find.byKey(const Key('profile_search_posts_button')));
    await tester.pumpAndSettle();

    expect(find.text('Search @me.bsky.social'), findsOneWidget);
  });

  testWidgets('profile edit route builds the own profile edit screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/profile/me/edit');
    await tester.pumpAndSettle();

    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile_edit_save_button')), findsOneWidget);

    router.dispose();
  });

  testWidgets('opens profile connections route with requested initial tab', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    when(() => profileRepository.getFollowers(actor: tokens.handle, cursor: null, limit: 100)).thenAnswer(
      (_) async => const ProfileConnectionsPage(
        subject: ProfileView(did: 'did:plc:me', handle: 'me.bsky.social'),
        profiles: [],
      ),
    );
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/profile/${Uri.encodeComponent(tokens.handle)}/connections?tab=followers');
    await tester.pumpAndSettle();

    expect(find.text('@me.bsky.social'), findsOneWidget);
    verify(() => profileRepository.getFollowers(actor: tokens.handle, cursor: null, limit: 100)).called(1);

    router.dispose();
  });

  testWidgets('Android back at non-Home tab root switches to Home tab', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tapProfileBottomTab(tester);

    expect(find.text('RIVER TAM'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.selectedIndex, 0);
    expect(find.text('No feeds pinned'), findsOneWidget);
  });

  testWidgets('Android back at Home root follows system-exit path', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(handled, isFalse);
  });

  testWidgets('drawer contains Messages and Settings entries', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();

    expect(find.text('NOTIFICATIONS'), findsOneWidget);
    expect(find.text('MESSAGES'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('AUDIT FOLLOWS'), 200, scrollable: find.byType(Scrollable).last);
    expect(find.text('ADVANCED'), findsOneWidget);
    expect(find.text('AT EXPLORER'), findsOneWidget);
    expect(find.text('AUDIT FOLLOWS'), findsOneWidget);
  });

  testWidgets('drawer profile tag opens account switcher sheet', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('River Tam'));
    await tester.pumpAndSettle();

    expect(find.text('Accounts'), findsOneWidget);
    expect(find.text('Add Account'), findsOneWidget);
  });

  testWidgets('tapping bottom nav tabs switches active branch', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.selectedIndex, 0);

    await tapProfileBottomTab(tester);

    final navBarAfter = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBarAfter.selectedIndex, 4);
    expect(find.text('RIVER TAM'), findsOneWidget);
  });

  testWidgets('tapping AT Explorer bottom tab opens the explorer branch', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tapAtExplorerBottomTab(tester);

    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.selectedIndex, 2);
    expect(find.text('PDS Explorer'), findsWidgets);
  });

  testWidgets('LazuriteAppBar shows section label and hamburger on home screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsAtLeastNWidgets(1));
    expect(find.byTooltip('Open menu'), findsOneWidget);
  });

  testWidgets('logged-out root opens public Bluesky discover', (tester) async {
    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);

    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/public/bluesky/discover');
    expect(find.text('BlueSky Discover'), findsOneWidget);

    router.dispose();
  });

  testWidgets('authenticated root remains on the home feed', (tester) async {
    currentAuthState = AuthState.authenticated(tokens);
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);

    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/');
    expect(find.text('No feeds pinned'), findsOneWidget);

    router.dispose();
  });

  testWidgets('public provider routes normalize invalid values', (tester) async {
    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);

    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/public/mastodon/feeds');
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/public/bluesky/feeds');
    expect(find.text('BlueSky Feeds'), findsOneWidget);

    router.dispose();
  });

  testWidgets('public provider switching does not persist app view settings', (tester) async {
    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);

    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('BlackSky'));
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/public/blacksky/discover');
    verifyNever(() => settingsCubit.setAppViewProvider(any()));

    router.dispose();
  });

  testWidgets('unauthenticated bottom navigation maps destinations and login action', (tester) async {
    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/public/blacksky/discover');
    await tester.pumpAndSettle();

    var navBar = tester.widget<NavigationBar>(find.byKey(const ValueKey<String>('unauthenticated-navigation-bar')));
    expect(navBar.selectedIndex, 0);
    expect(navBar.labelBehavior, NavigationDestinationLabelBehavior.alwaysShow);
    expect(navBar.destinations.map((destination) => (destination as NavigationDestination).label), [
      'Home',
      'AT Explorer',
      'Settings',
      'Sign In',
    ]);

    await tester.tap(find.text('AT Explorer').last);
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/settings/devtools');
    expect(router.routerDelegate.currentConfiguration.uri.queryParameters['publicHome'], '/public/blacksky/discover');
    navBar = tester.widget<NavigationBar>(find.byKey(const ValueKey<String>('unauthenticated-navigation-bar')));
    expect(navBar.selectedIndex, 1);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/settings');
    expect(router.routerDelegate.currentConfiguration.uri.queryParameters['publicHome'], '/public/blacksky/discover');
    navBar = tester.widget<NavigationBar>(find.byKey(const ValueKey<String>('unauthenticated-navigation-bar')));
    expect(navBar.selectedIndex, 2);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/public/blacksky/discover');

    router.go('/public/blacksky/feeds');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('unauthenticated-login-button')));
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/login');
    expect(router.routerDelegate.currentConfiguration.uri.queryParameters['provider'], 'blacksky');
    expect(router.routerDelegate.currentConfiguration.uri.queryParameters['publicHome'], '/public/blacksky/feeds');
    navBar = tester.widget<NavigationBar>(find.byKey(const ValueKey<String>('unauthenticated-navigation-bar')));
    expect(navBar.selectedIndex, 3);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/public/blacksky/feeds');

    router.dispose();
  });

  testWidgets('unauthenticated settings and AT Explorer login use persisted provider', (tester) async {
    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);
    const blackskySettings = SettingsState(
      themePalette: AppThemePalette.oxocarbon,
      themeVariant: AppThemeVariant.dark,
      useSystemTheme: false,
      appViewProvider: 'blacksky',
    );
    when(() => settingsCubit.state).thenReturn(blackskySettings);
    whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: blackskySettings);
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/settings');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('unauthenticated-login-button')));
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/login');
    expect(router.routerDelegate.currentConfiguration.uri.queryParameters['provider'], 'blacksky');

    router.go('/settings/devtools');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('unauthenticated-login-button')));
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/login');
    expect(router.routerDelegate.currentConfiguration.uri.queryParameters['provider'], 'blacksky');

    router.dispose();
  });

  testWidgets('logged-out feed detail route uses provider query for public read-only rendering', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    final feedUri = atcore.AtUri.parse('at://did:plc:feed/app.bsky.feed.generator/blacksky');
    when(
      () => feedRepository.getFeedGenerator(feedUri),
    ).thenAnswer((_) async => FakePublicContentRepository._feed('blacksky'));
    when(
      () => feedRepository.getFeed(
        feedUri: feedUri,
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => FeedResult(posts: [_publicFeedPost()]));

    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<FeedPreferencesCubit>.value(value: feedPreferencesCubit),
          BlocProvider<FeedBloc>.value(value: feedBloc),
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
          BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
          BlocProvider<AccountSwitcherCubit>.value(value: accountSwitcherCubit),
        ],
        child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<FeedRepository>.value(value: feedRepository),
            RepositoryProvider<PublicContentRepository>.value(value: const FakePublicContentRepository()),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    await tester.pumpAndSettle();

    router.go('/feed?uri=${Uri.encodeQueryComponent(feedUri.toString())}&provider=blacksky');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('unauthenticated-navigation-bar')), findsOneWidget);
    expect(find.byKey(const ValueKey('public_post_card_footer')), findsOneWidget);
    expect(find.byTooltip('Share post'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_outline), findsNothing);

    router.dispose();
  });

  testWidgets('logged-out post route uses provider query for public read-only rendering', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    final thread = _publicThread();
    when(() => postThreadRepository.getPostThread(thread.post.uri.toString())).thenAnswer((_) async => thread);
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
        ],
        child: RepositoryProvider<PostThreadRepository>.value(
          value: postThreadRepository,
          child: RepositoryProvider<PublicContentRepository>.value(
            value: const FakePublicContentRepository(),
            child: MaterialApp.router(routerConfig: router),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    router.go('/post?uri=${Uri.encodeQueryComponent(thread.post.uri.toString())}&provider=blacksky');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('unauthenticated-navigation-bar')), findsOneWidget);
    expect(router.canPop(), isFalse);
    expect(find.byKey(const ValueKey('public_post_card_footer')), findsOneWidget);
    expect(find.byTooltip('Share post'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_outline), findsNothing);

    router.dispose();
  });

  testWidgets('image viewer route without extra redirects home instead of throwing', (tester) async {
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/images');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/');

    router.dispose();
  });

  testWidgets('image viewer route with invalid args redirects home instead of indexing missing images', (tester) async {
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/images', extra: const ImageViewerRouteArgs(images: [], initialIndex: 0));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/');

    router.dispose();
  });

  testWidgets('image viewer route restores from URL payload when extra is missing', (tester) async {
    final router = AppRouter(authBloc: authBloc).router;
    const args = ImageViewerRouteArgs(
      images: [
        ImageViewerItem(
          fullsizeUrl: 'https://example.com/full.jpg',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          heroTag: 'restored-image-test',
          altText: 'restored alt text',
        ),
      ],
      initialIndex: 0,
    );

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go(args.location);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/images');
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.text('restored alt text'), findsOneWidget);

    router.dispose();
  });

  testWidgets('logged-out image viewer route remains public instead of redirecting to login', (tester) async {
    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go(
      '/images',
      extra: const ImageViewerRouteArgs(
        images: [
          ImageViewerItem(
            fullsizeUrl: 'https://example.com/full.jpg',
            thumbnailUrl: 'https://example.com/thumb.jpg',
            heroTag: 'public-image-test',
            altText: 'alt text',
          ),
        ],
        initialIndex: 0,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(router.routerDelegate.currentConfiguration.uri.path, '/images');
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('login-continue-button')), findsNothing);

    router.dispose();
  });

  testWidgets('invalid list route shows invalid-link screen instead of throwing', (tester) async {
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/list?uri=not-an-at-uri');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Invalid link'), findsWidgets);
    expect(find.text('This list link is invalid.'), findsOneWidget);

    router.dispose();
  });

  testWidgets('invalid feed query route shows invalid-link screen instead of resolving as missing', (tester) async {
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/feed?uri=not-an-at-uri');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Invalid link'), findsWidgets);
    expect(find.text('This feed link is invalid.'), findsOneWidget);
    verifyNever(
      () => feedRepository.resolveFeedGeneratorUri(
        actor: any(named: 'actor'),
        rkey: any(named: 'rkey'),
      ),
    );

    router.dispose();
  });

  testWidgets('logged-out invalid feed query route shows invalid-link screen instead of resolving as missing', (
    tester,
  ) async {
    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/feed?uri=not-an-at-uri&provider=blacksky');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Invalid link'), findsWidgets);
    expect(find.text('This feed link is invalid.'), findsOneWidget);

    router.dispose();
  });

  testWidgets('video viewer route without extra redirects home instead of throwing', (tester) async {
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/video');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/');

    router.dispose();
  });

  testWidgets('video viewer route with invalid args redirects home instead of initializing blank video', (
    tester,
  ) async {
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/video', extra: const VideoPlayerRouteArgs(playlistUrl: ''));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/');

    router.dispose();
  });

  testWidgets('video viewer route restores from URL payload when extra is missing', (tester) async {
    final router = AppRouter(authBloc: authBloc).router;
    const args = VideoPlayerRouteArgs(
      playlistUrl: 'https://example.com/video.m3u8',
      downloadUrl: 'https://example.com/video.mp4',
      thumbnailUrl: 'https://example.com/thumb.jpg',
      altText: 'restored video alt text',
      aspectRatio: 16 / 9,
      isGif: true,
    );

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go(args.location);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(router.routerDelegate.currentConfiguration.uri.path, '/video');
    expect(find.text('Video'), findsOneWidget);
    expect(find.text('restored video alt text'), findsOneWidget);

    router.dispose();
  });

  testWidgets('logged-out video viewer route remains public instead of redirecting to login', (tester) async {
    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go(
      '/video',
      extra: const VideoPlayerRouteArgs(
        playlistUrl: 'https://example.com/video.m3u8',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        altText: 'video alt text',
        aspectRatio: 16 / 9,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(router.routerDelegate.currentConfiguration.uri.path, '/video');
    expect(find.text('Video'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('login-continue-button')), findsNothing);

    router.dispose();
  });

  testWidgets('logged-out topic route uses provider query for public read-only rendering', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);
    when(
      () => searchRepository.searchTopicPosts(
        topic: any(named: 'topic'),
        sort: any(named: 'sort'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => TopicPostsResult(posts: [_publicFeedPost().post], topicName: 'Cookout'));
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/topic?topic=1972&provider=blacksky');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('unauthenticated-navigation-bar')), findsOneWidget);
    expect(router.canPop(), isFalse);
    expect(find.text('Cookout'), findsWidgets);
    expect(find.byKey(const ValueKey('public_post_card_footer')), findsOneWidget);
    expect(find.byTooltip('Share post'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_outline), findsNothing);

    router.dispose();
  });

  testWidgets('logged-out profile route resolves actor and hides authenticated controls', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    final post = _publicFeedPost();
    when(() => profileRepository.getProfile('alice.bsky.social')).thenAnswer(
      (_) async => const ProfileViewDetailed(
        did: 'did:plc:alice',
        handle: 'alice.bsky.social',
        displayName: 'Alice',
        postsCount: 1,
      ),
    );
    when(
      () => feedRepository.getAuthorFeed(
        actor: any(named: 'actor'),
        filter: any(named: 'filter'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => FeedResult(posts: [post]));
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
          BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
        ],
        child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<ProfileRepository>.value(value: profileRepository),
            RepositoryProvider<FeedRepository>.value(value: feedRepository),
            RepositoryProvider<PublicContentRepository>.value(value: const FakePublicContentRepository()),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    await tester.pumpAndSettle();

    router.go('/profile/alice.bsky.social?provider=blacksky');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('unauthenticated-navigation-bar')), findsOneWidget);
    expect(router.canPop(), isFalse);
    expect(find.text('Alice'), findsWidgets);
    expect(find.text('POSTS'), findsWidgets);
    expect(find.text('REPLIES'), findsOneWidget);
    expect(find.text('MEDIA'), findsOneWidget);
    expect(find.text('QUOTES'), findsNothing);
    expect(find.byKey(const ValueKey('public_post_card_footer')), findsOneWidget);
    expect(find.byKey(const Key('profile_search_posts_button')), findsNothing);

    router.dispose();
  });

  testWidgets('logged-out authenticated-only profile child routes redirect to public profile', (tester) async {
    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/profile/alice.bsky.social/connections?tab=followers&provider=blacksky');
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/profile/alice.bsky.social');
    expect(router.routerDelegate.currentConfiguration.uri.queryParameters['provider'], 'blacksky');
    expect(router.routerDelegate.currentConfiguration.uri.queryParameters.containsKey('tab'), isFalse);

    router.go('/profile/alice.bsky.social/search-posts?provider=blacksky');
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/profile/alice.bsky.social');
    expect(router.routerDelegate.currentConfiguration.uri.queryParameters['provider'], 'blacksky');

    router.dispose();
  });

  testWidgets('unauthenticated settings login falls back to BlueSky for invalid persisted provider', (tester) async {
    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);
    const invalidSettings = SettingsState(
      themePalette: AppThemePalette.oxocarbon,
      themeVariant: AppThemeVariant.dark,
      useSystemTheme: false,
      appViewProvider: 'unknown',
    );
    when(() => settingsCubit.state).thenReturn(invalidSettings);
    whenListen(settingsCubit, const Stream<SettingsState>.empty(), initialState: invalidSettings);
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/settings');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('unauthenticated-login-button')));
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/login');
    expect(router.routerDelegate.currentConfiguration.uri.queryParameters['provider'], 'bluesky');

    router.dispose();
  });

  testWidgets('public tab switch preserves discover scroll position', (tester) async {
    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
    await tester.pumpAndSettle();
    final scrolledOffset = tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels;
    expect(scrolledOffset, greaterThan(0));

    await tester.tap(find.text('Feeds').last);
    await tester.pumpAndSettle();
    expect(router.routerDelegate.currentConfiguration.uri.path, '/public/bluesky/feeds');

    await tester.tap(find.text('Discover').last);
    await tester.pumpAndSettle();

    final restoredOffset = tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels;
    expect(restoredOffset, scrolledOffset);

    router.dispose();
  });

  testWidgets('stays on public settings after logout without crashing', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = AppRouter(authBloc: authBloc).router;

    final widget = MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<FeedPreferencesCubit>.value(value: feedPreferencesCubit),
        BlocProvider<ProfileBloc>.value(value: profileBloc),
        BlocProvider<FeedBloc>.value(value: feedBloc),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
        BlocProvider<ConnectivityCubit>.value(value: connectivityCubit),
        BlocProvider<AccountSwitcherCubit>.value(value: accountSwitcherCubit),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final app = MaterialApp.router(routerConfig: router);
          if (!state.isAuthenticated) {
            return app;
          }

          return MultiBlocProvider(
            providers: [BlocProvider<UnreadCountCubit>.value(value: unreadCountCubit)],
            child: MultiBlocProvider(
              providers: [BlocProvider<ConvoListBloc>.value(value: convoListBloc)],
              child: RepositoryProvider<NotificationRepository>.value(value: notificationRepository, child: app),
            ),
          );
        },
      ),
    );

    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    router.go('/settings');
    await tester.pumpAndSettle();

    expect(find.text('APPEARANCE'), findsOneWidget);

    await tester.tap(find.byTooltip('Log Out'));
    await tester.pump();

    verify(() => authBloc.add(const LogoutRequested())).called(1);

    currentAuthState = const AuthState.unauthenticated();
    authController.add(currentAuthState);

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.byTooltip('Log Out'), findsNothing);
    expect(tester.takeException(), isNull);

    router.dispose();
  });

  testWidgets('allows unauthenticated access to public settings, devtools, privacy, and terms routes', (tester) async {
    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);

    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    router.go('/settings');
    await tester.pumpAndSettle();
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('ACCOUNT'), findsNothing);

    router.go('/settings/logs');
    await tester.pumpAndSettle();
    expect(find.text('Logs'), findsWidgets);

    router.go('/settings/about');
    await tester.pumpAndSettle();
    expect(find.text('About'), findsWidgets);

    router.go('/settings/devtools');
    await tester.pumpAndSettle();
    expect(find.text('PDS Explorer'), findsWidgets);

    router.go('/privacy');
    await tester.pumpAndSettle();
    expect(find.text('Privacy Policy'), findsWidgets);

    router.go('/terms');
    await tester.pumpAndSettle();
    expect(find.text('Terms of Service'), findsWidgets);

    router.dispose();
  });

  testWidgets('unauthenticated settings tab root hides back button', (tester) async {
    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);

    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    router.go('/settings');
    await tester.pumpAndSettle();
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);
    final navBar = tester.widget<NavigationBar>(find.byKey(const ValueKey<String>('unauthenticated-navigation-bar')));
    expect(navBar.selectedIndex, 2);

    router.dispose();
  });

  testWidgets('authenticated settings back button falls back to home when there is no stack to pop', (tester) async {
    currentAuthState = AuthState.authenticated(tokens);
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);

    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    await tester.pumpAndSettle();

    router.go('/settings');
    await tester.pumpAndSettle();
    expect(find.text('APPEARANCE'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsAtLeastNWidgets(1));
    expect(find.text('APPEARANCE'), findsNothing);
    router.dispose();
  });

  testWidgets('authenticated settings back button returns to profile when opened from profile', (tester) async {
    currentAuthState = AuthState.authenticated(tokens);
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);

    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    await tester.pumpAndSettle();

    await tapProfileBottomTab(tester);
    expect(find.text('RIVER TAM'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('APPEARANCE'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('RIVER TAM'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsNothing);
    router.dispose();
  });

  testWidgets('contextual profile route pops back to the originating shell route', (tester) async {
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    await tester.pumpAndSettle();

    expect(find.text('No feeds pinned'), findsOneWidget);
    clearInteractions(profileBloc);
    clearInteractions(feedBloc);

    unawaited(router.push('/profile/${Uri.encodeComponent('did:plc:alice')}'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(router.canPop(), isTrue);
    verifyNever(() => profileBloc.add(const ProfileLoadRequested(actor: 'did:plc:alice')));
    verifyNever(() => feedBloc.add(const FeedLoadRequested(actor: 'did:plc:alice', filter: FeedFilter.postsNoReplies)));

    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('No feeds pinned'), findsOneWidget);
    router.dispose();
  });

  testWidgets('contextual profile route uses Cupertino pages on iOS for edge-swipe back', (tester) async {
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router, theme: ThemeData(platform: TargetPlatform.iOS)));
    await tester.pumpAndSettle();

    unawaited(router.push('/profile/${Uri.encodeComponent('did:plc:alice')}'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(CupertinoPageTransition), findsWidgets);
    expect(router.canPop(), isTrue);
    router.dispose();
  });

  testWidgets('keeps account-scoped settings routes auth-gated when unauthenticated', (tester) async {
    currentAuthState = const AuthState.unauthenticated();
    when(() => authBloc.state).thenReturn(currentAuthState);
    whenListen(authBloc, Stream<AuthState>.value(currentAuthState), initialState: currentAuthState);

    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    router.go('/settings/video-limits');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('login-continue-button')), findsOneWidget);
    router.dispose();
  });

  testWidgets('allows authenticated access to login route when reauth query is present', (tester) async {
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    await tester.pumpAndSettle();

    router.go('/login?reauth=1');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('login-continue-button')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('unauthenticated-navigation-bar')), findsNothing);
    router.dispose();
  });

  testWidgets('reauth login route passes handle through and starts OAuth for that account', (tester) async {
    final router = AppRouter(authBloc: authBloc).router;

    await tester.pumpWidget(buildSubjectWithRouter(router));
    await tester.pumpAndSettle();

    router.go('/login?reauth=1&handle=alice.bsky.social');
    await tester.pumpAndSettle();

    final field = tester.widget<TextFormField>(find.byType(TextFormField).first);
    expect(field.controller?.text, 'alice.bsky.social');
    verify(() => authBloc.add(const OAuthLoginRequested(handle: 'alice.bsky.social'))).called(1);

    router.dispose();
  });

  testWidgets('processes oauth callback route while authenticated', (tester) async {
    final router = AppRouter(authBloc: authBloc).router;
    final pendingCallback = Completer<bool>();
    when(() => authBloc.handleOAuthRedirectUri(any())).thenAnswer((_) => pendingCallback.future);

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/oauth/callback?code=abc&state=xyz');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verify(
      () => authBloc.handleOAuthRedirectUri(
        any(that: predicate<Uri>((uri) => uri.path == OAuthCallbackScreen.routePath)),
      ),
    ).called(1);
    expect(router.routeInformationProvider.value.uri.path, equals(OAuthCallbackScreen.routePath));

    pendingCallback.complete(true);
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, isNot(equals(OAuthCallbackScreen.routePath)));
    expect(find.text('No feeds pinned'), findsOneWidget);
    router.dispose();
  });

  testWidgets('processes absolute HTTPS oauth callback route while authenticated', (tester) async {
    final router = AppRouter(authBloc: authBloc).router;
    final pendingCallback = Completer<bool>();
    when(() => authBloc.handleOAuthRedirectUri(any())).thenAnswer((_) => pendingCallback.future);

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('https://lazurite.stormlightlabs.org/oauth/callback?code=abc&state=xyz');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verify(
      () => authBloc.handleOAuthRedirectUri(
        any(
          that: predicate<Uri>(
            (uri) =>
                uri.scheme == 'https' &&
                uri.host == 'lazurite.stormlightlabs.org' &&
                uri.path == OAuthCallbackScreen.routePath &&
                uri.queryParameters['code'] == 'abc' &&
                uri.queryParameters['state'] == 'xyz',
          ),
        ),
      ),
    ).called(1);

    pendingCallback.complete(true);
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, isNot(equals(OAuthCallbackScreen.routePath)));
    expect(find.text('No feeds pinned'), findsOneWidget);
    router.dispose();
  });

  testWidgets('processes compatibility oauth callback route while authenticated', (tester) async {
    final router = AppRouter(authBloc: authBloc).router;
    final pendingCallback = Completer<bool>();
    when(() => authBloc.handleOAuthRedirectUri(any())).thenAnswer((_) => pendingCallback.future);

    await tester.pumpWidget(buildSubjectWithRouter(router));
    router.go('/callback?code=abc&state=xyz');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verify(
      () => authBloc.handleOAuthRedirectUri(
        any(that: predicate<Uri>((uri) => uri.path == OAuthCallbackScreen.compatibilityRoutePath)),
      ),
    ).called(1);
    expect(router.routeInformationProvider.value.uri.path, equals(OAuthCallbackScreen.compatibilityRoutePath));

    pendingCallback.complete(true);
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, isNot(equals(OAuthCallbackScreen.compatibilityRoutePath)));
    expect(find.text('No feeds pinned'), findsOneWidget);

    router.dispose();
  });
}

FeedViewPost _publicFeedPost() => testFeedViewPost(
  uri: 'at://did:plc:author/app.bsky.feed.post/route',
  cid: 'cid-route',
  record: FeedPostRecord(text: 'Public route post', createdAt: DateTime.utc(2026, 5, 18)).toJson(),
  indexedAt: DateTime.utc(2026, 5, 18),
  replyCount: 1,
  repostCount: 2,
  likeCount: 3,
);

ThreadViewPost _publicThread() => ThreadViewPost(post: _publicFeedPost().post);
