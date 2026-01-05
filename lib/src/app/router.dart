import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/core/widgets/tab_scaffold.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/dms/presentation/dms_screen.dart';
import 'package:lazurite/src/features/feeds/presentation/screens/feed_discovery_screen.dart';
import 'package:lazurite/src/features/feeds/presentation/screens/feed_management_screen.dart';
import 'package:lazurite/src/features/login/presentation/app_password_login_screen.dart';
import 'package:lazurite/src/features/login/presentation/auth_progress_view.dart';
import 'package:lazurite/src/features/login/presentation/login_screen.dart';
import 'package:lazurite/src/features/notifications/presentation/notifications_screen.dart';
import 'package:lazurite/src/features/profile/presentation/followers_page.dart';
import 'package:lazurite/src/features/profile/presentation/following_page.dart';
import 'package:lazurite/src/features/profile/presentation/profile_screen.dart';
import 'package:lazurite/src/features/search/presentation/search_screen.dart';
import 'package:lazurite/src/features/splash/presentation/splash_screen.dart';
import 'package:lazurite/src/features/thread/presentation/thread_screen.dart';
import 'package:lazurite/src/features/timeline/presentation/timeline_screen.dart';

/// Global navigator key for the root navigator.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Creates and configures the app router.
///
/// Uses [StatefulShellRoute.indexedStack] to preserve state across tabs.
GoRouter createRouter(Ref ref) {
  final authState = ValueNotifier(ref.read(authProvider));

  ref.listen(authProvider, (previous, next) {
    authState.value = next;
  });

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    refreshListenable: authState,
    redirect: (context, state) {
      final auth = authState.value;
      final location = state.matchedLocation;
      if (auth is AuthStateLoading) {
        return AppRoutes.splash;
      }

      if (location == AppRoutes.splash) {
        return AppRoutes.home;
      }

      final isLoggingIn =
          location == AppRoutes.login || location == '${AppRoutes.login}/app-password';
      final isCallback = location == AppRoutes.callback;
      final isPublic =
          location.startsWith(AppRoutes.home) || location.startsWith(AppRoutes.search);

      if (auth is! AuthStateAuthenticated) {
        if (isLoggingIn || isCallback || isPublic) return null;
        return AppRoutes.login;
      }

      if (isLoggingIn || isCallback) return AppRoutes.home;

      return null;
    },
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
                builder: (context, state) => const TimelineScreen(),
                routes: [
                  GoRoute(
                    path: 't/:uri',
                    name: '${AppRouteNames.home}_${AppRouteNames.thread}',
                    builder: (context, state) =>
                        ThreadScreen(postUri: state.pathParameters['uri']!),
                  ),
                  GoRoute(
                    path: AppRoutes.profileDetail,
                    name: '${AppRouteNames.home}_${AppRouteNames.profileDetail}',
                    builder: (context, state) {
                      final did = Uri.decodeComponent(state.pathParameters['did']!);
                      return ProfilePage(did: did);
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
                builder: (context, state) {
                  final query = state.uri.queryParameters['q'];
                  return SearchScreen(initialQuery: query);
                },
                routes: [
                  GoRoute(
                    path: 't/:uri',
                    name: '${AppRouteNames.search}_${AppRouteNames.thread}',
                    builder: (context, state) {
                      final uri = Uri.decodeComponent(state.pathParameters['uri']!);
                      return ThreadScreen(postUri: uri);
                    },
                  ),
                  GoRoute(
                    path: AppRoutes.profileDetail,
                    name: '${AppRouteNames.search}_${AppRouteNames.profileDetail}',
                    builder: (context, state) {
                      final did = Uri.decodeComponent(state.pathParameters['did']!);
                      return ProfilePage(did: did);
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
                      final uri = Uri.decodeComponent(state.pathParameters['uri']!);
                      return ThreadScreen(postUri: uri);
                    },
                  ),
                  GoRoute(
                    path: AppRoutes.profileDetail,
                    name: '${AppRouteNames.notifications}_${AppRouteNames.profileDetail}',
                    builder: (context, state) {
                      final did = Uri.decodeComponent(state.pathParameters['did']!);
                      return ProfilePage(did: did);
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
                routes: [
                  GoRoute(
                    path: AppRoutes.followers,
                    name: AppRouteNames.followers,
                    builder: (context, state) {
                      final did = Uri.decodeComponent(state.pathParameters['did']!);
                      return FollowersPage(did: did);
                    },
                  ),
                  GoRoute(
                    path: AppRoutes.following,
                    name: AppRouteNames.following,
                    builder: (context, state) {
                      final did = Uri.decodeComponent(state.pathParameters['did']!);
                      return FollowingPage(did: did);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRouteNames.login,
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'app-password',
            name: 'login_app_password',
            builder: (context, state) => const AppPasswordLoginScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.callback,
        name: AppRouteNames.callback,
        builder: (context, state) {
          final uri = state.uri;
          // TODO: CallbackScreen widget that initiates the completion.
          return _CallbackHandler(uri: uri);
        },
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
      GoRoute(
        path: AppRoutes.splash,
        name: AppRouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.feeds,
        name: AppRouteNames.feeds,
        builder: (context, state) => const FeedManagementScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.discoverFeeds,
            name: AppRouteNames.discoverFeeds,
            builder: (context, state) => const FeedDiscoveryScreen(),
          ),
        ],
      ),
    ],
  );
}

class _CallbackHandler extends ConsumerStatefulWidget {
  const _CallbackHandler({required this.uri});
  final Uri uri;

  @override
  ConsumerState<_CallbackHandler> createState() => _CallbackHandlerState();
}

class _CallbackHandlerState extends ConsumerState<_CallbackHandler> {
  @override
  void initState() {
    super.initState();
    ref.read(authProvider.notifier).completeLogin(widget.uri);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: switch (authState) {
          AuthStateError(error: final e) => Text('Login Failed: $e'),
          _ => const AuthProgressView(message: 'Finishing sign in...'),
        },
      ),
    );
  }
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
