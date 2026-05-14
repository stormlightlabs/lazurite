part of '../poptart_client_adapter.dart';

class AtProtoRepoService {
  AtProtoRepoService._(this._client);

  final PoptartClient _client;

  Future<XRPCResponse<RepoDescribeRepoOutput>> describeRepo({
    required String repo,
    Map<String, String>? $headers,
    String? $service,
  }) => _client.call(
    comAtprotoRepoDescribeRepo,
    headers: $headers,
    service: $service,
    parameters: RepoDescribeRepoInput(repo: repo),
  );

  Future<XRPCResponse<RepoGetRecordOutput>> getRecord({
    required String repo,
    required String collection,
    required String rkey,
    String? cid,
    Map<String, String>? $headers,
    String? $service,
  }) => _client.call(
    comAtprotoRepoGetRecord,
    headers: $headers,
    service: $service,
    parameters: RepoGetRecordInput(repo: repo, collection: collection, rkey: rkey, cid: cid),
  );

  Future<XRPCResponse<RepoListRecordsOutput>> listRecords({
    required String repo,
    required String collection,
    int limit = 50,
    String? cursor,
    bool? reverse,
    Map<String, String>? $headers,
    String? $service,
  }) => _client.call(
    comAtprotoRepoListRecords,
    headers: $headers,
    service: $service,
    parameters: RepoListRecordsInput(
      repo: repo,
      collection: collection,
      limit: limit,
      cursor: cursor,
      reverse: reverse,
    ),
  );

  Future<XRPCResponse<RepoCreateRecordOutput>> createRecord({
    required String repo,
    required String collection,
    String? rkey,
    bool? validate,
    required Map<String, dynamic> record,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => _client.call(
    comAtprotoRepoCreateRecord,
    headers: $headers,
    service: $service,
    input: RepoCreateRecordInput(
      repo: repo,
      collection: collection,
      rkey: rkey,
      validate: validate,
      record: _normalizeJson(record) as Map<String, dynamic>,
      swapCommit: swapCommit,
    ),
  );

  Future<XRPCResponse<RepoPutRecordOutput>> putRecord({
    required String repo,
    required String collection,
    required String rkey,
    bool? validate,
    required Map<String, dynamic> record,
    String? swapRecord,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => _client.call(
    comAtprotoRepoPutRecord,
    headers: $headers,
    service: $service,
    input: RepoPutRecordInput(
      repo: repo,
      collection: collection,
      rkey: rkey,
      validate: validate,
      record: _normalizeJson(record) as Map<String, dynamic>,
      swapRecord: swapRecord,
      swapCommit: swapCommit,
    ),
  );

  Future<XRPCResponse<RepoDeleteRecordOutput>> deleteRecord({
    required String repo,
    required String collection,
    required String rkey,
    String? swapRecord,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => _client.call(
    comAtprotoRepoDeleteRecord,
    headers: $headers,
    service: $service,
    input: RepoDeleteRecordInput(
      repo: repo,
      collection: collection,
      rkey: rkey,
      swapRecord: swapRecord,
      swapCommit: swapCommit,
    ),
  );

  Future<XRPCResponse<RepoUploadBlobOutput>> uploadBlob({
    required Uint8List bytes,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(comAtprotoRepoUploadBlob, headers: $headers, service: $service, input: bytes);
  }

  Future<XRPCResponse<RepoApplyWritesOutput>> applyWrites({
    required String repo,
    bool? validate,
    required List<URepoApplyWritesWrites> writes,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => _client.call(
    comAtprotoRepoApplyWrites,
    headers: $headers,
    service: $service,
    input:
        _coerceDescriptorInput(
              comAtprotoRepoApplyWrites.methodDescriptor,
              RepoApplyWritesInput(repo: repo, validate: validate, writes: writes, swapCommit: swapCommit),
            )
            as RepoApplyWritesInput,
  );
}
