import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/router/app_router.dart';
import 'package:lazurite/core/theme/app_theme.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
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

class MockUnreadCountCubit extends MockCubit<UnreadCountState> implements UnreadCountCubit {}

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MockAuthBloc authBloc;
  late MockFeedPreferencesCubit feedPreferencesCubit;
  late MockProfileBloc profileBloc;
  late MockFeedBloc feedBloc;
  late MockSettingsCubit settingsCubit;
  late MockUnreadCountCubit unreadCountCubit;
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
    unreadCountCubit = MockUnreadCountCubit();
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
    when(() => unreadCountCubit.state).thenReturn(const UnreadCountState(0));
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
    whenListen(unreadCountCubit, const Stream<UnreadCountState>.empty(), initialState: const UnreadCountState(0));
  });

  tearDown(() async {
    await authController.close();
  });

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<FeedPreferencesCubit>.value(value: feedPreferencesCubit),
        BlocProvider<ProfileBloc>.value(value: profileBloc),
        BlocProvider<FeedBloc>.value(value: feedBloc),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
        BlocProvider<UnreadCountCubit>.value(value: unreadCountCubit),
      ],
      child: RepositoryProvider<NotificationRepository>(
        create: (_) => notificationRepository,
        child: MaterialApp.router(routerConfig: AppRouter(authBloc: authBloc).router),
      ),
    );
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
    expect(find.text('New Post'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Log Out'), 200, scrollable: find.byType(Scrollable).last);
    expect(find.text('Log Out'), findsOneWidget);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    expect(find.text('River Tam'), findsOneWidget);

    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    expect(find.text('APPEARANCE'), findsOneWidget);
  });

  testWidgets('redirects to login after logout without crashing on the settings branch', (tester) async {
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
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final app = MaterialApp.router(routerConfig: router);
          if (!state.isAuthenticated) {
            return app;
          }

          return MultiBlocProvider(
            providers: [BlocProvider<UnreadCountCubit>.value(value: unreadCountCubit)],
            child: RepositoryProvider<NotificationRepository>.value(value: notificationRepository, child: app),
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

    expect(find.text('Continue with BlueSky OAuth'), findsOneWidget);
    expect(tester.takeException(), isNull);

    router.dispose();
  });
}
