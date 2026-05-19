import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/unspecced/defs.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:poptart_core/poptart_core.dart' as atcore;

abstract interface class PublicContentRepository {
  Future<PublicDiscoverResult> loadDiscover({String? cursor, int limit = 25});

  Future<PublicFeedsResult> loadFeeds({String? cursor, int limit = 25});

  Future<PublicFeedsResult> searchFeeds({required String query, String? cursor, int limit = 25});
}

class RepositoryPublicContentRepository implements PublicContentRepository {
  const RepositoryPublicContentRepository({
    required this.providerKey,
    required FeedRepository feedRepository,
    required SearchRepository searchRepository,
  }) : _feedRepository = feedRepository,
       _searchRepository = searchRepository;

  final String providerKey;
  final FeedRepository _feedRepository;
  final SearchRepository _searchRepository;

  /// Curated list of feeds shown on blacksky.community
  /// instead of popular feed generators
  static const List<String> blackskyFeedUris = [
    'at://did:plc:w4xbfzo7kqfes5zb7r6qv3rw/app.bsky.feed.generator/blacksky-trend',
    'at://did:plc:w4xbfzo7kqfes5zb7r6qv3rw/app.bsky.feed.generator/blacksky',
    'at://did:plc:w4xbfzo7kqfes5zb7r6qv3rw/app.bsky.feed.generator/blacksky-edu',
    'at://did:plc:w4xbfzo7kqfes5zb7r6qv3rw/app.bsky.feed.generator/blacksky-op',
    'at://did:plc:w4xbfzo7kqfes5zb7r6qv3rw/app.bsky.feed.generator/blacksky-videos',
    'at://did:plc:w4xbfzo7kqfes5zb7r6qv3rw/app.bsky.feed.generator/blacksky-photos',
    'at://did:plc:3guzzweuqraryl3rdkimjamk/app.bsky.feed.generator/for-you',
  ];

  static List<atcore.AtUri> get blackSkyFeedAtUris => blackskyFeedUris.map(atcore.AtUri.parse).toList(growable: false);

  @override
  Future<PublicDiscoverResult> loadDiscover({String? cursor, int limit = 25}) async {
    if (providerKey == AppViewProviders.blackskyKey) {
      final trends = await _feedRepository.getTrends(limit: limit);
      return PublicDiscoverResult(trends: trends);
    }

    final feeds = await _feedRepository.getSuggestedFeeds(cursor: cursor, limit: limit);
    return PublicDiscoverResult(feeds: feeds);
  }

  @override
  Future<PublicFeedsResult> loadFeeds({String? cursor, int limit = 25}) async =>
      (providerKey == AppViewProviders.blackskyKey)
      ? PublicFeedsResult(feeds: await _feedRepository.getFeedGenerators(blackSkyFeedAtUris))
      : PublicFeedsResult(
          feeds: await _feedRepository.getSuggestedFeeds(cursor: cursor, limit: limit),
        );

  @override
  Future<PublicFeedsResult> searchFeeds({required String query, String? cursor, int limit = 25}) async {
    final result = await _searchRepository.searchFeedGenerators(query: query, cursor: cursor, limit: limit);
    return PublicFeedsResult(feeds: result.feeds, cursor: result.cursor);
  }
}

class EmptyPublicContentRepository implements PublicContentRepository {
  const EmptyPublicContentRepository();

  @override
  Future<PublicDiscoverResult> loadDiscover({String? cursor, int limit = 25}) async => const PublicDiscoverResult();

  @override
  Future<PublicFeedsResult> loadFeeds({String? cursor, int limit = 25}) async => const PublicFeedsResult(feeds: []);

  @override
  Future<PublicFeedsResult> searchFeeds({required String query, String? cursor, int limit = 25}) async {
    return const PublicFeedsResult(feeds: []);
  }
}

class PublicDiscoverResult {
  const PublicDiscoverResult({this.feeds = const [], this.trends = const [], this.cursor});

  final List<GeneratorView> feeds;
  final List<TrendView> trends;
  final String? cursor;

  bool get isEmpty => feeds.isEmpty && trends.isEmpty;
}

class PublicFeedsResult {
  const PublicFeedsResult({required this.feeds, this.cursor});

  final List<GeneratorView> feeds;
  final String? cursor;
}
