import 'package:bluesky/app_bsky_notification_listnotifications.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/shared/presentation/helpers/notification_icon_mapper.dart';

void main() {
  group('NotificationIconMapper', () {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0));

    test('maps like reason to favorite icon and error color', () {
      final style = NotificationIconMapper.map(
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.like),
        colorScheme: colorScheme,
      );

      expect(style.icon, Icons.favorite);
      expect(style.iconColor, colorScheme.error);
    });

    test('maps follow reason to person_add icon and primary color', () {
      final style = NotificationIconMapper.map(
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.follow),
        colorScheme: colorScheme,
      );

      expect(style.icon, Icons.person_add);
      expect(style.iconColor, colorScheme.primary);
    });

    test('maps like-via-repost reason to favorite icon and error color', () {
      final style = NotificationIconMapper.map(
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.likeViaRepost),
        colorScheme: colorScheme,
      );

      expect(style.icon, Icons.favorite);
      expect(style.iconColor, colorScheme.error);
    });

    test('maps verified reason to verified icon and primary color', () {
      final style = NotificationIconMapper.map(
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.verified),
        colorScheme: colorScheme,
      );

      expect(style.icon, Icons.verified);
      expect(style.iconColor, colorScheme.primary);
    });

    test('maps quote reason to quote icon and purple color', () {
      final style = NotificationIconMapper.map(
        reason: const bsky.NotificationReason.knownValue(data: bsky.KnownNotificationReason.quote),
        colorScheme: colorScheme,
      );

      expect(style.icon, Icons.format_quote);
      expect(style.iconColor, Colors.purple);
    });
  });
}
