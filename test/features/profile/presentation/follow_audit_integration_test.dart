import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/profile/cubit/follow_audit_cubit.dart';
import 'package:lazurite/features/profile/data/follow_audit_repository.dart';
import 'package:lazurite/features/profile/presentation/follow_audit_screen.dart';

class _ScriptedFollowAuditRepository implements FollowAuditRepository {
  _ScriptedFollowAuditRepository({required this.records, required this.classified});

  final List<FollowRecord> records;
  final List<ClassifiedFollow> classified;
  final List<List<ClassifiedFollow>> unfollowCalls = [];

  @override
  Future<int> batchUnfollow(List<ClassifiedFollow> selected, String ownDid) async {
    unfollowCalls.add(selected);
    return selected.length;
  }

  @override
  Future<({int failedCount, List<ClassifiedFollow> results})> classifyFollows(
    List<FollowRecord> records,
    String ownDid, {
    void Function(int classified)? onProgress,
  }) async {
    for (var i = 1; i <= records.length; i++) {
      onProgress?.call(i);
    }
    return (results: classified, failedCount: 0);
  }

  @override
  Stream<FollowAuditBatch> scanFollows(String did) async* {
    yield FollowAuditBatch(
      scannedCount: records.length,
      classifiedCount: records.length,
      results: classified,
      failedCount: 0,
      isComplete: true,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('scan follows, select one, and batch unfollow to completion', (tester) async {
    final records = [
      const FollowRecord(
        uri: 'at://did:plc:me/app.bsky.graph.follow/alice',
        rkey: 'alice',
        subjectDid: 'did:plc:alice',
      ),
      const FollowRecord(uri: 'at://did:plc:me/app.bsky.graph.follow/bob', rkey: 'bob', subjectDid: 'did:plc:bob'),
    ];

    final classified = [
      ClassifiedFollow(
        record: records[0],
        handle: 'alice.bsky.social',
        status: FollowStatus.deleted,
        statusLabel: 'Deleted',
      ),
      ClassifiedFollow(
        record: records[1],
        handle: 'bob.bsky.social',
        status: FollowStatus.blockedBy,
        statusLabel: 'Blocked by',
      ),
    ];

    final repository = _ScriptedFollowAuditRepository(records: records, classified: classified);
    final cubit = FollowAuditCubit(repository: repository, ownDid: 'did:plc:me');
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FollowAuditCubit>.value(value: cubit, child: const FollowAuditScreen()),
      ),
    );

    expect(find.text('Scan'), findsOneWidget);

    await tester.tap(find.byKey(const Key('follow_audit_scan_button')));
    await tester.pumpAndSettle();

    expect(find.text('alice.bsky.social'), findsOneWidget);
    expect(find.text('bob.bsky.social'), findsOneWidget);

    await tester.tap(find.byKey(const Key('follow_audit_checkbox_alice')));
    await tester.pumpAndSettle();

    expect(find.text('Unfollow Selected (1)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('follow_audit_unfollow_button')));
    await tester.pumpAndSettle();

    expect(find.text('Unfollowed 1 account(s)'), findsOneWidget);
    expect(repository.unfollowCalls.length, 1);
    expect(repository.unfollowCalls.first.length, 1);
    expect(repository.unfollowCalls.first.first.record.rkey, 'alice');
  });
}
