import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/feed/bloc/feed_bloc.dart';
import 'package:lazurite/features/profile/bloc/profile_bloc.dart';
import 'package:lazurite/features/profile/presentation/profile_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState> implements ProfileBloc {}

class MockFeedBloc extends MockBloc<FeedEvent, FeedState> implements FeedBloc {}

void main() {
  late MockAuthBloc authBloc;
  late MockProfileBloc profileBloc;
  late MockFeedBloc feedBloc;

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

  setUp(() {
    authBloc = MockAuthBloc();
    profileBloc = MockProfileBloc();
    feedBloc = MockFeedBloc();

    when(() => authBloc.state).thenReturn(const AuthState.authenticated(tokens));
    when(() => profileBloc.state).thenReturn(ProfileState.loaded(profile: profile));
    when(() => feedBloc.state).thenReturn(
      const FeedState.loaded(actor: 'did:plc:me', posts: [], filter: FeedFilter.postsNoReplies, hasMore: false),
    );

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
  });

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<ProfileBloc>.value(value: profileBloc),
        BlocProvider<FeedBloc>.value(value: feedBloc),
      ],
      child: const MaterialApp(home: ProfileScreen()),
    );
  }

  testWidgets('loads posts filter by default and renders the required profile fields', (tester) async {
    await tester.pumpWidget(buildSubject());

    verify(() => profileBloc.add(const ProfileLoadRequested(actor: 'did:plc:me'))).called(1);
    verify(
      () => feedBloc.add(const FeedLoadRequested(actor: 'did:plc:me', filter: FeedFilter.postsNoReplies)),
    ).called(1);

    expect(find.text('River Tam'), findsOneWidget);
    expect(find.text('@me.bsky.social'), findsOneWidget);
    expect(find.text('Signal and signal boost.'), findsOneWidget);
    expect(find.text('she/her'), findsOneWidget);
    expect(find.text('river.example'), findsOneWidget);
    expect(find.text('Joined March 2024'), findsOneWidget);
  });

  testWidgets('maps tabs to the expected server filters', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Replies'));
    await tester.pump();

    verify(
      () => feedBloc.add(const FeedLoadRequested(actor: 'did:plc:me', filter: FeedFilter.postsAndAuthorThreads)),
    ).called(1);

    await tester.tap(find.text('Media'));
    await tester.pump();

    verify(
      () => feedBloc.add(const FeedLoadRequested(actor: 'did:plc:me', filter: FeedFilter.postsWithMedia)),
    ).called(1);
  });
}
