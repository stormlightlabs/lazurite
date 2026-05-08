import 'dart:convert';
import 'dart:ui';

import 'package:bluesky/app_bsky_notification_listnotifications.dart';
import 'package:crypto/crypto.dart';
import 'package:lazurite/core/l10n/app_localizations.dart';
import 'package:lazurite/features/notifications/domain/notification_local_models.dart';
import 'package:lazurite/features/notifications/domain/notification_reason_utils.dart';

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
  static final AppLocalizations _fallbackL10n = lookupAppLocalizations(const Locale('en'));

  static LocalNotificationRequest? requestFromNotification(Notification notification) {
    if (notification.isRead) {
      return null;
    }

    final deepLink = NotificationReasonUtils.deepLinkForNotification(notification);
    if (deepLink == null) {
      return null;
    }

    return LocalNotificationRequest(
      notificationId: _stableNotificationId(notification.uri.toString()),
      title: _titleForNotification(notification),
      body: NotificationReasonUtils.localNotificationBodyForReason(notification.reason, l10n: _fallbackL10n),
      reasonFamily: NotificationReasonUtils.reasonFamilyForReason(notification.reason),
      deepLink: deepLink,
    );
  }

  static String _titleForNotification(Notification notification) {
    final displayName = notification.author.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    final handle = notification.author.handle.trim();
    return handle.isEmpty ? _fallbackL10n.messageNewNotification : handle;
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
        return NotificationLocalMapper._fallbackL10n.labelMentions;
      case NotificationReasonFamily.replies:
        return NotificationLocalMapper._fallbackL10n.labelReplies;
      case NotificationReasonFamily.follows:
        return NotificationLocalMapper._fallbackL10n.labelFollows;
      case NotificationReasonFamily.likes:
        return NotificationLocalMapper._fallbackL10n.labelLikes;
      case NotificationReasonFamily.misc:
        return NotificationLocalMapper._fallbackL10n.labelOther;
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
