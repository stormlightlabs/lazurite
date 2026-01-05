import 'package:drift/drift.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/saved_feeds_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

/// Repository for managing feed generators.
///
/// Handles syncing saved feeds from user preferences
/// (app.bsky.actor.getPreferences) and enriching them with metadata
/// from app.bsky.feed.getFeedGenerator.
class FeedRepository {
  FeedRepository(this._api, this._dao, this._logger);

  final XrpcClient _api;
  final SavedFeedsDao _dao;
  final Logger _logger;

  /// Syncs saved feeds from user preferences and hydrates with metadata.
  ///
  /// Fetches the savedFeedsPref array from app.bsky.actor.getPreferences,
  /// enriches each feed URI with metadata from app.bsky.feed.getFeedGenerator,
  /// and updates the local cache.
  ///
  /// For unauthenticated users, this is a no-op.
  Future<void> syncPreferences() async {
    if (!_api.isAuthenticated) {
      _logger.debug('Skipping preference sync for unauthenticated user');
      return;
    }

    _logger.info('Syncing feed preferences');

    try {
      final response = await _api.call('app.bsky.actor.getPreferences');
      final prefs = response['preferences'] as List;

      final savedFeedsPref = prefs.cast<Map<String, dynamic>>().firstWhere(
        (p) => p['\$type'] == 'app.bsky.actor.defs#savedFeedsPref',
        orElse: () => <String, dynamic>{},
      );

      if (savedFeedsPref.isEmpty) {
        _logger.debug('No savedFeedsPref found in preferences');
        return;
      }

      final savedFeeds = savedFeedsPref['saved'] as List? ?? [];
      final pinnedFeeds = savedFeedsPref['pinned'] as List? ?? [];

      _logger.debug('Found ${savedFeeds.length} saved feeds, ${pinnedFeeds.length} pinned');

      final feedCompanions = <SavedFeedsCompanion>[];
      final now = DateTime.now();

      for (var i = 0; i < savedFeeds.length; i++) {
        final feedUri = savedFeeds[i] as String;
        final isPinned = pinnedFeeds.contains(feedUri);

        try {
          final metadata = await getFeedMetadata(feedUri);

          feedCompanions.add(
            SavedFeedsCompanion.insert(
              uri: feedUri,
              displayName: metadata['displayName'] ?? 'Unknown Feed',
              description: Value(metadata['description']),
              avatar: Value(metadata['avatar']),
              creatorDid: metadata['creator']['did'] ?? '',
              likeCount: Value(metadata['likeCount'] ?? 0),
              sortOrder: i,
              isPinned: Value(isPinned),
              lastSynced: now,
            ),
          );
        } catch (e) {
          _logger.error('Failed to fetch metadata for feed $feedUri', {'error': e});
        }
      }

      if (feedCompanions.isNotEmpty) {
        await _dao.upsertFeeds(feedCompanions);
        _logger.info('Synced ${feedCompanions.length} feeds to local cache');
      }
    } catch (e) {
      _logger.error('Failed to sync feed preferences', {'error': e});
      rethrow;
    }
  }

  /// Saves a feed to user preferences and local cache.
  ///
  /// Fetches current preferences, adds the feed URI to savedFeedsPref,
  /// updates via app.bsky.actor.putPreferences, and updates local cache.
  ///
  /// The entire preferences object is sent to avoid overwriting other
  /// preference categories like contentLabelPref.
  Future<void> saveFeed(String feedUri, {bool pin = false}) async {
    if (!_api.isAuthenticated) {
      throw Exception('Cannot save feed: user not authenticated');
    }

    _logger.info('Saving feed', {'uri': feedUri, 'pin': pin});

    try {
      final currentPrefsResponse = await _api.call('app.bsky.actor.getPreferences');
      final prefs = List<Map<String, dynamic>>.from(
        (currentPrefsResponse['preferences'] as List).map(
          (p) => Map<String, dynamic>.from(p as Map),
        ),
      );

      var savedFeedsPref = prefs.cast<Map<String, dynamic>>().firstWhere(
        (p) => p['\$type'] == 'app.bsky.actor.defs#savedFeedsPref',
        orElse: () => <String, dynamic>{},
      );

      if (savedFeedsPref.isEmpty) {
        savedFeedsPref = {
          '\$type': 'app.bsky.actor.defs#savedFeedsPref',
          'saved': <String>[],
          'pinned': <String>[],
        };
        prefs.add(savedFeedsPref);
      } else {
        savedFeedsPref = Map<String, dynamic>.from(savedFeedsPref);
        final index = prefs.indexWhere((p) => p['\$type'] == 'app.bsky.actor.defs#savedFeedsPref');
        prefs[index] = savedFeedsPref;
      }

      final saved = List<String>.from(savedFeedsPref['saved'] ?? []);
      final pinned = List<String>.from(savedFeedsPref['pinned'] ?? []);

      if (!saved.contains(feedUri)) {
        saved.add(feedUri);
      }

      if (pin && !pinned.contains(feedUri)) {
        pinned.add(feedUri);
      }

      savedFeedsPref['saved'] = saved;
      savedFeedsPref['pinned'] = pinned;

      await _api.call('app.bsky.actor.putPreferences', body: {'preferences': prefs});

      final metadata = await getFeedMetadata(feedUri);
      await _dao.upsertFeed(
        SavedFeedsCompanion.insert(
          uri: feedUri,
          displayName: metadata['displayName'] ?? 'Unknown Feed',
          description: Value(metadata['description']),
          avatar: Value(metadata['avatar']),
          creatorDid: metadata['creator']['did'] ?? '',
          likeCount: Value(metadata['likeCount'] ?? 0),
          sortOrder: saved.indexOf(feedUri),
          isPinned: Value(pin),
          lastSynced: DateTime.now(),
        ),
      );

      _logger.info('Feed saved successfully');
    } catch (e) {
      _logger.error('Failed to save feed', {'error': e});
      rethrow;
    }
  }

