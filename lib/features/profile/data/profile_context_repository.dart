import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/graph/block.dart';
import 'package:bluesky_poptart/app/bsky/graph/defs.dart';
import 'package:poptart_lex/com/atproto/repo/list_records.dart';
import 'package:equatable/equatable.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/constellation_client.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/unauthorized_recovery_runner.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/auth/data/session_identity.dart';

const _blockedByPageSize = 16;
const _listsPageSize = 16;

class UnavailableProfileRef extends Equatable {
  const UnavailableProfileRef({required this.did, required this.reason});

  final String did;
  final String reason;

  @override
  List<Object?> get props => [did, reason];
}

class BlockedByEntry extends Equatable {
  BlockedByEntry.profile({required ProfileView this.profile}) : did = profile.did, unavailableReason = null;

  const BlockedByEntry.unavailable({required this.did, required this.unavailableReason}) : profile = null;

  final String did;
  final ProfileView? profile;
  final String? unavailableReason;

  bool get isAvailable => profile != null;

  @override
  List<Object?> get props => [did, profile, unavailableReason];
}

class ProfileContextRepository {
  ProfileContextRepository({
    required Bluesky bluesky,
    Bluesky? publicBluesky,
    required ConstellationClient constellationClient,
    Future<AuthTokens?> Function()? onUnauthorized,
    Bluesky? Function(AuthTokens tokens)? blueskyClientFactory,
  }) : _publicBluesky = publicBluesky ?? bluesky,
       _constellation = constellationClient {
    _authRecovery = UnauthorizedRecoveryRunner<Bluesky>(
      initialClient: bluesky,
      onUnauthorized: onUnauthorized,
      clientFactory: blueskyClientFactory ?? createBlueskyClient,
    );
  }

  late final UnauthorizedRecoveryRunner<Bluesky> _authRecovery;
  final Bluesky _publicBluesky;
  final ConstellationClient _constellation;

  /// Returns the number of accounts that have blocked [did].
  Future<int> getBlockedByCount(String did) async {
    return _constellation.getBacklinksCount(did, 'app.bsky.graph.block:subject');
  }

  /// Returns the number of lists that [did] is a member of.
  Future<int> getListsOnCount(String did) async {
    return _constellation.getBacklinksCount(did, 'app.bsky.graph.listitem:subject');
  }

  /// Returns a page of profiles that have blocked [did], along with the total
  /// count and a cursor for the next page.
  Future<({List<BlockedByEntry> entries, String? cursor, int total})> getBlockedByProfiles(
    String did, {
    String? cursor,
  }) async {
    final offset = int.tryParse(cursor ?? '0') ?? 0;
    log.i('ProfileContextRepository: blocked-by load start for $did offset=$offset via ${_constellation.baseUrl}');
    final collected = await _collectBlockedByDids(did);
    final hydrated = await _hydrateProfiles(collected.dids);
    final unavailableByDid = <String, String>{for (final entry in hydrated.unavailable) entry.did: entry.reason};
    final profileByDid = <String, ProfileView>{for (final profile in hydrated.profiles) profile.did: profile};

    final pageDids = collected.dids.skip(offset).take(_blockedByPageSize).toList();
    final entries = <BlockedByEntry>[];
    for (final pageDid in pageDids) {
      final profile = profileByDid[pageDid];
      if (profile != null) {
        entries.add(BlockedByEntry.profile(profile: profile));
        continue;
      }

      final unavailableReason = unavailableByDid[pageDid];
      if (unavailableReason != null) {
        entries.add(BlockedByEntry.unavailable(did: pageDid, unavailableReason: unavailableReason));
      }
    }

    final nextOffset = offset + _blockedByPageSize;
    log.i(
      'ProfileContextRepository: blocked-by load complete for $did total=${collected.total} dids=${collected.dids.length} resolved=${hydrated.profiles.length} unavailable=${hydrated.unavailable.length} returned=${entries.length}',
    );
    return (
      entries: entries,
      cursor: nextOffset < collected.dids.length ? '$nextOffset' : null,
      total: collected.total,
    );
  }

  /// Returns the total number of accounts that [did] is blocking.
  Future<int> getBlockingCount(String did) async {
    _assertCurrentSessionRepoAccess(did: did, operation: 'getBlockingCount');
    var total = 0;
    String? cursor;

    do {
      final response = await _authRecovery.run(
        (client) =>
            client.atproto.repo.listRecords(repo: did, collection: 'app.bsky.graph.block', limit: 100, cursor: cursor),
      );

      total += response.data.records.length;
      cursor = response.data.cursor;
    } while (cursor != null);

    return total;
  }

