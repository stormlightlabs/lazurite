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
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockFeedPreferencesCubit extends MockCubit<FeedPreferencesState> implements FeedPreferencesCubit {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState> implements ProfileBloc {}

class MockFeedBloc extends MockBloc<FeedEvent, FeedState> implements FeedBloc {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

void main() {
  late MockAuthBloc authBloc;
  late MockFeedPreferencesCubit feedPreferencesCubit;
  late MockProfileBloc profileBloc;
  late MockFeedBloc feedBloc;
  late MockSettingsCubit settingsCubit;

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

    when(() => authBloc.state).thenReturn(const AuthState.authenticated(tokens));
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

    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: const AuthState.authenticated(tokens));
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
  });

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<FeedPreferencesCubit>.value(value: feedPreferencesCubit),
        BlocProvider<ProfileBloc>.value(value: profileBloc),
        BlocProvider<FeedBloc>.value(value: feedBloc),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
      ],
      child: MaterialApp.router(routerConfig: AppRouter(authBloc: authBloc).router),
    );
  }

  testWidgets('renders bottom navigation and switches authenticated branches', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsAtLeastNWidgets(1));
    expect(find.text('Profile'), findsAtLeastNWidgets(1));
    expect(find.text('Settings'), findsAtLeastNWidgets(1));
    expect(find.text('No feeds pinned'), findsOneWidget);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    expect(find.text('River Tam'), findsOneWidget);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsAtLeastNWidgets(1));
    expect(find.text('APPEARANCE'), findsOneWidget);
  });
}
