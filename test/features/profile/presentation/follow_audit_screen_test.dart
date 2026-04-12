import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/profile/cubit/follow_audit_cubit.dart';
import 'package:lazurite/features/profile/data/follow_audit_repository.dart';
import 'package:lazurite/features/profile/presentation/follow_audit_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockFollowAuditCubit extends MockCubit<FollowAuditState> implements FollowAuditCubit {}

FollowRecord _record(String did, String rkey) {
  return FollowRecord(uri: 'at://did:plc:owner/app.bsky.graph.follow/$rkey', rkey: rkey, subjectDid: did);
}

ClassifiedFollow _classified({
  required String did,
  required String rkey,
  required FollowStatus status,
  required String statusLabel,
  bool selected = false,
}) {
  return ClassifiedFollow(
    record: _record(did, rkey),
    handle: '$rkey.bsky.social',
    status: status,
    statusLabel: statusLabel,
    selected: selected,
  );
}

Widget _buildSubject(MockFollowAuditCubit cubit) {
  return MaterialApp(
    home: BlocProvider<FollowAuditCubit>.value(value: cubit, child: const FollowAuditScreen()),
  );
}

Widget _buildRoutedSubject(MockFollowAuditCubit cubit) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            BlocProvider<FollowAuditCubit>.value(value: cubit, child: const FollowAuditScreen()),
      ),
      GoRoute(
        path: '/profile/view',
        builder: (context, state) => Scaffold(body: Text('profile:${state.uri.queryParameters['actor'] ?? ''}')),
      ),
    ],
  );

  return MaterialApp.router(routerConfig: router);
}

