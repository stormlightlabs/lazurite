import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/app/theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Test helper extension for [WidgetTester].
extension PumpApp on WidgetTester {
  /// Pumps the app with the given widget wrapped in necessary providers.
  ///
  /// If [router] is provided, it will be used instead of creating a new one.
  /// If [overrides] is provided, they will be applied to the [ProviderScope].
  Future<void> pumpApp(
    Widget widget, {
    GoRouter? router,
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(theme: AppTheme.dark, home: widget),
      ),
    );
    await pump();
  }

  /// Pumps the app with a router for navigation testing.
  ///
  /// If [router] is provided, it will be used.
  /// Otherwise creates a router via [goRouterProvider].
  Future<void> pumpRouterApp({
    GoRouter? router,
    List<Override> overrides = const [],
    ThemeData? theme,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: [if (router != null) goRouterProvider.overrideWithValue(router), ...overrides],
        child: Consumer(
          builder: (context, ref, _) {
            final appRouter = ref.watch(goRouterProvider);
            return MaterialApp.router(theme: theme ?? AppTheme.dark, routerConfig: appRouter);
          },
        ),
      ),
    );
    await pumpAndSettle();
  }
}

/// Creates a simple GoRouter for testing individual screens.
GoRouter createTestRouter({required String initialLocation, required Widget child}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [GoRoute(path: initialLocation, builder: (_, _) => child)],
  );
}
