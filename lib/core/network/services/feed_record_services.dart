part of '../poptart_client_adapter.dart';

class FeedLikeRecordService extends _CurrentRepoRecordService {
  FeedLikeRecordService._(PoptartClient client) : super(client, 'app.bsky.feed.like');

  Future<XRPCResponse<RepoCreateRecordOutput>> create({
    required RepoStrongRef subject,
    DateTime? createdAt,
    RepoStrongRef? via,
    String? rkey,
    bool? validate,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => createRecord(
    record: FeedLikeRecord(
      subject: subject,
      createdAt: canonicalAtProtoDateTime(createdAt ?? DateTime.now()),
      via: via,
    ).toJson(),
    rkey: rkey,
    validate: validate,
    swapCommit: swapCommit,
    $headers: $headers,
    $service: $service,
  );
}

class FeedRepostRecordService extends _CurrentRepoRecordService {
  FeedRepostRecordService._(PoptartClient client) : super(client, 'app.bsky.feed.repost');

  Future<XRPCResponse<RepoCreateRecordOutput>> create({
    required RepoStrongRef subject,
    DateTime? createdAt,
    RepoStrongRef? via,
    String? rkey,
    bool? validate,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => createRecord(
    record: FeedRepostRecord(
      subject: subject,
      createdAt: canonicalAtProtoDateTime(createdAt ?? DateTime.now()),
      via: via,
    ).toJson(),
    rkey: rkey,
    validate: validate,
    swapCommit: swapCommit,
    $headers: $headers,
    $service: $service,
  );
}

class FeedPostRecordService extends _CurrentRepoRecordService {
  FeedPostRecordService._(PoptartClient client) : super(client, 'app.bsky.feed.post');

  Future<XRPCResponse<RepoPutRecordOutput>> put({
    required String rkey,
    required FeedPostRecord record,
    bool? validate,
    String? swapRecord,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => putRecord(
    rkey: rkey,
    record: record.toJson(),
    validate: validate,
    swapRecord: swapRecord,
    swapCommit: swapCommit,
    $headers: $headers,
    $service: $service,
  );
}
