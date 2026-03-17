import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/features/auth/presentation/login_screen.dart';
import 'package:lazurite/features/devtools/presentation/dev_tools_screen.dart';
import 'package:lazurite/features/feed/presentation/feed_management_screen.dart';
import 'package:lazurite/features/feed/presentation/home_feed_screen.dart';
import 'package:lazurite/features/logs/presentation/logs_screen.dart';
import 'package:lazurite/features/profile/presentation/profile_screen.dart';
import 'package:lazurite/features/search/presentation/search_screen.dart';
import 'package:lazurite/features/settings/presentation/about_screen.dart';
import 'package:lazurite/features/settings/presentation/settings_screen.dart';

class AppRouter {
  AppRouter({required this.authBloc, this.navigatorObserver});
  final AuthBloc authBloc;
  final NavigatorObserver? navigatorObserver;
  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  final GlobalKey<NavigatorState> _searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
  final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');
  final GlobalKey<NavigatorState> _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

  GoRouter get router => GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    observers: navigatorObserver != null ? [navigatorObserver!] : null,
    redirect: (context, state) {
      final isAuthenticated = authBloc.state.isAuthenticated;
      final isLoggingIn = state.uri.path == '/login';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeFeedScreen(),
                routes: [GoRoute(path: 'feeds', builder: (context, state) => const FeedManagementScreen())],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: [GoRoute(path: '/search', builder: (context, state) => const SearchScreen())],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'view',
                    builder: (context, state) =>
                        ProfileScreen(actor: state.uri.queryParameters['actor'], showBackButton: true),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(path: 'about', builder: (context, state) => const AboutScreen()),
                  GoRoute(path: 'logs', builder: (context, state) => const LogsScreen()),
                  GoRoute(path: 'devtools', builder: (context, state) => const DevToolsScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((state) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