void main() {
  late MockFollowAuditCubit cubit;

  setUp(() {
    cubit = MockFollowAuditCubit();

    when(() => cubit.audit()).thenAnswer((_) async {});
    when(() => cubit.confirmUnfollow()).thenAnswer((_) async {});
    when(() => cubit.toggleSelection(any())).thenReturn(null);
    when(() => cubit.selectAllByStatus(FollowStatus.deleted)).thenReturn(null);
    when(() => cubit.selectAllByStatus(FollowStatus.blockedBy)).thenReturn(null);
    when(() => cubit.deselectAllByStatus(FollowStatus.deleted)).thenReturn(null);
    when(() => cubit.deselectAllByStatus(FollowStatus.blockedBy)).thenReturn(null);
    when(() => cubit.toggleVisibility(FollowStatus.deleted)).thenReturn(null);
    when(() => cubit.toggleVisibility(FollowStatus.blockedBy)).thenReturn(null);

    const initialState = FollowAuditState();
    when(() => cubit.state).thenReturn(initialState);
    whenListen(cubit, const Stream<FollowAuditState>.empty(), initialState: initialState);
  });

  testWidgets('initial state renders Scan button', (tester) async {
    await tester.pumpWidget(_buildSubject(cubit));

    expect(find.byKey(const Key('follow_audit_scan_button')), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
  });

  testWidgets('fetching state shows progress bar with count text', (tester) async {
    const state = FollowAuditState(status: FollowAuditStatus.fetching, progress: 3, totalFollows: 7);
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<FollowAuditState>.empty(), initialState: state);

    await tester.pumpWidget(_buildSubject(cubit));

    expect(find.byKey(const Key('follow_audit_progress')), findsOneWidget);
    expect(find.text('Fetching follows: 3/7'), findsOneWidget);
  });

  testWidgets('ready state renders results list with status badges', (tester) async {
    final results = [
      _classified(did: 'did:plc:alice', rkey: 'alice', status: FollowStatus.deleted, statusLabel: 'Deleted'),
      _classified(did: 'did:plc:bob', rkey: 'bob', status: FollowStatus.blockedBy, statusLabel: 'Blocked by'),
    ];
    final state = FollowAuditState(
      status: FollowAuditStatus.ready,
      results: results,
      visibleStatuses: FollowStatus.values.toSet(),
    );

    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<FollowAuditState>.empty(), initialState: state);

    await tester.pumpWidget(_buildSubject(cubit));

    expect(find.text('alice.bsky.social'), findsOneWidget);
    expect(find.text('bob.bsky.social'), findsOneWidget);
    expect(find.text('Deleted'), findsOneWidget);
    expect(find.text('Blocked by'), findsOneWidget);
  });

  testWidgets('selected record row has destructive tint', (tester) async {
    final results = [
      _classified(
        did: 'did:plc:alice',
        rkey: 'alice',
        status: FollowStatus.deleted,
        statusLabel: 'Deleted',
        selected: true,
      ),
    ];
    final state = FollowAuditState(
      status: FollowAuditStatus.ready,
      results: results,
      visibleStatuses: FollowStatus.values.toSet(),
    );

    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<FollowAuditState>.empty(), initialState: state);

    await tester.pumpWidget(_buildSubject(cubit));

    final row = tester.widget<Container>(find.byKey(const Key('follow_audit_row_alice')));
    expect(row.color, isNotNull);
  });

  testWidgets('Unfollow Selected button shows selected count', (tester) async {
    final results = [
      _classified(
        did: 'did:plc:alice',
        rkey: 'alice',
        status: FollowStatus.deleted,
        statusLabel: 'Deleted',
        selected: true,
      ),
      _classified(did: 'did:plc:bob', rkey: 'bob', status: FollowStatus.blockedBy, statusLabel: 'Blocked by'),
    ];
    final state = FollowAuditState(
      status: FollowAuditStatus.ready,
      results: results,
      visibleStatuses: FollowStatus.values.toSet(),
    );

    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<FollowAuditState>.empty(), initialState: state);

    await tester.pumpWidget(_buildSubject(cubit));

    expect(find.text('Unfollow Selected (1)'), findsOneWidget);
  });

  testWidgets('Unfollow Selected button is disabled when nothing selected', (tester) async {
    final results = [
      _classified(did: 'did:plc:alice', rkey: 'alice', status: FollowStatus.deleted, statusLabel: 'Deleted'),
    ];
    final state = FollowAuditState(
      status: FollowAuditStatus.ready,
      results: results,
      visibleStatuses: FollowStatus.values.toSet(),
    );

    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<FollowAuditState>.empty(), initialState: state);

    await tester.pumpWidget(_buildSubject(cubit));

    final button = tester.widget<FilledButton>(find.byKey(const Key('follow_audit_unfollow_button')));
    expect(button.onPressed, isNull);
  });

  testWidgets('visibility filters hide rows outside visible statuses', (tester) async {
    final results = [
      _classified(did: 'did:plc:alice', rkey: 'alice', status: FollowStatus.deleted, statusLabel: 'Deleted'),
      _classified(did: 'did:plc:bob', rkey: 'bob', status: FollowStatus.blockedBy, statusLabel: 'Blocked by'),
    ];
    final state = FollowAuditState(
      status: FollowAuditStatus.ready,
      results: results,
      visibleStatuses: const {FollowStatus.blockedBy},
    );

    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<FollowAuditState>.empty(), initialState: state);

    await tester.pumpWidget(_buildSubject(cubit));

    expect(find.text('alice.bsky.social'), findsNothing);
    expect(find.text('bob.bsky.social'), findsOneWidget);

    await tester.tap(find.byKey(const Key('follow_audit_visibility_deleted')));
    verify(() => cubit.toggleVisibility(FollowStatus.deleted)).called(1);
  });

  testWidgets('Select All checkbox calls selectAllByStatus for the category', (tester) async {
    final results = [
      _classified(did: 'did:plc:alice', rkey: 'alice', status: FollowStatus.deleted, statusLabel: 'Deleted'),
      _classified(did: 'did:plc:bob', rkey: 'bob', status: FollowStatus.deleted, statusLabel: 'Deleted'),
    ];
    final state = FollowAuditState(
      status: FollowAuditStatus.ready,
      results: results,
      visibleStatuses: FollowStatus.values.toSet(),
    );

    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<FollowAuditState>.empty(), initialState: state);

    await tester.pumpWidget(_buildSubject(cubit));

    await tester.tap(find.byKey(const Key('follow_audit_select_all_deleted')));
    verify(() => cubit.selectAllByStatus(FollowStatus.deleted)).called(1);
  });

  testWidgets('complete state shows unfollow count message', (tester) async {
    const state = FollowAuditState(status: FollowAuditStatus.complete, unfollowedCount: 2, visibleStatuses: {});
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<FollowAuditState>.empty(), initialState: state);

    await tester.pumpWidget(_buildSubject(cubit));

    expect(find.byKey(const Key('follow_audit_complete_message')), findsOneWidget);
    expect(find.text('Unfollowed 2 account(s)'), findsOneWidget);
  });

  testWidgets('error state shows message and retry button', (tester) async {
    const state = FollowAuditState(status: FollowAuditStatus.error, errorMessage: 'network failure');
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<FollowAuditState>.empty(), initialState: state);

    await tester.pumpWidget(_buildSubject(cubit));

    expect(find.text('network failure'), findsOneWidget);
    expect(find.byKey(const Key('follow_audit_retry_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('follow_audit_retry_button')));
    verify(() => cubit.audit()).called(1);
  });

  testWidgets('ready state with no results shows empty message', (tester) async {
    final state = FollowAuditState(
      status: FollowAuditStatus.ready,
      results: const [],
      visibleStatuses: FollowStatus.values.toSet(),
    );
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<FollowAuditState>.empty(), initialState: state);

    await tester.pumpWidget(_buildSubject(cubit));

    expect(find.byKey(const Key('follow_audit_empty_message')), findsOneWidget);
    expect(find.text('No problematic follows found'), findsOneWidget);
  });

  testWidgets('tapping a handle navigates to profile screen', (tester) async {
    final results = [
      _classified(did: 'did:plc:alice', rkey: 'alice', status: FollowStatus.deleted, statusLabel: 'Deleted'),
    ];
    final state = FollowAuditState(
      status: FollowAuditStatus.ready,
      results: results,
      visibleStatuses: FollowStatus.values.toSet(),
    );
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<FollowAuditState>.empty(), initialState: state);

    await tester.pumpWidget(_buildRoutedSubject(cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('follow_audit_handle_alice')));
    await tester.pumpAndSettle();

    expect(find.text('profile:did:plc:alice'), findsOneWidget);
  });

  testWidgets('renders horizontal filter chips on narrow width', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(500, 900));

    final state = FollowAuditState(
      status: FollowAuditStatus.ready,
      results: [_classified(did: 'did:plc:alice', rkey: 'alice', status: FollowStatus.deleted, statusLabel: 'Deleted')],
      visibleStatuses: FollowStatus.values.toSet(),
    );
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<FollowAuditState>.empty(), initialState: state);

    await tester.pumpWidget(_buildSubject(cubit));

    expect(find.byKey(const Key('follow_audit_filter_chips')), findsOneWidget);
    expect(find.byKey(const Key('follow_audit_filter_sidebar')), findsNothing);
  });

  testWidgets('renders sidebar filters on wide width', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(900, 900));

    final state = FollowAuditState(
      status: FollowAuditStatus.ready,
      results: [_classified(did: 'did:plc:alice', rkey: 'alice', status: FollowStatus.deleted, statusLabel: 'Deleted')],
      visibleStatuses: FollowStatus.values.toSet(),
    );
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<FollowAuditState>.empty(), initialState: state);

    await tester.pumpWidget(_buildSubject(cubit));

    expect(find.byKey(const Key('follow_audit_filter_chips')), findsNothing);
    expect(find.byKey(const Key('follow_audit_filter_sidebar')), findsOneWidget);
  });
}
