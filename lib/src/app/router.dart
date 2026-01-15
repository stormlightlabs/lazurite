import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/animation_controller.dart' as lazurite_anim;
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/core/animations/page_transitions.dart';
import 'package:lazurite/src/core/widgets/fullscreen_image_viewer.dart';
import 'package:lazurite/src/core/widgets/fullscreen_video_viewer.dart';
import 'package:lazurite/src/core/widgets/tab_scaffold.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/composer/presentation/screens/composer_screen.dart';
import 'package:lazurite/src/features/composer/presentation/screens/draft_list_screen.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/draft_recovery_listener.dart';
import 'package:lazurite/src/features/developer_tools/presentation/screens/collections_page.dart';
import 'package:lazurite/src/features/developer_tools/presentation/screens/dev_tools_home_page.dart';
import 'package:lazurite/src/features/developer_tools/presentation/screens/record_detail_page.dart';
import 'package:lazurite/src/features/developer_tools/presentation/screens/records_page.dart';
import 'package:lazurite/src/features/dms/presentation/conversation_detail_screen.dart';
import 'package:lazurite/src/features/dms/presentation/conversation_list_screen.dart';
import 'package:lazurite/src/features/feeds/presentation/screens/bookmarks_screen.dart';
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
import 'package:lazurite/src/features/settings/presentation/screens/accessibility_settings_screen.dart';
import 'package:lazurite/src/features/settings/presentation/screens/content_moderation_screen.dart';
import 'package:lazurite/src/features/settings/presentation/screens/feed_preferences_screen.dart';
import 'package:lazurite/src/features/settings/presentation/screens/muted_words_screen.dart';
import 'package:lazurite/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:lazurite/src/features/settings/presentation/screens/theme_editor_screen.dart';
import 'package:lazurite/src/features/settings/presentation/screens/theme_settings_screen.dart';
import 'package:lazurite/src/features/splash/presentation/splash_screen.dart';
import 'package:lazurite/src/features/thread/presentation/thread_screen.dart';

/// Global navigator key for the root navigator.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Helper to get DID from auth state for DevTools routes.
String _getDidFromAuth(Ref ref) {
  final authState = ref.read(authProvider);
  if (authState is AuthStateAuthenticated) {
    return authState.session.did;
  }
  return '';
}

