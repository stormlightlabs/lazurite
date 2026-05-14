part of '../poptart_client_adapter.dart';

class BlueskyBookmarkService {
  BlueskyBookmarkService._(this._client);

  final PoptartClient _client;

  Future<XRPCResponse<EmptyData>> createBookmark({
    required AtUri uri,
    required String cid,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyBookmarkCreateBookmark,
      headers: $headers,
      service: $service,
      input: BookmarkCreateBookmarkInput(uri: uri, cid: cid),
    );
  }

  Future<XRPCResponse<EmptyData>> deleteBookmark({
    required AtUri uri,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyBookmarkDeleteBookmark,
      headers: $headers,
      service: $service,
      input: BookmarkDeleteBookmarkInput(uri: uri),
    );
  }

  Future<XRPCResponse<BookmarkGetBookmarksOutput>> getBookmarks({
    int limit = 50,
    String? cursor,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyBookmarkGetBookmarks,
      headers: $headers,
      service: $service,
      parameters: BookmarkGetBookmarksInput(limit: limit, cursor: cursor),
    );
  }
}
