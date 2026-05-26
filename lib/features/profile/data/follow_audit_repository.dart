import 'dart:async';

import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/graph/follow.dart';
import 'package:poptart_core/poptart_core.dart' as atcore show UnauthorizedException;
import 'package:poptart_lex/com/atproto/repo/apply_writes.dart';
import 'package:equatable/equatable.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/unauthorized_recovery_runner.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/auth/data/session_identity.dart';

enum FollowStatus { deleted, deactivated, suspended, blockedBy, blocking, mutualBlock, hidden, selfFollow }

class FollowRecord {
  const FollowRecord({required this.uri, required this.rkey, required this.subjectDid});

  final String uri;
  final String rkey;
  final String subjectDid;
}

class FollowRecordPage {
  const FollowRecordPage({required this.records, required this.cursor});

  final List<FollowRecord> records;
  final String? cursor;
}

class FollowAuditBatch {
  const FollowAuditBatch({
    required this.totalFollows,
    required this.scannedCount,
    required this.classifiedCount,
    required this.results,
    required this.failedCount,
    required this.isComplete,
  });

  final int? totalFollows;
  final int scannedCount;
  final int classifiedCount;
  final List<ClassifiedFollow> results;
  final int failedCount;
  final bool isComplete;
}

class ClassifiedFollow extends Equatable {
  const ClassifiedFollow({
    required this.record,
    required this.handle,
    required this.status,
    required this.statusLabel,
    this.selected = false,
  });

  final FollowRecord record;
  final String? handle;
  final FollowStatus status;
  final String statusLabel;
  final bool selected;

