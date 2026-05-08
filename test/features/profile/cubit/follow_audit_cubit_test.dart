import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/profile/cubit/follow_audit_cubit.dart';
import 'package:lazurite/features/profile/data/follow_audit_repository.dart';

class _FakeFollowAuditRepository implements FollowAuditRepository {
  _FakeFollowAuditRepository({
    List<FollowRecord> fetchResult = const [],
    List<ClassifiedFollow> classifyResult = const [],
    List<FollowAuditBatch>? scanBatches,
    int classifyFailedCount = 0,
    int batchUnfollowResult = 0,
    Exception? fetchError,
    Exception? classifyError,
    Exception? scanError,
    Exception? unfollowError,
    List<int>? fetchProgressValues,
    List<int>? classifyProgressValues,
    Completer<void>? scanGate,
  }) : _fetchResult = fetchResult,
       _classifyResult = classifyResult,
       _scanBatches = scanBatches,
       _classifyFailedCount = classifyFailedCount,
       _batchUnfollowResult = batchUnfollowResult,
       _fetchError = fetchError,
       _classifyError = classifyError,
       _scanError = scanError,
       _unfollowError = unfollowError,
       _fetchProgressValues = fetchProgressValues,
       _classifyProgressValues = classifyProgressValues,
       _scanGate = scanGate;

  final List<FollowRecord> _fetchResult;
  final List<ClassifiedFollow> _classifyResult;
  final List<FollowAuditBatch>? _scanBatches;
  final int _classifyFailedCount;
  final int _batchUnfollowResult;
  final Exception? _fetchError;
  final Exception? _classifyError;
  final Exception? _scanError;
  final Exception? _unfollowError;
  final List<int>? _fetchProgressValues;
  final List<int>? _classifyProgressValues;
  final Completer<void>? _scanGate;

  @override
  Future<List<FollowRecord>> fetchAllFollows(String did, {void Function(int fetched)? onProgress}) async {
    if (_fetchError != null) throw _fetchError;
    if (_fetchProgressValues != null) {
      for (final v in _fetchProgressValues) {
        onProgress?.call(v);
      }
    }
    return _fetchResult;
  }

  @override
  Future<({List<ClassifiedFollow> results, int failedCount})> classifyFollows(
    List<FollowRecord> records,
    String ownDid, {
    void Function(int classified)? onProgress,
  }) async {
    if (_classifyError != null) throw _classifyError;
    if (_classifyProgressValues != null) {
      for (final v in _classifyProgressValues) {
        onProgress?.call(v);
      }
    }
    return (results: _classifyResult, failedCount: _classifyFailedCount);
  }

  @override
  Future<int> batchUnfollow(List<ClassifiedFollow> selected, String ownDid) async {
    if (_unfollowError != null) throw _unfollowError;
    return _batchUnfollowResult;
  }

