import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_searchposts.dart';
import 'package:bluesky/bluesky.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';

class SearchRepository {
  SearchRepository({required Bluesky bluesky, ModerationService? moderationService})
    : _bluesky = bluesky,
      _moderationService = moderationService;

  final Bluesky _bluesky;
  final ModerationService? _moderationService;

  Future<SearchPostsResult> searchPosts({
    required String query,
    String sort = 'top',
    String? cursor,
    int limit = 50,
  }) async {
    final sortValue = sort == 'latest'
        ? const FeedSearchPostsSort.knownValue(data: KnownFeedSearchPostsSort.latest)
        : const FeedSearchPostsSort.knownValue(data: KnownFeedSearchPostsSort.top);

    final response = await _bluesky.feed.searchPosts(
      q: query,
      sort: sortValue,
      cursor: cursor,
      limit: limit,
      $headers: await _moderationService?.headersForRequest(),
    );

    return SearchPostsResult(
      posts: _filterPosts(response.data.posts),
      cursor: response.data.cursor,
      hitsTotal: response.data.hitsTotal,
    );
  }

  Future<SearchActorsResult> searchActors({required String query, String? cursor, int limit = 50}) async {
    final response = await _bluesky.actor.searchActors(
      q: query,
      cursor: cursor,
      limit: limit,
      $headers: await _moderationService?.headersForRequest(),
    );

    return SearchActorsResult(actors: _filterProfiles(response.data.actors), cursor: response.data.cursor);
  }

  Future<List<ProfileViewBasic>> searchActorsTypeahead({required String query, int limit = 10}) async {
    final response = await _bluesky.actor.searchActorsTypeahead(
      q: query,
      limit: limit,
      $headers: await _moderationService?.headersForRequest(),
    );

    return _filterBasicProfiles(response.data.actors);
  }

  List<PostView> _filterPosts(List<PostView> posts) {
    final moderationService = _moderationService;
    if (moderationService == null) {
      return posts;
    }

    return posts.where((post) => !moderationService.shouldFilterPostInList(post)).toList();
  }

  List<ProfileView> _filterProfiles(List<ProfileView> profiles) {
    final moderationService = _moderationService;
    if (moderationService == null) {
      return profiles;
    }

    return profiles.where((profile) => !moderationService.shouldFilterProfileInList(profile)).toList();
  }

  List<ProfileViewBasic> _filterBasicProfiles(List<ProfileViewBasic> profiles) {
    final moderationService = _moderationService;
    if (moderationService == null) {
      return profiles;
    }

    return profiles.where((profile) => !moderationService.shouldFilterProfileBasicInList(profile)).toList();
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