  ClassifiedFollow copyWith({bool? selected}) {
    return ClassifiedFollow(
      record: record,
      handle: handle,
      status: status,
      statusLabel: statusLabel,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object?> get props => [record.uri, handle, status, statusLabel];

  @override
  bool get stringify => false;
}

const _profileBatchSize = 25;
const _concurrentBatches = 2;
const _interGroupDelay = Duration(milliseconds: 500);
const _retryDelays = [Duration(seconds: 1), Duration(seconds: 2), Duration(seconds: 4)];
const _maxRetries = 3;
const _unfollowBatchSize = 200;

class FollowAuditRepository {
  FollowAuditRepository({
    required Bluesky bluesky,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
    Future<AuthTokens?> Function()? onUnauthorized,
    Bluesky? Function(AuthTokens tokens)? blueskyClientFactory,
  }) : _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       ) {
    _authRecovery = UnauthorizedRecoveryRunner<Bluesky>(
      initialClient: bluesky,
      onUnauthorized: onUnauthorized,
      clientFactory: blueskyClientFactory ?? createBlueskyClient,
    );
  }

  late final UnauthorizedRecoveryRunner<Bluesky> _authRecovery;
  final AppViewRequestContext _appViewContext;

  Future<int?> fetchFollowCount(String did) async {
    _assertCurrentSessionRepoAccess(did: did, operation: 'fetchFollowCount');
    try {
      final response = await _authRecovery.run(
        (client) => client.actor.getProfile(
          actor: did,
          $headers: _appViewContext.appBskyHeadersForEndpoint('app.bsky.actor.getProfile'),
        ),
      );
      final count = response.data.followsCount;
      return count is int && count >= 0 ? count : null;
    } on atcore.UnauthorizedException {
      rethrow;
    } catch (error, stackTrace) {
      log.w('FollowAuditRepository: failed to fetch followsCount for $did', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  Future<FollowRecordPage> fetchFollowPage(String did, {String? cursor, int limit = 100}) async {
    _assertCurrentSessionRepoAccess(did: did, operation: 'fetchFollowPage');
    final response = await _authRecovery.run(
      (client) => client.atproto.repo.listRecords(
        repo: did,
        collection: 'app.bsky.graph.follow',
        limit: limit.clamp(1, 100),
        cursor: cursor,
      ),
    );

    final records = <FollowRecord>[];
    for (final raw in response.data.records) {
      final value = raw.value;
      if (!GraphFollowRecord.validate(value)) {
        log.w('FollowAuditRepository: skipping malformed follow record uri=${raw.uri}');
        continue;
      }

      final follow = const GraphFollowRecordConverter().fromJson(value);
      final uri = raw.uri.toString();
      late final String rkey;
      try {
        rkey = AtUri.parse(uri).rkey;
      } catch (error, stackTrace) {
        log.w(
          'FollowAuditRepository: skipping follow record with malformed uri=$uri',
          error: error,
          stackTrace: stackTrace,
        );
        continue;
      }
      records.add(FollowRecord(uri: uri, rkey: rkey, subjectDid: follow.subject));
    }

    return FollowRecordPage(records: records, cursor: response.data.cursor);
  }

  Stream<FollowAuditBatch> scanFollows(String did) async* {
    _assertCurrentSessionRepoAccess(did: did, operation: 'scanFollows');
    final expectedTotalFollows = await fetchFollowCount(did);
    var scannedCount = 0;
    var classifiedCount = 0;
    var failedCount = 0;
    String? cursor;

    do {
      final page = await fetchFollowPage(did, cursor: cursor);
      cursor = page.cursor;
      scannedCount += page.records.length;

      if (page.records.isEmpty) {
        yield FollowAuditBatch(
          totalFollows: expectedTotalFollows,
          scannedCount: scannedCount,
          classifiedCount: classifiedCount,
          results: const [],
          failedCount: failedCount,
          isComplete: cursor == null,
        );
        continue;
      }

      final classified = await classifyFollows(page.records, did);
      classifiedCount += page.records.length;
      failedCount += classified.failedCount;
      yield FollowAuditBatch(
        totalFollows: expectedTotalFollows,
        scannedCount: scannedCount,
        classifiedCount: classifiedCount,
        results: classified.results,
        failedCount: failedCount,
        isComplete: cursor == null,
      );
    } while (cursor != null);
  }

  Future<({List<ClassifiedFollow> results, int failedCount})> classifyFollows(
    List<FollowRecord> records,
    String ownDid, {
    void Function(int classified)? onProgress,
  }) async {
    final results = <ClassifiedFollow>[];
    var failedCount = 0;
    var processedCount = 0;

    final recordByDid = <String, FollowRecord>{for (final r in records) r.subjectDid: r};
    final dids = records.map((r) => r.subjectDid).toList();

    for (var groupStart = 0; groupStart < dids.length; groupStart += _profileBatchSize * _concurrentBatches) {
      if (groupStart > 0) {
        await Future<void>.delayed(_interGroupDelay);
      }

      final groupDids = dids.sublist(
        groupStart,
        (groupStart + _profileBatchSize * _concurrentBatches).clamp(0, dids.length),
      );

      final futures = <Future<_BatchResult>>[];
      for (var batchStart = 0; batchStart < groupDids.length; batchStart += _profileBatchSize) {
        final batch = groupDids.sublist(batchStart, (batchStart + _profileBatchSize).clamp(0, groupDids.length));
        futures.add(_processBatch(batch, recordByDid, ownDid));
      }

      final batchResults = await Future.wait(futures);
      for (final br in batchResults) {
        results.addAll(br.classified);
        failedCount += br.failedCount;
      }

      processedCount += groupDids.length;
      onProgress?.call(processedCount);
    }

    return (results: results, failedCount: failedCount);
  }

  Future<_BatchResult> _processBatch(List<String> batch, Map<String, FollowRecord> recordByDid, String ownDid) async {
    final profileByDid = await _fetchBatchWithRetry(batch);
    final classified = <ClassifiedFollow>[];
    var failedCount = 0;

    for (final did in batch) {
      final record = recordByDid[did];
      if (record == null) continue;

      final profile = profileByDid[did];

      if (profile == null) {
        final fallback = await _fetchSingleWithRetry(did);
        if (fallback.failed) {
          failedCount++;
          continue;
        }
        if (fallback.profile != null) {
          final status = _classifyProfile(fallback.profile!, did, ownDid);
          if (status != null) {
            classified.add(_buildClassifiedFollow(record, fallback.profile!.handle, status));
          }
        } else if (fallback.status != null) {
          classified.add(_buildClassifiedFollow(record, null, fallback.status!));
        }
      } else {
        final status = _classifyProfile(profile, did, ownDid);
        if (status != null) {
          classified.add(_buildClassifiedFollow(record, profile.handle, status));
        }
      }
    }

    return _BatchResult(classified: classified, failedCount: failedCount);
  }

  Future<Map<String, ProfileView>> _fetchBatchWithRetry(List<String> batch) async {
    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final response = await _authRecovery.run(
          (client) => client.actor.getProfiles(
            actors: batch,
            $headers: _appViewContext.appBskyHeadersForEndpoint('app.bsky.actor.getProfiles'),
          ),
        );
        final result = <String, ProfileView>{};
        for (final profile in response.data.profiles) {
          final view = _asProfileView(profile);
          if (view != null) {
            result[view.did] = view;
          }
        }
        return result;
      } on atcore.UnauthorizedException {
        rethrow;
      } catch (error, stackTrace) {
        if (attempt >= _maxRetries || !_isRetryable(error)) {
          log.w(
            'FollowAuditRepository: batch getProfiles failed after $attempt retries',
            error: error,
            stackTrace: stackTrace,
          );
          return {};
        }
        await Future<void>.delayed(_retryDelays[attempt]);
      }
    }
    return {};
  }

  Future<_SingleResult> _fetchSingleWithRetry(String did) async {
    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final response = await _authRecovery.run(
          (client) => client.actor.getProfile(
            actor: did,
            $headers: _appViewContext.appBskyHeadersForEndpoint('app.bsky.actor.getProfile'),
          ),
        );
        final view = _asProfileView(response.data);
        return _SingleResult(profile: view, status: null, failed: view == null);
      } on atcore.UnauthorizedException {
        rethrow;
      } catch (error, stackTrace) {
        if (attempt >= _maxRetries || !_isRetryable(error)) {
          final status = _classifyError(error);
          if (status != null) {
            return _SingleResult(profile: null, status: status, failed: false);
          }
          log.w(
            'FollowAuditRepository: per-DID getProfile failed for $did after $attempt retries',
            error: error,
            stackTrace: stackTrace,
          );
          return const _SingleResult(profile: null, status: null, failed: true);
        }
        await Future<void>.delayed(_retryDelays[attempt]);
      }
    }
    return const _SingleResult(profile: null, status: null, failed: true);
  }

