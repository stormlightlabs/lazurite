import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'widget_harness.dart';

class TestRouterHarness {
  TestRouterHarness({required Widget home, String initialLocation = '/', List<GoRoute> routes = const []})
    : router = GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(path: '/', builder: (context, state) => home),
          ...routes,
        ],
      );

  TestRouterHarness.withRoutes({required List<RouteBase> routes, String initialLocation = '/'})
    : router = GoRouter(initialLocation: initialLocation, routes: routes);

  TestRouterHarness._(this.router);

  factory TestRouterHarness.capturing({
    required Widget home,
    required String targetPath,
    String initialLocation = '/',
    Widget target = const Scaffold(body: SizedBox.shrink()),
  }) {
    late final TestRouterHarness harness;
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/', builder: (context, state) => home),
        GoRoute(
          path: targetPath,
          builder: (context, state) {
            harness.lastUri = state.uri;
            return target;
          },
        ),
      ],
    );
    harness = TestRouterHarness._(router);
    return harness;
  }

  final GoRouter router;
  Uri? lastUri;

  String? get lastRoute => lastUri?.toString();
  String? get lastPath => lastUri?.path;

  GoRoute captureRoute({required String path, Widget child = const Scaffold(body: SizedBox.shrink())}) => GoRoute(
    path: path,
    builder: (context, state) {
      lastUri = state.uri;
      return child;
    },
  );

  Future<void> pump(WidgetTester tester, {bool settle = true}) => pumpTestRouterApp(tester, router, settle: settle);

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
}

GoRoute capturedRoute({
  required String path,
  required void Function(Uri uri) onRoute,
  Widget child = const Scaffold(body: SizedBox.shrink()),
}) => GoRoute(
  path: path,
  builder: (context, state) {
    onRoute(state.uri);
    return child;
  },
);

GoRoute profileCaptureRoute({
  required void Function(Uri uri) onRoute,
  Widget child = const Scaffold(body: Text('profile')),
}) => capturedRoute(path: '/profile/:actor', onRoute: onRoute, child: child);

GoRoute postCaptureRoute({
  required void Function(Uri uri) onRoute,
  Widget child = const Scaffold(body: Text('post')),
}) => capturedRoute(path: '/post', onRoute: onRoute, child: child);

GoRoute loginRoute({Widget child = const Scaffold(body: Text('login'))}) => GoRoute(
  path: '/login',
  builder: (context, state) => child,
);
