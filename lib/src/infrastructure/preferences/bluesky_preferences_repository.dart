import 'dart:convert';

import '../../core/utils/logger.dart';
import '../../features/settings/domain/bluesky_preferences.dart';
import '../db/daos/bluesky_preferences_dao.dart';
import '../db/daos/preference_sync_queue_dao.dart';
import '../network/xrpc_client.dart';

/// Repository for managing Bluesky account preferences.
///
/// Handles syncing preferences from the remote server and provides
/// typed access to content moderation, feed/thread view, and muted
/// word settings. Also manages the sync queue for offline updates.
class BlueskyPreferencesRepository {
  BlueskyPreferencesRepository(this._api, this._dao, this._syncQueueDao, this._logger);

  final XrpcClient _api;
  final BlueskyPreferencesDao _dao;
  final PreferenceSyncQueueDao _syncQueueDao;
  final Logger _logger;

  /// Syncs all preferences from the remote Bluesky server.
  Future<void> syncPreferencesFromRemote(String ownerDid) async {
    if (!_api.isAuthenticated) {
      _logger.debug('Skipping preference sync for unauthenticated user');
      return;
    }

    _logger.info('Syncing Bluesky preferences from remote', {'ownerDid': ownerDid});

    try {
      final response = await _api.call('app.bsky.actor.getPreferences');
      final prefsJson = response['preferences'] as List<dynamic>?;

      if (prefsJson == null) {
        _logger.warning('Preferences response missing preferences array');
        return;
      }

      final now = DateTime.now();

      final contentLabels = <Map<String, dynamic>>[];
      AdultContentPref? adultContent;
      LabelersPref? labelers;
      FeedViewPref? feedView;
      ThreadViewPref? threadView;
      MutedWordsPref? mutedWords;

      for (final pref in prefsJson) {
        if (pref is! Map<String, dynamic>) continue;

        final type = pref[r'$type'] as String?;
        if (type == null) continue;

        try {
          switch (type) {
            case BlueskyPreferenceTypes.adultContent:
              adultContent = AdultContentPref.fromJson(pref);
            case BlueskyPreferenceTypes.contentLabel:
              contentLabels.add(pref);
            case BlueskyPreferenceTypes.labelers:
              labelers = LabelersPref.fromJson(pref);
            case BlueskyPreferenceTypes.feedView:
              feedView = FeedViewPref.fromJson(pref);
            case BlueskyPreferenceTypes.threadView:
              threadView = ThreadViewPref.fromJson(pref);
            case BlueskyPreferenceTypes.mutedWords:
              mutedWords = MutedWordsPref.fromJson(pref);
          }
        } catch (e) {
          _logger.warning('Failed to parse preference type $type', {'error': e.toString()});
        }
      }

      if (adultContent != null) {
        await _dao.upsertPreference(
          type: 'adultContent',
          ownerDid: ownerDid,
          data: adultContent.toStoredJson(),
          lastSynced: now,
        );
      }

      if (contentLabels.isNotEmpty) {
        final prefs = ContentLabelPrefs.fromJsonList(contentLabels);
        await _dao.upsertPreference(
          type: 'contentLabels',
          ownerDid: ownerDid,
          data: prefs.toStoredJson(),
          lastSynced: now,
        );
      }

      if (labelers != null) {
        await _dao.upsertPreference(
          type: 'labelers',
          ownerDid: ownerDid,
          data: labelers.toStoredJson(),
          lastSynced: now,
        );
      }

      if (feedView != null) {
        await _dao.upsertPreference(
          type: 'feedView',
          ownerDid: ownerDid,
          data: feedView.toStoredJson(),
          lastSynced: now,
        );
      }

      if (threadView != null) {
        await _dao.upsertPreference(
          type: 'threadView',
          ownerDid: ownerDid,
          data: threadView.toStoredJson(),
          lastSynced: now,
        );
      }

      if (mutedWords != null) {
        await _dao.upsertPreference(
          type: 'mutedWords',
          ownerDid: ownerDid,
          data: mutedWords.toStoredJson(),
          lastSynced: now,
        );
      }

      _logger.info('Successfully synced Bluesky preferences');
    } catch (e, stack) {
      _logger.error('Failed to sync preferences', {
        'error': e.toString(),
        'stack': stack.toString(),
      });
      rethrow;
    }
  }

