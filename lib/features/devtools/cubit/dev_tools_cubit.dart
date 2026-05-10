import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/actor_repository_service_resolver.dart';
import 'package:lazurite/core/network/atproto_host_resolver.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:poptart_lex/app/bsky/actor/defs.dart';
import 'package:poptart_lex/app/bsky/actor/search_actors_typeahead.dart';
import 'package:poptart_lex/com/atproto/identity/resolve_handle.dart';
import 'package:poptart_lex/com/atproto/repo/describe_repo.dart';
import 'package:poptart_lex/com/atproto/repo/get_record.dart';
import 'package:poptart_lex/com/atproto/repo/list_records.dart';

part 'dev_tools_state.dart';

abstract interface class DevToolsRepository {
  Future<IdentityResolveHandleOutput> resolveHandle({required String handle});

  Future<RepoDescribeRepoOutput> describeRepo({required String repo, String? serviceHost});

  Future<List<ProfileViewBasic>> searchActorsTypeahead({required String query, int limit = 8});

  Future<RepoListRecordsOutput> listRecords({
    required String repo,
    required String collection,
    int? limit,
    String? cursor,
    bool? reverse,
    String? serviceHost,
  });

  Future<RepoGetRecordOutput> getRecord({
    required String repo,
    required String collection,
    required String rkey,
    String? serviceHost,
  });
}

final class AtprotoDevToolsRepository implements DevToolsRepository {
  const AtprotoDevToolsRepository({required ATProto atproto}) : _atproto = atproto;

  static const _searchActorsTypeaheadNsid = NSID('app.bsky.actor.searchActorsTypeahead');

  final ATProto _atproto;

  @override
  Future<IdentityResolveHandleOutput> resolveHandle({required String handle}) async {
    final response = await _atproto.identity.resolveHandle(handle: handle);
    return response.data;
  }

  @override
  Future<RepoDescribeRepoOutput> describeRepo({required String repo, String? serviceHost}) async {
    final response = await _atproto.repo.describeRepo(repo: repo, $service: serviceHost);
    return response.data;
  }

  @override
  Future<List<ProfileViewBasic>> searchActorsTypeahead({required String query, int limit = 8}) async {
    final normalizedQuery = query.trim().replaceFirst(RegExp(r'^@+'), '');
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final response = await _atproto.get(
      _searchActorsTypeaheadNsid,
      parameters: {'q': normalizedQuery, 'limit': limit},
      to: const ActorSearchActorsTypeaheadOutputConverter().fromJson,
    );
    return response.data.actors;
  }

  @override
  Future<RepoListRecordsOutput> listRecords({
    required String repo,
    required String collection,
    int? limit,
    String? cursor,
    bool? reverse,
    String? serviceHost,
  }) async {
    final response = await _atproto.repo.listRecords(
      repo: repo,
      collection: collection,
      limit: limit,
      cursor: cursor,
      reverse: reverse,
      $service: serviceHost,
    );
    return response.data;
  }

  @override
  Future<RepoGetRecordOutput> getRecord({
    required String repo,
    required String collection,
    required String rkey,
    String? serviceHost,
  }) async {
    final response = await _atproto.repo.getRecord(
      repo: repo,
      collection: collection,
      rkey: rkey,
      $service: serviceHost,
    );
    return response.data;
  }
}

class DevToolsCubit extends Cubit<DevToolsState> {
  DevToolsCubit({ATProto? atproto, DevToolsRepository? repository, ActorRepositoryServiceResolver? actorRepoResolver})
    : assert(atproto != null || repository != null, 'Provide either atproto or repository'),
      _repository = repository ?? AtprotoDevToolsRepository(atproto: atproto!),
      _actorRepoResolver = actorRepoResolver ?? (atproto == null ? null : ActorRepositoryServiceResolver()),
      super(const DevToolsState());

  static const _pageSize = 50;
  static const _countPageSize = 100;

