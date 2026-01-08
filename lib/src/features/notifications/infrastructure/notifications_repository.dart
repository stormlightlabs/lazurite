import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/utils/logger.dart';
import '../../../infrastructure/db/app_database.dart';
import '../../../infrastructure/db/daos/notifications_dao.dart';
import '../../../infrastructure/network/xrpc_client.dart';
import '../domain/notification.dart';
import '../domain/notification_type.dart';

/// Repository for managing notifications from Bluesky.
///
/// Handles fetching, caching, and streaming notifications from
/// app.bsky.notification.listNotifications API.
class NotificationsRepository {
  NotificationsRepository(this._client, this._dao, this._logger);

  final XrpcClient _client;
  final NotificationsDao _dao;
  final Logger _logger;

  /// Feed key for notifications cursor storage.
  static const kNotificationsFeedKey = 'notifications';

  /// Fetches notifications from the API and caches them locally.
  ///
  /// [cursor] - Pagination cursor for fetching older notifications.
  /// [limit] - Maximum number of notifications to fetch (default 50, max 100).
  Future<void> fetchNotifications({String? cursor, int limit = 50}) async {
    _logger.info('Fetching notifications', {'cursor': cursor, 'limit': limit});

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

  /// Returns a stream of notifications from the local cache.
  ///
  /// Notifications are joined with actor profiles for complete display data.
  Stream<List<AppNotification>> watchNotifications() {
    return _dao.watchNotifications().map((items) {
      return items
          .map((item) {
            final type = NotificationType.fromString(item.notification.type);
            if (type == null) return null;

            return AppNotification(
              uri: item.notification.uri,
              actor: item.actor,
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

  /// Gets the pagination cursor for loading more notifications.
  Future<String?> getCursor() {
    return _dao.getCursor();
  }

  /// Clears all cached notifications.
  Future<void> clearNotifications() {
    return _dao.clearNotifications();
  }

  /// Deletes notifications older than the specified threshold.
  Future<int> deleteStaleNotifications(DateTime threshold) {
    return _dao.deleteStaleNotifications(threshold);
  }

  /// Marks all notifications as read locally.
  Future<void> markAllAsRead() {
    return _dao.markAllAsRead();
  }

  /// Encodes labels array to JSON string.
  String? _encodeLabels(dynamic labels) {
    if (labels == null) return null;
    if (labels is List && labels.isEmpty) return null;
    return jsonEncode(labels);
  }
}
