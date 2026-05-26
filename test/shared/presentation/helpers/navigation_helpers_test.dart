import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';

import '../../../helpers/router_harness.dart';
import '../../../helpers/widget_harness.dart';

Widget _buttonRoute(VoidCallback onPressed, String label) => Scaffold(
  body: Center(
    child: FilledButton(onPressed: onPressed, child: Text(label)),
  ),
);

void main() {
  group('navigation_helpers', () {
    testWidgets('navigateToProfile pushes encoded profile route', (tester) async {
      const actorDid = 'did:plc:alice.test';
      Uri? pushedRoute;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => _buttonRoute(() => navigateToProfile(context, actorDid), 'go'),
          ),
          profileCaptureRoute(onRoute: (uri) => pushedRoute = uri),
        ],
      );

      await pumpTestRouterApp(tester, router);
      await tapAndSettle(tester, find.text('go'));

      expect(pushedRoute, isNotNull);
      expect(pushedRoute!.path, '/profile/${Uri.encodeComponent(actorDid)}');
      expect(router.canPop(), isTrue);
    });

    testWidgets('navigateToProfile pushes from non-shell routes like /post', (tester) async {
      const actorDid = 'did:plc:alice.test';
      Uri? activeRoute;
      final router = GoRouter(
        initialLocation: '/post',
        routes: [
          GoRoute(
            path: '/post',
            builder: (context, state) => _buttonRoute(() => navigateToProfile(context, actorDid), 'go'),
          ),
          profileCaptureRoute(onRoute: (uri) => activeRoute = uri),
        ],
      );

      await pumpTestRouterApp(tester, router);
      await tapAndSettle(tester, find.text('go'));

      expect(activeRoute!.path, '/profile/${Uri.encodeComponent(actorDid)}');
      expect(router.canPop(), isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('navigateToProfile routes the current user to the profile tab root', (tester) async {
      const actorDid = 'did:plc:me.test';
      Uri? activeRoute;
      final router = GoRouter(
        initialLocation: '/post',
        routes: [
          GoRoute(
            path: '/post',
            builder: (context, state) => _buttonRoute(() => navigateToProfile(context, actorDid), 'go'),
          ),
          capturedRoute(
            path: '/profile/me',
            onRoute: (uri) => activeRoute = uri,
            child: const Scaffold(body: Text('me')),
          ),
        ],
      );

      await tester.pumpWidget(RepositoryProvider<String>.value(value: actorDid, child: testRouterApp(router)));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.text('go'));

      expect(activeRoute!.path, '/profile/me');
      expect(router.canPop(), isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('navigateToPost pushes encoded post route', (tester) async {
      const postUri = 'at://did:plc:alice/app.bsky.feed.post/123';
      Uri? pushedRoute;
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (context, state) => _buttonRoute(() => navigateToPost(context, postUri), 'go')),
          postCaptureRoute(onRoute: (uri) => pushedRoute = uri),
        ],
      );

      await pumpTestRouterApp(tester, router);
      await tapAndSettle(tester, find.text('go'));

      expect(pushedRoute, isNotNull);
      expect(pushedRoute!.path, '/post');
      expect(pushedRoute!.queryParameters['uri'], postUri);
    });

    testWidgets('returns null and does not throw without a router', (tester) async {
      Future<Object?>? result;

      await pumpTestHomeApp(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) {
              result = navigateToProfile(context, 'did:plc:no-router');
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(result, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('navigateToSettings pushes settings when a router is available', (tester) async {
      Uri? activeRoute;
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (context, state) => _buttonRoute(() => navigateToSettings(context), 'settings')),
          capturedRoute(
            path: '/settings',
            onRoute: (uri) => activeRoute = uri,
            child: const Scaffold(body: Text('settings screen')),
          ),
        ],
      );

      await pumpTestRouterApp(tester, router);
      await tapAndSettle(tester, find.text('settings'));
      expect(activeRoute!.path, '/settings');
      expect(router.canPop(), isTrue);
    });
  });
}
