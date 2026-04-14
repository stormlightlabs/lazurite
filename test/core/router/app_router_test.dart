import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/router/app_router.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/account/cubit/account_switcher_cubit.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
import 'package:lazurite/features/messages/bloc/convo_list_bloc.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockFeedPreferencesCubit extends MockCubit<FeedPreferencesState> implements FeedPreferencesCubit {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState> implements ProfileBloc {}

class MockFeedBloc extends MockBloc<FeedEvent, FeedState> implements FeedBloc {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

class MockAccountSwitcherCubit extends MockCubit<AccountSwitcherState> implements AccountSwitcherCubit {}

class MockUnreadCountCubit extends MockCubit<UnreadCountState> implements UnreadCountCubit {}

class MockConvoListBloc extends MockBloc<ConvoListEvent, ConvoListState> implements ConvoListBloc {}

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MockAuthBloc authBloc;
  late MockFeedPreferencesCubit feedPreferencesCubit;
  late MockProfileBloc profileBloc;
  late MockFeedBloc feedBloc;
  late MockSettingsCubit settingsCubit;
  late MockConnectivityCubit connectivityCubit;
  late MockAccountSwitcherCubit accountSwitcherCubit;
  late MockUnreadCountCubit unreadCountCubit;
  late MockConvoListBloc convoListBloc;
  late MockNotificationRepository notificationRepository;
  late StreamController<AuthState> authController;
  late AuthState currentAuthState;

  const tokens = AuthTokens(
    accessToken: 'access',
    refreshToken: 'refresh',
    did: 'did:plc:me',
    handle: 'me.bsky.social',
    displayName: 'River Tam',
  );

  final profile = ProfileViewDetailed(
    did: 'did:plc:me',
    handle: 'me.bsky.social',
    displayName: 'River Tam',
    followersCount: 12,
    followsCount: 8,
    postsCount: 3,
    createdAt: DateTime.utc(2024, 3, 1),
  );

  setUp(() {
    authBloc = MockAuthBloc();
    feedPreferencesCubit = MockFeedPreferencesCubit();
    profileBloc = MockProfileBloc();
    feedBloc = MockFeedBloc();
    settingsCubit = MockSettingsCubit();
    connectivityCubit = MockConnectivityCubit();
    accountSwitcherCubit = MockAccountSwitcherCubit();
    unreadCountCubit = MockUnreadCountCubit();
    convoListBloc = MockConvoListBloc();
    notificationRepository = MockNotificationRepository();
    authController = StreamController<AuthState>.broadcast();
    currentAuthState = const AuthState.authenticated(tokens);

    when(() => authBloc.state).thenAnswer((_) => currentAuthState);
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
    when(() => connectivityCubit.state).thenReturn(const ConnectivityState.online());
    when(() => accountSwitcherCubit.state).thenReturn(const AccountSwitcherState.ready(accounts: []));
    when(() => unreadCountCubit.state).thenReturn(const UnreadCountState(0));
    when(() => convoListBloc.state).thenReturn(const ConvoListState.loaded(convos: [], cursor: null, hasMore: false));
    when(() => notificationRepository.getUnreadCount()).thenAnswer((_) async => 0);

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

  Widget buildSubject() => MultiBlocProvider(
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
      child: MaterialApp.router(routerConfig: AppRouter(authBloc: authBloc).router),
    ),
  );

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

  testWidgets('bottom navigation bar shows 4 tabs with uppercase labels', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.destinations.length, 4);

    final destinations = navBar.destinations.cast<NavigationDestination>();
    expect(destinations.map((d) => d.label), containsAll(['HOME', 'SEARCH', 'ALERTS', 'PROFILE']));
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

    await tester.tap(find.text('PROFILE'));
    await tester.pumpAndSettle();

    final navBarAfter = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBarAfter.selectedIndex, 3);
    expect(find.text('RIVER TAM'), findsOneWidget);
  });

  testWidgets('LazuriteAppBar shows section label and hamburger on home screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsAtLeastNWidgets(1));
    expect(find.byTooltip('Open menu'), findsOneWidget);
  });

  testWidgets('redirects to login after logout without crashing on the settings route', (tester) async {
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

    expect(find.text('Continue'), findsOneWidget);
    expect(tester.takeException(), isNull);

    router.dispose();
  });
}
