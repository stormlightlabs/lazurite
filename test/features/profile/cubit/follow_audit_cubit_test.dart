import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/profile/cubit/follow_audit_cubit.dart';
import 'package:lazurite/features/profile/data/follow_audit_repository.dart';

class _FakeFollowAuditRepository implements FollowAuditRepository {
  _FakeFollowAuditRepository({
    List<FollowRecord> fetchResult = const [],
    List<ClassifiedFollow> classifyResult = const [],
    int classifyFailedCount = 0,
    int batchUnfollowResult = 0,
    Exception? fetchError,
    Exception? classifyError,
    Exception? unfollowError,
    List<int>? fetchProgressValues,
    List<int>? classifyProgressValues,
  }) : _fetchResult = fetchResult,
       _classifyResult = classifyResult,
       _classifyFailedCount = classifyFailedCount,
       _batchUnfollowResult = batchUnfollowResult,
       _fetchError = fetchError,
       _classifyError = classifyError,
       _unfollowError = unfollowError,
       _fetchProgressValues = fetchProgressValues,
       _classifyProgressValues = classifyProgressValues;

  final List<FollowRecord> _fetchResult;
  final List<ClassifiedFollow> _classifyResult;
  final int _classifyFailedCount;
  final int _batchUnfollowResult;
  final Exception? _fetchError;
  final Exception? _classifyError;
  final Exception? _unfollowError;
  final List<int>? _fetchProgressValues;
  final List<int>? _classifyProgressValues;

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
      'transitions initial → fetching → classifying → ready',
      build: () => _cubit(
        _FakeFollowAuditRepository(
          fetchResult: [_record('did:plc:alice')],
          classifyResult: [_classified('did:plc:alice', FollowStatus.blockedBy)],
        ),
      ),
      act: (cubit) => cubit.audit(),
      expect: () => [
        isA<FollowAuditState>().having((s) => s.status, 'status', FollowAuditStatus.fetching),
        isA<FollowAuditState>().having((s) => s.status, 'status', FollowAuditStatus.classifying),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.ready)
            .having((s) => s.results.length, 'results', 1)
            .having((s) => s.totalFollows, 'totalFollows', 1),
      ],
    );

    blocTest<FollowAuditCubit, FollowAuditState>(
      'emits progress updates during fetch phase',
      build: () => _cubit(
        _FakeFollowAuditRepository(
          fetchResult: [_record('did:plc:a'), _record('did:plc:b'), _record('did:plc:c')],
          fetchProgressValues: [1, 2, 3],
          classifyResult: [],
        ),
      ),
      act: (cubit) => cubit.audit(),
      expect: () => [
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.fetching)
            .having((s) => s.progress, 'progress', 0),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.fetching)
            .having((s) => s.progress, 'progress', 1),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.fetching)
            .having((s) => s.progress, 'progress', 2),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.fetching)
            .having((s) => s.progress, 'progress', 3),
        isA<FollowAuditState>().having((s) => s.status, 'status', FollowAuditStatus.classifying),
        isA<FollowAuditState>().having((s) => s.status, 'status', FollowAuditStatus.ready),
      ],
    );

    blocTest<FollowAuditCubit, FollowAuditState>(
      'emits progress updates during classify phase',
      build: () => _cubit(
        _FakeFollowAuditRepository(
          fetchResult: [_record('did:plc:a'), _record('did:plc:b')],
          classifyProgressValues: [1, 2],
          classifyResult: [],
        ),
      ),
      act: (cubit) => cubit.audit(),
      expect: () => [
        isA<FollowAuditState>().having((s) => s.status, 'status', FollowAuditStatus.fetching),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.classifying)
            .having((s) => s.progress, 'progress', 0),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.classifying)
            .having((s) => s.progress, 'progress', 1),
        isA<FollowAuditState>()
            .having((s) => s.status, 'status', FollowAuditStatus.classifying)
            .having((s) => s.progress, 'progress', 2),
        isA<FollowAuditState>().having((s) => s.status, 'status', FollowAuditStatus.ready),
      ],
    );

    blocTest<FollowAuditCubit, FollowAuditState>(
      'transitions to error when fetch fails',
      build: () => _cubit(_FakeFollowAuditRepository(fetchError: Exception('network error'))),
      act: (cubit) => cubit.audit(),
      expect: () => [
        isA<FollowAuditState>().having((s) => s.status, 'status', FollowAuditStatus.fetching),
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
        isA<FollowAuditState>().having((s) => s.status, 'status', FollowAuditStatus.fetching),
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
        isA<FollowAuditState>().having((s) => s.status, 'status', FollowAuditStatus.fetching),
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