/// Creates and configures the app router.
///
/// Uses [StatefulShellRoute.indexedStack] to preserve state across tabs.
GoRouter createRouter(Ref ref) {
  final authState = ValueNotifier(ref.read(authProvider));
  final splashMinWait = ValueNotifier(true);
  final animationController = ref.read(lazurite_anim.animationControllerProvider.notifier);

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
          return DraftRecoveryListener(child: TabScaffold(navigationShell: navigationShell));
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
                    pageBuilder: (context, state) => LazuritePageTransitions.build(
                      child: ThreadScreen(
                        postUri: Uri.decodeComponent(state.pathParameters['uri']!),
                      ),
                      type: LazuriteTransitionType.sharedAxisHorizontal,
                      state: state,
                      controller: animationController,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.profileDetail,
                    name: '${AppRouteNames.home}_${AppRouteNames.profileDetail}',
                    pageBuilder: (context, state) => LazuritePageTransitions.build(
                      child: ProfilePage(did: Uri.decodeComponent(state.pathParameters['did']!)),
                      type: LazuriteTransitionType.sharedAxisHorizontal,
                      state: state,
                      controller: animationController,
                    ),
                    routes: [
                      GoRoute(
                        path: 'followers',
                        name: '${AppRouteNames.home}_${AppRouteNames.followers}',
                        pageBuilder: (context, state) => LazuritePageTransitions.build(
                          child: FollowersPage(
                            did: Uri.decodeComponent(state.pathParameters['did']!),
                          ),
                          type: LazuriteTransitionType.sharedAxisHorizontal,
                          state: state,
                          controller: animationController,
                        ),
                      ),
                      GoRoute(
                        path: 'following',
                        name: '${AppRouteNames.home}_${AppRouteNames.following}',
                        pageBuilder: (context, state) => LazuritePageTransitions.build(
                          child: FollowingPage(
                            did: Uri.decodeComponent(state.pathParameters['did']!),
                          ),
                          type: LazuriteTransitionType.sharedAxisHorizontal,
                          state: state,
                          controller: animationController,
                        ),
                      ),
                    ],
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
                  final initialQuery = state.uri.queryParameters['q'];
                  final initialTabIndex = state.uri.queryParameters['type'] == 'people' ? 1 : 0;
                  return SearchScreen(
                    initialQuery: initialQuery,
                    initialTabIndex: initialTabIndex,
                  );
                },
                routes: [
                  GoRoute(
                    path: 't/:uri',
                    name: '${AppRouteNames.search}_${AppRouteNames.thread}',
                    pageBuilder: (context, state) => LazuritePageTransitions.build(
                      child: ThreadScreen(
                        postUri: Uri.decodeComponent(state.pathParameters['uri']!),
                      ),
                      type: LazuriteTransitionType.sharedAxisHorizontal,
                      state: state,
                      controller: animationController,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.profileDetail,
                    name: '${AppRouteNames.search}_${AppRouteNames.profileDetail}',
                    pageBuilder: (context, state) => LazuritePageTransitions.build(
                      child: ProfilePage(did: Uri.decodeComponent(state.pathParameters['did']!)),
                      type: LazuriteTransitionType.sharedAxisHorizontal,
                      state: state,
                      controller: animationController,
                    ),
                    routes: [
                      GoRoute(
                        path: 'followers',
                        name: '${AppRouteNames.search}_${AppRouteNames.followers}',
                        pageBuilder: (context, state) => LazuritePageTransitions.build(
                          child: FollowersPage(
                            did: Uri.decodeComponent(state.pathParameters['did']!),
                          ),
                          type: LazuriteTransitionType.sharedAxisHorizontal,
                          state: state,
                          controller: animationController,
                        ),
                      ),
                      GoRoute(
                        path: 'following',
                        name: '${AppRouteNames.search}_${AppRouteNames.following}',
                        pageBuilder: (context, state) => LazuritePageTransitions.build(
                          child: FollowingPage(
                            did: Uri.decodeComponent(state.pathParameters['did']!),
                          ),
                          type: LazuriteTransitionType.sharedAxisHorizontal,
                          state: state,
                          controller: animationController,
                        ),
                      ),
                    ],
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
                    pageBuilder: (context, state) => LazuritePageTransitions.build(
                      child: ThreadScreen(
                        postUri: Uri.decodeComponent(state.pathParameters['uri']!),
                      ),
                      type: LazuriteTransitionType.sharedAxisHorizontal,
                      state: state,
                      controller: animationController,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.profileDetail,
                    name: '${AppRouteNames.notifications}_${AppRouteNames.profileDetail}',
                    pageBuilder: (context, state) => LazuritePageTransitions.build(
                      child: ProfilePage(did: Uri.decodeComponent(state.pathParameters['did']!)),
                      type: LazuriteTransitionType.sharedAxisHorizontal,
                      state: state,
                      controller: animationController,
                    ),
                    routes: [
                      GoRoute(
                        path: 'followers',
                        name: '${AppRouteNames.notifications}_${AppRouteNames.followers}',
                        pageBuilder: (context, state) => LazuritePageTransitions.build(
                          child: FollowersPage(
                            did: Uri.decodeComponent(state.pathParameters['did']!),
                          ),
                          type: LazuriteTransitionType.sharedAxisHorizontal,
                          state: state,
                          controller: animationController,
                        ),
                      ),
                      GoRoute(
                        path: 'following',
                        name: '${AppRouteNames.notifications}_${AppRouteNames.following}',
                        pageBuilder: (context, state) => LazuritePageTransitions.build(
                          child: FollowingPage(
                            did: Uri.decodeComponent(state.pathParameters['did']!),
                          ),
                          type: LazuriteTransitionType.sharedAxisHorizontal,
                          state: state,
                          controller: animationController,
                        ),
                      ),
                    ],
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
                builder: (context, state) => const ConversationListScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.convo,
                    name: AppRouteNames.convo,
                    pageBuilder: (context, state) => LazuritePageTransitions.build(
                      child: ConversationDetailScreen(convoId: state.pathParameters['convoId']!),
                      type: LazuriteTransitionType.sharedAxisHorizontal,
                      state: state,
                      controller: animationController,
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
                    pageBuilder: (context, state) => LazuritePageTransitions.build(
                      child: FollowersPage(did: state.pathParameters['did']!),
                      type: LazuriteTransitionType.sharedAxisHorizontal,
                      state: state,
                      controller: animationController,
                    ),
                  ),
                  GoRoute(
                    path: AppRoutes.following,
                    name: AppRouteNames.following,
                    pageBuilder: (context, state) => LazuritePageTransitions.build(
                      child: FollowingPage(did: state.pathParameters['did']!),
                      type: LazuriteTransitionType.sharedAxisHorizontal,
                      state: state,
                      controller: animationController,
                    ),
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
        pageBuilder: (context, state) => LazuritePageTransitions.build(
          child: ComposerScreen(
            draftId: state.uri.queryParameters['draftId'],
            replyTo: state.uri.queryParameters['replyTo'],
            quoteTo: state.uri.queryParameters['quoteTo'],
          ),
          type: LazuriteTransitionType.sharedAxisVertical,
          state: state,
          controller: animationController,
        ),
      ),
      GoRoute(
        path: '/drafts',
        name: AppRouteNames.drafts,
        builder: (context, state) => const DraftListScreen(),
        routes: [
          GoRoute(
            path: ':draftId',
            name: AppRouteNames.draftDetail,
            redirect: (context, state) {
              final draftId = state.pathParameters['draftId'];
              return '/compose?draftId=$draftId';
            },
          ),
        ],
      ),
      GoRoute(
        path: '/bookmarks',
        name: 'bookmarks',
        builder: (context, state) => const BookmarksScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'appearance',
            name: AppRouteNames.appearance,
            pageBuilder: (context, state) => LazuritePageTransitions.build(
              child: const ThemeSettingsScreen(),
              type: LazuriteTransitionType.sharedAxisHorizontal,
              state: state,
              controller: animationController,
            ),
            routes: [
              GoRoute(
                path: 'editor',
                name: 'theme_editor',
                pageBuilder: (context, state) => LazuritePageTransitions.build(
                  child: ThemeEditorScreen(customThemeId: state.uri.queryParameters['id']),
                  type: LazuriteTransitionType.sharedAxisHorizontal,
                  state: state,
                  controller: animationController,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'about',
            name: AppRouteNames.about,
            pageBuilder: (context, state) => LazuritePageTransitions.build(
              child: const AboutScreen(),
              type: LazuriteTransitionType.sharedAxisHorizontal,
              state: state,
              controller: animationController,
            ),
          ),
          GoRoute(
            path: 'feeds',
            name: AppRouteNames.feedPreferences,
            pageBuilder: (context, state) => LazuritePageTransitions.build(
              child: const FeedPreferencesScreen(),
              type: LazuriteTransitionType.sharedAxisHorizontal,
              state: state,
              controller: animationController,
            ),
          ),
          GoRoute(
            path: 'moderation',
            name: AppRouteNames.contentModeration,
            pageBuilder: (context, state) => LazuritePageTransitions.build(
              child: const ContentModerationScreen(),
              type: LazuriteTransitionType.sharedAxisHorizontal,
              state: state,
              controller: animationController,
            ),
          ),
          GoRoute(
            path: 'muted-words',
            name: AppRouteNames.mutedWords,
            pageBuilder: (context, state) => LazuritePageTransitions.build(
              child: const MutedWordsScreen(),
              type: LazuriteTransitionType.sharedAxisHorizontal,
              state: state,
              controller: animationController,
            ),
          ),
          GoRoute(
            path: 'accessibility',
            name: AppRouteNames.accessibility,
            pageBuilder: (context, state) => LazuritePageTransitions.build(
              child: const AccessibilitySettingsScreen(),
              type: LazuriteTransitionType.sharedAxisHorizontal,
              state: state,
              controller: animationController,
            ),
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
      GoRoute(
        path: AppRoutes.devtools,
        name: AppRouteNames.devToolsHome,
        builder: (context, state) => const DevToolsHomePage(),
        routes: [
          GoRoute(
            path: AppRoutes.devtoolsCollections,
            name: AppRouteNames.devToolsCollections,
            pageBuilder: (context, state) => LazuritePageTransitions.build(
              child: const CollectionsPage(),
              type: LazuriteTransitionType.sharedAxisHorizontal,
              state: state,
              controller: animationController,
            ),
            routes: [
              GoRoute(
                path: AppRoutes.devtoolsRecords,
                name: AppRouteNames.devToolsRecords,
                pageBuilder: (context, state) => LazuritePageTransitions.build(
                  child: RecordsPage(
                    did: _getDidFromAuth(ref),
                    collection: Uri.decodeComponent(state.pathParameters['collection']!),
                  ),
                  type: LazuriteTransitionType.sharedAxisHorizontal,
                  state: state,
                  controller: animationController,
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.devtoolsRecord,
                    name: AppRouteNames.devToolsRecord,
                    pageBuilder: (context, state) => LazuritePageTransitions.build(
                      child: RecordDetailPage(
                        collection: Uri.decodeComponent(state.pathParameters['collection']!),
                        rkey: Uri.decodeComponent(state.pathParameters['rkey']!),
                      ),
                      type: LazuriteTransitionType.sharedAxisHorizontal,
                      state: state,
                      controller: animationController,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.fullscreenImage,
        name: AppRouteNames.fullscreenImage,
        pageBuilder: (context, state) {
          final initialIndex = int.tryParse(state.uri.queryParameters['index'] ?? '0') ?? 0;
          final extra = state.extra as Map<String, dynamic>?;

          if (extra == null || extra['images'] == null) {
            return LazuritePageTransitions.build(
              child: const Scaffold(
                body: Center(child: Text('Invalid request: missing images data')),
              ),
              type: LazuriteTransitionType.fadeScale,
              state: state,
              controller: animationController,
            );
          }

          final images = extra['images'] as List<Map<String, dynamic>>;

          return LazuritePageTransitions.build(
            child: FullscreenImageViewer(
              images: images,
              initialIndex: initialIndex.clamp(0, images.length - 1),
            ),
            type: LazuriteTransitionType.fadeScale,
            state: state,
            controller: animationController,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.fullscreenVideo,
        name: AppRouteNames.fullscreenVideo,
        pageBuilder: (context, state) {
          final playlist = state.uri.queryParameters['playlist'] ?? '';
          final thumbnail = state.uri.queryParameters['thumbnail'];
          final alt = state.uri.queryParameters['alt'];
          final cid = state.uri.queryParameters['cid'];
          final authorDid = state.uri.queryParameters['authorDid'];
          final durationSeconds = int.tryParse(state.uri.queryParameters['durationSeconds'] ?? '');

          return LazuritePageTransitions.build(
            child: FullscreenVideoViewer(
              playlist: playlist,
              thumbnail: thumbnail,
              alt: alt,
              cid: cid,
              authorDid: authorDid,
              durationSeconds: durationSeconds,
            ),
            type: LazuriteTransitionType.fadeScale,
            state: state,
            controller: animationController,
          );
        },
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
// ignore: unused_element
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
