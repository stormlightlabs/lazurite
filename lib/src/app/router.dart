import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/core/widgets/tab_scaffold.dart';
import 'package:lazurite/src/features/dms/presentation/dms_screen.dart';
import 'package:lazurite/src/features/home/presentation/home_screen.dart';
import 'package:lazurite/src/features/login/presentation/login_screen.dart';
import 'package:lazurite/src/features/notifications/presentation/notifications_screen.dart';
import 'package:lazurite/src/features/profile/presentation/profile_screen.dart';
import 'package:lazurite/src/features/search/presentation/search_screen.dart';

/// Global navigator key for the root navigator.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Creates and configures the app router.
///
/// Uses [StatefulShellRoute.indexedStack] to preserve state across tabs.
GoRouter createRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return TabScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: AppRouteNames.home,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.thread,
                    name: '${AppRouteNames.home}_${AppRouteNames.thread}',
                    builder: (context, state) {
                      final postKey = state.pathParameters['postKey']!;
                      return _PlaceholderScreen(title: 'Thread', subtitle: 'Post: $postKey');
                    },
                  ),
                  GoRoute(
                    path: AppRoutes.profileDetail,
                    name: '${AppRouteNames.home}_${AppRouteNames.profileDetail}',
                    builder: (context, state) {
                      final did = state.pathParameters['did']!;
                      return _PlaceholderScreen(title: 'Profile', subtitle: 'DID: $did');
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                name: AppRouteNames.search,
                builder: (context, state) => const SearchScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.thread,
                    name: '${AppRouteNames.search}_${AppRouteNames.thread}',
                    builder: (context, state) {
                      final postKey = state.pathParameters['postKey']!;
                      return _PlaceholderScreen(title: 'Thread', subtitle: 'Post: $postKey');
                    },
                  ),
                  GoRoute(
                    path: AppRoutes.profileDetail,
                    name: '${AppRouteNames.search}_${AppRouteNames.profileDetail}',
                    builder: (context, state) {
                      final did = state.pathParameters['did']!;
                      return _PlaceholderScreen(title: 'Profile', subtitle: 'DID: $did');
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.notifications,
                name: AppRouteNames.notifications,
                builder: (context, state) => const NotificationsScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.thread,
                    name: '${AppRouteNames.notifications}_${AppRouteNames.thread}',
                    builder: (context, state) {
                      final postKey = state.pathParameters['postKey']!;
                      return _PlaceholderScreen(title: 'Thread', subtitle: 'Post: $postKey');
                    },
                  ),
                  GoRoute(
                    path: AppRoutes.profileDetail,
                    name: '${AppRouteNames.notifications}_${AppRouteNames.profileDetail}',
                    builder: (context, state) {
                      final did = state.pathParameters['did']!;
                      return _PlaceholderScreen(title: 'Profile', subtitle: 'DID: $did');
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dms,
                name: AppRouteNames.dms,
                builder: (context, state) => const DmsScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.convo,
                    name: AppRouteNames.convo,
                    builder: (context, state) {
                      final convoId = state.pathParameters['convoId']!;
                      return _PlaceholderScreen(
                        title: 'Conversation',
                        subtitle: 'Convo: $convoId',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: AppRouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.compose,
        name: AppRouteNames.compose,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Compose', subtitle: 'Create a new post'),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRouteNames.settings,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Settings', subtitle: 'App settings'),
      ),
    ],
  );
}

/// Temporary placeholder screen for unimplemented routes.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 64,
              color: theme.colorScheme.primary.withAlpha(127),
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