  @override
  Stream<FollowAuditBatch> scanFollows(String did) async* {
    if (_scanError != null) throw _scanError;

    final batches = _scanBatches;
    if (batches != null) {
      for (final batch in batches) {
        yield batch;
        await Future<void>.delayed(Duration.zero);
      }
      await _scanGate?.future;
      return;
    }

    if (_fetchError != null) throw _fetchError;
    if (_classifyError != null) throw _classifyError;
    final scanned = _fetchResult.length;
    yield FollowAuditBatch(
      scannedCount: scanned,
      classifiedCount: scanned,
      results: _classifyResult,
      failedCount: _classifyFailedCount,
      isComplete: true,
    );
    await _scanGate?.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _ownDid = 'did:plc:owner';

FollowRecord _record(String did, [String? rkey]) {
  final k = rkey ?? 'rkey${did.hashCode.abs()}';
  return FollowRecord(uri: 'at:///app.bsky.graph.follow/$k', rkey: k, subjectDid: did);
}

ClassifiedFollow _classified(String did, FollowStatus status) {
  return ClassifiedFollow(record: _record(did), handle: '$did.bsky.social', status: status, statusLabel: status.name);
}

FollowAuditCubit _cubit(_FakeFollowAuditRepository repo) => FollowAuditCubit(repository: repo, ownDid: _ownDid);

void main() {
  group('FollowAuditState', () {
    test('initial state has correct defaults', () {
      const s = FollowAuditState();
      expect(s.status, FollowAuditStatus.initial);
      expect(s.results, isEmpty);
      expect(s.totalFollows, 0);
      expect(s.progress, 0);
      expect(s.failedProfiles, 0);
      expect(s.unfollowedCount, 0);
      expect(s.errorMessage, isNull);
      expect(s.visibleStatuses, isEmpty);
    });

    test('selectedResults returns only selected items', () {
      final s = FollowAuditState(
        results: [
          _classified('did:plc:a', FollowStatus.deleted),
          _classified('did:plc:b', FollowStatus.blockedBy).copyWith(selected: true),
        ],
      );
      expect(s.selectedResults.length, 1);
    });

    test('copyWith clears errorMessage when clearError is true', () {
      const s = FollowAuditState(errorMessage: 'oops');
      final cleared = s.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
    });

    test('Equatable props cover all fields', () {
      const a = FollowAuditState(totalFollows: 5);
      const b = FollowAuditState(totalFollows: 5);
      expect(a, equals(b));

      const c = FollowAuditState(totalFollows: 6);
      expect(a, isNot(equals(c)));
    });
  });

  group('FollowAuditCubit.audit', () {
    blocTest<FollowAuditCubit, FollowAuditState>(
      'transitions initial → classifying → ready',
      build: () => _cubit(
        _FakeFollowAuditRepository(
          fetchResult: [_record('did:plc:alice')],
          classifyResult: [_classified('did:plc:alice', FollowStatus.blockedBy)],
        ),
      ),
      act: (cubit) => cubit.audit(),
      expect: () => [
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.classifying)
            .having((s) => s.results, 'results', isEmpty),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.ready)
            .having((s) => s.results.length, 'results', 1)
            .having((s) => s.totalFollows, 'totalFollows', 1),
      ],
    );

    blocTest<FollowAuditCubit, FollowAuditState>(
      'appends streamed classified batches',
      build: () => _cubit(
        _FakeFollowAuditRepository(
          scanBatches: [
            FollowAuditBatch(
              scannedCount: 2,
              classifiedCount: 2,
              results: [_classified('did:plc:a', FollowStatus.deleted)],
              failedCount: 0,
              isComplete: false,
            ),
            FollowAuditBatch(
              scannedCount: 3,
              classifiedCount: 3,
              results: [_classified('did:plc:b', FollowStatus.blockedBy)],
              failedCount: 1,
              isComplete: true,
            ),
          ],
        ),
      ),
      act: (cubit) => cubit.audit(),
      expect: () => [
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.classifying)
            .having((s) => s.results, 'results', isEmpty),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.classifying)
            .having((s) => s.progress, 'progress', 2)
            .having((s) => s.totalFollows, 'totalFollows', 2)
            .having((s) => s.results.length, 'results', 1),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.ready)
            .having((s) => s.progress, 'progress', 3)
            .having((s) => s.totalFollows, 'totalFollows', 3)
            .having((s) => s.results.length, 'results', 2)
            .having((s) => s.failedProfiles, 'failedProfiles', 1),
      ],
    );

    blocTest<FollowAuditCubit, FollowAuditState>(
      'can cancel streaming scan and keep partial results ready for unfollow',
      build: () => _cubit(
        _FakeFollowAuditRepository(
          scanBatches: [
            FollowAuditBatch(
              scannedCount: 1,
              classifiedCount: 1,
              results: [_classified('did:plc:a', FollowStatus.deleted).copyWith(selected: true)],
              failedCount: 0,
              isComplete: false,
            ),
          ],
          scanGate: Completer<void>(),
        ),
      ),
      act: (cubit) async {
        unawaited(cubit.audit());
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await cubit.cancelAudit();
      },
      expect: () => [
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.classifying)
            .having((s) => s.results, 'results', isEmpty),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.classifying)
            .having((s) => s.progress, 'progress', 1),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.ready)
            .having((s) => s.results.length, 'results', 1),
      ],
    );

    blocTest<FollowAuditCubit, FollowAuditState>(
      'transitions to error when scan fails',
      build: () => _cubit(_FakeFollowAuditRepository(scanError: Exception('network error'))),
      act: (cubit) => cubit.audit(),
      expect: () => [
        isA<FollowAuditState>().having((s) => s.status, 'status', FollowAuditStatus.classifying),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<FollowAuditCubit, FollowAuditState>(
      'transitions to ready with empty results when no problematic follows found',
      build: () => _cubit(
        _FakeFollowAuditRepository(fetchResult: [_record('did:plc:alice'), _record('did:plc:bob')], classifyResult: []),
      ),
      act: (cubit) => cubit.audit(),
      expect: () => [
        isA<FollowAuditState>().having((s) => s.status, 'status', FollowAuditStatus.classifying),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.ready)
            .having((s) => s.results, 'results', isEmpty)
            .having((s) => s.totalFollows, 'totalFollows', 2),
      ],
    );

    blocTest<FollowAuditCubit, FollowAuditState>(
      'records failedProfiles from classify',
      build: () => _cubit(
        _FakeFollowAuditRepository(fetchResult: [_record('did:plc:alice')], classifyResult: [], classifyFailedCount: 3),
      ),
      act: (cubit) => cubit.audit(),
      expect: () => [
        isA<FollowAuditState>().having((s) => s.status, 'status', FollowAuditStatus.classifying),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.ready)
            .having((s) => s.failedProfiles, 'failedProfiles', 3),
      ],
    );
  });

  group('FollowAuditCubit.toggleSelection', () {
    test('toggles selected flag on correct index and emits new state', () {
      final cf = _classified('did:plc:alice', FollowStatus.blockedBy);
      final cubit = FollowAuditCubit(repository: _FakeFollowAuditRepository(), ownDid: _ownDid);

      cubit.emit(FollowAuditState(status: FollowAuditStatus.ready, results: [cf]));
      cubit.toggleSelection(0);
      expect(cubit.state.results[0].selected, isTrue);
    });

    test('toggling twice restores original selection', () {
      final cf = _classified('did:plc:alice', FollowStatus.blockedBy);
      final cubit = FollowAuditCubit(repository: _FakeFollowAuditRepository(), ownDid: _ownDid);
      cubit.emit(FollowAuditState(status: FollowAuditStatus.ready, results: [cf]));

      cubit.toggleSelection(0);
      cubit.toggleSelection(0);

      expect(cubit.state.results[0].selected, isFalse);
    });

    test('out-of-bounds index does nothing', () {
      final cubit = FollowAuditCubit(repository: _FakeFollowAuditRepository(), ownDid: _ownDid);
      cubit.emit(const FollowAuditState(status: FollowAuditStatus.ready));

      cubit.toggleSelection(99);

      expect(cubit.state.results, isEmpty);
    });
  });

  group('FollowAuditCubit.selectAllByStatus / deselectAllByStatus', () {
    test('selectAllByStatus selects all records matching status', () {
      final records = [
        _classified('did:plc:a', FollowStatus.deleted),
        _classified('did:plc:b', FollowStatus.deleted),
        _classified('did:plc:c', FollowStatus.blockedBy),
      ];
      final cubit = FollowAuditCubit(repository: _FakeFollowAuditRepository(), ownDid: _ownDid);
      cubit.emit(FollowAuditState(status: FollowAuditStatus.ready, results: records));

      cubit.selectAllByStatus(FollowStatus.deleted);

      final state = cubit.state;
      expect(state.results[0].selected, isTrue);
      expect(state.results[1].selected, isTrue);
      expect(state.results[2].selected, isFalse);
    });

    test('deselectAllByStatus deselects all records matching status', () {
      final records = [
        _classified('did:plc:a', FollowStatus.deleted).copyWith(selected: true),
        _classified('did:plc:b', FollowStatus.deleted).copyWith(selected: true),
        _classified('did:plc:c', FollowStatus.blockedBy).copyWith(selected: true),
      ];
      final cubit = FollowAuditCubit(repository: _FakeFollowAuditRepository(), ownDid: _ownDid);
      cubit.emit(FollowAuditState(status: FollowAuditStatus.ready, results: records));

      cubit.deselectAllByStatus(FollowStatus.deleted);

      final state = cubit.state;
      expect(state.results[0].selected, isFalse);
      expect(state.results[1].selected, isFalse);
      expect(state.results[2].selected, isTrue);
    });
  });

  group('FollowAuditCubit.toggleVisibility', () {
    test('adds status to visibleStatuses when not present', () {
      final cubit = FollowAuditCubit(repository: _FakeFollowAuditRepository(), ownDid: _ownDid);
      cubit.emit(const FollowAuditState(status: FollowAuditStatus.ready, visibleStatuses: {}));

      cubit.toggleVisibility(FollowStatus.deleted);

      expect(cubit.state.visibleStatuses, contains(FollowStatus.deleted));
    });

    test('removes status from visibleStatuses when present', () {
      final cubit = FollowAuditCubit(repository: _FakeFollowAuditRepository(), ownDid: _ownDid);
      cubit.emit(
        const FollowAuditState(
          status: FollowAuditStatus.ready,
          visibleStatuses: {FollowStatus.deleted, FollowStatus.blockedBy},
        ),
      );

      cubit.toggleVisibility(FollowStatus.deleted);

      expect(cubit.state.visibleStatuses, isNot(contains(FollowStatus.deleted)));
      expect(cubit.state.visibleStatuses, contains(FollowStatus.blockedBy));
    });
  });

  group('FollowAuditCubit.confirmUnfollow', () {
    blocTest<FollowAuditCubit, FollowAuditState>(
      'transitions ready → unfollowing → complete, removes unfollowed records',
      build: () {
        final repo = _FakeFollowAuditRepository(batchUnfollowResult: 2);
        return FollowAuditCubit(repository: repo, ownDid: _ownDid);
      },
      seed: () => FollowAuditState(
        status: FollowAuditStatus.ready,
        results: [
          _classified('did:plc:a', FollowStatus.deleted).copyWith(selected: true),
          _classified('did:plc:b', FollowStatus.blockedBy).copyWith(selected: true),
          _classified('did:plc:c', FollowStatus.suspended),
        ],
      ),
      act: (cubit) => cubit.confirmUnfollow(),
      expect: () => [
        isA<FollowAuditState>().having((s) => s.status, 'status', FollowAuditStatus.unfollowing),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.complete)
            .having((s) => s.unfollowedCount, 'unfollowedCount', 2)
            .having((s) => s.results.length, 'results length', 1),
      ],
    );

    blocTest<FollowAuditCubit, FollowAuditState>(
      'does nothing when no items selected',
      build: () => FollowAuditCubit(repository: _FakeFollowAuditRepository(), ownDid: _ownDid),
      seed: () =>
          FollowAuditState(status: FollowAuditStatus.ready, results: [_classified('did:plc:a', FollowStatus.deleted)]),
      act: (cubit) => cubit.confirmUnfollow(),
      expect: () => [],
    );

    blocTest<FollowAuditCubit, FollowAuditState>(
      'transitions to error when batchUnfollow fails',
      build: () {
        final repo = _FakeFollowAuditRepository(unfollowError: Exception('applyWrites failed'));
        return FollowAuditCubit(repository: repo, ownDid: _ownDid);
      },
      seed: () => FollowAuditState(
        status: FollowAuditStatus.ready,
        results: [_classified('did:plc:a', FollowStatus.deleted).copyWith(selected: true)],
      ),
      act: (cubit) => cubit.confirmUnfollow(),
      expect: () => [
        isA<FollowAuditState>().having((s) => s.status, 'status', FollowAuditStatus.unfollowing),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });
}
