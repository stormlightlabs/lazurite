import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lazurite/src/core/domain/author.dart';

import '../../../core/utils/logger.dart';
import '../../../infrastructure/db/app_database.dart' hide Post, Profile;
import '../../../infrastructure/db/daos/notifications_dao.dart';
import '../../../infrastructure/db/daos/notifications_sync_queue_dao.dart';
import '../../../infrastructure/network/xrpc_client.dart';
import '../domain/notification.dart';
import '../domain/notification_type.dart';

/// Repository for managing notifications from Bluesky.
///
/// Handles fetching, caching, and streaming notifications from
/// app.bsky.notification.listNotifications API.
class NotificationsRepository {
  NotificationsRepository(this._client, this._dao, this._syncQueue, this._logger);

  final XrpcClient _client;
  final NotificationsDao _dao;
  final NotificationsSyncQueueDao _syncQueue;
  final Logger _logger;

  /// Feed key for notifications cursor storage.
  static const kNotificationsFeedKey = 'notifications';

  /// Fetches notifications from the API and caches them locally.
  Future<void> fetchNotifications({
    required String ownerDid,
    String? cursor,
    int limit = 50,
  }) async {
    _logger.info('Fetching notifications', {
      'cursor': cursor,
      'limit': limit,
      'ownerDid': ownerDid,
    });

    try {
      final params = <String, dynamic>{'limit': limit.clamp(1, 100)};
      if (cursor != null) {
        params['cursor'] = cursor;
      }

      final response = await _client.call(
        'app.bsky.notification.listNotifications',
        params: params,
      );

      final notificationsList = response['notifications'] as List<dynamic>? ?? [];
      final newCursor = response['cursor'] as String?;

      _logger.debug('Received notifications', {
        'count': notificationsList.length,
        'newCursor': newCursor,
      });

      final notifications = <NotificationsCompanion>[];
      final profiles = <ProfilesCompanion>[];

      final now = DateTime.now();

      for (final item in notificationsList) {
        final notificationMap = item as Map<String, dynamic>;
        final author = notificationMap['author'] as Map<String, dynamic>?;

        if (author == null) {
          _logger.debug('Skipping notification without author', {'uri': notificationMap['uri']});
          continue;
        }

        profiles.add(
          ProfilesCompanion.insert(
            did: author['did'] as String,
            handle: author['handle'] as String? ?? 'unknown',
            displayName: Value(author['displayName'] as String?),
            description: Value(author['description'] as String?),
            avatar: Value(author['avatar'] as String?),
            banner: Value(author['banner'] as String?),
            labels: Value(_encodeLabels(author['labels'])),
          ),
        );

        final reasonString = notificationMap['reason'] as String? ?? '';
        final type = NotificationType.fromString(reasonString);
        if (type == null) {
          _logger.debug('Skipping unknown notification type', {'reason': reasonString});
          continue;
        }

        final indexedAtStr = notificationMap['indexedAt'] as String?;
        final indexedAt = indexedAtStr != null ? DateTime.tryParse(indexedAtStr) ?? now : now;

        final record = notificationMap['record'] as Map<String, dynamic>?;
        final recordJson = record != null ? jsonEncode(record) : null;

        notifications.add(
          NotificationsCompanion.insert(
            uri: notificationMap['uri'] as String,
            actorDid: author['did'] as String,
            ownerDid: ownerDid,
            type: type.name,
            reasonSubjectUri: Value(notificationMap['reasonSubject'] as String?),
            recordJson: Value(recordJson),
            indexedAt: indexedAt,
            isRead: Value(notificationMap['isRead'] as bool? ?? false),
            cachedAt: now,
          ),
        );
      }

      await _dao.insertNotificationsBatch(
        newNotifications: notifications,
        newProfiles: profiles,
        ownerDid: ownerDid,
        newCursor: newCursor,
      );

      _logger.info('Cached notifications', {
        'notificationCount': notifications.length,
        'profileCount': profiles.length,
      });
    } catch (error, stack) {
      _logger.error('Failed to fetch notifications', error, stack);
      rethrow;
    }
  }