  /// Gets the adult content preference.
  Future<AdultContentPref> getAdultContentPref(String ownerDid) async {
    final row = await _dao.getPreferenceByType('adultContent', ownerDid);
    if (row == null) return const AdultContentPref(enabled: false);
    try {
      return AdultContentPref.fromStoredJson(row.data);
    } catch (e) {
      _logger.warning('Failed to parse adult content pref', {'error': e});
      return const AdultContentPref(enabled: false);
    }
  }

  /// Watches the adult content preference for changes.
  Stream<AdultContentPref> watchAdultContentPref(String ownerDid) {
    return _dao.watchPreferenceByType('adultContent', ownerDid).map((row) {
      if (row == null) return const AdultContentPref(enabled: false);
      try {
        return AdultContentPref.fromStoredJson(row.data);
      } catch (e) {
        _logger.warning('Failed to parse adult content pref', {'error': e});
        return const AdultContentPref(enabled: false);
      }
    });
  }

  /// Gets all content label preferences.
  Future<ContentLabelPrefs> getContentLabelPrefs(String ownerDid) async {
    final row = await _dao.getPreferenceByType('contentLabels', ownerDid);
    if (row == null) return ContentLabelPrefs.empty;
    try {
      return ContentLabelPrefs.fromStoredJson(row.data);
    } catch (e) {
      _logger.warning('Failed to parse content label prefs', {'error': e});
      return ContentLabelPrefs.empty;
    }
  }

  /// Watches content label preferences for changes.
  Stream<ContentLabelPrefs> watchContentLabelPrefs(String ownerDid) {
    return _dao.watchPreferenceByType('contentLabels', ownerDid).map((row) {
      if (row == null) return ContentLabelPrefs.empty;
      try {
        return ContentLabelPrefs.fromStoredJson(row.data);
      } catch (e) {
        _logger.warning('Failed to parse content label prefs', {'error': e});
        return ContentLabelPrefs.empty;
      }
    });
  }

  /// Gets the labelers preference.
  Future<LabelersPref> getLabelersPref(String ownerDid) async {
    final row = await _dao.getPreferenceByType('labelers', ownerDid);
    if (row == null) return LabelersPref.empty;
    try {
      return LabelersPref.fromStoredJson(row.data);
    } catch (e) {
      _logger.warning('Failed to parse labelers pref', {'error': e});
      return LabelersPref.empty;
    }
  }

  /// Watches the labelers preference for changes.
  Stream<LabelersPref> watchLabelersPref(String ownerDid) {
    return _dao.watchPreferenceByType('labelers', ownerDid).map((row) {
      if (row == null) return LabelersPref.empty;
      try {
        return LabelersPref.fromStoredJson(row.data);
      } catch (e) {
        _logger.warning('Failed to parse labelers pref', {'error': e});
        return LabelersPref.empty;
      }
    });
  }

  /// Gets the feed view preference.
  Future<FeedViewPref> getFeedViewPref(String ownerDid) async {
    final row = await _dao.getPreferenceByType('feedView', ownerDid);
    if (row == null) return FeedViewPref.defaultPref;
    try {
      return FeedViewPref.fromStoredJson(row.data);
    } catch (e) {
      _logger.warning('Failed to parse feed view pref', {'error': e});
      return FeedViewPref.defaultPref;
    }
  }

  /// Watches the feed view preference for changes.
  Stream<FeedViewPref> watchFeedViewPref(String ownerDid) {
    return _dao.watchPreferenceByType('feedView', ownerDid).map((row) {
      if (row == null) return FeedViewPref.defaultPref;
      try {
        return FeedViewPref.fromStoredJson(row.data);
      } catch (e) {
        _logger.warning('Failed to parse feed view pref', {'error': e});
        return FeedViewPref.defaultPref;
      }
    });
  }

  /// Gets the thread view preference.
  Future<ThreadViewPref> getThreadViewPref(String ownerDid) async {
    final row = await _dao.getPreferenceByType('threadView', ownerDid);
    if (row == null) return ThreadViewPref.defaultPref;
    try {
      return ThreadViewPref.fromStoredJson(row.data);
    } catch (e) {
      _logger.warning('Failed to parse thread view pref', {'error': e});
      return ThreadViewPref.defaultPref;
    }
  }

