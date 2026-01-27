import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/core/utils/pagination.dart';
import 'package:lazurite/src/features/developer_tools/domain/repo_collection.dart';
import 'package:lazurite/src/features/developer_tools/domain/repo_record.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

/// Repository for accessing ATProto repository data for DevTools.
///
/// Provides read-only access to explore collections and records in a
/// user's repository.
class DevtoolsRepository {
  DevtoolsRepository(this._xrpc, this._logger);

  final XrpcClient _xrpc;
  final Logger _logger;

  /// Describes a repository and lists all collections.
  ///
  /// Calls com.atproto.repo.describeRepo to get available collections
  /// for the specified DID.
  ///
  /// Returns a list of collections with their NSIDs. Note that the API
  /// only returns collection NSIDs (as strings), not record counts.
  Future<List<RepoCollection>> describeRepo(String did) async {
    _logger.info('Describing repo for DID: $did');

    try {
      final response = await _xrpc.call('com.atproto.repo.describeRepo', params: {'repo': did});

      final collections = response['collections'] as List<dynamic>?;
      if (collections == null) {
        _logger.warning('No collections field in describeRepo response');
        return [];
      }

      return collections.map((nsid) => RepoCollection.fromNsid(nsid as String)).toList();
    } catch (e, stack) {
      _logger.error('Failed to describe repo for DID: $did', e, stack);
      rethrow;
    }
  }

  /// Lists records in a collection with cursor-based pagination.
  ///
  /// Calls com.atproto.repo.listRecords to fetch records from the specified
  /// collection in the given repository.
  ///
  /// [repo] is the DID of the repository to query.
  /// [collection] is the NSID of the collection (e.g., "app.bsky.feed.post").
  /// [limit] is the maximum number of records to return (default: 50, max: 100).
  /// [cursor] is the pagination cursor from a previous response.
  /// [rkeyStart] filters records by rkey prefix.
  /// [rkeyEnd] filters records by rkey end boundary.
  /// [reverse] reverses the sort order if true.
  ///
  /// Returns a [PaginatedResult] of [RepoRecord].
  Future<PaginatedResult<RepoRecord>> listRecords({
    required String repo,
    required String collection,
    int limit = 50,
    String? cursor,
    String? rkeyStart,
    String? rkeyEnd,
    bool reverse = false,
  }) async {
    _logger.info('Listing records for $repo/$collection (limit: $limit)');

    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 100');
    }

    try {
      final params = <String, dynamic>{
        'repo': repo,
        'collection': collection,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
        if (rkeyStart != null) 'rkeyStart': rkeyStart,
        if (rkeyEnd != null) 'rkeyEnd': rkeyEnd,
        if (reverse) 'reverse': true,
      };

      final response = await _xrpc.call('com.atproto.repo.listRecords', params: params);

      final recordsJson = response['records'] as List<dynamic>? ?? [];
      final records = recordsJson
          .map((json) => RepoRecord.fromJson(json as Map<String, dynamic>))
          .toList();

      final nextCursor = response['cursor'] as String?;

      return PaginatedResult(items: records, cursor: nextCursor);
    } catch (e, stack) {
      _logger.error('Failed to list records for $repo/$collection', e, stack);
      rethrow;
    }
  }

  /// Fetches a single record by its AT URI.
  ///
  /// Calls com.atproto.repo.getRecord to retrieve the record.
  ///
  /// [repo] is the DID of the repository.
  /// [collection] is the NSID of the collection.
  /// [rkey] is the record key.
  /// [cid] is an optional specific version CID to fetch.
  ///
  /// Returns the RepoRecord or null if not found.
  Future<RepoRecord?> getRecord({
    required String repo,
    required String collection,
    required String rkey,
    String? cid,
  }) async {
    _logger.info('Getting record $repo/$collection/$rkey');

    try {
      final params = <String, dynamic>{
        'repo': repo,
        'collection': collection,
        'rkey': rkey,
        if (cid != null) 'cid': cid,
      };

      final response = await _xrpc.call('com.atproto.repo.getRecord', params: params);

      final uri = response['uri'] as String?;
      final recordCid = response['cid'] as String?;
      final value = response['value'] as Map<String, dynamic>?;

      if (uri == null || recordCid == null || value == null) {
        _logger.warning('Incomplete record data in getRecord response');
        return null;
      }

      return RepoRecord(
        uri: uri,
        cid: recordCid,
        value: value,
        indexedAt: response['indexedAt'] != null
            ? DateTime.parse(response['indexedAt'] as String)
            : null,
      );
    } catch (e, stack) {
      _logger.error('Failed to get record $repo/$collection/$rkey', e, stack);
      rethrow;
    }
  }

  /// Resolves a handle to its DID.
  ///
  /// Calls com.atproto.identity.resolveHandle.
  Future<String?> resolveHandle(String handle) async {
    _logger.info('Resolving handle: $handle');

    try {
      final response = await _xrpc.call(
        'com.atproto.identity.resolveHandle',
        params: {'handle': handle},
      );
      return response['did'] as String?;
    } catch (e, stack) {
      _logger.error('Failed to resolve handle: $handle', e, stack);
      rethrow;
    }
  }
}
