part of '../poptart_client_adapter.dart';

class GraphBlockRecordService extends _CurrentRepoRecordService {
  GraphBlockRecordService._(PoptartClient client) : super(client, 'app.bsky.graph.block');

  Future<XRPCResponse<RepoCreateRecordOutput>> create({
    required String subject,
    DateTime? createdAt,
    String? rkey,
    bool? validate,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => createRecord(
    record: GraphBlockRecord(
      subject: subject,
      createdAt: canonicalAtProtoDateTime(createdAt ?? DateTime.now()),
    ).toJson(),
    rkey: rkey,
    validate: validate,
    swapCommit: swapCommit,
    $headers: $headers,
    $service: $service,
  );
}

class GraphListRecordService extends _CurrentRepoRecordService {
  GraphListRecordService._(PoptartClient client) : super(client, 'app.bsky.graph.list');

  Future<XRPCResponse<RepoCreateRecordOutput>> create({
    required ListPurpose purpose,
    required String name,
    String? description,
    List<RichtextFacet>? descriptionFacets,
    Blob? avatar,
    UGraphListLabels? labels,
    DateTime? createdAt,
    String? rkey,
    bool? validate,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => createRecord(
    record: GraphListRecord(
      purpose: purpose,
      name: name,
      description: description,
      descriptionFacets: descriptionFacets,
      avatar: avatar,
      labels: labels,
      createdAt: canonicalAtProtoDateTime(createdAt ?? DateTime.now()),
    ).toJson(),
    rkey: rkey,
    validate: validate,
    swapCommit: swapCommit,
    $headers: $headers,
    $service: $service,
  );

  Future<XRPCResponse<RepoPutRecordOutput>> put({
    required String rkey,
    required ListPurpose purpose,
    required String name,
    String? description,
    List<RichtextFacet>? descriptionFacets,
    Blob? avatar,
    UGraphListLabels? labels,
    DateTime? createdAt,
    bool? validate,
    String? swapRecord,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => putRecord(
    rkey: rkey,
    record: GraphListRecord(
      purpose: purpose,
      name: name,
      description: description,
      descriptionFacets: descriptionFacets,
      avatar: avatar,
      labels: labels,
      createdAt: canonicalAtProtoDateTime(createdAt ?? DateTime.now()),
    ).toJson(),
    validate: validate,
    swapRecord: swapRecord,
    swapCommit: swapCommit,
    $headers: $headers,
    $service: $service,
  );
}

class GraphFollowRecordService extends _CurrentRepoRecordService {
  GraphFollowRecordService._(PoptartClient client) : super(client, 'app.bsky.graph.follow');

  Future<XRPCResponse<RepoCreateRecordOutput>> create({
    required String subject,
    DateTime? createdAt,
    RepoStrongRef? via,
    String? rkey,
    bool? validate,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => createRecord(
    record: GraphFollowRecord(
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

class GraphListblockRecordService extends _CurrentRepoRecordService {
  GraphListblockRecordService._(PoptartClient client) : super(client, 'app.bsky.graph.listblock');

  Future<XRPCResponse<RepoCreateRecordOutput>> create({
    required AtUri subject,
    DateTime? createdAt,
    String? rkey,
    bool? validate,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => createRecord(
    record: GraphListblockRecord(
      subject: subject,
      createdAt: canonicalAtProtoDateTime(createdAt ?? DateTime.now()),
    ).toJson(),
    rkey: rkey,
    validate: validate,
    swapCommit: swapCommit,
    $headers: $headers,
    $service: $service,
  );
}

class GraphListitemRecordService extends _CurrentRepoRecordService {
  GraphListitemRecordService._(PoptartClient client) : super(client, 'app.bsky.graph.listitem');

  Future<XRPCResponse<RepoCreateRecordOutput>> create({
    required AtUri list,
    required String subject,
    DateTime? createdAt,
    String? rkey,
    bool? validate,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => createRecord(
    record: GraphListitemRecord(
      list: list,
      subject: subject,
      createdAt: canonicalAtProtoDateTime(createdAt ?? DateTime.now()),
    ).toJson(),
    rkey: rkey,
    validate: validate,
    swapCommit: swapCommit,
    $headers: $headers,
    $service: $service,
  );
}

class GraphStarterpackRecordService extends _CurrentRepoRecordService {
  GraphStarterpackRecordService._(PoptartClient client) : super(client, 'app.bsky.graph.starterpack');

  Future<XRPCResponse<RepoCreateRecordOutput>> create({
    required String name,
    required AtUri list,
    String? description,
    List<FeedItem>? feeds,
    DateTime? createdAt,
    String? rkey,
    bool? validate,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => createRecord(
    record: GraphStarterpackRecord(
      name: name,
      list: list,
      description: description,
      feeds: feeds,
      createdAt: canonicalAtProtoDateTime(createdAt ?? DateTime.now()),
    ).toJson(),
    rkey: rkey,
    validate: validate,
    swapCommit: swapCommit,
    $headers: $headers,
    $service: $service,
  );

  Future<XRPCResponse<RepoPutRecordOutput>> put({
    required String rkey,
    required String name,
    required AtUri list,
    String? description,
    List<FeedItem>? feeds,
    DateTime? createdAt,
    bool? validate,
    String? swapRecord,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) => putRecord(
    rkey: rkey,
    record: GraphStarterpackRecord(
      name: name,
      list: list,
      description: description,
      feeds: feeds,
      createdAt: canonicalAtProtoDateTime(createdAt ?? DateTime.now()),
    ).toJson(),
    validate: validate,
    swapRecord: swapRecord,
    swapCommit: swapCommit,
    $headers: $headers,
    $service: $service,
  );
}
