import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/profile/cubit/suggested_follows_cubit.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';
import 'package:lazurite/features/profile/presentation/widgets/suggested_follows_sheet.dart';
import 'package:mocktail/mocktail.dart';

class MockSuggestedFollowsCubit extends MockCubit<SuggestedFollowsState> implements SuggestedFollowsCubit {}

class MockProfileActionRepository extends Mock implements ProfileActionRepository {}

ProfileView _profile(String did, {String? displayName}) =>
    ProfileView(did: did, handle: '$did.bsky.social', displayName: displayName, indexedAt: DateTime.utc(2026));

void main() {
  late MockSuggestedFollowsCubit cubit;
  late MockProfileActionRepository profileActionRepository;

  setUp(() {
    cubit = MockSuggestedFollowsCubit();
    profileActionRepository = MockProfileActionRepository();
  });

  Widget buildSubject() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => RepositoryProvider<ProfileActionRepository>.value(
            value: profileActionRepository,
            child: Scaffold(
              body: BlocProvider<SuggestedFollowsCubit>.value(
                value: cubit,
                child: const SuggestedFollowsSheet(actor: 'did:plc:target'),
              ),
            ),
          ),
          routes: [
            GoRoute(
              path: 'profile/:actor',
              builder: (context, state) => Scaffold(body: Text('Profile View ${state.pathParameters['actor']}')),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows loading indicator when state is loading', (tester) async {
    when(() => cubit.state).thenReturn(const SuggestedFollowsState.loading());
    whenListen(cubit, const Stream<SuggestedFollowsState>.empty(), initialState: const SuggestedFollowsState.loading());

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message when state has error', (tester) async {
    when(() => cubit.state).thenReturn(const SuggestedFollowsState.error('Something went wrong'));
    whenListen(
      cubit,
      const Stream<SuggestedFollowsState>.empty(),
      initialState: const SuggestedFollowsState.error('Something went wrong'),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Something went wrong'), findsOneWidget);
  });

  testWidgets('shows empty state when loaded with no suggestions', (tester) async {
    when(() => cubit.state).thenReturn(const SuggestedFollowsState.loaded([]));
    whenListen(
      cubit,
      const Stream<SuggestedFollowsState>.empty(),
      initialState: const SuggestedFollowsState.loaded([]),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('No suggestions found'), findsOneWidget);
  });

  testWidgets('renders profile tiles when loaded with suggestions', (tester) async {
    final profiles = [
      _profile('did:plc:bob', displayName: 'Bob Builder'),
      _profile('did:plc:carol', displayName: 'Carol Danvers'),
    ];
    when(() => cubit.state).thenReturn(SuggestedFollowsState.loaded(profiles));
    whenListen(
      cubit,
      const Stream<SuggestedFollowsState>.empty(),
      initialState: SuggestedFollowsState.loaded(profiles),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Bob Builder'), findsOneWidget);
    expect(find.text('@did:plc:bob.bsky.social'), findsOneWidget);
    expect(find.text('Carol Danvers'), findsOneWidget);
    expect(find.text('@did:plc:carol.bsky.social'), findsOneWidget);
  });

  testWidgets('shows Follow button for unfollowed profiles', (tester) async {
    final profiles = [_profile('did:plc:bob', displayName: 'Bob Builder')];
    when(() => profileActionRepository.followActor(did: 'did:plc:bob')).thenAnswer((_) async => 'at://follow/bob');
    when(() => cubit.state).thenReturn(SuggestedFollowsState.loaded(profiles));
    whenListen(
      cubit,
      const Stream<SuggestedFollowsState>.empty(),
      initialState: SuggestedFollowsState.loaded(profiles),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Follow'), findsOneWidget);
  });

  testWidgets('follow button toggles using profile action repository', (tester) async {
    final profiles = [_profile('did:plc:bob', displayName: 'Bob Builder')];
    when(() => profileActionRepository.followActor(did: 'did:plc:bob')).thenAnswer((_) async => 'at://follow/bob');
    when(() => cubit.state).thenReturn(SuggestedFollowsState.loaded(profiles));
    whenListen(
      cubit,
      const Stream<SuggestedFollowsState>.empty(),
      initialState: SuggestedFollowsState.loaded(profiles),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.text('Follow'));
    await tester.pumpAndSettle();

    verify(() => profileActionRepository.followActor(did: 'did:plc:bob')).called(1);
    expect(find.text('Following'), findsOneWidget);
  });

  testWidgets('tapping a suggestion navigates to /profile/:actor', (tester) async {
    final profiles = [_profile('did:plc:bob', displayName: 'Bob Builder')];
    when(() => cubit.state).thenReturn(SuggestedFollowsState.loaded(profiles));
    whenListen(
      cubit,
      const Stream<SuggestedFollowsState>.empty(),
      initialState: SuggestedFollowsState.loaded(profiles),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.text('Bob Builder'));
    await tester.pumpAndSettle();

    expect(find.text('Profile View did:plc:bob'), findsOneWidget);
  });

  testWidgets('shows sheet title', (tester) async {
    when(() => cubit.state).thenReturn(const SuggestedFollowsState.loaded([]));
    whenListen(
      cubit,
      const Stream<SuggestedFollowsState>.empty(),
      initialState: const SuggestedFollowsState.loaded([]),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Suggested Follows'), findsOneWidget);
  });
}
