import 'package:bluesky_poptart/app/bsky/notification/list_notifications.dart' as bsky;
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/notifications/domain/notification_reason_utils.dart';

void main() {
  group('NotificationReasonUtils', () {
    test('provides explicit summary copy for all known notification reasons', () {
      final expectedTextByReason = <bsky.KnownNotificationReason, String>{
        bsky.KnownNotificationReason.like: 'liked your post',
        bsky.KnownNotificationReason.repost: 'reposted your post',
        bsky.KnownNotificationReason.follow: 'followed you',
        bsky.KnownNotificationReason.mention: 'mentioned you',
        bsky.KnownNotificationReason.reply: 'replied to your post',
        bsky.KnownNotificationReason.quote: 'quoted your post',
        bsky.KnownNotificationReason.starterpackJoined: 'joined via your starter pack',
        bsky.KnownNotificationReason.verified: 'verified your account',
        bsky.KnownNotificationReason.unverified: 'removed your verification',
        bsky.KnownNotificationReason.likeViaRepost: 'liked your repost',
        bsky.KnownNotificationReason.repostViaRepost: 'reposted your repost',
        bsky.KnownNotificationReason.subscribedPost: 'posted a new update',
        bsky.KnownNotificationReason.contactMatch: 'joined from your contacts',
      };

      for (final entry in expectedTextByReason.entries) {
        final text = NotificationReasonUtils.summaryTextForReason(bsky.NotificationReason.knownValue(data: entry.key));
        expect(text, entry.value, reason: 'Unexpected summary for ${entry.key.value}');
      }
    });
  });
}