  /// Removes a feed from user preferences and local cache.
  ///
  /// Fetches current preferences, removes the feed URI from savedFeedsPref,
  /// updates via app.bsky.actor.putPreferences, and deletes from local cache.
  Future<void> removeFeed(String feedUri) async {
    if (!_api.isAuthenticated) {
      throw Exception('Cannot remove feed: user not authenticated');
    }

    _logger.info('Removing feed', {'uri': feedUri});

    try {
      final currentPrefsResponse = await _api.call('app.bsky.actor.getPreferences');
      final prefs = List<Map<String, dynamic>>.from(
        (currentPrefsResponse['preferences'] as List).map(
          (p) => Map<String, dynamic>.from(p as Map),
        ),
      );

      var savedFeedsPref = prefs.cast<Map<String, dynamic>>().firstWhere(
        (p) => p['\$type'] == 'app.bsky.actor.defs#savedFeedsPref',
        orElse: () => <String, dynamic>{},
      );

      if (savedFeedsPref.isNotEmpty) {
        savedFeedsPref = Map<String, dynamic>.from(savedFeedsPref);
        final index = prefs.indexWhere((p) => p['\$type'] == 'app.bsky.actor.defs#savedFeedsPref');
        prefs[index] = savedFeedsPref;

        final saved = List<String>.from(savedFeedsPref['saved'] ?? []);
        final pinned = List<String>.from(savedFeedsPref['pinned'] ?? []);

        saved.remove(feedUri);
        pinned.remove(feedUri);

        savedFeedsPref['saved'] = saved;
        savedFeedsPref['pinned'] = pinned;

        await _api.call('app.bsky.actor.putPreferences', body: {'preferences': prefs});
      }

      await _dao.deleteFeed(feedUri);
      _logger.info('Feed removed successfully');
    } catch (e) {
      _logger.error('Failed to remove feed', {'error': e});
      rethrow;
    }
  }

  /// Discovers trending feed generators.
  ///
  /// Calls app.bsky.unspecced.getPopularFeedGenerators to fetch popular feeds.
  /// Returns a list of feed generator metadata.
  Future<List<Map<String, dynamic>>> discoverFeeds({int limit = 50}) async {
    _logger.info('Discovering trending feeds', {'limit': limit});

    try {
      final response = await _api.call(
        'app.bsky.unspecced.getPopularFeedGenerators',
        params: {'limit': limit},
      );

      final feeds = response['feeds'] as List;
      _logger.debug('Discovered ${feeds.length} trending feeds');

      return feeds.cast<Map<String, dynamic>>();
    } catch (e) {
      _logger.error('Failed to discover feeds', {'error': e});
      rethrow;
    }
  }

  /// Gets metadata for a specific feed generator.
  ///
  /// Calls app.bsky.feed.getFeedGenerator with the feed URI.
  /// Returns the feed generator metadata including displayName, description, avatar, creator,
  /// and likeCount.
  Future<Map<String, dynamic>> getFeedMetadata(String feedUri) async {
    _logger.debug('Fetching feed metadata', {'uri': feedUri});

    try {
      final response = await _api.call(
        'app.bsky.feed.getFeedGenerator',
        params: {'feed': feedUri},
      );

      return response['view'] as Map<String, dynamic>;
    } catch (e) {
      _logger.error('Failed to fetch feed metadata', {'uri': feedUri, 'error': e});
      rethrow;
    }
  }

