import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_searchposts.dart';
import 'package:bluesky/bluesky.dart';

class SearchRepository {
  SearchRepository({required Bluesky bluesky}) : _bluesky = bluesky;

  final Bluesky _bluesky;

  Future<SearchPostsResult> searchPosts({
    required String query,
    String sort = 'top',
    String? cursor,
    int limit = 50,
  }) async {
    final sortValue = sort == 'latest'
        ? const FeedSearchPostsSort.knownValue(data: KnownFeedSearchPostsSort.latest)
        : const FeedSearchPostsSort.knownValue(data: KnownFeedSearchPostsSort.top);

    final response = await _bluesky.feed.searchPosts(q: query, sort: sortValue, cursor: cursor, limit: limit);

    return SearchPostsResult(
      posts: response.data.posts,
      cursor: response.data.cursor,
      hitsTotal: response.data.hitsTotal,
    );
  }

  Future<SearchActorsResult> searchActors({required String query, String? cursor, int limit = 50}) async {
    final response = await _bluesky.actor.searchActors(q: query, cursor: cursor, limit: limit);

    return SearchActorsResult(actors: response.data.actors, cursor: response.data.cursor);
  }

  Future<List<ProfileViewBasic>> searchActorsTypeahead({required String query, int limit = 10}) async {
    final response = await _bluesky.actor.searchActorsTypeahead(q: query, limit: limit);

    return response.data.actors;
  }
}

class SearchPostsResult {
  SearchPostsResult({required this.posts, this.cursor, this.hitsTotal});

  final List<PostView> posts;
  final String? cursor;
  final int? hitsTotal;
}

class SearchActorsResult {
  SearchActorsResult({required this.actors, this.cursor});

  final List<ProfileView> actors;
  final String? cursor;
}
