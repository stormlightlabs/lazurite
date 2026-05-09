import 'package:poptart_core/poptart_core.dart';
import 'package:poptart_lex/app/bsky/notification/list_notifications.dart' as bsky;
import 'dart:ui';

import 'package:lazurite/core/l10n/app_localizations.dart';
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

  static final AppLocalizations _fallbackL10n = lookupAppLocalizations(const Locale('en'));

  static String summaryTextForReason(bsky.NotificationReason reason, {AppLocalizations? l10n}) {
    final strings = l10n ?? _fallbackL10n;
    if (!reason.isKnownValue) {
      return strings.messageNotificationInteracted;
    }

    switch (reason.knownValue) {
      case bsky.KnownNotificationReason.like:
        return strings.messageNotificationLike;
      case bsky.KnownNotificationReason.repost:
        return strings.messageNotificationRepost;
      case bsky.KnownNotificationReason.likeViaRepost:
        return strings.messageNotificationLikeViaRepost;
      case bsky.KnownNotificationReason.repostViaRepost:
        return strings.messageNotificationRepostViaRepost;
      case bsky.KnownNotificationReason.follow:
        return strings.messageNotificationFollow;
      case bsky.KnownNotificationReason.mention:
        return strings.messageNotificationMention;
      case bsky.KnownNotificationReason.reply:
        return strings.messageNotificationReply;
      case bsky.KnownNotificationReason.quote:
        return strings.messageNotificationQuote;
      case bsky.KnownNotificationReason.starterpackJoined:
        return strings.messageNotificationStarterPackJoined;
      case bsky.KnownNotificationReason.verified:
        return strings.messageNotificationVerified;
      case bsky.KnownNotificationReason.unverified:
        return strings.messageNotificationUnverified;
      case bsky.KnownNotificationReason.subscribedPost:
        return strings.messageNotificationSubscribedPost;
      case bsky.KnownNotificationReason.contactMatch:
        return strings.messageNotificationContactMatch;
      default:
        return strings.messageNotificationInteracted;
    }
  }

  static String localNotificationBodyForReason(bsky.NotificationReason reason, {AppLocalizations? l10n}) {
    final strings = l10n ?? _fallbackL10n;
    final summary = summaryTextForReason(reason, l10n: strings);
    return summary == strings.messageNotificationInteracted ? strings.messageLocalNotificationFallbackBody : summary;
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
