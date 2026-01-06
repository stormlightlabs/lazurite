import 'package:drift/drift.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/preference_sync_queue_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/saved_feeds_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

/// Duration after which permanently failed sync items are cleaned up.
const Duration kSyncQueueCleanupAge = Duration(days: 30);

/// Repository for managing feed generators.
///
/// Handles syncing saved feeds from user preferences
/// (app.bsky.actor.getPreferences) and enriching them with metadata
/// from app.bsky.feed.getFeedGenerator.
class FeedRepository {
  FeedRepository(this._api, this._dao, this._syncQueueDao, this._logger);

  final XrpcClient _api;
  final SavedFeedsDao _dao;
  final PreferenceSyncQueueDao _syncQueueDao;
  final Logger _logger;

  /// Validates that a feed URI follows the AT Protocol URI format.
  ///
  /// AT URIs for feed generators must follow the format:
  /// `at://did:METHOD:IDENTIFIER/app.bsky.feed.generator/RKEY`
  ///
  /// Throws [ArgumentError] if the URI is invalid.
  void _validateFeedUri(String feedUri) {
    if (feedUri.isEmpty) {
      throw ArgumentError.value(feedUri, 'feedUri', 'Feed URI cannot be empty');
    }

    if (!feedUri.startsWith('at://')) {
      throw ArgumentError.value(feedUri, 'feedUri', 'Feed URI must start with "at://"');
    }

    final uriWithoutScheme = feedUri.substring(5);
    final parts = uriWithoutScheme.split('/');

    if (parts.length < 3) {
      throw ArgumentError.value(
        feedUri,
        'feedUri',
        'Feed URI must have format: at://did:METHOD:ID/collection/rkey',
      );
    }

    final did = parts[0];
    final collection = parts[1];
    final rkey = parts[2];

    if (!did.startsWith('did:')) {
      throw ArgumentError.value(
        feedUri,
        'feedUri',
        'Feed URI must contain a valid DID (e.g., did:plc:...)',
      );
    }

    if (collection != 'app.bsky.feed.generator') {
      throw ArgumentError.value(
        feedUri,
        'feedUri',
        'Feed URI collection must be "app.bsky.feed.generator"',
      );
    }

    if (rkey.isEmpty) {
      throw ArgumentError.value(
        feedUri,
        'feedUri',
        'Feed URI must have a valid record key (rkey)',
      );
    }
  }

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
  /// Uses a fail-safe transaction pattern:
  /// 1. Atomically update local state AND queue sync operation
  /// 2. Attempt remote sync
  /// 3. If remote succeeds, dequeue the operation
  ///
  /// This ensures data consistency even if the app crashes during sync.
  ///
  /// Throws [ArgumentError] if the feed URI is invalid.
  Future<void> saveFeed(String feedUri, {bool pin = false}) async {
    if (!_api.isAuthenticated) {
      throw Exception('Cannot save feed: user not authenticated');
    }

    _validateFeedUri(feedUri);

    _logger.info('Saving feed', {'uri': feedUri, 'pin': pin});

    Map<String, dynamic> metadata = {};
    try {
      metadata = await getFeedMetadata(feedUri);
    } catch (e) {
      final existing = await _dao.getFeed(feedUri);
      if (existing != null) {
        metadata = {
          'displayName': existing.displayName,
          'description': existing.description,
          'avatar': existing.avatar,
          'creator': {'did': existing.creatorDid},
          'likeCount': existing.likeCount,
        };
      } else {
        _logger.warning('Could not fetch metadata for feed save, proceeding with defaults');
        metadata = {
          'displayName': 'Saved Feed',
          'creator': {'did': ''},
        };
      }
    }

    final allFeeds = await _dao.getAllFeeds();

    int? queueId;
    try {
      queueId = await _dao.db.transaction(() async {
        await _dao.upsertFeed(
          SavedFeedsCompanion.insert(
            uri: feedUri,
            displayName: metadata['displayName'] ?? 'Unknown Feed',
            description: Value(metadata['description']),
            avatar: Value(metadata['avatar']),
            creatorDid: metadata['creator']['did'] ?? '',
            likeCount: Value(metadata['likeCount'] ?? 0),
            sortOrder: allFeeds.length,
            isPinned: Value(pin),
            lastSynced: DateTime.now(),
          ),
        );

        return await _syncQueueDao.enqueue(
          PreferenceSyncQueueCompanion.insert(
            type: 'save',
            feedUri: feedUri,
            createdAt: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      _logger.error('Failed to perform atomic local update + queue', {'error': e});
      rethrow;
    }

    try {
      await _executeRemoteSaveFeed(feedUri, pin);
      _logger.info('Feed saved to remote successfully');
      if (queueId != null) {
        await _syncQueueDao.deleteItem(queueId);
      }
    } catch (e) {
      _logger.warning('Network failed during saveFeed, operation queued for retry', {
        'error': e,
        'queueId': queueId,
      });
    }
  }

  Future<void> _executeRemoteSaveFeed(String feedUri, bool pin) async {
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
  }

  /// Removes a feed from user preferences and local cache.
  ///
  /// Uses a fail-safe transaction pattern:
  /// 1. Atomically remove from local state AND queue sync operation
  /// 2. Attempt remote sync
  /// 3. If remote succeeds, dequeue the operation
  ///
  /// This ensures data consistency even if the app crashes during sync.
  Future<void> removeFeed(String feedUri) async {
    if (!_api.isAuthenticated) {
      throw Exception('Cannot remove feed: user not authenticated');
    }

    _logger.info('Removing feed', {'uri': feedUri});

    int? queueId;
    try {
      queueId = await _dao.db.transaction(() async {
        await _dao.deleteFeed(feedUri);

        return await _syncQueueDao.enqueue(
          PreferenceSyncQueueCompanion.insert(
            type: 'remove',
            feedUri: feedUri,
            createdAt: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      _logger.error('Failed to perform atomic local delete + queue', {'error': e});
      rethrow;
    }

    try {
      await _executeRemoteRemoveFeed(feedUri);
      _logger.info('Feed removed from remote successfully');
      if (queueId != null) {
        await _syncQueueDao.deleteItem(queueId);
      }
    } catch (e) {
      _logger.warning('Network failed during removeFeed, operation queued for retry', {
        'error': e,
        'queueId': queueId,
      });
    }
  }

  Future<void> _executeRemoteRemoveFeed(String feedUri) async {
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
    if (!_api.isAuthenticated) return;

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

  /// Processes the offline preference sync queue.
  ///
  /// Attempts to re-apply any queued save/remove operations.
  /// Items that have reached the maximum retry count ([kMaxSyncRetries]) are
  /// skipped and left for cleanup.
  Future<void> processSyncQueue() async {
    if (!_api.isAuthenticated) return;

    final retryable = await _syncQueueDao.getRetryableItems();
    if (retryable.isEmpty) {
      return;
    }

    _logger.info('Processing ${retryable.length} retryable sync items');

    for (final item in retryable) {
      try {
        if (item.type == 'save') {
          final localFeed = await _dao.getFeed(item.feedUri);
          final shouldPin = localFeed?.isPinned ?? false;

          await _executeRemoteSaveFeed(item.feedUri, shouldPin);
        } else if (item.type == 'remove') {
          await _executeRemoteRemoveFeed(item.feedUri);
        }

        await _syncQueueDao.deleteItem(item.id);
      } catch (e) {
        _logger.error('Failed to process sync item ${item.id}', {
          'error': e,
          'retryCount': item.retryCount + 1,
        });
        await _syncQueueDao.incrementRetryCount(item.id);
      }
    }
  }

  /// Syncs everything on app resume or network restoration.
  ///
  /// Also cleans up permanently failed sync items older than 30 days.
  Future<void> syncOnResume() async {
    _logger.info('Performing resume sync');
    try {
      final cleanupThreshold = DateTime.now().subtract(kSyncQueueCleanupAge);
      final cleaned = await _syncQueueDao.cleanupOldFailedItems(cleanupThreshold);
      if (cleaned > 0) {
        _logger.info('Cleaned up $cleaned old failed sync items');
      }

      await processSyncQueue();
      await syncPreferences();
      await refreshStaleMetadata();
    } catch (e) {
      _logger.error('Resume sync failed', {'error': e});
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

  /// URI for the What's Hot feed (public).
  static const kDiscoverFeedUri =
      'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/whats-hot';

  /// URI for the curated For You feed shown to authenticated users.
  static const kForYouFeedUri =
      'at://did:plc:3guzzweuqraryl3rdkimjamk/app.bsky.feed.generator/for-you';

  /// Deprecated URI that was renamed - kept for cleanup purposes.
  static const _kDeprecatedDiscoverUri =
      'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/discover';

  /// Seeds default feeds if they don't already exist.
  ///
  /// For unauthenticated users, ensures the Discover feed is available.
  /// For authenticated users, removes all seeded feeds since they should only see feeds
  /// from their preferences.
  Future<void> seedDefaultFeeds() async {
    _logger.debug('Seeding default feeds');

    await _dao.deleteFeed(_kDeprecatedDiscoverUri);

    if (_api.isAuthenticated) {
      await _dao.deleteFeed(kHomeFeedUri);
      await _dao.deleteFeed(kForYouFeedUri);
      await _dao.deleteFeed(kDiscoverFeedUri);
      _logger.debug('Removed seeded feeds for authenticated user');
      return;
    }

    final now = DateTime.now();
    final defaultFeeds = <SavedFeedsCompanion>[];

    await _ensureCuratedFeed(
      uri: kDiscoverFeedUri,
      fallbackName: 'Discover',
      fallbackDescription: 'Explore trending posts',
      sortOrder: 0,
      shouldPin: true,
      now: now,
      feeds: defaultFeeds,
    );

    if (defaultFeeds.isEmpty) {
      _logger.debug('Default feeds already up to date');
      return;
    }

    await _dao.upsertFeeds(defaultFeeds);
    _logger.info('Seeded ${defaultFeeds.length} default feeds');
  }

  Future<void> _ensureCuratedFeed({
    required String uri,
    required String fallbackName,
    required String fallbackDescription,
    required int sortOrder,
    required bool shouldPin,
    required DateTime now,
    required List<SavedFeedsCompanion> feeds,
  }) async {
    final existing = await _dao.getFeed(uri);
    if (existing != null) {
      return;
    }

    Map<String, dynamic>? metadata;
    try {
      metadata = await getFeedMetadata(uri);
    } catch (e) {
      _logger.error('Failed to fetch metadata for feed $uri, using defaults', {'error': e});
    }

    String creatorDid = '';
    if (metadata?['creator'] is Map<String, dynamic>) {
      creatorDid = (metadata!['creator'] as Map<String, dynamic>)['did'] ?? '';
    }

    feeds.add(
      SavedFeedsCompanion.insert(
        uri: uri,
        displayName: metadata?['displayName'] ?? fallbackName,
        description: Value(metadata?['description'] ?? fallbackDescription),
        avatar: Value(metadata?['avatar']),
        creatorDid: creatorDid,
        likeCount: Value(metadata?['likeCount'] ?? 0),
        sortOrder: sortOrder,
        isPinned: Value(shouldPin),
        lastSynced: now,
      ),
    );
  }
}