  /// Watches the thread view preference for changes.
  Stream<ThreadViewPref> watchThreadViewPref(String ownerDid) {
    return _dao.watchPreferenceByType('threadView', ownerDid).map((row) {
      if (row == null) return ThreadViewPref.defaultPref;
      try {
        return ThreadViewPref.fromStoredJson(row.data);
      } catch (e) {
        _logger.warning('Failed to parse thread view pref', {'error': e});
        return ThreadViewPref.defaultPref;
      }
    });
  }

  /// Updates the feed view preference.
  ///
  /// Persists locally and queues for sync to Bluesky.
  Future<void> updateFeedViewPref(FeedViewPref pref, String ownerDid) async {
    _logger.info('Updating feed view preference');
    final now = DateTime.now();
    final data = pref.toStoredJson();

    await _dao.upsertPreference(type: 'feedView', ownerDid: ownerDid, data: data, lastSynced: now);

    await _syncQueueDao.enqueueBlueskyPrefSync(
      preferenceType: 'feedView',
      preferenceData: data,
      ownerDid: ownerDid,
    );

    _logger.debug('Feed view preference updated and queued for sync');
  }

  /// Updates the thread view preference.
  ///
  /// Persists locally and queues for sync to Bluesky.
  Future<void> updateThreadViewPref(ThreadViewPref pref, String ownerDid) async {
    _logger.info('Updating thread view preference');
    final now = DateTime.now();
    final data = pref.toStoredJson();

    await _dao.upsertPreference(
      type: 'threadView',
      ownerDid: ownerDid,
      data: data,
      lastSynced: now,
    );

    await _syncQueueDao.enqueueBlueskyPrefSync(
      preferenceType: 'threadView',
      preferenceData: data,
      ownerDid: ownerDid,
    );

    _logger.debug('Thread view preference updated and queued for sync');
  }

  /// Updates the adult content preference.
  ///
  /// Persists locally and queues for sync to Bluesky.
  Future<void> updateAdultContentPref(AdultContentPref pref, String ownerDid) async {
    _logger.info('Updating adult content preference');
    final now = DateTime.now();
    final data = pref.toStoredJson();

    await _dao.upsertPreference(
      type: 'adultContent',
      ownerDid: ownerDid,
      data: data,
      lastSynced: now,
    );

    await _syncQueueDao.enqueueBlueskyPrefSync(
      preferenceType: 'adultContent',
      preferenceData: data,
      ownerDid: ownerDid,
    );

    _logger.debug('Adult content preference updated and queued for sync');
  }

  /// Updates content label preferences.
  ///
  /// Persists locally and queues for sync to Bluesky.
  Future<void> updateContentLabelPrefs(ContentLabelPrefs prefs, String ownerDid) async {
    _logger.info('Updating content label preferences');
    final now = DateTime.now();
    final data = prefs.toStoredJson();

    await _dao.upsertPreference(
      type: 'contentLabels',
      ownerDid: ownerDid,
      data: data,
      lastSynced: now,
    );

    await _syncQueueDao.enqueueBlueskyPrefSync(
      preferenceType: 'contentLabels',
      preferenceData: data,
      ownerDid: ownerDid,
    );

    _logger.debug('Content label preferences updated and queued for sync');
  }

  /// Gets the muted words preference.
  Future<MutedWordsPref> getMutedWordsPref(String ownerDid) async {
    final row = await _dao.getPreferenceByType('mutedWords', ownerDid);
    if (row == null) return MutedWordsPref.empty;
    try {
      return MutedWordsPref.fromStoredJson(row.data);
    } catch (e) {
      _logger.warning('Failed to parse muted words pref', {'error': e});
      return MutedWordsPref.empty;
    }
  }

  /// Watches the muted words preference for changes.
  Stream<MutedWordsPref> watchMutedWordsPref(String ownerDid) {
    return _dao.watchPreferenceByType('mutedWords', ownerDid).map((row) {
      if (row == null) return MutedWordsPref.empty;
      try {
        return MutedWordsPref.fromStoredJson(row.data);
      } catch (e) {
        _logger.warning('Failed to parse muted words pref', {'error': e});
        return MutedWordsPref.empty;
      }
    });
  }

