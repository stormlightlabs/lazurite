import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:poptart_lex/app/bsky/bookmark/get_bookmarks.dart';
import 'package:poptart_lex/app/bsky/feed/get_likes.dart';
import 'package:poptart_lex/app/bsky/feed/get_quotes.dart';
import 'package:poptart_lex/app/bsky/feed/get_reposted_by.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';

class PostActionRepository {
  PostActionRepository({required Bluesky bluesky, String? appViewProvider, String Function()? appViewProviderResolver})
    : _bluesky = bluesky,
      _appViewContext = AppViewRequestContext(
        appViewProvider: appViewProvider,
        appViewProviderResolver: appViewProviderResolver,
      );

  final Bluesky _bluesky;
  final AppViewRequestContext _appViewContext;

  Future<String> likePost({required AtUri uri, required String cid}) async {
    final response = await _bluesky.feed.like.create(
      subject: RepoStrongRef(cid: cid, uri: uri),
      createdAt: DateTime.now(),
      $headers: _appViewContext.appBskyHeadersWithoutProxy(),
    );

    return response.data.uri.toString();
  }

  Future<void> unlikePost({required String likeUri}) async {
    final rkey = _extractRkey(likeUri);
    await _bluesky.feed.like.delete(rkey: rkey, $headers: _appViewContext.appBskyHeadersWithoutProxy());
  }

  Future<String> repostPost({required AtUri uri, required String cid}) async {
    final response = await _bluesky.feed.repost.create(
      subject: RepoStrongRef(cid: cid, uri: uri),
      createdAt: DateTime.now(),
      $headers: _appViewContext.appBskyHeadersWithoutProxy(),
    );

    return response.data.uri.toString();
  }

  Future<void> unrepostPost({required String repostUri}) async {
    final rkey = _extractRkey(repostUri);
    await _bluesky.feed.repost.delete(rkey: rkey, $headers: _appViewContext.appBskyHeadersWithoutProxy());
  }

  Future<void> deletePost({required String postUri}) async {
    final rkey = _extractRkey(postUri);
    await _bluesky.feed.post.delete(rkey: rkey, $headers: _appViewContext.appBskyHeadersWithoutProxy());
  }

  Future<void> createBookmark({required AtUri uri, required String cid}) async {
    await _bluesky.bookmark.createBookmark(uri: uri, cid: cid, $headers: _appViewContext.appBskyHeadersWithoutProxy());
  }

  Future<void> deleteBookmark({required AtUri uri}) async {
    await _bluesky.bookmark.deleteBookmark(uri: uri, $headers: _appViewContext.appBskyHeadersWithoutProxy());
  }

  Future<BookmarkGetBookmarksOutput> getBookmarks({int? limit, String? cursor}) async {
    final response = await _bluesky.bookmark.getBookmarks(
      limit: limit ?? 50,
      cursor: cursor,
      $headers: _appViewContext.appBskyHeadersForEndpoint('app.bsky.bookmark.getBookmarks'),
    );
    return response.data;
  }

  Future<FeedGetLikesOutput> getLikes({required AtUri uri, String? cursor}) async {
    final response = await _bluesky.feed.getLikes(
      uri: uri,
      limit: 25,
      cursor: cursor,
      $headers: _appViewContext.appBskyHeadersForEndpoint('app.bsky.feed.getLikes'),
    );
    return response.data;
  }

  Future<FeedGetRepostedByOutput> getRepostedBy({required AtUri uri, String? cursor}) async {
    final response = await _bluesky.feed.getRepostedBy(
      uri: uri,
      limit: 25,
      cursor: cursor,
      $headers: _appViewContext.appBskyHeadersForEndpoint('app.bsky.feed.getRepostedBy'),
    );
    return response.data;
  }

  Future<FeedGetQuotesOutput> getQuotes({required AtUri uri, String? cursor}) async {
    final response = await _bluesky.feed.getQuotes(
      uri: uri,
      limit: 25,
      cursor: cursor,
      $headers: _appViewContext.appBskyHeadersForEndpoint('app.bsky.feed.getQuotes'),
    );
    return response.data;
  }

  String _extractRkey(String uri) {
    final atUri = AtUri.parse(uri);
    return atUri.rkey;
  }
}