  /// Returns a stream of notifications from the local cache for a specific user.
  Stream<List<AppNotification>> watchNotifications(String ownerDid) {
    return _dao.watchNotifications(ownerDid).map((items) {
      return items
          .map((item) {
            final type = NotificationType.fromString(item.notification.type);
            if (type == null) return null;

            return AppNotification(
              uri: item.notification.uri,
              actor: Author.fromProfile(item.actor),
              type: type,
              reasonSubjectUri: item.notification.reasonSubjectUri,
              recordJson: item.notification.recordJson,
              indexedAt: item.notification.indexedAt,
              isRead: item.notification.isRead,
            );
          })
          .whereType<AppNotification>()
          .toList();
    });
  }

  /// Gets the pagination cursor for loading more notifications for a specific user.
  Future<String?> getCursor(String ownerDid) {
    return _dao.getCursor(ownerDid);
  }

  /// Clears all cached notifications for a specific user.
  Future<void> clearNotifications(String ownerDid) {
    return _dao.clearNotifications(ownerDid);
  }

  /// Deletes notifications older than the specified threshold for a specific user.
  Future<int> deleteStaleNotifications(DateTime threshold, String ownerDid) {
    return _dao.deleteStaleNotifications(threshold, ownerDid);
  }

  /// Marks all notifications as read locally for a specific user.
  Future<void> markAllAsRead(String ownerDid) {
    return _dao.markAllAsRead(ownerDid);
  }

  /// Returns a stream of the unread notification count for a specific user.
  Stream<int> watchUnreadCount(String ownerDid) {
    return _dao.watchUnreadCount(ownerDid);
  }

  /// Fetches the current unread count from the API.
  Future<int> getUnreadCount() async {
    _logger.info('Fetching unread count from API', {});

    try {
      final response = await _client.call('app.bsky.notification.getUnreadCount');
      final count = response['count'] as int? ?? 0;

      _logger.debug('Received unread count', {'count': count});
      return count;
    } catch (error, stack) {
      _logger.error('Failed to fetch unread count', error, stack);
      rethrow;
    }
  }

  /// Marks notifications as seen on the server.
  Future<void> updateSeen(DateTime seenAt) async {
    _logger.info('Updating seen state', {'seenAt': seenAt.toIso8601String()});

    try {
      await _client.call(
        'app.bsky.notification.updateSeen',
        body: {'seenAt': seenAt.toIso8601String()},
      );

      _logger.debug('Successfully updated seen state', {});
    } catch (error, stack) {
      _logger.error('Failed to update seen state', error, stack);
      rethrow;
    }
  }

  /// Marks specific notifications as seen locally for a specific user.
  Future<void> markAsSeenLocally(DateTime seenAt, String ownerDid) async {
    _logger.debug('Marking notifications as seen locally', {
      'seenAt': seenAt.toIso8601String(),
      'ownerDid': ownerDid,
    });

    await _dao.markAsSeenBefore(seenAt, ownerDid);
  }

  /// Processes the sync queue to retry failed mark-as-seen operations for a specific user.
  Future<void> processSyncQueue(String ownerDid) async {
    _logger.debug('Processing notification sync queue', {'ownerDid': ownerDid});

    final threshold = DateTime.now().subtract(const Duration(days: 30));
    final cleanedCount = await _syncQueue.cleanupOldFailedItems(threshold, ownerDid);
    if (cleanedCount > 0) {
      _logger.info('Cleaned up old failed sync items', {'count': cleanedCount});
    }

    final latestSeenAt = await _syncQueue.getLatestSeenAt(ownerDid);
    if (latestSeenAt == null) {
      _logger.debug('No items in sync queue', {});
      return;
    }

    _logger.info('Processing sync queue', {'latestSeenAt': latestSeenAt.toIso8601String()});

    final retryableItems = await _syncQueue.getRetryableItems(ownerDid);

    try {
      await markAsSeenLocally(latestSeenAt, ownerDid);
      await updateSeen(latestSeenAt);

      final deletedCount = await _syncQueue.deleteItemsUpTo(latestSeenAt, ownerDid);
      _logger.info('Successfully synced notifications', {
        'seenAt': latestSeenAt.toIso8601String(),
        'clearedQueueItems': deletedCount,
      });
    } catch (error, stack) {
      _logger.error('Failed to process sync queue', error, stack);

      for (final item in retryableItems) {
        await _syncQueue.incrementRetryCount(item.id);
      }
    }
  }

  /// Encodes labels array to JSON string.
  String? _encodeLabels(dynamic labels) {
    if (labels == null) return null;
    if (labels is List && labels.isEmpty) return null;
    return jsonEncode(labels);
  }
}
