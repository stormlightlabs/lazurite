import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_notification_listnotifications.dart' as bsky;
import 'package:lazurite/features/notifications/domain/notification_local_models.dart';

abstract final class NotificationReasonUtils {
  static bool isProfileNavigationReason(bsky.NotificationReason reason) {
    if (!reason.isKnownValue) {
      return false;
    }

    switch (reason.knownValue) {
      case bsky.KnownNotificationReason.follow:
      case bsky.KnownNotificationReason.verified:
      case bsky.KnownNotificationReason.unverified:
      case bsky.KnownNotificationReason.contactMatch:
        return true;
      default:
        return false;
    }
  }

  static bool isEngagementReason(bsky.NotificationReason reason) {
    if (!reason.isKnownValue) {
      return false;
    }

    switch (reason.knownValue) {
      case bsky.KnownNotificationReason.like:
      case bsky.KnownNotificationReason.repost:
      case bsky.KnownNotificationReason.likeViaRepost:
      case bsky.KnownNotificationReason.repostViaRepost:
        return true;
      default:
        return false;
    }
  }

  static String summaryTextForReason(bsky.NotificationReason reason) {
    if (!reason.isKnownValue) {
      return 'interacted with you';
    }

    switch (reason.knownValue) {
      case bsky.KnownNotificationReason.like:
        return 'liked your post';
      case bsky.KnownNotificationReason.repost:
        return 'reposted your post';
      case bsky.KnownNotificationReason.likeViaRepost:
        return 'liked your repost';
      case bsky.KnownNotificationReason.repostViaRepost:
        return 'reposted your repost';
      case bsky.KnownNotificationReason.follow:
        return 'followed you';
      case bsky.KnownNotificationReason.mention:
        return 'mentioned you';
      case bsky.KnownNotificationReason.reply:
        return 'replied to your post';
      case bsky.KnownNotificationReason.quote:
        return 'quoted your post';
      case bsky.KnownNotificationReason.starterpackJoined:
        return 'joined via your starter pack';
      case bsky.KnownNotificationReason.verified:
        return 'verified your account';
      case bsky.KnownNotificationReason.unverified:
        return 'removed your verification';
      case bsky.KnownNotificationReason.subscribedPost:
        return 'posted a new update';
      case bsky.KnownNotificationReason.contactMatch:
        return 'joined from your contacts';
      default:
        return 'interacted with you';
    }
  }

  static String localNotificationBodyForReason(bsky.NotificationReason reason) {
    final summary = summaryTextForReason(reason);
    return summary == 'interacted with you' ? 'sent a notification' : summary;
  }

  static NotificationReasonFamily reasonFamilyForReason(bsky.NotificationReason reason) {
    final known = reason.knownValue;
    if (known == null) {
      return NotificationReasonFamily.misc;
    }

    switch (known) {
      case bsky.KnownNotificationReason.mention:
        return NotificationReasonFamily.mentions;
      case bsky.KnownNotificationReason.reply:
      case bsky.KnownNotificationReason.quote:
      case bsky.KnownNotificationReason.subscribedPost:
        return NotificationReasonFamily.replies;
      case bsky.KnownNotificationReason.follow:
      case bsky.KnownNotificationReason.contactMatch:
      case bsky.KnownNotificationReason.starterpackJoined:
        return NotificationReasonFamily.follows;
      case bsky.KnownNotificationReason.like:
      case bsky.KnownNotificationReason.repost:
      case bsky.KnownNotificationReason.likeViaRepost:
      case bsky.KnownNotificationReason.repostViaRepost:
        return NotificationReasonFamily.likes;
      case bsky.KnownNotificationReason.verified:
      case bsky.KnownNotificationReason.unverified:
        return NotificationReasonFamily.misc;
    }
  }

  static NotificationDeepLink? deepLinkForNotification(bsky.Notification notification) {
    if (notification.reason.knownValue == bsky.KnownNotificationReason.starterpackJoined) {
      final starterPackUri = notification.reasonSubject ?? _extractSubjectUri(notification.record);
      if (starterPackUri != null) {
        return NotificationDeepLink(
          route: '/starter-pack?uri=${Uri.encodeQueryComponent(starterPackUri.toString())}',
          navigationMode: NotificationTapNavigationMode.push,
        );
      }
    }

    if (isProfileNavigationReason(notification.reason)) {
      final actor = notification.author.did.trim();
      if (actor.isEmpty) {
        return null;
      }
      return NotificationDeepLink(
        route: '/profile/${Uri.encodeComponent(actor)}',
        navigationMode: NotificationTapNavigationMode.go,
      );
    }

    final targetUri = deepLinkTargetUri(notification);
    return NotificationDeepLink(
      route: '/post?uri=${Uri.encodeQueryComponent(targetUri.toString())}',
      navigationMode: NotificationTapNavigationMode.push,
    );
  }

  static AtUri deepLinkTargetUri(bsky.Notification notification) {
    if (!isEngagementReason(notification.reason)) {
      return notification.uri;
    }

    final reasonSubject = notification.reasonSubject;
    if (_isPostUri(reasonSubject)) {
      return reasonSubject!;
    }

    final recordSubject = _extractSubjectUri(notification.record);
    if (_isPostUri(recordSubject)) {
      return recordSubject!;
    }

    return reasonSubject ?? recordSubject ?? notification.uri;
  }

  static bool _isPostUri(AtUri? uri) => uri?.collection.toString() == 'app.bsky.feed.post';

  static AtUri? _extractSubjectUri(Map<String, dynamic> record) {
    final rawSubject = record['subject'];
    final uriValue = switch (rawSubject) {
      final Map<String, dynamic> subjectMap => subjectMap['uri'],
      final String value => value,
      _ => null,
    };

    if (uriValue is! String || uriValue.trim().isEmpty) {
      return null;
    }

    try {
      return AtUri.parse(uriValue.trim());
    } catch (_) {
      return null;
    }
  }
}
