import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/presentation/home_screen.dart';
import 'package:lazurite/features/auth/presentation/login_screen.dart';
import 'package:lazurite/features/logs/presentation/logs_screen.dart';
import 'package:lazurite/features/profile/presentation/profile_screen.dart';
import 'package:lazurite/features/settings/presentation/settings_screen.dart';

class AppRouter {
  AppRouter({required this.authBloc, this.navigatorObserver});
  final AuthBloc authBloc;
  final NavigatorObserver? navigatorObserver;

  GoRouter get router => GoRouter(
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
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => ProfileScreen(actor: state.uri.queryParameters['actor']),
      ),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/logs', builder: (context, state) => const LogsScreen()),
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