  Future<int> batchUnfollow(List<ClassifiedFollow> selected, String ownDid) async {
    _assertCurrentSessionRepoAccess(did: ownDid, operation: 'batchUnfollow');
    if (selected.isEmpty) return 0;

    final rkeys = selected.map((f) => f.record.rkey).toList();
    var deletedCount = 0;

    for (var i = 0; i < rkeys.length; i += _unfollowBatchSize) {
      final chunk = rkeys.sublist(i, (i + _unfollowBatchSize).clamp(0, rkeys.length));
      final writes = chunk
          .map(
            (rkey) => URepoApplyWritesWrites.delete(
              data: Delete(collection: 'app.bsky.graph.follow', rkey: rkey),
            ),
          )
          .toList();

      await _authRecovery.run((client) => client.atproto.repo.applyWrites(repo: ownDid, writes: writes));
      deletedCount += chunk.length;
    }

    return deletedCount;
  }

  FollowStatus? _classifyProfile(ProfileView profile, String did, String ownDid) {
    if (did == ownDid) return FollowStatus.selfFollow;

    final viewer = profile.viewer;
    final isBlockedBy = viewer?.blockedBy == true;
    final isBlocking = viewer?.blocking != null || viewer?.blockingByList != null;

    if (isBlockedBy && isBlocking) return FollowStatus.mutualBlock;
    if (isBlockedBy) return FollowStatus.blockedBy;
    if (isBlocking) return FollowStatus.blocking;

    final labels = profile.labels ?? [];
    if (labels.any((l) => l.val == '!hide')) return FollowStatus.hidden;

    return null;
  }

