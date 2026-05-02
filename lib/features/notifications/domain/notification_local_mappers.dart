import 'dart:convert';

import 'package:bluesky/app_bsky_notification_listnotifications.dart';
import 'package:crypto/crypto.dart';
import 'package:lazurite/features/notifications/domain/notification_local_models.dart';

class NotificationPayloadCodec {
  static String encode(NotificationDeepLink deepLink) {
    return jsonEncode(<String, String>{'route': deepLink.route, 'mode': deepLink.navigationMode.name});
  }

  static NotificationDeepLink? decode(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final route = decoded['route'];
      if (route is! String || !route.startsWith('/')) {
        return null;
      }

      final mode = decoded['mode'];
      final navigationMode = mode == NotificationTapNavigationMode.go.name
          ? NotificationTapNavigationMode.go
          : NotificationTapNavigationMode.push;

      return NotificationDeepLink(route: route, navigationMode: navigationMode);
    } catch (_) {
      return null;
    }
  }
}

class NotificationLocalMapper {
  static LocalNotificationRequest? requestFromNotification(Notification notification) {
    if (notification.isRead) {
      return null;
    }

    final deepLink = _deepLinkForNotification(notification);
    if (deepLink == null) {
      return null;
    }

    return LocalNotificationRequest(
      notificationId: _stableNotificationId(notification.uri.toString()),
      title: _titleForNotification(notification),
      body: _bodyForReason(notification.reason),
      reasonFamily: _reasonFamilyForReason(notification.reason),
      deepLink: deepLink,
    );
  }

  static NotificationReasonFamily _reasonFamilyForReason(NotificationReason reason) {
    final known = reason.knownValue;
    if (known == null) {
      return NotificationReasonFamily.misc;
    }

    switch (known) {
      case KnownNotificationReason.mention:
        return NotificationReasonFamily.mentions;
      case KnownNotificationReason.reply:
      case KnownNotificationReason.quote:
        return NotificationReasonFamily.replies;
      case KnownNotificationReason.follow:
        return NotificationReasonFamily.follows;
      case KnownNotificationReason.like:
      case KnownNotificationReason.repost:
        return NotificationReasonFamily.likes;
      default:
        return NotificationReasonFamily.misc;
    }
  }

  static NotificationDeepLink? _deepLinkForNotification(Notification notification) {
    final knownReason = notification.reason.knownValue;

    if (knownReason == KnownNotificationReason.follow) {
      final actor = notification.author.did.trim();
      if (actor.isEmpty) {
        return null;
      }
      return NotificationDeepLink(
        route: '/profile/${Uri.encodeComponent(actor)}',
        navigationMode: NotificationTapNavigationMode.go,
      );
    }

    final useReasonSubject =
        knownReason == KnownNotificationReason.like || knownReason == KnownNotificationReason.repost;
    final targetUri = (useReasonSubject ? notification.reasonSubject : null) ?? notification.uri;

    return NotificationDeepLink(
      route: '/post?uri=${Uri.encodeQueryComponent(targetUri.toString())}',
      navigationMode: NotificationTapNavigationMode.push,
    );
  }

  static String _titleForNotification(Notification notification) {
    final displayName = notification.author.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    final handle = notification.author.handle.trim();
    return handle.isEmpty ? 'New notification' : handle;
  }

  static String _bodyForReason(NotificationReason reason) {
    final known = reason.knownValue;
    switch (known) {
      case KnownNotificationReason.like:
        return 'liked your post';
      case KnownNotificationReason.repost:
        return 'reposted your post';
      case KnownNotificationReason.reply:
        return 'replied to your post';
      case KnownNotificationReason.follow:
        return 'followed you';
      case KnownNotificationReason.mention:
        return 'mentioned you';
      case KnownNotificationReason.quote:
        return 'quoted your post';
      default:
        return 'sent a notification';
    }
  }

  static int _stableNotificationId(String value) {
    final digest = sha1.convert(utf8.encode(value)).bytes;
    final id = (digest[0] << 24) | (digest[1] << 16) | (digest[2] << 8) | digest[3];
    return id & 0x7fffffff;
  }
}

extension NotificationReasonFamilyChannels on NotificationReasonFamily {
  String get androidChannelId {
    switch (this) {
      case NotificationReasonFamily.mentions:
        return 'mentions';
      case NotificationReasonFamily.replies:
        return 'replies';
      case NotificationReasonFamily.follows:
        return 'follows';
      case NotificationReasonFamily.likes:
        return 'likes';
      case NotificationReasonFamily.misc:
        return 'misc';
    }
  }

  String get androidChannelName {
    switch (this) {
      case NotificationReasonFamily.mentions:
        return 'Mentions';
      case NotificationReasonFamily.replies:
        return 'Replies';
      case NotificationReasonFamily.follows:
        return 'Follows';
      case NotificationReasonFamily.likes:
        return 'Likes';
      case NotificationReasonFamily.misc:
        return 'Other';
    }
  }

  String get iosCategoryIdentifier {
    switch (this) {
      case NotificationReasonFamily.mentions:
        return 'mentions';
      case NotificationReasonFamily.replies:
        return 'replies';
      case NotificationReasonFamily.follows:
        return 'follows';
      case NotificationReasonFamily.likes:
        return 'likes';
      case NotificationReasonFamily.misc:
        return 'misc';
    }
  }
}
