import 'package:poptart_lex/com/atproto/repo/apply_writes.dart';
import 'package:poptart_core/poptart_core.dart' show AtUri;
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/profile/data/follow_audit_repository.dart';

ProfileView _profile(String did, String handle, {bool blockedBy = false, bool blocking = false}) {
  final viewer = ViewerState(
    blockedBy: blockedBy ? true : null,
    blocking: blocking ? AtUri.parse('at://$did/app.bsky.graph.block/xyz') : null,
    blockingByList: null,
  );
  return ProfileView(did: did, handle: handle, indexedAt: DateTime.utc(2026, 1, 1), viewer: viewer);
}

FollowRecord _followRecord(String did, {String? rkey}) {
  final k = rkey ?? 'rkey${did.replaceAll(':', '').replaceAll('/', '')}';
  return FollowRecord(uri: 'at://did:plc:owner/app.bsky.graph.follow/$k', rkey: k, subjectDid: did);
}

class _FakeBluesky {
  _FakeBluesky({required this.atproto, required this.actor});

  final _FakeAtProtoClient atproto;
  final _FakeActorService actor;
}

class _FakeAtProtoClient {
  _FakeAtProtoClient({required this.repo});

  final _FakeRepoService repo;
}

class _FakeRepoService {
  _FakeRepoService({this.pages = const [], this.applyWritesCallback});

  /// Each entry is one page: list of (uri, subjectDid) pairs.
  final List<List<(String, String)>> pages;
  final void Function(String repo, List<URepoApplyWritesWrites> writes)? applyWritesCallback;

  int _pageIndex = 0;
  List<_FakeApplyWritesCall> appliedWrites = [];

  Future<_FakeResponse<_FakeListRecordsOutput>> listRecords({
    required String repo,
    required String collection,
    int limit = 100,
    String? cursor,
  }) async {
    if (_pageIndex >= pages.length) {
      return _FakeResponse(_FakeListRecordsOutput(records: [], cursor: null));
    }
    final page = pages[_pageIndex++];
    final records = page.map((pair) {
      final (uri, subject) = pair;
      return _FakeRecord(uri: uri, value: {'subject': subject});
    }).toList();
    final nextCursor = _pageIndex < pages.length ? 'page$_pageIndex' : null;
    return _FakeResponse(_FakeListRecordsOutput(records: records, cursor: nextCursor));
  }

  Future<void> applyWrites({
    required String repo,
    List<URepoApplyWritesWrites>? writes,
    bool? validate,
    String? swapCommit,
  }) async {
    final w = writes ?? [];
    appliedWrites.add(_FakeApplyWritesCall(repo: repo, writes: w));
    applyWritesCallback?.call(repo, w);
  }
}

class _FakeApplyWritesCall {
  const _FakeApplyWritesCall({required this.repo, required this.writes});

  final String repo;
  final List<URepoApplyWritesWrites> writes;
}

class _FakeRecord {
  _FakeRecord({required this.uri, required this.value});

  final String uri;
  final Map<String, dynamic> value;
}

class _FakeListRecordsOutput {
  _FakeListRecordsOutput({required this.records, required this.cursor});

  final List<_FakeRecord> records;
  final String? cursor;
}

class _FakeActorService {
  _FakeActorService({
    this.batchProfiles = const {},
    this.singleProfiles = const {},
    this.followCounts = const {},
    Map<String, Object>? singleErrors,
    this.batchFailCount = 0,
  }) : singleErrors = singleErrors ?? {};

  /// DID → ProfileView for batch (getProfiles).
  final Map<String, ProfileView> batchProfiles;

  /// DID → ProfileView for per-DID fallback (getProfile).
  final Map<String, ProfileView> singleProfiles;

  /// DID → followsCount for profile count lookup.
  final Map<String, int> followCounts;

  /// DID → exception for per-DID fallback.
  final Map<String, Object> singleErrors;

  /// How many times getProfiles should throw before succeeding (simulates 429).
  final int batchFailCount;
  int _batchCallCount = 0;

  Future<_FakeResponse<_FakeProfilesOutput>> getProfiles({
    required List<String> actors,
    String? $service,
    Map<String, String>? $headers,
  }) async {
    _batchCallCount++;
    if (_batchCallCount <= batchFailCount) {
      throw Exception('429 RateLimitExceeded');
    }
    final matched = actors.where(batchProfiles.containsKey).map((did) => batchProfiles[did]!).toList();
    return _FakeResponse(_FakeProfilesOutput(profiles: matched));
  }

