part of '../poptart_client_adapter.dart';

class BlueskyFeedService {
  BlueskyFeedService._(this._client);

  final PoptartClient _client;

  FeedLikeRecordService get like => FeedLikeRecordService._(_client);
  FeedPostRecordService get post => FeedPostRecordService._(_client);
  FeedRepostRecordService get repost => FeedRepostRecordService._(_client);

  Future<XRPCResponse<FeedGetTimelineOutput>> getTimeline({
    String? algorithm,
    int limit = 50,
    String? cursor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyFeedGetTimeline,
      headers: $headers,
      service: $service,
      parameters: FeedGetTimelineInput(algorithm: algorithm, limit: limit, cursor: cursor),
    );
  }

  Future<XRPCResponse<FeedGetFeedOutput>> getFeed({
    required AtUri feed,
    int limit = 50,
    String? cursor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyFeedGetFeed,
      headers: $headers,
      service: $service,
      parameters: FeedGetFeedInput(feed: feed, limit: limit, cursor: cursor),
    );
  }

  Future<XRPCResponse<FeedGetAuthorFeedOutput>> getAuthorFeed({
    required String actor,
    int limit = 50,
    String? cursor,
    FeedGetAuthorFeedFilter? filter,
    bool includePins = false,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyFeedGetAuthorFeed,
      headers: $headers,
      service: $service,
      parameters: FeedGetAuthorFeedInput(
        actor: actor,
        limit: limit,
        cursor: cursor,
        filter: filter,
        includePins: includePins,
      ),
    );
  }

  Future<XRPCResponse<FeedGetSuggestedFeedsOutput>> getSuggestedFeeds({
    int limit = 50,
    String? cursor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyFeedGetSuggestedFeeds,
      headers: $headers,
      service: $service,
      parameters: FeedGetSuggestedFeedsInput(limit: limit, cursor: cursor),
    );
  }

  Future<XRPCResponse<FeedGetFeedGeneratorOutput>> getFeedGenerator({
    required AtUri feed,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyFeedGetFeedGenerator,
      headers: $headers,
      service: $service,
      parameters: FeedGetFeedGeneratorInput(feed: feed),
    );
  }

  Future<XRPCResponse<FeedGetFeedGeneratorsOutput>> getFeedGenerators({
    required List<AtUri> feeds,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyFeedGetFeedGenerators,
      headers: $headers,
      service: $service,
      parameters: FeedGetFeedGeneratorsInput(feeds: feeds),
    );
  }

  Future<XRPCResponse<FeedGetPostThreadOutput>> getPostThread({
    required AtUri uri,
    int depth = 6,
    int parentHeight = 80,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyFeedGetPostThread,
      headers: $headers,
      service: $service,
      parameters: FeedGetPostThreadInput(uri: uri, depth: depth, parentHeight: parentHeight),
    );
  }

  Future<XRPCResponse<FeedGetPostsOutput>> getPosts({
    required List<AtUri> uris,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyFeedGetPosts,
      headers: $headers,
      service: $service,
      parameters: FeedGetPostsInput(uris: uris),
    );
  }

  Future<XRPCResponse<FeedSearchPostsOutput>> searchPosts({
    required String q,
    FeedSearchPostsSort? sort,
    String? since,
    String? until,
    String? mentions,
    String? author,
    String? lang,
    String? domain,
    String? url,
    List<String>? tag,
    int limit = 25,
    String? cursor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyFeedSearchPosts,
      headers: $headers,
      service: $service,
      parameters: FeedSearchPostsInput(
        q: q,
        sort: sort,
        since: since,
        until: until,
        mentions: mentions,
        author: author,
        lang: lang,
        domain: domain,
        url: url,
        tag: tag,
        limit: limit,
        cursor: cursor,
      ),
    );
  }

  Future<XRPCResponse<FeedGetActorLikesOutput>> getActorLikes({
    required String actor,
    int limit = 50,
    String? cursor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyFeedGetActorLikes,
      headers: $headers,
      service: $service,
      parameters: FeedGetActorLikesInput(actor: actor, limit: limit, cursor: cursor),
    );
  }

  Future<XRPCResponse<FeedGetListFeedOutput>> getListFeed({
    required AtUri list,
    int limit = 50,
    String? cursor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyFeedGetListFeed,
      headers: $headers,
      service: $service,
      parameters: FeedGetListFeedInput(list: list, limit: limit, cursor: cursor),
    );
  }

  Future<XRPCResponse<FeedGetLikesOutput>> getLikes({
    required AtUri uri,
    String? cid,
    int limit = 50,
    String? cursor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyFeedGetLikes,
      headers: $headers,
      service: $service,
      parameters: FeedGetLikesInput(uri: uri, cid: cid, limit: limit, cursor: cursor),
    );
  }

  Future<XRPCResponse<FeedGetRepostedByOutput>> getRepostedBy({
    required AtUri uri,
    String? cid,
    int limit = 50,
    String? cursor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyFeedGetRepostedBy,
      headers: $headers,
      service: $service,
      parameters: FeedGetRepostedByInput(uri: uri, cid: cid, limit: limit, cursor: cursor),
    );
  }

  Future<XRPCResponse<FeedGetQuotesOutput>> getQuotes({
    required AtUri uri,
    String? cid,
    int limit = 50,
    String? cursor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyFeedGetQuotes,
      headers: $headers,
      service: $service,
      parameters: FeedGetQuotesInput(uri: uri, cid: cid, limit: limit, cursor: cursor),
    );
  }
}
