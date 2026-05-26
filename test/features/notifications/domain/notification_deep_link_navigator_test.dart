import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/notifications/domain/notification_deep_link_navigator.dart';
import 'package:lazurite/features/notifications/domain/notification_local_models.dart';

import '../../../helpers/widget_harness.dart';

void main() {
  testWidgets('go navigation opens profile route from notification deep link', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/profile/:actor',
          builder: (_, state) => Scaffold(body: Text('profile:${state.pathParameters['actor']}')),
        ),
      ],
    );

    await pumpTestRouterApp(tester, router);

    NotificationDeepLinkNavigator.navigate(
      router,
      const NotificationDeepLink(route: '/profile/did%3Aplc%3Aalice', navigationMode: NotificationTapNavigationMode.go),
    );
    await tester.pumpAndSettle();
    expect(find.text('profile:did:plc:alice'), findsOneWidget);
  });

  testWidgets('push navigation opens post route from notification deep link', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/post',
          builder: (_, state) => Scaffold(body: Text('post:${state.uri.queryParameters['uri']}')),
        ),
      ],
    );

    await pumpTestRouterApp(tester, router);
    NotificationDeepLinkNavigator.navigate(
      router,
      const NotificationDeepLink(
        route: '/post?uri=at%3A%2F%2Fdid%3Aplc%3Atest%2Fapp.bsky.feed.post%2F1',
        navigationMode: NotificationTapNavigationMode.push,
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('post:at://did:plc:test/app.bsky.feed.post/1'), findsOneWidget);
  });
}
