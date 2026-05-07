import 'package:atproto_core/atproto_core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:lazurite/features/profile/cubit/profile_connections_cubit.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:lazurite/features/profile/data/profile_repository.dart';
import 'package:lazurite/features/profile/presentation/profile_connections_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockProfileActionRepository extends Mock implements ProfileActionRepository {}

class MockConnectivityCubit extends MockCubit<ConnectivityState> implements ConnectivityCubit {}

void main() {
  late MockProfileRepository profileRepository;
  late MockProfileActionRepository profileActionRepository;
  late MockConnectivityCubit connectivityCubit;

  const subject = ProfileView(did: 'did:plc:alice', handle: 'alice.bsky.social');
  final followingUri = AtUri.parse('at://did:plc:me/app.bsky.graph.follow/abc123');
  final astronaut = ProfileView(
    did: 'did:plc:astro',
    handle: 'astro.bsky.social',
    displayName: 'Lina Orbit',
    description: 'Space systems engineer',
    createdAt: DateTime.utc(2024, 1, 1),
  );
  final followingAstronaut = astronaut.copyWith(viewer: ViewerState(following: followingUri));
  const gardener = ProfileView(
    did: 'did:plc:garden',
    handle: 'garden.bsky.social',
    displayName: 'Moss Vale',
    description: 'Native plant notes',
  );

  setUp(() {
    profileRepository = MockProfileRepository();
    profileActionRepository = MockProfileActionRepository();
    connectivityCubit = MockConnectivityCubit();

    when(() => connectivityCubit.state).thenReturn(const ConnectivityState.online());
    whenListen(
      connectivityCubit,
      const Stream<ConnectivityState>.empty(),
      initialState: const ConnectivityState.online(),
    );
  });

  Widget buildSubject({ProfileConnectionsTab initialTab = ProfileConnectionsTab.following}) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProfileRepository>.value(value: profileRepository),
        RepositoryProvider<ProfileActionRepository>.value(value: profileActionRepository),
        RepositoryProvider<String>.value(value: 'did:plc:me'),
      ],
      child: BlocProvider(
        create: (_) => ProfileConnectionsCubit(repository: profileRepository, actor: subject.did),
        child: BlocProvider<ConnectivityCubit>.value(
          value: connectivityCubit,
          child: MaterialApp(
            home: ProfileConnectionsScreen(actor: subject.did, handle: subject.handle, initialTab: initialTab),
          ),
        ),
      ),
    );
  }

  testWidgets('renders profiles with relationship action, description, and joined age', (tester) async {
    when(
      () => profileRepository.getFollowing(actor: subject.did, cursor: null, limit: 100),
    ).thenAnswer((_) async => ProfileConnectionsPage(subject: subject, profiles: [astronaut, followingAstronaut]));
    when(
      () => profileActionRepository.followActor(did: astronaut.did),
    ).thenAnswer((_) async => 'at://did:plc:me/app.bsky.graph.follow/new-follow');

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('@alice.bsky.social'), findsOneWidget);
    expect(find.text('Mutuals'), findsOneWidget);
    expect(find.text('Lina Orbit'), findsWidgets);
    expect(find.text('Space systems engineer'), findsWidgets);
    expect(find.textContaining('Joined'), findsWidgets);
    expect(find.widgetWithText(FilledButton, 'Follow'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Following'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Follow'));
    await tester.pumpAndSettle();

    verify(() => profileActionRepository.followActor(did: astronaut.did)).called(1);
  });

  testWidgets('fuzzy search filters by profile description', (tester) async {
    var firstPageCalls = 0;
    when(() => profileRepository.getFollowing(actor: subject.did, cursor: null, limit: 100)).thenAnswer((_) async {
      firstPageCalls += 1;
      if (firstPageCalls == 1) {
        return const ProfileConnectionsPage(subject: subject, profiles: [gardener], cursor: 'next');
      }
      return const ProfileConnectionsPage(subject: subject, profiles: [gardener], cursor: 'next');
    });
    when(
      () => profileRepository.getFollowing(actor: subject.did, cursor: 'next', limit: 100),
    ).thenAnswer((_) async => ProfileConnectionsPage(subject: subject, profiles: [astronaut]));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('profile_connections_search_field')), 'space engineer');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Lina Orbit'), findsOneWidget);
    expect(find.text('Moss Vale'), findsNothing);
    expect(find.text('Searched 2 accounts'), findsOneWidget);
  });

  testWidgets('loads the requested initial followers tab', (tester) async {
    when(
      () => profileRepository.getFollowers(actor: subject.did, cursor: null, limit: 100),
    ).thenAnswer((_) async => const ProfileConnectionsPage(subject: subject, profiles: [gardener]));

    await tester.pumpWidget(buildSubject(initialTab: ProfileConnectionsTab.followers));
    await tester.pumpAndSettle();

    verify(() => profileRepository.getFollowers(actor: subject.did, cursor: null, limit: 100)).called(1);
    expect(find.text('Moss Vale'), findsOneWidget);
  });
}
