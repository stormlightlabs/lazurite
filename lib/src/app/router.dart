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
import 'package:lazurite/src/features/feeds/presentation/screens/feed_screen.dart';
import 'package:lazurite/src/features/landing/presentation/landing_screen.dart';
import 'package:lazurite/src/features/login/presentation/app_password_login_screen.dart';
import 'package:lazurite/src/features/login/presentation/auth_progress_view.dart';
import 'package:lazurite/src/features/login/presentation/login_screen.dart';
import 'package:lazurite/src/features/notifications/presentation/notifications_screen.dart';
import 'package:lazurite/src/features/profile/presentation/followers_page.dart';
import 'package:lazurite/src/features/profile/presentation/following_page.dart';
import 'package:lazurite/src/features/profile/presentation/profile_screen.dart';
import 'package:lazurite/src/features/search/presentation/search_screen.dart';
import 'package:lazurite/src/features/settings/presentation/screens/about_screen.dart';
import 'package:lazurite/src/features/settings/presentation/screens/content_moderation_screen.dart';
import 'package:lazurite/src/features/settings/presentation/screens/feed_preferences_screen.dart';
import 'package:lazurite/src/features/settings/presentation/screens/muted_words_screen.dart';
import 'package:lazurite/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:lazurite/src/features/settings/presentation/screens/theme_settings_screen.dart';
import 'package:lazurite/src/features/splash/presentation/splash_screen.dart';
import 'package:lazurite/src/features/thread/presentation/thread_screen.dart';

/// Global navigator key for the root navigator.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Creates and configures the app router.
///
/// Uses [StatefulShellRoute.indexedStack] to preserve state across tabs.
GoRouter createRouter(Ref ref) {
  final authState = ValueNotifier(ref.read(authProvider));
  final splashMinWait = ValueNotifier(true);

  ref.listen(authProvider, (previous, next) {
    authState.value = next;
  });

  Future.delayed(const Duration(milliseconds: 500), () {
    splashMinWait.value = false;
  });

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: Listenable.merge([authState, splashMinWait]),
    redirect: (context, state) {
      final auth = authState.value;
      final location = state.matchedLocation;

      if (location == AppRoutes.splash) {
        if (auth is AuthStateLoading || splashMinWait.value) {
          return null;
        }

        if (auth is AuthStateAuthenticated) {
          return AppRoutes.home;
        }
        return AppRoutes.landing;
      }

      final isLoggingIn =
          location == AppRoutes.login || location == '${AppRoutes.login}/app-password';
      final isCallback = location == AppRoutes.callback;
      final isLanding = location == AppRoutes.landing;
      final isPublicRoute = location.startsWith(AppRoutes.home);

      if (auth is! AuthStateAuthenticated) {
        if (isLoggingIn || isCallback || isLanding || isPublicRoute) return null;
        return AppRoutes.landing;
      }

      if (isLoggingIn || isCallback || isLanding) return AppRoutes.home;

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
                builder: (context, state) => const FeedScreen(),
                routes: [
                  GoRoute(
                    path: 't/:uri',
                    name: '${AppRouteNames.home}_${AppRouteNames.thread}',
                    builder: (context, state) =>
                        ThreadScreen(postUri: Uri.decodeComponent(state.pathParameters['uri']!)),
                  ),
                  GoRoute(
                    path: AppRoutes.profileDetail,
                    name: '${AppRouteNames.home}_${AppRouteNames.profileDetail}',
                    builder: (context, state) =>
                        ProfilePage(did: Uri.decodeComponent(state.pathParameters['did']!)),
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
                builder: (context, state) =>
                    SearchScreen(initialQuery: state.uri.queryParameters['q']),
                routes: [
                  GoRoute(
                    path: 't/:uri',
                    name: '${AppRouteNames.search}_${AppRouteNames.thread}',
                    builder: (context, state) =>
                        ThreadScreen(postUri: Uri.decodeComponent(state.pathParameters['uri']!)),
                  ),
                  GoRoute(
                    path: AppRoutes.profileDetail,
                    name: '${AppRouteNames.search}_${AppRouteNames.profileDetail}',
                    builder: (context, state) =>
                        ProfilePage(did: Uri.decodeComponent(state.pathParameters['did']!)),
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
                    builder: (context, state) =>
                        ThreadScreen(postUri: Uri.decodeComponent(state.pathParameters['uri']!)),
                  ),
                  GoRoute(
                    path: AppRoutes.profileDetail,
                    name: '${AppRouteNames.notifications}_${AppRouteNames.profileDetail}',
                    builder: (context, state) =>
                        ProfilePage(did: Uri.decodeComponent(state.pathParameters['did']!)),
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
                    builder: (context, state) => _PlaceholderScreen(
                      title: 'Conversation',
                      subtitle: 'Convo: ${state.pathParameters['convoId']}',
                    ),
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
                    builder: (context, state) => FollowersPage(did: state.pathParameters['did']!),
                  ),
                  GoRoute(
                    path: AppRoutes.following,
                    name: AppRouteNames.following,
                    builder: (context, state) => FollowingPage(did: state.pathParameters['did']!),
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
        builder: (context, state) => _CallbackHandler(uri: state.uri),
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
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'appearance',
            name: AppRouteNames.appearance,
            builder: (context, state) => const ThemeSettingsScreen(),
          ),
          GoRoute(
            path: 'about',
            name: AppRouteNames.about,
            builder: (context, state) => const AboutScreen(),
          ),
          GoRoute(
            path: 'feeds',
            name: AppRouteNames.feedPreferences,
            builder: (context, state) => const FeedPreferencesScreen(),
          ),
          GoRoute(
            path: 'moderation',
            name: AppRouteNames.contentModeration,
            builder: (context, state) => const ContentModerationScreen(),
          ),
          GoRoute(
            path: 'muted-words',
            name: AppRouteNames.mutedWords,
            builder: (context, state) => const MutedWordsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.splash,
        name: AppRouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.landing,
        name: AppRouteNames.landing,
        builder: (context, state) => const LandingScreen(),
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
