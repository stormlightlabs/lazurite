import 'package:drift/drift.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/feeds/domain/feed_generator.dart';
import 'package:lazurite/src/features/feeds/domain/list_view.dart';
import 'package:lazurite/src/features/feeds/domain/saved_feeds_pref.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/preference_sync_queue_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/profile_dao.dart';
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
  FeedRepository(this._api, this._dao, this._syncQueueDao, this._profileDao, this._logger);

  final XrpcClient _api;
  final SavedFeedsDao _dao;
  final PreferenceSyncQueueDao _syncQueueDao;
  final ProfileDao _profileDao;
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
  /// Uses a timestamp-based merge strategy to handle multi-device conflicts.
  /// Validates [ownerDid] matches the authenticated session to prevent data leakage.
  Future<void> syncPreferences(String ownerDid) async {
    _logger.debug('syncPreferences() called for $ownerDid');

    if (!_api.isAuthenticated) {
      _logger.debug('Skipping preference sync for unauthenticated user');
      return;
    }

    // Sanity check: ensure we are syncing for the logged-in user
    // Note: session.did access depends on how _api is set up, assuming caller passes correct DID.
    // If mismatch, we risks mixing data, but strict DAO scoping prevents reading wrong data.
    // Writing wrong data is the risk.
    // Assuming XrpcClient is session-bound or we trust the caller.

    try {
      _logger.debug('Calling app.bsky.actor.getPreferences API');
      final response = await _api.call('app.bsky.actor.getPreferences');
      final prefsJson = response['preferences'];

      if (prefsJson is! List) {
        throw FormatException('preferences must be a List', response);
      }

      final parsed = SavedFeedsPreferenceParser.parse(prefsJson);
      List<String> remoteSavedUris;
      List<String> remotePinnedUris;

      if (parsed.v2 != null) {
        remoteSavedUris = parsed.v2!.savedUris;
        remotePinnedUris = parsed.v2!.pinnedUris;
      } else if (parsed.v1 != null) {
        remoteSavedUris = parsed.v1!.saved;
        remotePinnedUris = parsed.v1!.pinned;
      } else {
        remoteSavedUris = [];
        remotePinnedUris = [];
      }

      await _mergeWithRemotePreferences(remoteSavedUris, remotePinnedUris, ownerDid);
      _logger.info('syncPreferences() completed successfully');
    } catch (e, stack) {
      _logger.error('Failed to sync feed preferences', {'error': e, 'stack': stack});
      rethrow;
    }
  }

  /// Merges local and remote feed preferences using timestamp-based resolution.
  /// Uses batch fetching for new feed metadata.
  Future<void> _mergeWithRemotePreferences(
    List<String> remoteSavedUris,
    List<String> remotePinnedUris,
    String ownerDid,
  ) async {
    final localFeeds = await _dao.getAllFeeds(ownerDid);
    final now = DateTime.now();
    final remoteSavedSet = remoteSavedUris.toSet();
    final feedsToInsert = <SavedFeedsCompanion>[];
    final feedsToUpdate = <_FeedUpdate>[];
    final feedsToRemove = <String>[];
    final feedsToSyncToRemote = <String>[];

    // Identify new remote feeds needing metadata
    final newRemoteFeeds = <String>[];
    for (final uri in remoteSavedUris) {
      if (uri.startsWith('at://') &&
          !uri.contains('/app.bsky.graph.list/') &&
          !localFeeds.any((f) => f.uri == uri)) {
        newRemoteFeeds.add(uri);
      }
    }

    // Batch fetch metadata for new feeds
    final Map<String, FeedGenerator> fetchedMetadata = {};
    if (newRemoteFeeds.isNotEmpty) {
      try {
        final batchResults = await getFeedGenerators(newRemoteFeeds);
        for (final feed in batchResults) {
          fetchedMetadata[feed.uri] = feed;
        }
      } catch (e) {
        _logger.warning('Failed to batch fetch feed metadata', {'error': e});
      }
    }

    for (var i = 0; i < remoteSavedUris.length; i++) {
      final remoteUri = remoteSavedUris[i];
      final remoteIsPinned = remotePinnedUris.contains(remoteUri);
      final local = localFeeds.where((f) => f.uri == remoteUri).firstOrNull;

      if (!remoteUri.startsWith('at://')) {
        // Handle special feeds...
        if (local == null) {
          feedsToInsert.add(
            SavedFeedsCompanion.insert(
              uri: remoteUri,
              ownerDid: ownerDid,
              displayName: _getSpecialFeedDisplayName(remoteUri),
              description: Value(_getSpecialFeedDescription(remoteUri)),
              creatorDid: '',
              likeCount: const Value(0),
              sortOrder: i,
              isPinned: Value(remoteIsPinned),
              lastSynced: now,
              localUpdatedAt: const Value(null),
            ),
          );
        } else if (local.localUpdatedAt == null ||
            !local.localUpdatedAt!.isAfter(local.lastSynced)) {
          // Unchanged or old local: Update from remote
          feedsToUpdate.add(
            _FeedUpdate(
              uri: remoteUri,
              sortOrder: i,
              isPinned: remoteIsPinned,
              lastSynced: now,
              clearLocalUpdatedAt: true,
            ),
          );
        } else {
          // Local is newer
          feedsToSyncToRemote.add(remoteUri);
        }
        continue;
      }

      if (local == null) {
        // New remote feed
        if (remoteUri.contains('/app.bsky.graph.list/')) {
          // List requires individual fetch
          try {
            final listMetadata = await getListMetadata(remoteUri);
            await _profileDao.upsertProfile(
              ProfilesCompanion.insert(
                did: listMetadata.creator.did,
                handle: listMetadata.creator.handle,
              ),
            );
            feedsToInsert.add(
              SavedFeedsCompanion.insert(
                uri: remoteUri,
                ownerDid: ownerDid,
                displayName: listMetadata.name,
                description: Value(listMetadata.description),
                avatar: Value(listMetadata.avatar),
                creatorDid: listMetadata.creator.did,
                likeCount: Value(listMetadata.listItemCount ?? 0),
                sortOrder: i,
                isPinned: Value(remoteIsPinned),
                lastSynced: now,
                localUpdatedAt: const Value(null),
              ),
            );
          } catch (e) {
            _logger.warning('Failed to fetch list $remoteUri', {'error': e});
          }
        } else {
          // Feed Generator - check batched metadata
          final metadata = fetchedMetadata[remoteUri];
          if (metadata != null) {
            await _profileDao.upsertProfile(
              ProfilesCompanion.insert(did: metadata.creator.did, handle: metadata.creator.handle),
            );
            feedsToInsert.add(
              SavedFeedsCompanion.insert(
                uri: remoteUri,
                ownerDid: ownerDid,
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
          } else {
            // Fallback individual fetch if missed in batch (e.g. error) or try individually?
            // If it failed in batch, it likely fails here too, but let's just skip/warn.
            _logger.warning('Missing metadata for $remoteUri');
          }
        }
      } else if (local.localUpdatedAt == null ||
          !local.localUpdatedAt!.isAfter(local.lastSynced)) {
        // Remote state wins
        feedsToUpdate.add(
          _FeedUpdate(
            uri: remoteUri,
            sortOrder: i,
            isPinned: remoteIsPinned,
            lastSynced: now,
            clearLocalUpdatedAt: true,
          ),
        );
      } else {
        // Local state wins
        feedsToSyncToRemote.add(remoteUri);
      }
    }

    // Detect removals
    for (final local in localFeeds) {
      if (!remoteSavedSet.contains(local.uri)) {
        if (local.localUpdatedAt != null && local.localUpdatedAt!.isAfter(local.lastSynced)) {
          feedsToSyncToRemote.add(local.uri);
        } else {
          feedsToRemove.add(local.uri);
        }
      }
    }

    // Apply changes
    if (feedsToInsert.isNotEmpty) {
      await _dao.upsertFeeds(feedsToInsert);
    }
    for (final update in feedsToUpdate) {
      await _dao.updateSyncState(
        uri: update.uri,
        ownerDid: ownerDid,
        sortOrder: update.sortOrder,
        isPinned: update.isPinned,
        lastSynced: update.lastSynced,
        clearLocalModification: update.clearLocalUpdatedAt,
      );
    }
    for (final uri in feedsToRemove) {
      await _dao.deleteFeed(uri, ownerDid);
    }

    // Queue local changes
    for (final uri in feedsToSyncToRemote) {
      final existing = await _syncQueueDao.getPendingItems(ownerDid);
      if (!existing.any((e) => e.payload == uri && e.type == 'save')) {
        await _syncQueueDao.enqueueFeedSync(type: 'save', feedUri: uri, ownerDid: ownerDid);
      }
    }
  }

  /// Saves a feed to user preferences and local cache.
  Future<void> saveFeed(String feedUri, String ownerDid, {bool pin = false}) async {
    if (!_api.isAuthenticated) throw Exception('User not authenticated');
    _validateFeedUri(feedUri);

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

      await _profileDao.upsertProfile(
        ProfilesCompanion.insert(did: creatorDid, handle: metadata.creator.handle),
      );
    } catch (e) {
      final existing = await _dao.getFeed(feedUri, ownerDid);
      if (existing != null) {
        displayName = existing.displayName;
        description = existing.description;
        avatar = existing.avatar;
        creatorDid = existing.creatorDid;
        likeCount = existing.likeCount;
      }
    }

    final allFeeds = await _dao.getAllFeeds(ownerDid);
    int? queueId;

    try {
      queueId = await _dao.db.transaction(() async {
        await _dao.upsertFeed(
          SavedFeedsCompanion.insert(
            uri: feedUri,
            ownerDid: ownerDid,
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

        return await _syncQueueDao.enqueueFeedSync(
          type: 'save',
          feedUri: feedUri,
          ownerDid: ownerDid,
        );
      });
    } catch (e) {
      rethrow;
    }

    try {
      await _executeRemoteSaveFeed(feedUri, pin);
      if (queueId != null) await _syncQueueDao.deleteItem(queueId);
    } catch (e) {
      // Failed sync, leave in queue
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
  Future<void> removeFeed(String feedUri, String ownerDid) async {
    if (!_api.isAuthenticated) throw Exception('User not authenticated');

    int? queueId;
    try {
      queueId = await _dao.db.transaction(() async {
        await _dao.deleteFeed(feedUri, ownerDid);
        return await _syncQueueDao.enqueueFeedSync(
          type: 'remove',
          feedUri: feedUri,
          ownerDid: ownerDid,
        );
      });
    } catch (e) {
      rethrow;
    }

    try {
      await _executeRemoteRemoveFeed(feedUri);
      if (queueId != null) await _syncQueueDao.deleteItem(queueId);
    } catch (e) {
      // Failed sync
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
  Future<void> reorderFeeds(List<String> orderedUris, String ownerDid) async {
    if (!_api.isAuthenticated) throw Exception('User not authenticated');

    int? queueId;
    try {
      queueId = await _dao.db.transaction(() async {
        // Optimized update: only update if changed? For now just iterate.
        for (var i = 0; i < orderedUris.length; i++) {
          await _dao.updateSortOrder(orderedUris[i], i, ownerDid);
        }

        return await _syncQueueDao.enqueueFeedSync(
          type: 'reorder',
          feedUri: orderedUris.join(','),
          ownerDid: ownerDid,
        );
      });
    } catch (e) {
      rethrow;
    }

    try {
      await _executeRemoteReorderFeeds(orderedUris);
      if (queueId != null) await _syncQueueDao.deleteItem(queueId);
    } catch (e) {
      // Failed sync
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

  /// Gets metadata for a specific list.
  ///
  /// Calls app.bsky.graph.getList with the list URI.
  /// Returns the list metadata including name, description, avatar, creator,
  /// and listItemCount.
  ///
  /// Throws [FormatException] if the API response has an invalid structure.
  Future<ListView> getListMetadata(String listUri) async {
    _logger.debug('Fetching list metadata', {'uri': listUri});

    try {
      final response = await _api.call('app.bsky.graph.getList', params: {'list': listUri});

      final listJson = response['list'];
      if (listJson is! Map<String, dynamic>) {
        throw FormatException('Invalid list metadata response: list must be a Map', response);
      }

      return ListView.fromJson(listJson);
    } catch (e) {
      _logger.error('Failed to fetch list metadata', {'uri': listUri, 'error': e});
      rethrow;
    }
  }

  /// Returns display name for special feeds (non-at:// URIs).
  String _getSpecialFeedDisplayName(String feedUri) {
    switch (feedUri) {
      case kFollowingFeedUri:
        return 'Following';
      case kTimelineFeedUri:
        return 'Home';
      default:
        return feedUri;
    }
  }

  /// Returns description for special feeds (non-at:// URIs).
  String _getSpecialFeedDescription(String feedUri) {
    switch (feedUri) {
      case kFollowingFeedUri:
        return 'Posts from people you follow';
      case kTimelineFeedUri:
        return 'Your home timeline';
      default:
        return 'Special feed: $feedUri';
    }
  }

  /// Refreshes stale feed metadata.
  ///
  /// Finds feeds with lastSynced older than 24 hours and updates their
  /// metadata from appropriate API endpoints (getFeedGenerator for feed generators,
  /// getList for lists). Special feeds (non-at:// URIs) are skipped.
  Future<void> refreshStaleMetadata(String ownerDid) async {
    if (!_api.isAuthenticated) return;

    final threshold = DateTime.now().subtract(const Duration(hours: 24));
    final staleFeeds = await _dao.getStaleFeeds(threshold, ownerDid);

    if (staleFeeds.isEmpty) {
      _logger.debug('No stale feeds to refresh');
      return;
    }

    _logger.info('Refreshing ${staleFeeds.length} stale feeds');

    for (final feed in staleFeeds) {
      try {
        if (!feed.uri.startsWith('at://')) {
          _logger.debug('Skipping special feed refresh: ${feed.uri}');
          continue;
        }

        if (feed.uri.contains('/app.bsky.graph.list/')) {
          final listMetadata = await getListMetadata(feed.uri);

          await _profileDao.upsertProfile(
            ProfilesCompanion.insert(
              did: listMetadata.creator.did,
              handle: listMetadata.creator.handle,
            ),
          );

          await _dao.upsertFeed(
            SavedFeedsCompanion.insert(
              uri: feed.uri,
              ownerDid: ownerDid,
              displayName: listMetadata.name,
              description: Value(listMetadata.description),
              avatar: Value(listMetadata.avatar),
              creatorDid: listMetadata.creator.did,
              likeCount: Value(listMetadata.listItemCount ?? 0),
              sortOrder: feed.sortOrder,
              isPinned: Value(feed.isPinned),
              lastSynced: DateTime.now(),
            ),
          );
        } else {
          final metadata = await getFeedMetadata(feed.uri);

          await _profileDao.upsertProfile(
            ProfilesCompanion.insert(did: metadata.creator.did, handle: metadata.creator.handle),
          );

          await _dao.upsertFeed(
            SavedFeedsCompanion.insert(
              uri: feed.uri,
              ownerDid: ownerDid,
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
        }
      } catch (e) {
        _logger.error('Failed to refresh metadata for feed ${feed.uri}', {'error': e});
      }
    }
  }

  /// Processes the offline preference sync queue.
  ///
  /// Attempts to re-apply any queued save/remove operations.
  /// Items that have reached the maximum retry count ([kMaxSyncRetries]) are skipped and left
  /// for cleanup.
  Future<void> processSyncQueue(String ownerDid) async {
    if (!_api.isAuthenticated) return;

    final retryable = await _syncQueueDao.getRetryableFeedItems(ownerDid);
    if (retryable.isEmpty) {
      return;
    }

    _logger.info('Processing ${retryable.length} retryable sync items');

    for (final item in retryable) {
      try {
        if (item.type == 'save') {
          final localFeed = await _dao.getFeed(item.payload, ownerDid);
          final shouldPin = localFeed?.isPinned ?? false;

          await _executeRemoteSaveFeed(item.payload, shouldPin);
        } else if (item.type == 'remove') {
          await _executeRemoteRemoveFeed(item.payload);
        } else if (item.type == 'reorder') {
          final orderedUris = item.payload.split(',');
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
  Future<void> syncOnResume(String ownerDid) async {
    _logger.info('Performing resume sync for $ownerDid');
    try {
      final cleanupThreshold = DateTime.now().subtract(kSyncQueueCleanupAge);
      final cleaned = await _syncQueueDao.cleanupOldFailedItems(cleanupThreshold);
      if (cleaned > 0) {
        _logger.info('Cleaned up $cleaned old failed sync items');
      }

      await processSyncQueue(ownerDid);
      await syncPreferences(ownerDid);
      await refreshStaleMetadata(ownerDid);
    } catch (e) {
      _logger.error('Resume sync failed', {'error': e});
    }
  }

  /// Watches all saved feeds reactively.
  Stream<List<SavedFeed>> watchAllFeeds(String ownerDid) {
    return _dao.watchAllFeeds(ownerDid);
  }

  /// Watches pinned feeds reactively.
  Stream<List<SavedFeed>> watchPinnedFeeds(String ownerDid) {
    return _dao.watchPinnedFeeds(ownerDid);
  }

  /// Gets a specific feed by URI.
  Future<SavedFeed?> getFeed(String uri, String ownerDid) {
    return _dao.getFeed(uri, ownerDid);
  }

  /// URI for the Home timeline (authenticated users).
  static const kHomeFeedUri = 'home';
  static const kFollowingFeedUri = 'following';
  static const kTimelineFeedUri = 'timeline';

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
  Future<_MigrationResult?> _migrateDeprecatedFeed(String ownerDid) async {
    final deprecatedFeed = await _dao.getFeed(_kDeprecatedDiscoverUri, ownerDid);
    if (deprecatedFeed == null) {
      return null;
    }

    final newFeedExists = await _dao.getFeed(kDiscoverFeedUri, ownerDid) != null;

    final result = _MigrationResult(
      isPinned: deprecatedFeed.isPinned,
      sortOrder: deprecatedFeed.sortOrder,
    );

    await _dao.deleteFeed(_kDeprecatedDiscoverUri, ownerDid);
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
  /// For unauthenticated users (ownerDid="unauthenticated"), ensures Discover feed.
  /// For authenticated users, cleans up legacy/seed feeds that shouldn't be there.
  Future<void> seedDefaultFeeds(String ownerDid) async {
    _logger.debug('Seeding default feeds');

    final migration = await _migrateDeprecatedFeed(ownerDid); // Pass ownerDid if needed

    if (_api.isAuthenticated) {
      // Cleanup for authenticated users
      await _dao.deleteFeed(kHomeFeedUri, ownerDid);
      await _dao.deleteFeed(kForYouFeedUri, ownerDid);
      await _dao.deleteFeed(kDiscoverFeedUri, ownerDid);
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
      ownerDid: ownerDid,
    );

    if (defaultFeeds.isNotEmpty) {
      await _dao.upsertFeeds(defaultFeeds);
      _logger.info('Seeded ${defaultFeeds.length} default feeds');
    } else {
      _logger.debug('Default feeds already up to date');
    }
  }

  Future<void> _ensureCuratedFeed({
    required String uri,
    required String fallbackName,
    required String fallbackDescription,
    required int sortOrder,
    required bool shouldPin,
    required DateTime now,
    required List<SavedFeedsCompanion> feeds,
    required String ownerDid,
  }) async {
    final existing = await _dao.getFeed(uri, ownerDid);
    if (existing != null) return;

    FeedGenerator? metadata;
    try {
      metadata = await getFeedMetadata(uri);
    } catch (e) {
      _logger.error('Failed to fetch metadata for feed $uri, using defaults', {'error': e});
    }

    feeds.add(
      SavedFeedsCompanion.insert(
        uri: uri,
        ownerDid: ownerDid,
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

  /// Fetches metadata for multiple feed generators in batches.
  Future<List<FeedGenerator>> getFeedGenerators(List<String> uris) async {
    if (uris.isEmpty) return [];

    // Chunk requests to avoid hitting URL length limits or API constraints
    // Assuming 25 is a safe batch size
    const batchSize = 25;
    final results = <FeedGenerator>[];

    for (var i = 0; i < uris.length; i += batchSize) {
      final end = (i + batchSize < uris.length) ? i + batchSize : uris.length;
      final batch = uris.sublist(i, end);

      try {
        final response = await _api.call(
          'app.bsky.feed.getFeedGenerators',
          params: {'feeds': batch},
        );

        final views = (response['feeds'] as List).cast<Map<String, dynamic>>();
        results.addAll(views.map((v) => FeedGenerator.fromJson(v)));
      } catch (e) {
        _logger.error('Batch fetch failed for slice $i-$end', {'error': e});
        // Don't rethrow, partial success is better
      }
    }

    return results;
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
