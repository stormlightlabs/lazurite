import '../../../infrastructure/db/app_database.dart';
import 'notification.dart';
import 'notification_type.dart';

/// Represents a group of similar notifications for compact display.
///
/// Groups notifications of the same type, on the same subject,
/// within a 24-hour window.
class GroupedNotification {
  GroupedNotification({
    required this.type,
    required this.actors,
    required this.subjectUri,
    required this.mostRecentTimestamp,
    required this.hasUnread,
    required this.totalCount,
    required this.notifications,
  });

  /// The notification type shared by all in this group.
  final NotificationType type;

  /// Actors who triggered notifications in this group.
  final List<Profile> actors;

  /// URI of the subject (post/profile) this group is about.
  final String? subjectUri;

  /// Timestamp of the most recent notification in the group.
  final DateTime mostRecentTimestamp;

  /// Whether any notification in this group is unread.
  final bool hasUnread;

  /// Total number of notifications in this group.
  final int totalCount;

  /// All underlying notifications in this group.
  final List<AppNotification> notifications;

  /// Maximum number of actors to display inline.
  static const int maxDisplayActors = 5;

  /// Maximum time difference for grouping (24 hours).
  static const Duration groupingWindow = Duration(hours: 24);

  /// Returns a formatted display text for this group.
  ///
  /// Examples:
  /// - Single actor: "Alice liked your post"
  /// - Two actors: "Alice and Bob liked your post"
  /// - Many actors: "Alice, Bob and 3 others liked your post"
  String get displayText {
    if (actors.isEmpty) return type.displayText;

    final names = actors.take(2).map((a) => a.displayName ?? a.handle).toList();
    final remaining = totalCount - names.length;

    if (totalCount == 1) {
      return '${names[0]} ${type.displayText}';
    } else if (totalCount == 2) {
      return '${names[0]} and ${names[1]} ${type.displayText}';
    } else {
      return '${names[0]}, ${names[1]} and $remaining others ${type.displayText}';
    }
  }

  /// Groups a list of notifications by type and subject within 24 hours.
  ///
  /// Returns a list of [GroupedNotification] sorted by most recent timestamp.
  static List<GroupedNotification> groupNotifications(List<AppNotification> notifications) {
    if (notifications.isEmpty) return [];

    final sorted = [...notifications]..sort((a, b) => b.indexedAt.compareTo(a.indexedAt));

    final groups = <GroupedNotification>[];
    var currentGroup = <AppNotification>[sorted.first];
    var currentType = sorted.first.type;
    var currentSubject = sorted.first.reasonSubjectUri;
    var groupStartTime = sorted.first.indexedAt;

    for (var i = 1; i < sorted.length; i++) {
      final notification = sorted[i];
      final timeDiff = groupStartTime.difference(notification.indexedAt);
      final sameType = notification.type == currentType;
      final sameSubject = notification.reasonSubjectUri == currentSubject;
      final withinWindow = timeDiff <= groupingWindow;

      if (sameType && sameSubject && withinWindow) {
        currentGroup.add(notification);
      } else {
        groups.add(_createGroup(currentGroup));
        currentGroup = [notification];
        currentType = notification.type;
        currentSubject = notification.reasonSubjectUri;
        groupStartTime = notification.indexedAt;
      }
    }

    if (currentGroup.isNotEmpty) {
      groups.add(_createGroup(currentGroup));
    }

    return groups;
  }

  static GroupedNotification _createGroup(List<AppNotification> notifications) {
    final seenDids = <String>{};
    final uniqueActors = <Profile>[];
    for (final n in notifications) {
      if (!seenDids.contains(n.actor.did)) {
        seenDids.add(n.actor.did);
        uniqueActors.add(n.actor);
      }
    }

    return GroupedNotification(
      type: notifications.first.type,
      actors: uniqueActors,
      subjectUri: notifications.first.reasonSubjectUri,
      mostRecentTimestamp: notifications.first.indexedAt,
      hasUnread: notifications.any((n) => !n.isRead),
      totalCount: uniqueActors.length,
      notifications: notifications,
    );
  }
}