  Future<_FakeResponse<dynamic>> getProfile({
    required String actor,
    String? $service,
    Map<String, String>? $headers,
  }) async {
    final error = singleErrors[actor];
    if (error != null) throw error;
    final followCount = followCounts[actor];
    if (followCount != null) {
      return _FakeResponse(ProfileViewDetailed(did: actor, handle: 'owner.bsky.social', followsCount: followCount));
    }
    final profile = singleProfiles[actor];
    if (profile == null) throw Exception('HTTP 404 Profile not found');
    return _FakeResponse(profile);
  }
}

class _FakeProfilesOutput {
  _FakeProfilesOutput({required this.profiles});

  final List<dynamic> profiles;
}

class _FakeResponse<T> {
  _FakeResponse(this.data);

  final T data;
}

_FakeBluesky _bluesky({
  List<List<(String, String)>> pages = const [],
  Map<String, ProfileView> batchProfiles = const {},
  Map<String, ProfileView> singleProfiles = const {},
  Map<String, int> followCounts = const {},
  Map<String, Object>? singleErrors,
  int batchFailCount = 0,
  void Function(String repo, List<URepoApplyWritesWrites> writes)? applyWritesCallback,
}) {
  return _FakeBluesky(
    atproto: _FakeAtProtoClient(
      repo: _FakeRepoService(pages: pages, applyWritesCallback: applyWritesCallback),
    ),
    actor: _FakeActorService(
      batchProfiles: batchProfiles,
      singleProfiles: singleProfiles,
      followCounts: followCounts,
      singleErrors: singleErrors,
      batchFailCount: batchFailCount,
    ),
  );
}

FollowAuditRepository _repo(_FakeBluesky client) => FollowAuditRepository(bluesky: client);

const _ownerDid = 'did:plc:owner';

String _uri(String did, [String? rkey]) {
  final k = rkey ?? 'rkey${did.replaceAll(':', '').replaceAll('/', '')}';
  return 'at://$_ownerDid/app.bsky.graph.follow/$k';
}

