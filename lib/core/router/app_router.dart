import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bluesky/bluesky.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/features/auth/presentation/login_screen.dart';
import 'package:lazurite/features/compose/bloc/compose_bloc.dart';
import 'package:lazurite/features/compose/presentation/compose_route_args.dart';
import 'package:lazurite/features/compose/presentation/compose_screen.dart';
import 'package:lazurite/features/devtools/presentation/dev_tools_screen.dart';
import 'package:lazurite/features/feed/presentation/feed_management_screen.dart';
import 'package:lazurite/features/feed/presentation/home_feed_screen.dart';
import 'package:lazurite/features/feed/presentation/post_thread_screen.dart';
import 'package:lazurite/features/logs/presentation/logs_screen.dart';
import 'package:lazurite/features/notifications/bloc/notification_bloc.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/notifications/presentation/notifications_screen.dart';
import 'package:lazurite/features/profile/presentation/profile_screen.dart';
import 'package:lazurite/features/feed/presentation/saved_posts_screen.dart';
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
  final GlobalKey<NavigatorState> _notificationsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'notifications');
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
      GoRoute(
        path: '/compose',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final args = state.extra as ComposeRouteArgs?;
          return BlocProvider(
            create: (_) => ComposeBloc(
              composeRepository: ComposeRepository(bluesky: context.read<Bluesky>()),
              database: context.read<AppDatabase>(),
              accountDid: context.read<String>(),
            ),
            child: ComposeScreen(
              replyParentUri: args?.replyParentUri,
              replyParentCid: args?.replyParentCid,
              replyRootUri: args?.replyRootUri,
              replyRootCid: args?.replyRootCid,
              replyAuthorHandle: args?.replyAuthorHandle,
              quoteUri: args?.quoteUri,
              quoteCid: args?.quoteCid,
              quoteAuthorHandle: args?.quoteAuthorHandle,
              draftId: args?.draftId,
            ),
          );
        },
      ),
      GoRoute(
        path: '/post',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final uri = state.uri.queryParameters['uri'] ?? '';
          return PostThreadScreen(postUri: Uri.decodeComponent(uri));
        },
      ),
      GoRoute(
        path: '/saved',
        builder: (context, state) => SavedPostsScreen(accountDid: context.read<String>()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          UnreadCountCubit? existingCubit;
          try {
            existingCubit = context.read<UnreadCountCubit>();
          } catch (_) {
            log.d('UnreadCountCubit not found, creating new one');
          }

          if (existingCubit != null) {
            return AppShell(navigationShell: navigationShell);
          }

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) =>
                    UnreadCountCubit(notificationRepository: NotificationRepository(bluesky: context.read<Bluesky>())),
              ),
            ],
            child: AppShell(navigationShell: navigationShell),
          );
        },
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
            navigatorKey: _notificationsNavigatorKey,
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => BlocProvider(
                  create: (_) => NotificationBloc(
                    notificationRepository: NotificationRepository(bluesky: context.read<Bluesky>()),
                  ),
                  child: const NotificationsScreen(),
                ),
              ),
            ],
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
