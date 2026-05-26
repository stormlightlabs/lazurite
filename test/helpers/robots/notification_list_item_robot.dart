import 'package:bluesky_poptart/app/bsky/notification/list_notifications.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/notifications/presentation/widgets/notification_list_item.dart';
import 'package:poptart_core/poptart_core.dart';

import '../router_harness.dart';

export '../fixtures/notification.dart';

class NotificationListItemRobot {
  NotificationListItemRobot(this.tester);

  final WidgetTester tester;
  TestRouterHarness? _harness;

  Uri get lastRoute {
    final route = _harness?.lastUri;
    expect(route, isNotNull);
    return route!;
  }

  Future<void> pump({
    required bsky.Notification notification,
    required String targetPath,
    Widget target = const Scaffold(body: SizedBox.shrink()),
  }) async {
    _harness = TestRouterHarness.capturing(
      home: Scaffold(body: NotificationListItem(notification: notification)),
      targetPath: targetPath,
      target: target,
    );
    await _harness!.pump(tester);
  }

  Future<void> tapItem() async {
    await _harness!.tapAndSettle(tester, find.byType(NotificationListItem));
  }

  void expectProfileRoute(String actor) {
    expect(lastRoute.path, '/profile/${Uri.encodeComponent(actor)}');
  }

  void expectPostRoute(AtUri postUri) {
    expect(lastRoute.path, '/post');
    expect(Uri.decodeComponent(lastRoute.queryParameters['uri']!), postUri.toString());
  }

  void expectStarterPackRoute(AtUri starterPackUri) {
    expect(lastRoute.path, '/starter-pack');
    expect(Uri.decodeComponent(lastRoute.queryParameters['uri']!), starterPackUri.toString());
  }
}