  final DevToolsRepository _repository;
  final ActorRepositoryServiceResolver? _actorRepoResolver;
  int _resolveRequestId = 0;
  int _collectionRequestId = 0;
  int _recordRequestId = 0;
  int _typeaheadRequestId = 0;

  Future<void> resolve(String input) async {
    final query = _normalizeInputForResolve(input);
    if (query.isEmpty) {
      clearInput();
      return;
    }

    final resolveRequestId = _beginResolveRequest();
    emit(const DevToolsState(status: DevToolsStatus.loading));

    try {
      if (query.startsWith('at://')) {
        await _resolveAtUri(query, resolveRequestId);
        return;
      }

      final identity = await _resolveIdentity(query);
      if (!_isActiveResolveRequest(resolveRequestId)) {
        return;
      }

      final repo = await _repository.describeRepo(repo: identity.did, serviceHost: identity.pdsHost);
      if (!_isActiveResolveRequest(resolveRequestId)) {
        return;
      }

      emit(
        _buildRepoState(
          repo: repo,
          did: identity.did,
          handle: identity.handle,
          repoServiceHost: identity.pdsHost,
          status: DevToolsStatus.repoLoaded,
        ),
      );
      unawaited(
        _loadCollectionCounts(resolveRequestId: resolveRequestId, did: identity.did, repoServiceHost: identity.pdsHost),
      );
    } catch (error, stackTrace) {
      log.e('DevToolsCubit: Failed to resolve repo', error: error, stackTrace: stackTrace);
      if (_isActiveResolveRequest(resolveRequestId)) {
        emit(state.copyWith(status: DevToolsStatus.error, errorMessage: _formatError(error)));
      }
    }
  }

  Future<void> queryTypeahead(String input) async {
    final query = input.trim();
    if (!query.startsWith('@')) {
      clearTypeahead();
      return;
    }

    final normalizedQuery = query.replaceFirst(RegExp(r'^@+'), '');
    if (normalizedQuery.isEmpty) {
      clearTypeahead();
      return;
    }

    final typeaheadRequestId = _beginTypeaheadRequest();
    emit(state.copyWith(isTypeaheadLoading: true, typeaheadActors: const []));

    try {
      final actors = await _repository.searchActorsTypeahead(query: normalizedQuery);
      if (!_isActiveTypeaheadRequest(typeaheadRequestId)) {
        return;
      }

      emit(state.copyWith(typeaheadActors: actors, isTypeaheadLoading: false));
    } catch (error, stackTrace) {
      log.w('DevToolsCubit: Failed to fetch handle typeahead', error: error, stackTrace: stackTrace);
      if (_isActiveTypeaheadRequest(typeaheadRequestId)) {
        emit(state.copyWith(typeaheadActors: const [], isTypeaheadLoading: false));
      }
    }
  }

  void clearTypeahead() {
    final hadTypeahead = state.typeaheadActors.isNotEmpty || state.isTypeaheadLoading;
    _beginTypeaheadRequest();
    if (!hadTypeahead) {
      return;
    }
    emit(state.copyWith(typeaheadActors: const [], isTypeaheadLoading: false));
  }