  /// Refreshes stale feed metadata.
  ///
  /// Finds feeds with lastSynced older than 24 hours and updates their
  /// metadata from app.bsky.feed.getFeedGenerator.
  Future<void> refreshStaleMetadata() async {
    final threshold = DateTime.now().subtract(const Duration(hours: 24));
    final staleFeeds = await _dao.getStaleFeeds(threshold);

    if (staleFeeds.isEmpty) {
      _logger.debug('No stale feeds to refresh');
      return;
    }

    _logger.info('Refreshing ${staleFeeds.length} stale feeds');

    for (final feed in staleFeeds) {
      try {
        final metadata = await getFeedMetadata(feed.uri);
        await _dao.upsertFeed(
          SavedFeedsCompanion.insert(
            uri: feed.uri,
            displayName: metadata['displayName'] ?? feed.displayName,
            description: Value(metadata['description']),
            avatar: Value(metadata['avatar']),
            creatorDid: metadata['creator']['did'] ?? feed.creatorDid,
            likeCount: Value(metadata['likeCount'] ?? 0),
            sortOrder: feed.sortOrder,
            isPinned: Value(feed.isPinned),
            lastSynced: DateTime.now(),
          ),
        );
      } catch (e) {
        _logger.error('Failed to refresh metadata for feed ${feed.uri}', {'error': e});
      }
    }
  }

  /// Watches all saved feeds reactively.
  Stream<List<SavedFeed>> watchAllFeeds() {
    return _dao.watchAllFeeds();
  }

  /// Watches pinned feeds reactively.
  Stream<List<SavedFeed>> watchPinnedFeeds() {
    return _dao.watchPinnedFeeds();
  }

  /// Gets a specific feed by URI.
  Future<SavedFeed?> getFeed(String uri) {
    return _dao.getFeed(uri);
  }

  /// URI for the Home timeline (authenticated users).
  static const kHomeFeedUri = 'home';

  /// URI for the Discover feed (public).
  static const kDiscoverFeedUri =
      'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/discover';

  /// Seeds default feeds if they don't already exist.
  ///
  /// Ensures that Home (for authenticated users) and Discover (public) feeds
  /// are always available in the local cache. This should be called during
  /// app initialization or after user login.
  Future<void> seedDefaultFeeds() async {
    _logger.debug('Seeding default feeds');

    final now = DateTime.now();
    final defaultFeeds = <SavedFeedsCompanion>[];

    final homeFeed = await _dao.getFeed(kHomeFeedUri);
    if (homeFeed == null && _api.isAuthenticated) {
      defaultFeeds.add(
        SavedFeedsCompanion.insert(
          uri: kHomeFeedUri,
          displayName: 'Home',
          description: const Value('Your personalized timeline'),
          avatar: const Value(null),
          creatorDid: '',
          likeCount: const Value(0),
          sortOrder: 0,
          isPinned: const Value(true),
          lastSynced: now,
        ),
      );
    }

    final discoverFeed = await _dao.getFeed(kDiscoverFeedUri);
    if (discoverFeed == null) {
      try {
        final metadata = await getFeedMetadata(kDiscoverFeedUri);
        defaultFeeds.add(
          SavedFeedsCompanion.insert(
            uri: kDiscoverFeedUri,
            displayName: metadata['displayName'] ?? 'Discover',
            description: Value(metadata['description']),
            avatar: Value(metadata['avatar']),
            creatorDid: metadata['creator']['did'] ?? '',
            likeCount: Value(metadata['likeCount'] ?? 0),
            sortOrder: 1,
            isPinned: const Value(true),
            lastSynced: now,
          ),
        );
      } catch (e) {
        _logger.error('Failed to fetch Discover feed metadata, using defaults', {'error': e});

        defaultFeeds.add(
          SavedFeedsCompanion.insert(
            uri: kDiscoverFeedUri,
            displayName: 'Discover',
            description: const Value('Explore trending posts'),
            avatar: const Value(null),
            creatorDid: '',
            likeCount: const Value(0),
            sortOrder: 1,
            isPinned: const Value(true),
            lastSynced: now,
          ),
        );
      }
    }

    if (defaultFeeds.isNotEmpty) {
      await _dao.upsertFeeds(defaultFeeds);
      _logger.info('Seeded ${defaultFeeds.length} default feeds');
    } else {
      _logger.debug('Default feeds already exist');
    }
  }
}
