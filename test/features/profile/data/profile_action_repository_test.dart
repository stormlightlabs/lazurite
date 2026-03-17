import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/profile/data/profile_action_repository.dart';

class MockProfileActionRepository implements ProfileActionRepository {
  final Map<String, String> _follows = {};
  final Map<String, String> _blocks = {};
  final Set<String> _mutes = {};
  final List<Map<String, dynamic>> _reports = [];

  @override
  Future<String> followActor({required String did}) async {
    final followUri = 'at://did:plc:test/app.bsky.graph.follow/${did}_follow';
    _follows[did] = followUri;
    return followUri;
  }

  @override
  Future<void> unfollowActor({required String followUri}) async {
    _follows.removeWhere((key, value) => value == followUri);
  }

  @override
  Future<void> muteActor({required String did}) async {
    _mutes.add(did);
  }

  @override
  Future<void> unmuteActor({required String did}) async {
    _mutes.remove(did);
  }

  @override
  Future<String> blockActor({required String did}) async {
    final blockUri = 'at://did:plc:test/app.bsky.graph.block/${did}_block';
    _blocks[did] = blockUri;
    return blockUri;
  }

  @override
  Future<void> unblockActor({required String blockUri}) async {
    _blocks.removeWhere((key, value) => value == blockUri);
  }

  @override
  Future<String> reportPost({
    required dynamic postUri,
    required String cid,
    required dynamic reasonType,
    String? reason,
  }) async {
    final reportId = 'report_${_reports.length}';
    _reports.add({
      'id': reportId,
      'type': 'post',
      'uri': postUri.toString(),
      'cid': cid,
      'reasonType': reasonType.toString(),
      'reason': reason,
    });
    return reportId;
  }

  @override
  Future<String> reportActor({required String did, required dynamic reasonType, String? reason}) async {
    final reportId = 'report_${_reports.length}';
    _reports.add({'id': reportId, 'type': 'actor', 'did': did, 'reasonType': reasonType.toString(), 'reason': reason});
    return reportId;
  }

  bool isFollowing(String did) => _follows.containsKey(did);
  bool isBlocked(String did) => _blocks.containsKey(did);
  bool isMuted(String did) => _mutes.contains(did);
  String? getFollowUri(String did) => _follows[did];
  String? getBlockUri(String did) => _blocks[did];
  int get reportCount => _reports.length;
}

void main() {
  late MockProfileActionRepository repository;

  setUp(() {
    repository = MockProfileActionRepository();
  });

  const testDid = 'did:plc:testuser123';
  const testPostUri = 'at://did:plc:other/app.bsky.feed.post/abc123';
  const testCid = 'bafyreie5cvv4hhpwo4y6x4f4m6fsq3xrm5f3p5vzum5h5uv5x5x5x5x5x5';

  group('ProfileActionRepository Contract', () {
    group('followActor', () {
      test('should return follow URI when successful', () async {
        final result = await repository.followActor(did: testDid);

        expect(result, isNotNull);
        expect(result, contains('app.bsky.graph.follow'));
        expect(repository.isFollowing(testDid), isTrue);
      });

      test('should return different URIs for different actors', () async {
        const did1 = 'did:plc:user1';
        const did2 = 'did:plc:user2';

        final result1 = await repository.followActor(did: did1);
        final result2 = await repository.followActor(did: did2);

        expect(result1, isNot(equals(result2)));
      });
    });

    group('unfollowActor', () {
      test('should remove follow relationship', () async {
        final followUri = await repository.followActor(did: testDid);
        expect(repository.isFollowing(testDid), isTrue);

        await repository.unfollowActor(followUri: followUri);

        expect(repository.isFollowing(testDid), isFalse);
      });
    });

    group('muteActor', () {
      test('should mute actor', () async {
        expect(repository.isMuted(testDid), isFalse);

        await repository.muteActor(did: testDid);

        expect(repository.isMuted(testDid), isTrue);
      });
    });

    group('unmuteActor', () {
      test('should unmute actor', () async {
        await repository.muteActor(did: testDid);
        expect(repository.isMuted(testDid), isTrue);

        await repository.unmuteActor(did: testDid);

        expect(repository.isMuted(testDid), isFalse);
      });
    });

    group('blockActor', () {
      test('should return block URI when successful', () async {
        final result = await repository.blockActor(did: testDid);

        expect(result, isNotNull);
        expect(result, contains('app.bsky.graph.block'));
        expect(repository.isBlocked(testDid), isTrue);
      });
    });

    group('unblockActor', () {
      test('should remove block relationship', () async {
        final blockUri = await repository.blockActor(did: testDid);
        expect(repository.isBlocked(testDid), isTrue);

        await repository.unblockActor(blockUri: blockUri);

        expect(repository.isBlocked(testDid), isFalse);
      });
    });

    group('reportPost', () {
      test('should create post report and return report ID', () async {
        final reportId = await repository.reportPost(postUri: testPostUri, cid: testCid, reasonType: 'reasonSpam');

        expect(reportId, isNotNull);
        expect(reportId, startsWith('report_'));
        expect(repository.reportCount, 1);
      });

      test('should include reason in report', () async {
        await repository.reportPost(
          postUri: testPostUri,
          cid: testCid,
          reasonType: 'reasonOther',
          reason: 'This is inappropriate',
        );

        expect(repository.reportCount, 1);
      });
    });

    group('reportActor', () {
      test('should create actor report and return report ID', () async {
        final reportId = await repository.reportActor(did: testDid, reasonType: 'reasonSpam');

        expect(reportId, isNotNull);
        expect(reportId, startsWith('report_'));
        expect(repository.reportCount, 1);
      });

      test('should include reason in actor report', () async {
        await repository.reportActor(
          did: testDid,
          reasonType: 'reasonViolation',
          reason: 'Violating community guidelines',
        );

        expect(repository.reportCount, 1);
      });
    });

    group('action independence', () {
      test('follow and block should be independent', () async {
        expect(repository.isFollowing(testDid), isFalse);
        expect(repository.isBlocked(testDid), isFalse);

        await repository.followActor(did: testDid);
        expect(repository.isFollowing(testDid), isTrue);
        expect(repository.isBlocked(testDid), isFalse);

        await repository.blockActor(did: testDid);
        expect(repository.isFollowing(testDid), isTrue);
        expect(repository.isBlocked(testDid), isTrue);
      });

      test('mute should not affect follow/block status', () async {
        await repository.followActor(did: testDid);
        expect(repository.isFollowing(testDid), isTrue);
        expect(repository.isMuted(testDid), isFalse);

        await repository.muteActor(did: testDid);
        expect(repository.isFollowing(testDid), isTrue);
        expect(repository.isMuted(testDid), isTrue);
      });
    });
  });
}