  Future<void> loadCollection(String collection) async {
    if (state.did == null) return;

    final collectionRequestId = _beginCollectionRequest();
    emit(state.copyWith(isCollectionLoading: true, isRecordLoading: false, errorMessage: null));

    try {
      final response = await _repository.listRecords(
        repo: state.did!,
        collection: collection,
        limit: _pageSize,
        serviceHost: state.repoServiceHost,
      );
      if (!_isActiveCollectionRequest(collectionRequestId)) {
        return;
      }

      emit(
        state.copyWith(
          status: DevToolsStatus.collectionLoaded,
          selectedCollection: collection,
          records: response.records,
          recordsCursor: response.cursor,
          selectedRecord: null,
          isCollectionLoading: false,
          isRecordLoading: false,
          errorMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      log.e('DevToolsCubit: Failed to load collection', error: error, stackTrace: stackTrace);
      if (_isActiveCollectionRequest(collectionRequestId)) {
        emit(state.copyWith(isCollectionLoading: false, errorMessage: _formatError(error)));
      }
    }
  }

  Future<void> loadMoreRecords() async {
    if (state.did == null || state.selectedCollection == null || state.recordsCursor == null) return;

    emit(state.copyWith(status: DevToolsStatus.loadingMore, errorMessage: null));

    final activeCollectionRequestId = _collectionRequestId;
    try {
      final response = await _repository.listRecords(
        repo: state.did!,
        collection: state.selectedCollection!,
        cursor: state.recordsCursor,
        limit: _pageSize,
        serviceHost: state.repoServiceHost,
      );
      if (!_isActiveCollectionRequest(activeCollectionRequestId)) {
        return;
      }

      emit(
        state.copyWith(
          status: DevToolsStatus.collectionLoaded,
          records: [...?state.records, ...response.records],
          recordsCursor: response.cursor,
          errorMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      log.e('DevToolsCubit: Failed to load more records', error: error, stackTrace: stackTrace);
      if (_isActiveCollectionRequest(activeCollectionRequestId)) {
        emit(
          state.copyWith(
            status: DevToolsStatus.collectionLoaded,
            isCollectionLoading: false,
            isRecordLoading: false,
            errorMessage: _formatError(error),
          ),
        );
      }
    }
  }

  Future<void> loadRecord(RepoListRecordsRecord record) async {
    if (state.did == null) return;

    final recordRequestId = _beginRecordRequest();
    emit(state.copyWith(isRecordLoading: true, errorMessage: null));

    try {
      final resolvedRecord = await _repository.getRecord(
        repo: state.did!,
        collection: record.uri.collection.toString(),
        rkey: record.uri.rkey,
        serviceHost: state.repoServiceHost,
      );
      if (!_isActiveRecordRequest(recordRequestId)) {
        return;
      }

      emit(
        state.copyWith(
          status: DevToolsStatus.recordLoaded,
          selectedRecord: RecordInfo(
            uri: resolvedRecord.uri.toString(),
            cid: resolvedRecord.cid,
            value: resolvedRecord.value,
          ),
          isRecordLoading: false,
          errorMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      log.e('DevToolsCubit: Failed to load record', error: error, stackTrace: stackTrace);
      if (_isActiveRecordRequest(recordRequestId)) {
        emit(state.copyWith(isRecordLoading: false, errorMessage: _formatError(error)));
      }
    }
  }

  void goBackToCollection() {
    _recordRequestId++;
    if (state.selectedCollection != null) {
      emit(
        state.copyWith(
          status: DevToolsStatus.collectionLoaded,
          selectedRecord: null,
          isCollectionLoading: false,
          isRecordLoading: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: DevToolsStatus.repoLoaded,
          selectedCollection: null,
          records: null,
          recordsCursor: null,
          selectedRecord: null,
          isCollectionLoading: false,
          isRecordLoading: false,
        ),
      );
    }
  }

  void goBackToRepo() {
    _collectionRequestId++;
    _recordRequestId++;
    emit(
      state.copyWith(
        status: DevToolsStatus.repoLoaded,
        selectedCollection: null,
        records: null,
        recordsCursor: null,
        selectedRecord: null,
        isCollectionLoading: false,
        isRecordLoading: false,
      ),
    );
  }

  void clearInput() {
    _beginResolveRequest();
    emit(const DevToolsState());
  }

  int _beginResolveRequest() {
    _resolveRequestId++;
    _collectionRequestId++;
    _recordRequestId++;
    _typeaheadRequestId++;
    return _resolveRequestId;
  }

  int _beginCollectionRequest() {
    _collectionRequestId++;
    _recordRequestId++;
    return _collectionRequestId;
  }

  int _beginRecordRequest() {
    _recordRequestId++;
    return _recordRequestId;
  }

  int _beginTypeaheadRequest() {
    _typeaheadRequestId++;
    return _typeaheadRequestId;
  }

  bool _isActiveResolveRequest(int requestId) => requestId == _resolveRequestId;

  bool _isActiveCollectionRequest(int requestId) => requestId == _collectionRequestId;

  bool _isActiveRecordRequest(int requestId) => requestId == _recordRequestId;

  bool _isActiveTypeaheadRequest(int requestId) => requestId == _typeaheadRequestId;

  Future<void> _resolveAtUri(String input, int resolveRequestId) async {
    final atUri = _parseAtUri(input);
    final identity = await _resolveIdentity(atUri.hostname);
    if (!_isActiveResolveRequest(resolveRequestId)) {
      return;
    }

    final repo = await _repository.describeRepo(repo: identity.did, serviceHost: identity.pdsHost);
    if (!_isActiveResolveRequest(resolveRequestId)) {
      return;
    }

    final collection = _collectionFromAtUri(atUri);
    final rkey = _rkeyFromAtUri(atUri);

    if (collection == null) {
      emit(
        _buildRepoState(
          repo: repo,
          did: identity.did,
          handle: identity.handle,
          repoServiceHost: identity.pdsHost,
          status: DevToolsStatus.repoLoaded,
        ),
      );
      unawaited(
        _loadCollectionCounts(resolveRequestId: resolveRequestId, did: identity.did, repoServiceHost: identity.pdsHost),
      );
      return;
    }

    final records = await _repository.listRecords(
      repo: identity.did,
      collection: collection,
      limit: _pageSize,
      serviceHost: identity.pdsHost,
    );
    if (!_isActiveResolveRequest(resolveRequestId)) {
      return;
    }

    if (rkey == null) {
      emit(
        _buildRepoState(
          repo: repo,
          did: identity.did,
          handle: identity.handle,
          repoServiceHost: identity.pdsHost,
          status: DevToolsStatus.collectionLoaded,
          selectedCollection: collection,
          records: records.records,
          recordsCursor: records.cursor,
        ),
      );
      unawaited(
        _loadCollectionCounts(resolveRequestId: resolveRequestId, did: identity.did, repoServiceHost: identity.pdsHost),
      );
      return;
    }

    final record = await _repository.getRecord(
      repo: identity.did,
      collection: collection,
      rkey: rkey,
      serviceHost: identity.pdsHost,
    );
    if (!_isActiveResolveRequest(resolveRequestId)) {
      return;
    }

    emit(
      _buildRepoState(
        repo: repo,
        did: identity.did,
        handle: identity.handle,
        repoServiceHost: identity.pdsHost,
        status: DevToolsStatus.recordLoaded,
        selectedCollection: collection,
        records: records.records,
        recordsCursor: records.cursor,
        selectedRecord: RecordInfo(uri: record.uri.toString(), cid: record.cid, value: record.value),
      ),
    );
    unawaited(
      _loadCollectionCounts(resolveRequestId: resolveRequestId, did: identity.did, repoServiceHost: identity.pdsHost),
    );
  }

  Future<({String did, String? handle, String pdsHost})> _resolveIdentity(String input) async {
    final normalizedInput = _normalizeInputForResolve(input);
    final resolver = _actorRepoResolver;
    if (resolver != null) {
      final resolution = await resolver.resolve(normalizedInput);
      return (
        did: resolution.did,
        handle: normalizedInput.startsWith('did:') ? null : normalizedInput,
        pdsHost: resolution.pdsHost,
      );
    }

    final did = normalizedInput.startsWith('did:')
        ? normalizedInput
        : (await _repository.resolveHandle(handle: normalizedInput)).did;
    final repo = await _repository.describeRepo(repo: did);
    final pdsHost = extractAtprotoPdsHostFromDidDoc(repo.didDoc);
    if (pdsHost == null || pdsHost.isEmpty) {
      throw StateError('Unable to resolve PDS host for repo: $did');
    }
    return (did: did, handle: normalizedInput.startsWith('did:') ? null : normalizedInput, pdsHost: pdsHost);
  }

  AtUri _parseAtUri(String input) {
    try {
      return AtUri.parse(input);
    } on FormatException {
      throw const FormatException('Invalid AT-URI');
    }
  }

  String? _collectionFromAtUri(AtUri atUri) {
    final segments = atUri.pathname.split('/').where((segment) => segment.isNotEmpty).toList();
    if (segments.isEmpty) {
      return null;
    }

    return segments.first;
  }

  String? _rkeyFromAtUri(AtUri atUri) {
    final segments = atUri.pathname.split('/').where((segment) => segment.isNotEmpty).toList();
    if (segments.length < 2) {
      return null;
    }

    return segments[1];
  }

  DevToolsState _buildRepoState({
    required RepoDescribeRepoOutput repo,
    required String did,
    required String? handle,
    required String repoServiceHost,
    required DevToolsStatus status,
    String? selectedCollection,
    List<RepoListRecordsRecord>? records,
    String? recordsCursor,
    RecordInfo? selectedRecord,
  }) {
    return DevToolsState(
      status: status,
      did: did,
      handle: handle ?? repo.handle,
      repoServiceHost: repoServiceHost,
      repoHandle: repo.handle,
      collections: repo.collections.map(CollectionSummary.new).toList(growable: false),
      isCollectionCountsLoading: repo.collections.isNotEmpty,
      selectedCollection: selectedCollection,
      records: records,
      recordsCursor: recordsCursor,
      selectedRecord: selectedRecord,
      isCollectionLoading: false,
      isRecordLoading: false,
    );
  }

  Future<void> _loadCollectionCounts({
    required int resolveRequestId,
    required String did,
    required String repoServiceHost,
  }) async {
    if (state.collections.isEmpty) {
      if (_isActiveResolveRequest(resolveRequestId)) {
        emit(state.copyWith(isCollectionCountsLoading: false));
      }
      return;
    }

    final countsByCollection = <String, int>{};
    for (final collection in state.collections) {
      if (!_isActiveResolveRequest(resolveRequestId)) {
        return;
      }

      countsByCollection[collection.name] = await _countRecords(
        did: did,
        collection: collection.name,
        repoServiceHost: repoServiceHost,
      );
      if (!_isActiveResolveRequest(resolveRequestId)) {
        return;
      }

      emit(
        state.copyWith(
          collections: _mergeCollectionCounts(state.collections, countsByCollection),
          isCollectionCountsLoading: countsByCollection.length < state.collections.length,
        ),
      );
    }
  }

  Future<int> _countRecords({required String did, required String collection, required String repoServiceHost}) async {
    var total = 0;
    String? cursor;

    do {
      final response = await _repository.listRecords(
        repo: did,
        collection: collection,
        limit: _countPageSize,
        cursor: cursor,
        serviceHost: repoServiceHost,
      );
      total += response.records.length;
      cursor = response.cursor;
    } while (cursor != null && cursor.isNotEmpty);

    return total;
  }

  List<CollectionSummary> _mergeCollectionCounts(
    List<CollectionSummary> collections,
    Map<String, int> countsByCollection,
  ) {
    return collections
        .map(
          (collection) => CollectionSummary(
            collection.name,
            recordCount: countsByCollection[collection.name] ?? collection.recordCount,
          ),
        )
        .toList(growable: false);
  }

  String _formatError(Object error) {
    if (error is FormatException) {
      return error.message;
    }

    return error.toString();
  }

  String _normalizeInputForResolve(String input) {
    final query = input.trim();
    if (query.startsWith('@') && !query.startsWith('at://')) {
      return query.replaceFirst(RegExp(r'^@+'), '');
    }
    return query;
  }
}
