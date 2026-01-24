import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lazurite/src/core/domain/author.dart';

import 'notification.dart';
import 'notification_type.dart';

part 'grouped_notification.freezed.dart';

/// Represents a group of similar notifications for compact display.
@freezed
abstract class GroupedNotification with _$GroupedNotification {
  const factory GroupedNotification({
    /// The notification type shared by all in this group.
    required NotificationType type,

    /// Actors who triggered notifications in this group.
    required List<Author> actors,

    /// URI of the subject (post/profile) this group is about.
    String? subjectUri,

    /// Timestamp of the most recent notification in the group.
    required DateTime mostRecentTimestamp,

    /// Whether any notification in this group is unread.
    required bool hasUnread,

    /// Total number of notifications in this group.
    required int totalCount,

    /// All underlying notifications in this group.
    required List<AppNotification> notifications,
  }) = _GroupedNotification;

  const GroupedNotification._();

  /// Maximum number of actors to display inline.
  static const int maxDisplayActors = 5;

  /// Maximum time difference for grouping (24 hours).
  static const Duration groupingWindow = Duration(hours: 24);

  /// Returns a formatted display text for this group.
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
    final uniqueActors = <Author>[];
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
