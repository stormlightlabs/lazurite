import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/shared/presentation/helpers/navigation_helpers.dart';

void main() {
  group('navigation_helpers', () {
    testWidgets('navigateToProfile pushes encoded profile route', (tester) async {
      const actorDid = 'did:plc:alice.test';
      String? pushedRoute;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: FilledButton(onPressed: () => navigateToProfile(context, actorDid), child: const Text('go')),
              ),
            ),
          ),
          GoRoute(
            path: '/profile/view',
            builder: (context, state) {
              pushedRoute = state.uri.toString();
              return const Scaffold(body: Text('profile'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(pushedRoute, isNotNull);
      expect(Uri.parse(pushedRoute!).path, '/profile/view');
      expect(Uri.parse(pushedRoute!).queryParameters['actor'], actorDid);
    });

    testWidgets('navigateToProfile uses go from non-shell routes like /post', (tester) async {
      const actorDid = 'did:plc:alice.test';
      String? activePath;

      final router = GoRouter(
        initialLocation: '/post',
        routes: [
          GoRoute(
            path: '/post',
            builder: (context, state) => Scaffold(
              body: Center(
                child: FilledButton(onPressed: () => navigateToProfile(context, actorDid), child: const Text('go')),
              ),
            ),
          ),
          GoRoute(
            path: '/profile/view',
            builder: (context, state) {
              activePath = state.uri.path;
              return const Scaffold(body: Text('profile'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(activePath, '/profile/view');
      expect(router.canPop(), isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('navigateToPost pushes encoded post route', (tester) async {
      const postUri = 'at://did:plc:alice/app.bsky.feed.post/123';
      String? pushedRoute;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: FilledButton(onPressed: () => navigateToPost(context, postUri), child: const Text('go')),
              ),
            ),
          ),
          GoRoute(
            path: '/post',
            builder: (context, state) {
              pushedRoute = state.uri.toString();
              return const Scaffold(body: Text('post'));
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(pushedRoute, isNotNull);
      expect(Uri.parse(pushedRoute!).path, '/post');
      expect(Uri.parse(pushedRoute!).queryParameters['uri'], postUri);
    });

    testWidgets('returns null and does not throw without a router', (tester) async {
      Future<Object?>? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                result = navigateToProfile(context, 'did:plc:no-router');
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(result, isNull);
      expect(tester.takeException(), isNull);
    });
  });
}
