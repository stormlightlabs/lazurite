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
  }) {
    return AtProtoRepoService._(_client).createRecord(
      repo: _repoDid(_client),
      collection: _collection,
      rkey: rkey,
      validate: validate,
      record: record,
      swapCommit: swapCommit,
      $headers: $headers,
      $service: $service,
    );
  }

  Future<XRPCResponse<RepoPutRecordOutput>> putRecord({
    required String rkey,
    required Map<String, dynamic> record,
    bool? validate,
    String? swapRecord,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return AtProtoRepoService._(_client).putRecord(
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
  }

  Future<XRPCResponse<RepoDeleteRecordOutput>> delete({
    required String rkey,
    String? swapRecord,
    String? swapCommit,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return AtProtoRepoService._(_client).deleteRecord(
      repo: _repoDid(_client),
      collection: _collection,
      rkey: rkey,
      swapRecord: swapRecord,
      swapCommit: swapCommit,
      $headers: $headers,
      $service: $service,
    );
  }
}

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
  }) {
    return createRecord(
      record: FeedLikeRecord(subject: subject, createdAt: createdAt ?? DateTime.now().toUtc(), via: via).toJson(),
      rkey: rkey,
      validate: validate,
      swapCommit: swapCommit,
      $headers: $headers,
      $service: $service,
    );
  }
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
  }) {
    return createRecord(
      record: FeedRepostRecord(subject: subject, createdAt: createdAt ?? DateTime.now().toUtc(), via: via).toJson(),
      rkey: rkey,
      validate: validate,
      swapCommit: swapCommit,
      $headers: $headers,
      $service: $service,
    );
  }
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
  }) {
    return putRecord(
      rkey: rkey,
      record: record.toJson(),
      validate: validate,
      swapRecord: swapRecord,
      swapCommit: swapCommit,
      $headers: $headers,
      $service: $service,
    );
  }
}

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
  }) {
    return createRecord(
      record: GraphBlockRecord(subject: subject, createdAt: createdAt ?? DateTime.now().toUtc()).toJson(),
      rkey: rkey,
      validate: validate,
      swapCommit: swapCommit,
      $headers: $headers,
      $service: $service,
    );
  }
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
  }) {
    return createRecord(
      record: GraphListRecord(
        purpose: purpose,
        name: name,
        description: description,
        descriptionFacets: descriptionFacets,
        avatar: avatar,
        labels: labels,
        createdAt: createdAt ?? DateTime.now().toUtc(),
      ).toJson(),
      rkey: rkey,
      validate: validate,
      swapCommit: swapCommit,
      $headers: $headers,
      $service: $service,
    );
  }

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
  }) {
    return putRecord(
      rkey: rkey,
      record: GraphListRecord(
        purpose: purpose,
        name: name,
        description: description,
        descriptionFacets: descriptionFacets,
        avatar: avatar,
        labels: labels,
        createdAt: createdAt ?? DateTime.now().toUtc(),
      ).toJson(),
      validate: validate,
      swapRecord: swapRecord,
      swapCommit: swapCommit,
      $headers: $headers,
      $service: $service,
    );
  }
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
  }) {
    return createRecord(
      record: GraphFollowRecord(subject: subject, createdAt: createdAt ?? DateTime.now().toUtc(), via: via).toJson(),
      rkey: rkey,
      validate: validate,
      swapCommit: swapCommit,
      $headers: $headers,
      $service: $service,
    );
  }
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
  }) {
    return createRecord(
      record: GraphListblockRecord(subject: subject, createdAt: createdAt ?? DateTime.now().toUtc()).toJson(),
      rkey: rkey,
      validate: validate,
      swapCommit: swapCommit,
      $headers: $headers,
      $service: $service,
    );
  }
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
  }) {
    return createRecord(
      record: GraphListitemRecord(
        list: list,
        subject: subject,
        createdAt: createdAt ?? DateTime.now().toUtc(),
      ).toJson(),
      rkey: rkey,
      validate: validate,
      swapCommit: swapCommit,
      $headers: $headers,
      $service: $service,
    );
  }
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
  }) {
    return createRecord(
      record: GraphStarterpackRecord(
        name: name,
        list: list,
        description: description,
        feeds: feeds,
        createdAt: createdAt ?? DateTime.now().toUtc(),
      ).toJson(),
      rkey: rkey,
      validate: validate,
      swapCommit: swapCommit,
      $headers: $headers,
      $service: $service,
    );
  }

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
  }) {
    return putRecord(
      rkey: rkey,
      record: GraphStarterpackRecord(
        name: name,
        list: list,
        description: description,
        feeds: feeds,
        createdAt: createdAt ?? DateTime.now().toUtc(),
      ).toJson(),
      validate: validate,
      swapRecord: swapRecord,
      swapCommit: swapCommit,
      $headers: $headers,
      $service: $service,
    );
  }
}
