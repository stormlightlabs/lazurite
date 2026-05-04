import 'package:bluesky/app_bsky_notification_listnotifications.dart';
import 'package:bluesky/app_bsky_notification_registerpush.dart';
import 'package:bluesky/app_bsky_notification_unregisterpush.dart';
import 'package:bluesky/bluesky.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';

class NotificationRepository {
  NotificationRepository({
    required Bluesky bluesky,
    ModerationService? moderationService,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
  }) : _bluesky = bluesky,
       _moderationService = moderationService,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       );

  final Bluesky _bluesky;
  final ModerationService? _moderationService;
  final AppViewRequestContext _appViewContext;

  Future<NotificationListResult> listNotifications({String? cursor, int limit = 50}) async {
    final response = await _bluesky.notification.listNotifications(
      cursor: cursor,
      limit: limit,
      $headers: _appViewContext.appBskyHeadersForEndpoint(
        'app.bsky.notification.listNotifications',
        await _moderationService?.headersForRequest(),
      ),
    );

    return NotificationListResult(
      notifications: _filterNotifications(response.data.notifications),
      cursor: response.data.cursor,
      seenAt: response.data.seenAt,
    );
  }

  Future<int> getUnreadCount() async {
    final response = await _bluesky.notification.getUnreadCount(
      $headers: _appViewContext.appBskyHeadersForEndpoint(
        'app.bsky.notification.getUnreadCount',
        await _moderationService?.headersForRequest(),
      ),
    );
    return response.data.count;
  }

  Future<void> updateSeen() async {
    await _bluesky.notification.updateSeen(
      seenAt: DateTime.now(),
      $headers: _appViewContext.appBskyHeadersForEndpoint(
        'app.bsky.notification.updateSeen',
        await _moderationService?.headersForRequest(),
      ),
    );
  }

  Future<void> registerPush({
    required String token,
    required String appId,
    required NotificationPushPlatform platform,
    bool? ageRestricted,
  }) async {
    final serviceDid = _appViewContext.notificationServiceDid();
    final headers = _notificationPushHeaders(await _moderationService?.headersForRequest());
    await _bluesky.notification.registerPush(
      serviceDid: serviceDid,
      token: token,
      platform: _registerPlatformFor(platform),
      appId: appId,
      ageRestricted: ageRestricted,
      $headers: headers,
    );
  }

  Future<void> unregisterPush({
    required String token,
    required String appId,
    required NotificationPushPlatform platform,
  }) async {
    final serviceDid = _appViewContext.notificationServiceDid();
    final headers = _notificationPushHeaders(await _moderationService?.headersForRequest());
    await _bluesky.notification.unregisterPush(
      serviceDid: serviceDid,
      token: token,
      platform: _unregisterPlatformFor(platform),
      appId: appId,
      $headers: headers,
    );
  }

  Future<Notification?> findNotificationByRecordUri({
    required String recordUri,
    String? senderDid,
    String? reason,
    int maxPages = 3,
    int limit = 50,
  }) async {
    if (recordUri.trim().isEmpty) {
      return null;
    }

    var cursor = '';
    for (var page = 0; page < maxPages; page++) {
      final response = await _bluesky.notification.listNotifications(
        cursor: cursor.isEmpty ? null : cursor,
        limit: limit,
        $headers: _appViewContext.appBskyHeadersForEndpoint(
          'app.bsky.notification.listNotifications',
          await _moderationService?.headersForRequest(),
        ),
      );

      final notifications = _filterNotifications(response.data.notifications);
      for (final notification in notifications) {
        if (!_matchesRecordUri(notification, recordUri)) {
          continue;
        }
        if (senderDid != null && senderDid.trim().isNotEmpty && notification.author.did != senderDid) {
          continue;
        }
        if (reason != null && reason.trim().isNotEmpty && !_reasonMatches(notification, reason)) {
          continue;
        }
        return notification;
      }

      final nextCursor = response.data.cursor;
      if (nextCursor == null || nextCursor.trim().isEmpty) {
        return null;
      }
      cursor = nextCursor;
    }

    return null;
  }

  List<Notification> _filterNotifications(List<Notification> notifications) {
    final moderationService = _moderationService;
    if (moderationService == null) {
      return notifications;
    }

    return notifications
        .where((notification) => !moderationService.shouldFilterNotificationInList(notification))
        .toList();
  }

  Map<String, String> _notificationPushHeaders(Map<String, String>? baseHeaders) {
    final headers = _appViewContext.appBskyHeadersWithoutProxy(baseHeaders);
    headers['atproto-proxy'] = _appViewContext.notificationProxyServiceDid();
    return headers;
  }

  NotificationRegisterPushPlatform _registerPlatformFor(NotificationPushPlatform platform) {
    return switch (platform) {
      NotificationPushPlatform.android => const NotificationRegisterPushPlatform.knownValue(
        data: KnownNotificationRegisterPushPlatform.android,
      ),
      NotificationPushPlatform.ios => const NotificationRegisterPushPlatform.knownValue(
        data: KnownNotificationRegisterPushPlatform.ios,
      ),
    };
  }

  NotificationUnregisterPushPlatform _unregisterPlatformFor(NotificationPushPlatform platform) {
    return switch (platform) {
      NotificationPushPlatform.android => const NotificationUnregisterPushPlatform.knownValue(
        data: KnownNotificationUnregisterPushPlatform.android,
      ),
      NotificationPushPlatform.ios => const NotificationUnregisterPushPlatform.knownValue(
        data: KnownNotificationUnregisterPushPlatform.ios,
      ),
    };
  }

  bool _matchesRecordUri(Notification notification, String recordUri) {
    final notificationUri = notification.uri.toString();
    final reasonSubjectUri = notification.reasonSubject?.toString();
    if (notificationUri == recordUri || reasonSubjectUri == recordUri) {
      return true;
    }

    final embeddedUri = notification.record['uri'];
    if (embeddedUri is String && embeddedUri == recordUri) {
      return true;
    }

    return false;
  }

  String _reasonName(Notification notification) {
    final known = notification.reason.knownValue;
    if (known != null) {
      return known.value;
    }
    final unknown = notification.reason.unknown;
    if (unknown != null) {
      return unknown;
    }
    return 'unknown';
  }

  bool _reasonMatches(Notification notification, String reason) {
    final normalizedPayloadReason = reason.trim();
    if (normalizedPayloadReason.isEmpty) {
      return true;
    }

    final notificationReason = _reasonName(notification);
    if (notificationReason == normalizedPayloadReason) {
      return true;
    }

    final familyReason = switch (notificationReason) {
      'like-via-repost' => 'like',
      'repost-via-repost' => 'repost',
      _ => notificationReason,
    };

    return familyReason == normalizedPayloadReason;
  }
}

class NotificationListResult {
  NotificationListResult({required this.notifications, this.cursor, this.seenAt});

  final List<Notification> notifications;
  final String? cursor;
  final DateTime? seenAt;
}

enum NotificationPushPlatform { android, ios }