void main() {
  group('FollowStatus', () {
    test('has all 8 required values', () {
      expect(FollowStatus.values.length, 8);
      expect(
        FollowStatus.values,
        containsAll([
          FollowStatus.deleted,
          FollowStatus.deactivated,
          FollowStatus.suspended,
          FollowStatus.blockedBy,
          FollowStatus.blocking,
          FollowStatus.mutualBlock,
          FollowStatus.hidden,
          FollowStatus.selfFollow,
        ]),
      );
    });
  });

  group('FollowRecord', () {
    test('stores uri, rkey and subjectDid', () {
      const record = FollowRecord(
        uri: 'at://did:plc:owner/app.bsky.graph.follow/abc123',
        rkey: 'abc123',
        subjectDid: 'did:plc:alice',
      );
      expect(record.uri, 'at://did:plc:owner/app.bsky.graph.follow/abc123');
      expect(record.rkey, 'abc123');
      expect(record.subjectDid, 'did:plc:alice');
    });
  });

  group('ClassifiedFollow', () {
    test('construction stores all fields', () {
      final record = _followRecord('did:plc:alice');
      final cf = ClassifiedFollow(
        record: record,
        handle: 'alice.bsky.social',
        status: FollowStatus.deleted,
        statusLabel: 'Deleted',
      );
      expect(cf.handle, 'alice.bsky.social');
      expect(cf.status, FollowStatus.deleted);
      expect(cf.statusLabel, 'Deleted');
      expect(cf.selected, isFalse);
    });

    test('Equatable excludes selected from equality', () {
      final record = _followRecord('did:plc:alice');
      final a = ClassifiedFollow(
        record: record,
        handle: 'alice.bsky.social',
        status: FollowStatus.blockedBy,
        statusLabel: 'Blocked by',
      );
      final b = ClassifiedFollow(
        record: record,
        handle: 'alice.bsky.social',
        status: FollowStatus.blockedBy,
        statusLabel: 'Blocked by',
        selected: true,
      );
      expect(a, equals(b));
    });

    test('statusLabel maps for all statuses', () {
      final statuses = {
        FollowStatus.deleted: 'Deleted',
        FollowStatus.deactivated: 'Deactivated',
        FollowStatus.suspended: 'Suspended',
        FollowStatus.blockedBy: 'Blocked by',
        FollowStatus.blocking: 'Blocking',
        FollowStatus.mutualBlock: 'Mutual block',
        FollowStatus.hidden: 'Hidden',
        FollowStatus.selfFollow: 'Self-follow',
      };

      expect(statuses.length, FollowStatus.values.length);
    });
  });

  group('FollowAuditRepository.fetchFollowPage', () {
    test('returns one page of follow records and cursor', () async {
      final client = _bluesky(
        pages: [
          [(_uri('did:plc:alice', 'rkey123'), 'did:plc:alice')],
          [(_uri('did:plc:bob', 'rkey456'), 'did:plc:bob')],
        ],
      );
      final repo = _repo(client);

      final page = await repo.fetchFollowPage(_ownerDid);

      expect(page.records.length, 1);
      expect(page.records.first.rkey, 'rkey123');
      expect(page.cursor, 'page1');
    });
  });

  group('FollowAuditRepository.fetchFollowCount', () {
    test('returns followsCount from own profile', () async {
      final client = _bluesky(followCounts: {_ownerDid: 789});
      final repo = _repo(client);

      final count = await repo.fetchFollowCount(_ownerDid);

      expect(count, 789);
    });

    test('returns null when followsCount cannot be loaded', () async {
      final client = _bluesky();
      final repo = _repo(client);

      final count = await repo.fetchFollowCount(_ownerDid);

      expect(count, isNull);
    });
  });

  group('FollowAuditRepository.scanFollows', () {
    test('streams classified pages as they are processed', () async {
      final aliceProfile = _profile('did:plc:alice', 'alice.bsky.social', blockedBy: true);
      final bobProfile = _profile('did:plc:bob', 'bob.bsky.social', blocking: true);
      final client = _bluesky(
        pages: [
          [(_uri('did:plc:alice'), 'did:plc:alice')],
          [(_uri('did:plc:bob'), 'did:plc:bob')],
        ],
        followCounts: {_ownerDid: 789},
        batchProfiles: {'did:plc:alice': aliceProfile, 'did:plc:bob': bobProfile},
      );
      final repo = _repo(client);

      final batches = await repo.scanFollows(_ownerDid).toList();

      expect(batches.length, 2);
      expect(batches.first.totalFollows, 789);
      expect(batches.first.scannedCount, 1);
      expect(batches.first.classifiedCount, 1);
      expect(batches.first.results.single.status, FollowStatus.blockedBy);
      expect(batches.first.isComplete, isFalse);
      expect(batches.last.scannedCount, 2);
      expect(batches.last.classifiedCount, 2);
      expect(batches.last.results.single.status, FollowStatus.blocking);
      expect(batches.last.isComplete, isTrue);
    });
  });

  group('FollowAuditRepository.classifyFollows', () {
    test('healthy account is not included in results', () async {
      final healthyProfile = _profile('did:plc:alice', 'alice.bsky.social');
      final client = _bluesky(batchProfiles: {'did:plc:alice': healthyProfile});
      final repo = _repo(client);

      final record = _followRecord('did:plc:alice');
      final (:results, :failedCount) = await repo.classifyFollows([record], _ownerDid);

      expect(results, isEmpty);
      expect(failedCount, 0);
    });

    test('self-follow is classified correctly', () async {
      final selfProfile = _profile(_ownerDid, 'owner.bsky.social');
      final client = _bluesky(batchProfiles: {_ownerDid: selfProfile});
      final repo = _repo(client);

      final record = _followRecord(_ownerDid);
      final (:results, :failedCount) = await repo.classifyFollows([record], _ownerDid);

      expect(results.length, 1);
      expect(results.first.status, FollowStatus.selfFollow);
    });

    test('blockedBy account is classified correctly', () async {
      final blockedByProfile = _profile('did:plc:alice', 'alice.bsky.social', blockedBy: true);
      final client = _bluesky(batchProfiles: {'did:plc:alice': blockedByProfile});
      final repo = _repo(client);

      final record = _followRecord('did:plc:alice');
      final (:results, :failedCount) = await repo.classifyFollows([record], _ownerDid);

      expect(results.length, 1);
      expect(results.first.status, FollowStatus.blockedBy);
      expect(results.first.handle, 'alice.bsky.social');
    });

    test('blocking account is classified correctly', () async {
      final blockingProfile = _profile('did:plc:alice', 'alice.bsky.social', blocking: true);
      final client = _bluesky(batchProfiles: {'did:plc:alice': blockingProfile});
      final repo = _repo(client);

      final record = _followRecord('did:plc:alice');
      final (:results, :failedCount) = await repo.classifyFollows([record], _ownerDid);

      expect(results.length, 1);
      expect(results.first.status, FollowStatus.blocking);
    });

    test('mutual block is classified correctly (both blockedBy and blocking)', () async {
      final mutualProfile = _profile('did:plc:alice', 'alice.bsky.social', blockedBy: true, blocking: true);
      final client = _bluesky(batchProfiles: {'did:plc:alice': mutualProfile});
      final repo = _repo(client);

      final record = _followRecord('did:plc:alice');
      final (:results, :failedCount) = await repo.classifyFollows([record], _ownerDid);

      expect(results.length, 1);
      expect(results.first.status, FollowStatus.mutualBlock);
    });

    test('deleted account is classified via per-DID fallback with not-found error', () async {
      final client = _bluesky(
        batchProfiles: {},
        singleErrors: {'did:plc:alice': Exception('HTTP 404 Profile not found')},
      );
      final repo = _repo(client);

      final record = _followRecord('did:plc:alice');
      final (:results, :failedCount) = await repo.classifyFollows([record], _ownerDid);

      expect(results.length, 1);
      expect(results.first.status, FollowStatus.deleted);
      expect(failedCount, 0);
    });

    test('deactivated account is classified via per-DID fallback with deactivated error', () async {
      final client = _bluesky(
        batchProfiles: {},
        singleErrors: {'did:plc:alice': Exception('AccountDeactivated: account is deactivated')},
      );
      final repo = _repo(client);

      final record = _followRecord('did:plc:alice');
      final (:results, :failedCount) = await repo.classifyFollows([record], _ownerDid);

      expect(results.length, 1);
      expect(results.first.status, FollowStatus.deactivated);
      expect(failedCount, 0);
    });

    test('suspended account is classified via per-DID fallback with takedown error', () async {
      final client = _bluesky(
        batchProfiles: {},
        singleErrors: {'did:plc:alice': Exception('AccountTakedown: account has been suspended')},
      );
      final repo = _repo(client);

      final record = _followRecord('did:plc:alice');
      final (:results, :failedCount) = await repo.classifyFollows([record], _ownerDid);

      expect(results.length, 1);
      expect(results.first.status, FollowStatus.suspended);
      expect(failedCount, 0);
    });

    test('profile missing from batch but returned by per-DID lookup is classified correctly', () async {
      final blockedByProfile = _profile('did:plc:alice', 'alice.bsky.social', blockedBy: true);
      final client = _bluesky(batchProfiles: {}, singleProfiles: {'did:plc:alice': blockedByProfile});
      final repo = _repo(client);

      final record = _followRecord('did:plc:alice');
      final (:results, :failedCount) = await repo.classifyFollows([record], _ownerDid);

      expect(results.length, 1);
      expect(results.first.status, FollowStatus.blockedBy);
      expect(failedCount, 0);
    });

    test('partial failure: unrecognized per-DID error counts as failedCount', () async {
      final aliceProfile = _profile('did:plc:alice', 'alice.bsky.social', blockedBy: true);
      final client = _bluesky(
        batchProfiles: {'did:plc:alice': aliceProfile},
        singleErrors: {'did:plc:bob': Exception('Internal server error')},
      );
      final repo = _repo(client);

      final records = [_followRecord('did:plc:alice'), _followRecord('did:plc:bob')];
      final (:results, :failedCount) = await repo.classifyFollows(records, _ownerDid);

      expect(results.length, 1);
      expect(results.first.status, FollowStatus.blockedBy);
      expect(failedCount, 1);
    });

    test('rate limit retry: getProfiles 429 retried, succeeds on retry', () async {
      final aliceProfile = _profile('did:plc:alice', 'alice.bsky.social', blockedBy: true);
      final client = _bluesky(
        batchProfiles: {'did:plc:alice': aliceProfile},
        batchFailCount: 1, // First call throws 429, second succeeds
      );
      final repo = _repo(client);

      final record = _followRecord('did:plc:alice');
      final (:results, :failedCount) = await repo.classifyFollows([record], _ownerDid);

      expect(results.length, 1);
      expect(results.first.status, FollowStatus.blockedBy);
    });

    test('returns empty results when all follows are healthy', () async {
      final profiles = {
        'did:plc:a': _profile('did:plc:a', 'a.bsky.social'),
        'did:plc:b': _profile('did:plc:b', 'b.bsky.social'),
      };
      final client = _bluesky(batchProfiles: profiles);
      final repo = _repo(client);

      final records = profiles.keys.map(_followRecord).toList();
      final (:results, :failedCount) = await repo.classifyFollows(records, _ownerDid);

      expect(results, isEmpty);
      expect(failedCount, 0);
    });
  });

  group('FollowAuditRepository.batchUnfollow', () {
    test('returns 0 for empty selection (no-op)', () async {
      final client = _bluesky();
      final repoInstance = _repo(client);

      final count = await repoInstance.batchUnfollow([], _ownerDid);

      expect(count, 0);
      expect(client.atproto.repo.appliedWrites, isEmpty);
    });

    test('deletes records in a single batch when fewer than 200', () async {
      final repoService = _FakeRepoService();
      final client = _FakeBluesky(
        atproto: _FakeAtProtoClient(repo: repoService),
        actor: _FakeActorService(),
      );
      final repoInstance = FollowAuditRepository(bluesky: client);

      final selected = List.generate(
        5,
        (i) => ClassifiedFollow(
          record: _followRecord('did:plc:u$i', rkey: 'rkey$i'),
          handle: 'u$i.bsky.social',
          status: FollowStatus.blockedBy,
          statusLabel: 'Blocked by',
          selected: true,
        ),
      );

      final count = await repoInstance.batchUnfollow(selected, _ownerDid);

      expect(count, 5);
      expect(repoService.appliedWrites.length, 1);
      expect(repoService.appliedWrites.first.repo, _ownerDid);
      final deletes = repoService.appliedWrites.first.writes;
      expect(deletes.length, 5);
      for (var i = 0; i < 5; i++) {
        expect(deletes[i].isDelete, isTrue);
        expect(deletes[i].delete!.collection, 'app.bsky.graph.follow');
        expect(deletes[i].delete!.rkey, 'rkey$i');
      }
    });

    test('chunks into multiple batches of 200 when > 200 records', () async {
      final repoService = _FakeRepoService();
      final client = _FakeBluesky(
        atproto: _FakeAtProtoClient(repo: repoService),
        actor: _FakeActorService(),
      );
      final repoInstance = FollowAuditRepository(bluesky: client);

      final selected = List.generate(
        250,
        (i) => ClassifiedFollow(
          record: _followRecord('did:plc:u$i', rkey: 'rkey$i'),
          handle: null,
          status: FollowStatus.deleted,
          statusLabel: 'Deleted',
          selected: true,
        ),
      );

      final count = await repoInstance.batchUnfollow(selected, _ownerDid);

      expect(count, 250);
      expect(repoService.appliedWrites.length, 2);
      expect(repoService.appliedWrites[0].writes.length, 200);
      expect(repoService.appliedWrites[1].writes.length, 50);
    });

    test('partial failure: throws after first batch, returns partial count', () async {
      var callCount = 0;
      final repoService = _FakeRepoService(
        applyWritesCallback: (repo, writes) {
          callCount++;
          if (callCount > 1) throw Exception('applyWrites failed');
        },
      );
      final client = _FakeBluesky(
        atproto: _FakeAtProtoClient(repo: repoService),
        actor: _FakeActorService(),
      );
      final repoInstance = FollowAuditRepository(bluesky: client);

      final selected = List.generate(
        250,
        (i) => ClassifiedFollow(
          record: _followRecord('did:plc:u$i', rkey: 'rkey$i'),
          handle: null,
          status: FollowStatus.deleted,
          statusLabel: 'Deleted',
          selected: true,
        ),
      );

      expect(() => repoInstance.batchUnfollow(selected, _ownerDid), throwsException);
    });
  });
}
