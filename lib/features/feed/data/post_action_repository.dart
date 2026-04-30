import 'package:atproto/com_atproto_repo_strongref.dart';
import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_bookmark_getbookmarks.dart';
import 'package:bluesky/app_bsky_feed_getlikes.dart';
import 'package:bluesky/app_bsky_feed_getrepostedby.dart';
import 'package:bluesky/bluesky.dart';
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
      limit: limit,
      cursor: cursor,
      $headers: _appViewContext.appBskyHeaders(),
    );
    return response.data;
  }

  Future<FeedGetLikesOutput> getLikes({required AtUri uri, String? cursor}) async {
    final response = await _bluesky.feed.getLikes(
      uri: uri,
      limit: 25,
      cursor: cursor,
      $headers: _appViewContext.appBskyHeaders(),
    );
    return response.data;
  }

  Future<FeedGetRepostedByOutput> getRepostedBy({required AtUri uri, String? cursor}) async {
    final response = await _bluesky.feed.getRepostedBy(
      uri: uri,
      limit: 25,
      cursor: cursor,
      $headers: _appViewContext.appBskyHeaders(),
    );
    return response.data;
  }

  String _extractRkey(String uri) {
    final atUri = AtUri.parse(uri);
    return atUri.rkey;
  }
}