  /// Updates the muted words preference.
  ///
  /// Persists locally and queues for sync to Bluesky.
  Future<void> updateMutedWordsPref(MutedWordsPref pref, String ownerDid) async {
    _logger.info('Updating muted words preference');
    final now = DateTime.now();
    final data = pref.toStoredJson();

    await _dao.upsertPreference(
      type: 'mutedWords',
      ownerDid: ownerDid,
      data: data,
      lastSynced: now,
    );

    await _syncQueueDao.enqueueBlueskyPrefSync(
      preferenceType: 'mutedWords',
      preferenceData: data,
      ownerDid: ownerDid,
    );

    _logger.debug('Muted words preference updated and queued for sync');
  }

  /// Clears all cached preferences.
  ///
  /// Useful when signing out.
  Future<void> clearAll(String ownerDid) async {
    _logger.info('Clearing all Bluesky preferences');
    await _dao.clearAll(ownerDid);
  }

  /// Processes the preference sync queue, retrying failed updates.
  ///
  /// For each queued preference update:
  /// 1. Fetches ALL current preferences from remote
  /// 2. Replaces the specific preference type with the queued data
  /// 3. Sends the complete array back via putPreferences
  /// 4. Deletes the queue item on success, or increments retry count on failure
  ///
  /// Also cleans up old permanently failed items (> 30 days).
  Future<void> processSyncQueue(String ownerDid) async {
    if (!_api.isAuthenticated) return;

    final threshold = DateTime.now().subtract(const Duration(days: 30));
    await _syncQueueDao.cleanupOldFailedItems(threshold);

    final retryable = await _syncQueueDao.getRetryableBlueskyPrefItems(ownerDid);
    if (retryable.isEmpty) {
      return;
    }

    _logger.info('Processing ${retryable.length} retryable preference sync items');

    for (final item in retryable) {
      try {
        await _syncSinglePreference(item.type, item.payload);
        await _syncQueueDao.deleteItem(item.id);
        _logger.debug('Successfully synced preference ${item.type}');
      } catch (e) {
        _logger.error('Failed to sync preference ${item.type}', {
          'error': e.toString(),
          'retryCount': item.retryCount,
        });
        await _syncQueueDao.incrementRetryCount(item.id);
      }
    }
  }

  /// Syncs a single preference type to the remote server.
  ///
  /// Fetches all current preferences, replaces the specific type, and sends
  /// the complete array back.
  Future<void> _syncSinglePreference(String preferenceType, String preferenceData) async {
    final response = await _api.call('app.bsky.actor.getPreferences');
    final currentPrefs = (response['preferences'] as List<dynamic>?) ?? [];

    final updatedPrefs = List<Map<String, dynamic>>.from(
      currentPrefs.map((p) => p as Map<String, dynamic>),
    );

    final typeToRemove = _getPreferenceTypeIdentifier(preferenceType);
    updatedPrefs.removeWhere((p) => p[r'$type'] == typeToRemove);

    final parsedData = jsonDecode(preferenceData) as Map<String, dynamic>;
    if (preferenceType == 'contentLabels') {
      final labels = (parsedData['labels'] as List<dynamic>?) ?? [];
      for (final label in labels) {
        updatedPrefs.add({
          r'$type': BlueskyPreferenceTypes.contentLabel,
          ...label as Map<String, dynamic>,
        });
      }
    } else {
      updatedPrefs.add({r'$type': typeToRemove, ...parsedData});
    }

    await _api.call('app.bsky.actor.putPreferences', body: {'preferences': updatedPrefs});
  }

  /// Maps internal preference type names to AT Protocol type identifiers.
  String _getPreferenceTypeIdentifier(String preferenceType) {
    switch (preferenceType) {
      case 'adultContent':
        return BlueskyPreferenceTypes.adultContent;
      case 'contentLabels':
        return BlueskyPreferenceTypes.contentLabel;
      case 'labelers':
        return BlueskyPreferenceTypes.labelers;
      case 'feedView':
        return BlueskyPreferenceTypes.feedView;
      case 'threadView':
        return BlueskyPreferenceTypes.threadView;
      case 'mutedWords':
        return BlueskyPreferenceTypes.mutedWords;
      default:
        throw ArgumentError('Unknown preference type: $preferenceType');
    }
  }
}
