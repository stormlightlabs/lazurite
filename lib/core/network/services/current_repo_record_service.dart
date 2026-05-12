part of '../poptart_client_adapter.dart';

abstract class _CurrentRepoRecordService {
  _CurrentRepoRecordService(this._client, this._collection);

  final PoptartClient _client;
  final String _collection;

  Future<XRPCResponse<RepoCreateRecordOutput>> createRecord({
    required Map<String, dynamic> record,
    String? rkey,
    bool? validate,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => AtProtoRepoService._(_client).createRecord(
    repo: _repoDid(_client),
    collection: _collection,
    rkey: rkey,
    validate: validate,
    record: record,
    swapCommit: swapCommit,
    $headers: $headers,
    $service: $service,
  );

  Future<XRPCResponse<RepoPutRecordOutput>> putRecord({
    required String rkey,
    required Map<String, dynamic> record,
    bool? validate,
    String? swapRecord,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => AtProtoRepoService._(_client).putRecord(
    repo: _repoDid(_client),
    collection: _collection,
    rkey: rkey,
    validate: validate,
    record: record,
    swapRecord: swapRecord,
    swapCommit: swapCommit,
    $headers: $headers,
    $service: $service,
  );

  Future<XRPCResponse<RepoDeleteRecordOutput>> delete({
    required String rkey,
    String? swapRecord,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => AtProtoRepoService._(_client).deleteRecord(
    repo: _repoDid(_client),
    collection: _collection,
    rkey: rkey,
    swapRecord: swapRecord,
    swapCommit: swapCommit,
    $headers: $headers,
    $service: $service,
  );
}
