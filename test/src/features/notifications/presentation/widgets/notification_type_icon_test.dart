import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/notifications/domain/notification_type.dart';
import 'package:lazurite/src/features/notifications/presentation/widgets/notification_type_icon.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('NotificationTypeIcon', () {
    testWidgets('displays heart icon for like', (tester) async {
      await tester.pumpApp(const NotificationTypeIcon(type: NotificationType.like));

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('displays repeat icon for repost', (tester) async {
      await tester.pumpApp(const NotificationTypeIcon(type: NotificationType.repost));

      expect(find.byIcon(Icons.repeat), findsOneWidget);
    });

    testWidgets('displays person_add icon for follow', (tester) async {
      await tester.pumpApp(const NotificationTypeIcon(type: NotificationType.follow));

      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('displays alternate_email icon for mention', (tester) async {
      await tester.pumpApp(const NotificationTypeIcon(type: NotificationType.mention));

      expect(find.byIcon(Icons.alternate_email), findsOneWidget);
    });

    testWidgets('displays reply icon for reply', (tester) async {
      await tester.pumpApp(const NotificationTypeIcon(type: NotificationType.reply));

      expect(find.byIcon(Icons.reply), findsOneWidget);
    });

    testWidgets('displays format_quote icon for quote', (tester) async {
      await tester.pumpApp(const NotificationTypeIcon(type: NotificationType.quote));

      expect(find.byIcon(Icons.format_quote), findsOneWidget);
    });

    testWidgets('displays group_add icon for starterpackJoined', (tester) async {
      await tester.pumpApp(const NotificationTypeIcon(type: NotificationType.starterpackJoined));

      expect(find.byIcon(Icons.group_add), findsOneWidget);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpApp(const NotificationTypeIcon(type: NotificationType.like, size: 32));

      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(icon.size, 32);
    });

    testWidgets('uses default size of 20', (tester) async {
      await tester.pumpApp(const NotificationTypeIcon(type: NotificationType.like));

      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(icon.size, 20);
    });
  });
}