  /// Returns a page of profiles that [did] is blocking, along with a cursor.
  /// Uses `com.atproto.repo.listRecords` on the actor's own repo.
  /// [total] reflects the number of profiles hydrated in this page.
  Future<({List<ProfileView> profiles, List<UnavailableProfileRef> unavailable, String? cursor, int total})>
  getBlockingProfiles(String did, {String? cursor}) async {
    _assertCurrentSessionRepoAccess(did: did, operation: 'getBlockingProfiles');
    final response = await _authRecovery.run(
      (client) =>
          client.atproto.repo.listRecords(repo: did, collection: 'app.bsky.graph.block', limit: 50, cursor: cursor),
    );

    final subjectDids = response.data.records.map(_blockSubjectDid).whereType<String>().toList(growable: false);
    final hydrated = await _hydrateProfiles(subjectDids);
    return (
      profiles: hydrated.profiles,
      unavailable: hydrated.unavailable,
      cursor: response.data.cursor,
      total: hydrated.profiles.length,
    );
  }

  /// Returns a page of lists that [did] is a member of, along with the total
  /// count and a cursor for the next page.
  Future<({List<ListView> lists, String? cursor, int total})> getListsOn(String did, {String? cursor}) async {
    final total = await _constellation.getBacklinksCount(did, 'app.bsky.graph.listitem:subject');
    final result = await _constellation.getManyToMany(
      did,
      'app.bsky.graph.listitem:subject',
      'list',
      limit: _listsPageSize,
      cursor: cursor,
    );

    final uniqueListUris = <String>{};
    final listUris = <String>[];
    for (final item in result.items) {
      if (uniqueListUris.add(item.otherSubject)) {
        listUris.add(item.otherSubject);
      }
    }

    final lists = <ListView>[];
    for (final uriString in listUris) {
      try {
        final uri = AtUri.parse(uriString);
        final response = await _publicBluesky.graph.getList(list: uri, limit: 1);
        lists.add(response.data.list);
      } catch (error, stackTrace) {
        log.w(
          'skipping invalid or unavailable list in profile context: $uriString',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    return (lists: lists, cursor: result.cursor, total: total);
  }

  /// Hydrates [dids] into [ProfileView] objects in batches of 25.
  Future<({List<ProfileView> profiles, List<UnavailableProfileRef> unavailable})> _hydrateProfiles(
    List<String> dids,
  ) async {
    final normalizedDids = _normalizeDids(dids);
    if (normalizedDids.isEmpty) {
      return (profiles: <ProfileView>[], unavailable: <UnavailableProfileRef>[]);
    }

    final allProfiles = <ProfileView>[];
    final unavailable = <UnavailableProfileRef>[];
    for (var i = 0; i < normalizedDids.length; i += 25) {
      final batch = normalizedDids.sublist(i, (i + 25).clamp(0, normalizedDids.length));
      final resolvedProfiles = <String, ProfileView>{};
      log.d(
        'ProfileContextRepository: blocked-by public batch ${i ~/ 25 + 1} size=${batch.length} dids=${batch.join(',')}',
      );
      try {
        final response = await _publicBluesky.actor.getProfiles(actors: batch);
        for (final profile in response.data.profiles) {
          final converted = _asProfileView(profile);
          if (converted != null) {
            resolvedProfiles[converted.did] = converted;
          }
        }
      } catch (error, stackTrace) {
        log.w(
          'ProfileContextRepository: blocked-by public batch failed, falling back to per-DID lookups for ${batch.length} actors',
          error: error,
          stackTrace: stackTrace,
        );
      }

      for (final did in batch) {
        final existing = resolvedProfiles[did];
        if (existing != null) {
          log.d('ProfileContextRepository: blocked-by public batch resolved $did');
          allProfiles.add(existing);
          continue;
        }

        try {
          final response = await _publicBluesky.actor.getProfile(actor: did);
          final converted = _asProfileView(response.data);
          if (converted != null) {
            log.d('ProfileContextRepository: blocked-by per-DID resolved $did');
            allProfiles.add(converted);
          } else {
            const reason = 'Public profile lookup failed';
            unavailable.add(UnavailableProfileRef(did: did, reason: reason));
            log.w('ProfileContextRepository: blocked-by per-DID returned an unsupported profile shape for $did');
          }
        } catch (error, stackTrace) {
          final reason = _publicProfileFailureReason(error);
          unavailable.add(UnavailableProfileRef(did: did, reason: reason));
          log.w(
            'ProfileContextRepository: blocked-by per-DID failed for $did: $reason',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
    }
    return (profiles: allProfiles, unavailable: unavailable);
  }

  Future<({List<String> dids, int total})> _collectBlockedByDids(String did) async {
    try {
      final dids = <String>[];
      final seen = <String>{};
      var total = 0;
      String? cursor;
      log.i('ProfileContextRepository: blocked-by using getDistinct for $did');

      do {
        final result = await _constellation.getDistinct(
          did,
          'app.bsky.graph.block:subject',
          limit: _blockedByPageSize,
          cursor: cursor,
        );
        final inputCursor = cursor;
        if (total == 0) {
          total = result.total;
          log.i('ProfileContextRepository: blocked-by count for $did is $total');
        }
        for (final rawDid in result.dids) {
          final normalizedDid = _normalizeDid(rawDid);
          if (normalizedDid != null && seen.add(normalizedDid)) {
            dids.add(normalizedDid);
          }
        }
        cursor = result.cursor;
        log.d(
          'ProfileContextRepository: blocked-by getDistinct page cursorIn=${inputCursor ?? 'null'} records=${result.dids.length} uniqueTotal=${dids.length} cursorOut=${cursor ?? 'null'}',
        );
      } while (cursor != null);

      log.i('ProfileContextRepository: blocked-by collected ${dids.length} unique DIDs from getDistinct for $did');
      return (dids: dids, total: total);
    } on ConstellationException catch (error) {
      if (!_isNotFound(error)) rethrow;
      log.w('ProfileContextRepository: blocked-by getDistinct returned 404 for $did, falling back to getBacklinks');

      final dids = <String>[];
      final seen = <String>{};
      var total = 0;
      String? cursor;

      do {
        final result = await _constellation.getBacklinks(
          did,
          'app.bsky.graph.block:subject',
          limit: _blockedByPageSize,
          cursor: cursor,
        );
        final inputCursor = cursor;
        if (total == 0) {
          total = result.total;
          log.i('ProfileContextRepository: blocked-by count for $did is $total');
        }
        for (final record in result.records) {
          final normalizedDid = _normalizeDid(record.did);
          if (normalizedDid != null && seen.add(normalizedDid)) {
            dids.add(normalizedDid);
          }
        }
        cursor = result.cursor;
        log.d(
          'ProfileContextRepository: blocked-by getBacklinks page cursorIn=${inputCursor ?? 'null'} records=${result.records.length} uniqueTotal=${dids.length} cursorOut=${cursor ?? 'null'}',
        );
      } while (cursor != null);

      log.i('ProfileContextRepository: blocked-by collected ${dids.length} unique DIDs from getBacklinks for $did');
      return (dids: dids, total: total);
    }
  }

  List<String> _normalizeDids(List<String> dids) {
    final normalized = <String>[];
    final seen = <String>{};
    for (final did in dids) {
      final value = _normalizeDid(did);
      if (value != null && seen.add(value)) {
        normalized.add(value);
      }
    }
    return normalized;
  }

  String? _normalizeDid(String did) {
    final trimmed = did.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  void _assertCurrentSessionRepoAccess({required String did, required String operation}) {
    final normalizedDid = _normalizeDid(did)?.toLowerCase();
    if (normalizedDid == null) {
      throw ArgumentError.value(did, 'did', 'DID must not be empty');
    }

    final sessionDid = _currentSessionDid();
    if (sessionDid == null) {
      return;
    }

    if (normalizedDid != sessionDid) {
      throw StateError(
        'ProfileContextRepository.$operation supports only current-session repo reads: did=$normalizedDid sessionDid=$sessionDid',
      );
    }
  }

  String? _currentSessionDid() => resolveCurrentSessionDid(
    sessionDid: _authRecovery.client.session?.did,
    oauthSubject: _authRecovery.client.oAuthSession?.sub,
  );

  String _publicProfileFailureReason(Object error) {
    final message = error.toString();
    final lowerMessage = message.toLowerCase();
    if (message.contains('AccountTakedown') || lowerMessage.contains('account has been suspended')) {
      return 'Suspended account';
    }
    if (message.contains('HTTP 404') || lowerMessage.contains('not found')) {
      return 'Profile unavailable';
    }
    return 'Public profile lookup failed';
  }

  ProfileView? _asProfileView(Object? profile) {
    if (profile is ProfileView) {
      return profile;
    }

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

  String? _blockSubjectDid(RepoListRecordsRecord record) {
    final value = record.value;
    if (!GraphBlockRecord.validate(value)) {
      return null;
    }

    final block = const GraphBlockRecordConverter().fromJson(value);
    final subject = block.subject.trim();
    return subject.isEmpty ? null : subject;
  }

  bool _isNotFound(ConstellationException error) => error.message.startsWith('HTTP 404');
}
