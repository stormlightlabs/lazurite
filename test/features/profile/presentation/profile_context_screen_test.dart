import 'package:poptart_core/poptart_core.dart' show AtUri;
import 'package:bloc_test/bloc_test.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/graph/defs.dart' as bsky_graph;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/profile/cubit/profile_context_cubit.dart';
import 'package:lazurite/features/profile/data/profile_context_repository.dart';
import 'package:lazurite/features/profile/presentation/profile_context_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileContextCubit extends MockCubit<ProfileContextState> implements ProfileContextCubit {}

class MockProfileContextRepository extends Mock implements ProfileContextRepository {}

const _did = 'did:plc:alice';
const _handle = 'alice.bsky.social';

ProfileView _profile(String did) =>
    ProfileView(did: did, handle: '$did.bsky.social', displayName: 'User $did', indexedAt: DateTime.utc(2026));

bsky_graph.ListView _list(
  String rkey, {
  bsky_graph.KnownListPurpose purpose = bsky_graph.KnownListPurpose.appBskyGraphDefsCuratelist,
  String? description,
  int? memberCount,
  String creatorHandle = 'owner.bsky.social',
}) => bsky_graph.ListView(
  uri: AtUri.parse('at://did:plc:owner/app.bsky.graph.list/$rkey'),
  cid: 'cid-$rkey',
  creator: ProfileView(did: 'did:plc:owner', handle: creatorHandle),
  name: 'List $rkey',
  purpose: bsky_graph.ListPurpose.knownValue(data: purpose),
  description: description,
  listItemCount: memberCount,
  indexedAt: DateTime.utc(2026),
);