  FollowStatus? _classifyError(Object error) {
    final message = error.toString();
    final lower = message.toLowerCase();

    if (message.contains('AccountTakedown') ||
        lower.contains('suspended') ||
        lower.contains('account has been suspended')) {
      return FollowStatus.suspended;
    }
    if (message.contains('AccountDeactivated') || lower.contains('deactivated')) {
      return FollowStatus.deactivated;
    }
    if (message.contains('HTTP 404') || lower.contains('not found') || lower.contains('profile not found')) {
      return FollowStatus.deleted;
    }
    return null;
  }

  bool _isRetryable(Object error) {
    final message = error.toString();
    return message.contains('429') ||
        message.contains('RateLimitExceeded') ||
        message.toLowerCase().contains('network');
  }

  ProfileView? _asProfileView(Object? profile) {
    if (profile is ProfileView) return profile;
    if (profile is ProfileViewDetailed) {
      return ProfileView(
        did: profile.did,
        handle: profile.handle,
        displayName: profile.displayName,
        pronouns: profile.pronouns,
        description: profile.description,
        avatar: profile.avatar,
        associated: profile.associated,
        indexedAt: profile.indexedAt,
        createdAt: profile.createdAt,
        viewer: profile.viewer,
        labels: profile.labels,
        verification: profile.verification,
        status: profile.status,
        debug: profile.debug,
      );
    }
    return null;
  }

  ClassifiedFollow _buildClassifiedFollow(FollowRecord record, String? handle, FollowStatus status) {
    return ClassifiedFollow(record: record, handle: handle, status: status, statusLabel: _statusLabel(status));
  }

  String _statusLabel(FollowStatus status) {
    switch (status) {
      case FollowStatus.deleted:
        return 'Deleted';
      case FollowStatus.deactivated:
        return 'Deactivated';
      case FollowStatus.suspended:
        return 'Suspended';
      case FollowStatus.blockedBy:
        return 'Blocked by';
      case FollowStatus.blocking:
        return 'Blocking';
      case FollowStatus.mutualBlock:
        return 'Mutual block';
      case FollowStatus.hidden:
        return 'Hidden';
      case FollowStatus.selfFollow:
        return 'Self-follow';
    }
  }

  void _assertCurrentSessionRepoAccess({required String did, required String operation}) {
    final normalizedDid = did.trim().toLowerCase();
    if (normalizedDid.isEmpty) {
      throw ArgumentError.value(did, 'did', 'DID must not be empty');
    }

    final sessionDid = _currentSessionDid();
    if (sessionDid == null) {
      return;
    }

    if (normalizedDid != sessionDid) {
      throw StateError(
        'FollowAuditRepository.$operation supports only current-session repo access: did=$normalizedDid sessionDid=$sessionDid',
      );
    }
  }

  String? _currentSessionDid() => resolveCurrentSessionDid(
    sessionDid: _authRecovery.client.session?.did,
    oauthSubject: _authRecovery.client.oAuthSession?.sub,
  );
}

class _BatchResult {
  const _BatchResult({required this.classified, required this.failedCount});

  final List<ClassifiedFollow> classified;
  final int failedCount;
}

class _SingleResult {
  const _SingleResult({required this.profile, required this.status, required this.failed});

  final ProfileView? profile;
  final FollowStatus? status;
  final bool failed;
}
