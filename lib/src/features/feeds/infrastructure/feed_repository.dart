import 'package:drift/drift.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/feeds/domain/feed_generator.dart';
import 'package:lazurite/src/features/feeds/domain/saved_feeds_pref.dart';
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

    if (collection != 'app.bsky.feed.generator' && collection != 'app.bsky.graph.list') {
      throw ArgumentError.value(
        feedUri,
        'feedUri',
        'Feed URI collection must be "app.bsky.feed.generator" or "app.bsky.graph.list"',
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
  /// Uses a timestamp-based merge strategy to handle multi-device conflicts:
  /// - Feeds with newer local modifications keep their local state
  /// - Feeds with newer remote state are updated from remote
  /// - Feeds removed remotely (but not modified locally) are removed locally
  /// - Feeds added locally but not yet synced are queued for sync
  ///
  /// For unauthenticated users, this is a no-op.
  Future<void> syncPreferences() async {
    _logger.debug('syncPreferences() called, isAuthenticated=${_api.isAuthenticated}');

    if (!_api.isAuthenticated) {
      _logger.debug('Skipping preference sync for unauthenticated user');
      return;
    }

    _logger.info('Syncing feed preferences with conflict resolution');

    try {
      _logger.debug('Calling app.bsky.actor.getPreferences API');
      final response = await _api.call('app.bsky.actor.getPreferences');
      _logger.debug('Got preferences response: ${response.keys}');

      final prefsJson = response['preferences'];
      if (prefsJson is! List) {
        throw FormatException('preferences must be a List', response);
      }
      _logger.debug('Preferences list has ${prefsJson.length} items');

      final parsed = SavedFeedsPreferenceParser.parse(prefsJson);

      List<String> remoteSavedUris;
      List<String> remotePinnedUris;

      if (parsed.v2 != null) {
        _logger.debug('Found V2 preferences with ${parsed.v2!.items.length} items');
        remoteSavedUris = parsed.v2!.savedUris;
        remotePinnedUris = parsed.v2!.pinnedUris;
        _logger.debug('V2 saved URIs: $remoteSavedUris');
        _logger.debug('V2 pinned URIs: $remotePinnedUris');
      } else if (parsed.v1 != null) {
        _logger.debug('Found V1 preferences');
        remoteSavedUris = parsed.v1!.saved;
        remotePinnedUris = parsed.v1!.pinned;
        _logger.debug('V1 saved URIs: $remoteSavedUris');
        _logger.debug('V1 pinned URIs: $remotePinnedUris');
      } else {
        _logger.debug('No saved feeds preference found, using empty lists');
        remoteSavedUris = [];
        remotePinnedUris = [];
      }

      _logger.info(
        'Remote state: ${remoteSavedUris.length} saved, ${remotePinnedUris.length} pinned',
      );
      _logger.debug('Saved URIs: $remoteSavedUris');
      _logger.debug('Pinned URIs: $remotePinnedUris');

      await _mergeWithRemotePreferences(remoteSavedUris, remotePinnedUris);
      _logger.info('syncPreferences() completed successfully');
    } catch (e, stack) {
      _logger.error('Failed to sync feed preferences', {
        'error': e.toString(),
        'stack': stack.toString(),
      });

      rethrow;
    }
  }

  /// Merges local and remote feed preferences using timestamp-based resolution.
  ///
  /// For each feed:
  /// - If local has newer modification → keep local, queue for remote sync
  /// - If remote is newer (or no local modification) → accept remote
  /// - Feeds in local but not remote: if locally modified → queue sync, else → remove
  Future<void> _mergeWithRemotePreferences(
    List<String> remoteSavedUris,
    List<String> remotePinnedUris,
  ) async {
    final localFeeds = await _dao.getAllFeeds();
    final now = DateTime.now();
    final remoteSavedSet = remoteSavedUris.toSet();
    final feedsToInsert = <SavedFeedsCompanion>[];
    final feedsToUpdate = <_FeedUpdate>[];
    final feedsToRemove = <String>[];
    final feedsToSyncToRemote = <String>[];

    for (var i = 0; i < remoteSavedUris.length; i++) {
      final remoteUri = remoteSavedUris[i];
      final remoteIsPinned = remotePinnedUris.contains(remoteUri);

      // TODO: implement special feeds like "following" and unsupported types
      if (!remoteUri.startsWith('at://')) {
        _logger.debug('Skipping non-at-uri feed: $remoteUri');
        continue;
      }

      // TODO: implement lists for (they need different API endpoint)
      if (remoteUri.contains('/app.bsky.graph.list/')) {
        _logger.debug('Skipping list (not yet supported): $remoteUri');
        continue;
      }

      final local = localFeeds.where((f) => f.uri == remoteUri).firstOrNull;

      if (local == null) {
        _logger.debug('Adding new remote feed: $remoteUri');
        try {
          final metadata = await getFeedMetadata(remoteUri);
          feedsToInsert.add(
            SavedFeedsCompanion.insert(
              uri: remoteUri,
              displayName: metadata.displayName,
              description: Value(metadata.description),
              avatar: Value(metadata.avatar),
              creatorDid: metadata.creator.did,
              likeCount: Value(metadata.likeCount ?? 0),
              sortOrder: i,
              isPinned: Value(remoteIsPinned),
              lastSynced: now,
              localUpdatedAt: const Value(null),
            ),
          );
        } catch (e) {
          _logger.error('Failed to fetch metadata for $remoteUri', {'error': e});
        }
      } else if (local.localUpdatedAt == null) {
        _logger.debug('Accepting remote state for: $remoteUri');
        feedsToUpdate.add(
          _FeedUpdate(
            uri: remoteUri,
            sortOrder: i,
            isPinned: remoteIsPinned,
            lastSynced: now,
            clearLocalUpdatedAt: true,
          ),
        );
      } else if (local.localUpdatedAt!.isAfter(local.lastSynced)) {
        _logger.debug('Local is newer, keeping local state for: $remoteUri');
        feedsToSyncToRemote.add(remoteUri);
      } else {
        _logger.debug('Remote is newer for: $remoteUri');
        feedsToUpdate.add(
          _FeedUpdate(
            uri: remoteUri,
            sortOrder: i,
            isPinned: remoteIsPinned,
            lastSynced: now,
            clearLocalUpdatedAt: true,
          ),
        );
      }
    }

    for (final local in localFeeds) {
      if (!remoteSavedSet.contains(local.uri)) {
        if (local.localUpdatedAt != null && local.localUpdatedAt!.isAfter(local.lastSynced)) {
          _logger.debug('Queueing local-only feed for sync: ${local.uri}');
          feedsToSyncToRemote.add(local.uri);
        } else {
          _logger.debug('Removing remotely-deleted feed: ${local.uri}');
          feedsToRemove.add(local.uri);
        }
      }
    }

    if (feedsToInsert.isNotEmpty) {
      await _dao.upsertFeeds(feedsToInsert);
      _logger.info('Added ${feedsToInsert.length} new feeds from remote');
    }

    for (final update in feedsToUpdate) {
      await _dao.updateSyncState(
        uri: update.uri,
        sortOrder: update.sortOrder,
        isPinned: update.isPinned,
        lastSynced: update.lastSynced,
        clearLocalModification: update.clearLocalUpdatedAt,
      );
    }
    if (feedsToUpdate.isNotEmpty) {
      _logger.info('Updated ${feedsToUpdate.length} feeds from remote');
    }

    for (final uri in feedsToRemove) {
      await _dao.deleteFeed(uri);
    }
    if (feedsToRemove.isNotEmpty) {
      _logger.info('Removed ${feedsToRemove.length} remotely-deleted feeds');
    }

    for (final uri in feedsToSyncToRemote) {
      final existing = await _syncQueueDao.getPendingItems();
      if (!existing.any((e) => e.feedUri == uri && e.type == 'save')) {
        await _syncQueueDao.enqueue(
          PreferenceSyncQueueCompanion.insert(type: 'save', feedUri: uri, createdAt: now),
        );
      }
    }
    if (feedsToSyncToRemote.isNotEmpty) {
      _logger.info('Queued ${feedsToSyncToRemote.length} local feeds for remote sync');
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

    FeedGenerator? metadata;
    String displayName = 'Saved Feed';
    String? description;
    String? avatar;
    String creatorDid = '';
    int? likeCount;

    try {
      metadata = await getFeedMetadata(feedUri);
      displayName = metadata.displayName;
      description = metadata.description;
      avatar = metadata.avatar;
      creatorDid = metadata.creator.did;
      likeCount = metadata.likeCount;
    } catch (e) {
      final existing = await _dao.getFeed(feedUri);
      if (existing != null) {
        displayName = existing.displayName;
        description = existing.description;
        avatar = existing.avatar;
        creatorDid = existing.creatorDid;
        likeCount = existing.likeCount;
      } else {
        _logger.warning('Could not fetch metadata for feed save, proceeding with defaults');
      }
    }

    final allFeeds = await _dao.getAllFeeds();

    int? queueId;
    try {
      queueId = await _dao.db.transaction(() async {
        await _dao.upsertFeed(
          SavedFeedsCompanion.insert(
            uri: feedUri,
            displayName: displayName,
            description: Value(description),
            avatar: Value(avatar),
            creatorDid: creatorDid,
            likeCount: Value(likeCount ?? 0),
            sortOrder: allFeeds.length,
            isPinned: Value(pin),
            lastSynced: DateTime.now(),
            localUpdatedAt: Value(DateTime.now()),
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

  /// Reorders feeds according to the provided URI list.
  ///
  /// Updates local sortOrder for each feed and syncs to remote preferences.
  /// Uses a fail-safe transaction pattern similar to saveFeed/removeFeed.
  Future<void> reorderFeeds(List<String> orderedUris) async {
    if (!_api.isAuthenticated) {
      throw Exception('Cannot reorder feeds: user not authenticated');
    }

    _logger.info('Reordering feeds', {'count': orderedUris.length});

    int? queueId;
    try {
      queueId = await _dao.db.transaction(() async {
        for (var i = 0; i < orderedUris.length; i++) {
          await _dao.updateSortOrder(orderedUris[i], i);
        }

        return await _syncQueueDao.enqueue(
          PreferenceSyncQueueCompanion.insert(
            type: 'reorder',
            feedUri: orderedUris.join(','),
            createdAt: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      _logger.error('Failed to perform atomic reorder update + queue', {'error': e});
      rethrow;
    }

    try {
      await _executeRemoteReorderFeeds(orderedUris);
      _logger.info('Feeds reordered on remote successfully');
      if (queueId != null) {
        await _syncQueueDao.deleteItem(queueId);
      }
    } catch (e) {
      _logger.warning('Network failed during reorderFeeds, operation queued for retry', {
        'error': e,
        'queueId': queueId,
      });
    }
  }

  Future<void> _executeRemoteReorderFeeds(List<String> orderedUris) async {
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
      return;
    }

    savedFeedsPref = Map<String, dynamic>.from(savedFeedsPref);
    final index = prefs.indexWhere((p) => p['\$type'] == 'app.bsky.actor.defs#savedFeedsPref');
    prefs[index] = savedFeedsPref;

    final currentSaved = List<String>.from(savedFeedsPref['saved'] ?? []);
    final currentPinned = List<String>.from(savedFeedsPref['pinned'] ?? []);

    final reorderedSaved = <String>[];
    final reorderedPinned = <String>[];

    for (final uri in orderedUris) {
      if (currentSaved.contains(uri)) {
        reorderedSaved.add(uri);
        if (currentPinned.contains(uri)) {
          reorderedPinned.add(uri);
        }
      }
    }

    for (final uri in currentSaved) {
      if (!reorderedSaved.contains(uri)) {
        reorderedSaved.add(uri);
      }
    }

    savedFeedsPref['saved'] = reorderedSaved;
    savedFeedsPref['pinned'] = reorderedPinned;

    await _api.call('app.bsky.actor.putPreferences', body: {'preferences': prefs});
  }

  /// Discovers trending feed generators or searches for them if a query is provided.
  ///
  /// Calls app.bsky.unspecced.getPopularFeedGenerators to fetch popular feeds.
  /// Returns a list of feed generator metadata.
  Future<List<Map<String, dynamic>>> discoverFeeds({int limit = 50, String? query}) async {
    _logger.info('Discovering feeds', {'limit': limit, 'query': query});

    try {
      final params = <String, dynamic>{'limit': limit};
      if (query != null && query.isNotEmpty) {
        params['query'] = query;
      }

      final response = await _api.call(
        'app.bsky.unspecced.getPopularFeedGenerators',
        params: params,
      );

      final feeds = response['feeds'] as List;
      _logger.debug('Discovered ${feeds.length} feeds');

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
  ///
  /// Throws [FormatException] if the API response has an invalid structure.
  Future<FeedGenerator> getFeedMetadata(String feedUri) async {
    _logger.debug('Fetching feed metadata', {'uri': feedUri});

    try {
      final response = await _api.call(
        'app.bsky.feed.getFeedGenerator',
        params: {'feed': feedUri},
      );

      final viewJson = response['view'];
      if (viewJson is! Map<String, dynamic>) {
        throw FormatException('Invalid feed metadata response: view must be a Map', response);
      }

      return FeedGenerator.fromJson(viewJson);
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
            displayName: metadata.displayName,
            description: Value(metadata.description),
            avatar: Value(metadata.avatar),
            creatorDid: metadata.creator.did,
            likeCount: Value(metadata.likeCount ?? 0),
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
        } else if (item.type == 'reorder') {
          final orderedUris = item.feedUri.split(',');
          await _executeRemoteReorderFeeds(orderedUris);
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

  /// Migrates users from the deprecated discover feed URI to the new one.
  ///
  /// Preserves pin status and sortOrder when migrating. Returns the migrated
  /// feed's properties if migration occurred, null otherwise.
  Future<_MigrationResult?> _migrateDeprecatedFeed() async {
    final deprecatedFeed = await _dao.getFeed(_kDeprecatedDiscoverUri);
    if (deprecatedFeed == null) {
      return null;
    }

    final newFeedExists = await _dao.getFeed(kDiscoverFeedUri) != null;

    final result = _MigrationResult(
      isPinned: deprecatedFeed.isPinned,
      sortOrder: deprecatedFeed.sortOrder,
    );

    await _dao.deleteFeed(_kDeprecatedDiscoverUri);
    _logger.info('Migrated deprecated discover feed', {
      'isPinned': result.isPinned,
      'sortOrder': result.sortOrder,
      'newFeedExists': newFeedExists,
    });

    if (newFeedExists) {
      return null;
    }

    return result;
  }

  /// Seeds default feeds if they don't already exist.
  ///
  /// For unauthenticated users, ensures the Discover feed is available.
  /// For authenticated users, removes all seeded feeds since they should only see feeds from their
  /// preferences.
  ///
  /// If a deprecated feed URI exists, migrates the user to the new URI while preserving their
  /// pin status and sortOrder.
  Future<void> seedDefaultFeeds() async {
    _logger.debug('Seeding default feeds');

    final migration = await _migrateDeprecatedFeed();

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
      sortOrder: migration?.sortOrder ?? 0,
      shouldPin: migration?.isPinned ?? true,
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

    FeedGenerator? metadata;
    try {
      metadata = await getFeedMetadata(uri);
    } catch (e) {
      _logger.error('Failed to fetch metadata for feed $uri, using defaults', {'error': e});
    }

    feeds.add(
      SavedFeedsCompanion.insert(
        uri: uri,
        displayName: metadata?.displayName ?? fallbackName,
        description: Value(metadata?.description ?? fallbackDescription),
        avatar: Value(metadata?.avatar),
        creatorDid: metadata?.creator.did ?? '',
        likeCount: Value(metadata?.likeCount ?? 0),
        sortOrder: sortOrder,
        isPinned: Value(shouldPin),
        lastSynced: now,
      ),
    );
  }
}

/// Helper class for representing a partial feed update during merge.
class _FeedUpdate {
  const _FeedUpdate({
    required this.uri,
    required this.sortOrder,
    required this.isPinned,
    required this.lastSynced,
    required this.clearLocalUpdatedAt,
  });

  final String uri;
  final int sortOrder;
  final bool isPinned;
  final DateTime lastSynced;
  final bool clearLocalUpdatedAt;
}

/// Helper class for storing deprecated feed migration properties.
class _MigrationResult {
  const _MigrationResult({required this.isPinned, required this.sortOrder});

  final bool isPinned;
  final int sortOrder;
}