void main() {
  late MockProfileContextCubit cubit;

  ProfileContextState initialState({bool isOwnProfile = false}) =>
      ProfileContextState.initial(did: _did, isOwnProfile: isOwnProfile);

  setUp(() {
    cubit = MockProfileContextCubit();
    when(() => cubit.init()).thenAnswer((_) async {});
    when(() => cubit.loadBlockedBy()).thenAnswer((_) async {});
    when(() => cubit.loadBlockedBy(cursor: any(named: 'cursor'))).thenAnswer((_) async {});
    when(() => cubit.loadBlocking()).thenAnswer((_) async {});
    when(() => cubit.loadBlocking(cursor: any(named: 'cursor'))).thenAnswer((_) async {});
    when(() => cubit.loadListsOn()).thenAnswer((_) async {});
    when(() => cubit.loadListsOn(cursor: any(named: 'cursor'))).thenAnswer((_) async {});
    when(() => cubit.refreshBlockedBy()).thenAnswer((_) async {});
    when(() => cubit.refreshBlocking()).thenAnswer((_) async {});
    when(() => cubit.refreshListsOn()).thenAnswer((_) async {});
  });

  Widget buildSubject({required ProfileContextState state, List<NavigatorObserver> observers = const []}) {
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<ProfileContextState>.empty(), initialState: state);

    final router = GoRouter(
      observers: observers,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => BlocProvider<ProfileContextCubit>.value(
            value: cubit,
            child: const ProfileContextScreen(handle: _handle),
          ),
          routes: [
            GoRoute(
              path: 'profile/:actor',
              builder: (context, state) => Scaffold(body: Text('Profile View ${state.pathParameters['actor']}')),
            ),
            GoRoute(
              path: 'list',
              builder: (context, state) => const Scaffold(body: Text('List Detail')),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  group('ProfileContextScreen', () {
    testWidgets('renders 3 tabs', (tester) async {
      await tester.pumpWidget(buildSubject(state: initialState()));

      expect(find.text('Blocked By'), findsOneWidget);
      expect(find.text('Blocking'), findsOneWidget);
      expect(find.text('Lists'), findsOneWidget);
    });

    testWidgets('AppBar shows title and handle subtitle', (tester) async {
      await tester.pumpWidget(buildSubject(state: initialState()));

      expect(find.text('Profile Context'), findsOneWidget);
      expect(find.text('@$_handle'), findsOneWidget);
    });

    testWidgets('tab labels include counts when non-zero', (tester) async {
      final state = const ProfileContextState.initial(
        did: _did,
        isOwnProfile: false,
      ).copyWith(blockedByCount: 5, listsOnCount: 3);
      await tester.pumpWidget(buildSubject(state: state));

      expect(find.text('Blocked By (5)'), findsOneWidget);
      expect(find.text('Lists (3)'), findsOneWidget);
    });

    group('Blocked By tab', () {
      testWidgets('shows count header on initial state', (tester) async {
        final state = initialState().copyWith(blockedByCount: 10);
        await tester.pumpWidget(buildSubject(state: state));

        expect(find.text('10 accounts'), findsOneWidget);
      });

      testWidgets('shows Show accounts button when status is initial', (tester) async {
        await tester.pumpWidget(buildSubject(state: initialState()));

        expect(find.byKey(const Key('blocked_by_show_accounts')), findsOneWidget);
      });

      testWidgets('Show accounts button calls loadBlockedBy on cubit', (tester) async {
        await tester.pumpWidget(buildSubject(state: initialState()));

        await tester.tap(find.byKey(const Key('blocked_by_show_accounts')));
        verify(() => cubit.loadBlockedBy()).called(1);
      });

      testWidgets('renders profile tiles when loaded', (tester) async {
        final profiles = [_profile('did:plc:user1'), _profile('did:plc:user2')];
        final state = initialState().copyWith(
          blockedByStatus: ProfileContextTabStatus.loaded,
          blockedByEntries: profiles.map((profile) => BlockedByEntry.profile(profile: profile)).toList(),
        );
        await tester.pumpWidget(buildSubject(state: state));

        expect(find.text('User did:plc:user1'), findsOneWidget);
        expect(find.text('User did:plc:user2'), findsOneWidget);
      });

      testWidgets('profile tile navigates to /profile/:actor on tap', (tester) async {
        final profiles = [_profile('did:plc:user1')];
        final state = initialState().copyWith(
          blockedByStatus: ProfileContextTabStatus.loaded,
          blockedByEntries: profiles.map((profile) => BlockedByEntry.profile(profile: profile)).toList(),
        );

        await tester.pumpWidget(buildSubject(state: state));
        await tester.tap(find.text('User did:plc:user1'));
        await tester.pumpAndSettle();

        expect(find.text('Profile View did:plc:user1.bsky.social'), findsOneWidget);
      });

      testWidgets('loads next blocked-by page when scrolled near the end', (tester) async {
        final profiles = List.generate(20, (index) => _profile('did:plc:user$index'));
        final state = initialState().copyWith(
          blockedByStatus: ProfileContextTabStatus.loaded,
          blockedByEntries: profiles.map((profile) => BlockedByEntry.profile(profile: profile)).toList(),
          blockedByCursor: 'next-page',
          blockedByHasMore: true,
        );
        await tester.pumpWidget(buildSubject(state: state));

        await tester.drag(find.byType(CustomScrollView).first, const Offset(0, -4000));
        await tester.pump();

        verify(() => cubit.loadBlockedBy(cursor: 'next-page')).called(greaterThanOrEqualTo(1));
      });

      testWidgets('shows contextualizing note', (tester) async {
        await tester.pumpWidget(buildSubject(state: initialState()));

        expect(find.textContaining('Blocks are a normal part of social media'), findsOneWidget);
      });

      testWidgets('shows empty state when loaded with no profiles', (tester) async {
        final state = initialState().copyWith(blockedByStatus: ProfileContextTabStatus.loaded, blockedByEntries: []);
        await tester.pumpWidget(buildSubject(state: state));

        expect(find.text('No accounts have blocked this user'), findsOneWidget);
      });

      testWidgets('shows unresolved-details message when count is non-zero but no profiles resolved', (tester) async {
        final state = initialState().copyWith(
          blockedByStatus: ProfileContextTabStatus.loaded,
          blockedByCount: 23,
          blockedByEntries: [],
        );
        await tester.pumpWidget(buildSubject(state: state));

        expect(find.textContaining('public Bluesky profile details could not be loaded'), findsOneWidget);
      });

      testWidgets('shows unavailable blocked-by rows inline with resolved profiles', (tester) async {
        final state = initialState().copyWith(
          blockedByStatus: ProfileContextTabStatus.loaded,
          blockedByCount: 23,
          blockedByEntries: [
            BlockedByEntry.profile(profile: _profile('did:plc:user1')),
            const BlockedByEntry.unavailable(did: 'did:plc:suspended', unavailableReason: 'Suspended account'),
          ],
        );
        await tester.pumpWidget(buildSubject(state: state));

        expect(find.byKey(const ValueKey('blocked_by_did:plc:user1')), findsOneWidget);
        expect(find.byKey(const ValueKey('blocked_by_unavailable_did:plc:suspended')), findsOneWidget);
        expect(find.text('did:plc:suspended'), findsOneWidget);
        expect(find.text('Suspended account'), findsOneWidget);
        expect(find.text('User did:plc:user1'), findsOneWidget);
        expect(find.text('23 accounts'), findsOneWidget);
      });

      testWidgets('unavailable blocked-by rows are non-navigable', (tester) async {
        final state = initialState().copyWith(
          blockedByStatus: ProfileContextTabStatus.loaded,
          blockedByCount: 1,
          blockedByEntries: const [
            BlockedByEntry.unavailable(did: 'did:plc:suspended', unavailableReason: 'Suspended account'),
          ],
        );
        await tester.pumpWidget(buildSubject(state: state));

        await tester.tap(find.text('did:plc:suspended'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Profile View'), findsNothing);
      });

      testWidgets('shows error and retry button on error state', (tester) async {
        final state = initialState().copyWith(
          blockedByStatus: ProfileContextTabStatus.error,
          blockedByError: 'Something went wrong',
        );
        await tester.pumpWidget(buildSubject(state: state));

        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('retry calls loadBlockedBy on cubit', (tester) async {
        final state = initialState().copyWith(blockedByStatus: ProfileContextTabStatus.error, blockedByError: 'error');
        await tester.pumpWidget(buildSubject(state: state));

        await tester.tap(find.text('Retry'));
        verify(() => cubit.loadBlockedBy()).called(1);
      });
    });

    group('Blocking tab', () {
      testWidgets('shows explanatory text for non-own profile', (tester) async {
        final state = initialState(isOwnProfile: false);
        await tester.pumpWidget(buildSubject(state: state));

        await tester.tap(find.text('Blocking'));
        await tester.pumpAndSettle();

        expect(find.textContaining('only available when viewing your own profile'), findsOneWidget);
      });

      testWidgets('renders profile tiles for own profile when loaded', (tester) async {
        final profiles = [_profile('did:plc:blocked1')];
        final state = const ProfileContextState.initial(
          did: _did,
          isOwnProfile: true,
        ).copyWith(blockingStatus: ProfileContextTabStatus.loaded, blockingProfiles: profiles);
        await tester.pumpWidget(buildSubject(state: state));

        await tester.tap(find.text('Blocking'));
        await tester.pumpAndSettle();

        expect(find.text('User did:plc:blocked1'), findsOneWidget);
      });

      testWidgets('shows count header for own profile', (tester) async {
        final state = const ProfileContextState.initial(
          did: _did,
          isOwnProfile: true,
        ).copyWith(blockingCount: 4, blockingStatus: ProfileContextTabStatus.loaded);
        await tester.pumpWidget(buildSubject(state: state));

        await tester.tap(find.text('Blocking (4)'));
        await tester.pumpAndSettle();

        expect(find.text('4 accounts'), findsOneWidget);
      });

      testWidgets('shows unavailable-account card on blocking tab', (tester) async {
        final state = const ProfileContextState.initial(did: _did, isOwnProfile: true).copyWith(
          blockingStatus: ProfileContextTabStatus.loaded,
          blockingUnavailable: const [
            UnavailableProfileRef(did: 'did:plc:takedown', reason: 'Suspended or taken-down account'),
          ],
        );
        await tester.pumpWidget(buildSubject(state: state));

        await tester.tap(find.text('Blocking'));
        await tester.pumpAndSettle();

        expect(find.text('Unavailable accounts (1)'), findsOneWidget);
        expect(find.text('did:plc:takedown'), findsOneWidget);
      });

      testWidgets('shows empty state for own profile when loaded with no profiles', (tester) async {
        final state = const ProfileContextState.initial(
          did: _did,
          isOwnProfile: true,
        ).copyWith(blockingStatus: ProfileContextTabStatus.loaded, blockingProfiles: []);
        await tester.pumpWidget(buildSubject(state: state));

        await tester.tap(find.text('Blocking'));
        await tester.pumpAndSettle();

        expect(find.text('Not blocking anyone'), findsOneWidget);
      });

      testWidgets('shows error and retry on error state for own profile', (tester) async {
        final state = const ProfileContextState.initial(
          did: _did,
          isOwnProfile: true,
        ).copyWith(blockingStatus: ProfileContextTabStatus.error, blockingError: 'Block error');
        await tester.pumpWidget(buildSubject(state: state));

        await tester.tap(find.text('Blocking'));
        await tester.pumpAndSettle();

        expect(find.text('Block error'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('retry calls loadBlocking on cubit', (tester) async {
        final state = const ProfileContextState.initial(
          did: _did,
          isOwnProfile: true,
        ).copyWith(blockingStatus: ProfileContextTabStatus.error, blockingError: 'error');
        await tester.pumpWidget(buildSubject(state: state));

        await tester.tap(find.text('Blocking'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Retry'));
        verify(() => cubit.loadBlocking()).called(greaterThanOrEqualTo(1));
      });

      testWidgets('profile tile navigates to /profile/:actor on tap', (tester) async {
        final profiles = [_profile('did:plc:blocked1')];
        final state = const ProfileContextState.initial(
          did: _did,
          isOwnProfile: true,
        ).copyWith(blockingStatus: ProfileContextTabStatus.loaded, blockingProfiles: profiles);
        await tester.pumpWidget(buildSubject(state: state));

        await tester.tap(find.text('Blocking'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('User did:plc:blocked1'));
        await tester.pumpAndSettle();

        expect(find.text('Profile View did:plc:blocked1.bsky.social'), findsOneWidget);
      });
    });

    group('Lists tab', () {
      testWidgets('renders list cards when loaded', (tester) async {
        final lists = [_list('rkey1'), _list('rkey2')];
        final state = initialState().copyWith(listsOnStatus: ProfileContextTabStatus.loaded, listsOn: lists);
        await tester.pumpWidget(buildSubject(state: state));

        await tester.tap(find.text('Lists'));
        await tester.pumpAndSettle();

        expect(find.text('List rkey1'), findsOneWidget);
        expect(find.text('List rkey2'), findsOneWidget);
      });

      testWidgets('groups lists by purpose and shows owner, purpose, and description', (tester) async {
        final lists = [
          _list(
            'curate',
            purpose: bsky_graph.KnownListPurpose.appBskyGraphDefsCuratelist,
            description: 'Curated follows',
            memberCount: 12,
            creatorHandle: 'curator.bsky.social',
          ),
          _list(
            'mod',
            purpose: bsky_graph.KnownListPurpose.appBskyGraphDefsModlist,
            description: 'Moderation context',
            memberCount: 3,
            creatorHandle: 'moderator.bsky.social',
          ),
          _list(
            'ref',
            purpose: bsky_graph.KnownListPurpose.appBskyGraphDefsReferencelist,
            memberCount: 8,
            creatorHandle: 'reference.bsky.social',
          ),
        ];
        final state = initialState().copyWith(listsOnStatus: ProfileContextTabStatus.loaded, listsOn: lists);
        await tester.pumpWidget(buildSubject(state: state));

        await tester.tap(find.text('Lists'));
        await tester.pumpAndSettle();

        expect(find.text('Curation Lists'), findsOneWidget);
        expect(find.text('Moderation Lists'), findsOneWidget);
        expect(find.text('Reference Lists'), findsOneWidget);
        expect(find.text('@curator.bsky.social'), findsOneWidget);
        expect(find.text('Curated follows'), findsOneWidget);
        expect(find.text('CURATE'), findsOneWidget);
        expect(find.text('MOD'), findsOneWidget);
        expect(find.text('REFERENCE'), findsOneWidget);
      });

      testWidgets('list card navigates to /list on tap', (tester) async {
        final lists = [_list('rkey1')];
        final state = initialState().copyWith(listsOnStatus: ProfileContextTabStatus.loaded, listsOn: lists);
        await tester.pumpWidget(buildSubject(state: state));

        await tester.tap(find.text('Lists'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('List rkey1'));
        await tester.pumpAndSettle();

        expect(find.text('List Detail'), findsOneWidget);
      });

      testWidgets('shows empty state when loaded with no lists', (tester) async {
        final state = initialState().copyWith(listsOnStatus: ProfileContextTabStatus.loaded, listsOn: []);
        await tester.pumpWidget(buildSubject(state: state));

        await tester.tap(find.text('Lists'));
        await tester.pumpAndSettle();

        expect(find.text('Not on any lists'), findsOneWidget);
      });

      testWidgets('shows error and retry on error state', (tester) async {
        final state = initialState().copyWith(
          listsOnStatus: ProfileContextTabStatus.error,
          listsOnError: 'List load error',
        );
        await tester.pumpWidget(buildSubject(state: state));

        await tester.tap(find.text('Lists'));
        await tester.pumpAndSettle();

        expect(find.text('List load error'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('retry calls loadListsOn on cubit', (tester) async {
        final state = initialState().copyWith(listsOnStatus: ProfileContextTabStatus.error, listsOnError: 'error');
        await tester.pumpWidget(buildSubject(state: state));

        await tester.tap(find.text('Lists'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Retry'));
        verify(() => cubit.loadListsOn()).called(greaterThanOrEqualTo(1));
      });
    });
  });
}
