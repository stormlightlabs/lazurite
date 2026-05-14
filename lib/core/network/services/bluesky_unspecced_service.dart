part of '../poptart_client_adapter.dart';

class BlueskyUnspeccedService {
  BlueskyUnspeccedService._(this._client);

  final PoptartClient _client;

  Future<XRPCResponse<UnspeccedGetTrendingTopicsOutput>> getTrendingTopics({
    String? viewer,
    int limit = 10,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyUnspeccedGetTrendingTopics,
      headers: $headers,
      service: $service,
      parameters: UnspeccedGetTrendingTopicsInput(viewer: viewer, limit: limit),
    );
  }

  Future<XRPCResponse<UnspeccedGetTrendsOutput>> getTrends({
    int limit = 10,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyUnspeccedGetTrends,
      headers: $headers,
      service: $service,
      parameters: UnspeccedGetTrendsInput(limit: limit),
    );
  }

  Future<XRPCResponse<UnspeccedGetPopularFeedGeneratorsOutput>> getPopularFeedGenerators({
    int limit = 50,
    String? cursor,
    String? query,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyUnspeccedGetPopularFeedGenerators,
      headers: $headers,
      service: $service,
      parameters: UnspeccedGetPopularFeedGeneratorsInput(limit: limit, cursor: cursor, query: query),
    );
  }
}
