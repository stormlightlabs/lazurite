part of '../poptart_client_adapter.dart';

class BlueskyGraphService {
  BlueskyGraphService._(this._client);

  final PoptartClient _client;

  GraphBlockRecordService get block => GraphBlockRecordService._(_client);
  GraphFollowRecordService get follow => GraphFollowRecordService._(_client);
  GraphListRecordService get list => GraphListRecordService._(_client);
  GraphListblockRecordService get listblock => GraphListblockRecordService._(_client);
  GraphListitemRecordService get listitem => GraphListitemRecordService._(_client);
  GraphStarterpackRecordService get starterpack => GraphStarterpackRecordService._(_client);

  Future<XRPCResponse<GraphGetFollowsOutput>> getFollows({
    required String actor,
    int limit = 50,
    String? cursor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyGraphGetFollows,
      headers: $headers,
      service: $service,
      parameters: GraphGetFollowsInput(actor: actor, limit: limit, cursor: cursor),
    );
  }

  Future<XRPCResponse<GraphGetFollowersOutput>> getFollowers({
    required String actor,
    int limit = 50,
    String? cursor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyGraphGetFollowers,
      headers: $headers,
      service: $service,
      parameters: GraphGetFollowersInput(actor: actor, limit: limit, cursor: cursor),
    );
  }

  Future<XRPCResponse<GraphGetListsOutput>> getLists({
    required String actor,
    int limit = 50,
    String? cursor,
    List<GraphGetListsPurposes>? purposes,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyGraphGetLists,
      headers: $headers,
      service: $service,
      parameters: GraphGetListsInput(actor: actor, limit: limit, cursor: cursor, purposes: purposes),
    );
  }

  Future<XRPCResponse<GraphGetListOutput>> getList({
    required AtUri list,
    int limit = 50,
    String? cursor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyGraphGetList,
      headers: $headers,
      service: $service,
      parameters: GraphGetListInput(list: list, limit: limit, cursor: cursor),
    );
  }

  Future<XRPCResponse<GraphGetListsWithMembershipOutput>> getListsWithMembership({
    required String actor,
    int limit = 50,
    String? cursor,
    List<GraphGetListsWithMembershipPurposes>? purposes,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyGraphGetListsWithMembership,
      headers: $headers,
      service: $service,
      parameters: GraphGetListsWithMembershipInput(actor: actor, limit: limit, cursor: cursor, purposes: purposes),
    );
  }

  Future<XRPCResponse<GraphGetActorStarterPacksOutput>> getActorStarterPacks({
    required String actor,
    int limit = 50,
    String? cursor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyGraphGetActorStarterPacks,
      headers: $headers,
      service: $service,
      parameters: GraphGetActorStarterPacksInput(actor: actor, limit: limit, cursor: cursor),
    );
  }

  Future<XRPCResponse<GraphGetStarterPackOutput>> getStarterPack({
    required AtUri starterPack,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyGraphGetStarterPack,
      headers: $headers,
      service: $service,
      parameters: GraphGetStarterPackInput(starterPack: starterPack),
    );
  }

  Future<XRPCResponse<GraphGetSuggestedFollowsByActorOutput>> getSuggestedFollowsByActor({
    required String actor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyGraphGetSuggestedFollowsByActor,
      headers: $headers,
      service: $service,
      parameters: GraphGetSuggestedFollowsByActorInput(actor: actor),
    );
  }

  Future<XRPCResponse<GraphSearchStarterPacksOutput>> searchStarterPacks({
    required String q,
    int limit = 25,
    String? cursor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyGraphSearchStarterPacks,
      headers: $headers,
      service: $service,
      parameters: GraphSearchStarterPacksInput(q: q, limit: limit, cursor: cursor),
    );
  }

  Future<XRPCResponse<EmptyData>> muteActor({required String actor, Map<String, String>? $headers, String? $service}) {
    return _client.call(
      appBskyGraphMuteActor,
      headers: $headers,
      service: $service,
      input: GraphMuteActorInput(actor: actor),
    );
  }

  Future<XRPCResponse<EmptyData>> unmuteActor({
    required String actor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyGraphUnmuteActor,
      headers: $headers,
      service: $service,
      input: GraphUnmuteActorInput(actor: actor),
    );
  }

  Future<XRPCResponse<EmptyData>> muteActorList({
    required AtUri list,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyGraphMuteActorList,
      headers: $headers,
      service: $service,
      input: GraphMuteActorListInput(list: list),
    );
  }

  Future<XRPCResponse<EmptyData>> unmuteActorList({
    required AtUri list,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyGraphUnmuteActorList,
      headers: $headers,
      service: $service,
      input: GraphUnmuteActorListInput(list: list),
    );
  }
}
