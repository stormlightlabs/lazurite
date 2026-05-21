import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:bluesky_poptart/app/bsky/bookmark/get_bookmarks.dart';
import 'package:bluesky_poptart/app/bsky/feed/get_likes.dart';
import 'package:bluesky_poptart/app/bsky/feed/get_quotes.dart';
import 'package:bluesky_poptart/app/bsky/feed/get_reposted_by.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/core/network/unauthorized_recovery_runner.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

class PostActionRepository {
  PostActionRepository({
    required Bluesky bluesky,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
    Future<AuthTokens?> Function()? onUnauthorized,
    Bluesky? Function(AuthTokens tokens)? blueskyClientFactory,
  }) : _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       ) {
    _authRecovery = UnauthorizedRecoveryRunner<Bluesky>(
      initialClient: bluesky,
      onUnauthorized: onUnauthorized,
      clientFactory: blueskyClientFactory ?? createBlueskyClient,
    );
  }

  late final UnauthorizedRecoveryRunner<Bluesky> _authRecovery;
  final AppViewRequestContext _appViewContext;

  Future<String> likePost({required AtUri uri, required String cid}) async {
    final response = await _authRecovery.run(
      (client) => client.feed.like.create(
        subject: RepoStrongRef(cid: cid, uri: uri),
        createdAt: DateTime.now(),
        $headers: _appViewContext.appBskyHeadersWithoutProxy(),
      ),
    );

    return response.data.uri.toString();
  }

  Future<void> unlikePost({required String likeUri}) async {
    final rkey = _extractRkey(likeUri);
    await _authRecovery.run(
      (client) => client.feed.like.delete(rkey: rkey, $headers: _appViewContext.appBskyHeadersWithoutProxy()),
    );
  }

  Future<String> repostPost({required AtUri uri, required String cid}) async {
    final response = await _authRecovery.run(
      (client) => client.feed.repost.create(
        subject: RepoStrongRef(cid: cid, uri: uri),
        createdAt: DateTime.now(),
        $headers: _appViewContext.appBskyHeadersWithoutProxy(),
      ),
    );

    return response.data.uri.toString();
  }

  Future<void> unrepostPost({required String repostUri}) async {
    final rkey = _extractRkey(repostUri);
    await _authRecovery.run(
      (client) => client.feed.repost.delete(rkey: rkey, $headers: _appViewContext.appBskyHeadersWithoutProxy()),
    );
  }

  Future<void> deletePost({required String postUri}) async {
    final rkey = _extractRkey(postUri);
    await _authRecovery.run(
      (client) => client.feed.post.delete(rkey: rkey, $headers: _appViewContext.appBskyHeadersWithoutProxy()),
    );
  }

  Future<void> createBookmark({required AtUri uri, required String cid}) async {
    await _authRecovery.run(
      (client) =>
          client.bookmark.createBookmark(uri: uri, cid: cid, $headers: _appViewContext.appBskyHeadersWithoutProxy()),
    );
  }

  Future<void> deleteBookmark({required AtUri uri}) async {
    await _authRecovery.run(
      (client) => client.bookmark.deleteBookmark(uri: uri, $headers: _appViewContext.appBskyHeadersWithoutProxy()),
    );
  }

  Future<BookmarkGetBookmarksOutput> getBookmarks({int? limit, String? cursor}) async {
    final response = await _authRecovery.run(
      (client) => client.bookmark.getBookmarks(
        limit: limit ?? 50,
        cursor: cursor,
        $headers: _appViewContext.appBskyHeadersForEndpoint('app.bsky.bookmark.getBookmarks'),
      ),
    );
    return response.data;
  }

  Future<FeedGetLikesOutput> getLikes({required AtUri uri, String? cursor}) async {
    final response = await _authRecovery.run(
      (client) => client.feed.getLikes(
        uri: uri,
        limit: 25,
        cursor: cursor,
        $headers: _appViewContext.appBskyHeadersForEndpoint('app.bsky.feed.getLikes'),
      ),
    );
    return response.data;
  }

  Future<FeedGetRepostedByOutput> getRepostedBy({required AtUri uri, String? cursor}) async {
    final response = await _authRecovery.run(
      (client) => client.feed.getRepostedBy(
        uri: uri,
        limit: 25,
        cursor: cursor,
        $headers: _appViewContext.appBskyHeadersForEndpoint('app.bsky.feed.getRepostedBy'),
      ),
    );
    return response.data;
  }

  Future<FeedGetQuotesOutput> getQuotes({required AtUri uri, String? cursor}) async {
    final response = await _authRecovery.run(
      (client) => client.feed.getQuotes(
        uri: uri,
        limit: 25,
        cursor: cursor,
        $headers: _appViewContext.appBskyHeadersForEndpoint('app.bsky.feed.getQuotes'),
      ),
    );
    return response.data;
  }

  String _extractRkey(String uri) {
    final atUri = AtUri.parse(uri);
    return atUri.rkey;
  }
}
