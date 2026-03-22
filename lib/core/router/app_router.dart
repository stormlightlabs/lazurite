import 'dart:async';

import 'package:atproto_core/atproto_core.dart' show AtUri;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bluesky/bluesky.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/features/auth/presentation/login_screen.dart';
import 'package:lazurite/features/alerts/presentation/alerts_screen.dart';
import 'package:lazurite/features/compose/bloc/compose_bloc.dart';
import 'package:lazurite/features/compose/presentation/compose_route_args.dart';
import 'package:lazurite/features/compose/presentation/compose_screen.dart';
import 'package:lazurite/features/devtools/presentation/dev_tools_screen.dart';
import 'package:lazurite/features/feed/presentation/feed_management_screen.dart';
import 'package:lazurite/features/feed/presentation/home_feed_screen.dart';
import 'package:lazurite/features/feed/presentation/media/image_viewer_screen.dart';
import 'package:lazurite/features/feed/presentation/media/image_viewer_route_args.dart';
import 'package:lazurite/features/feed/presentation/post_thread_screen.dart';
import 'package:lazurite/features/feed/presentation/media/video_player_route_args.dart';
import 'package:lazurite/features/feed/presentation/media/video_player_screen.dart';
import 'package:lazurite/features/logs/presentation/logs_screen.dart';
import 'package:lazurite/features/notifications/bloc/notification_bloc.dart';
import 'package:lazurite/features/notifications/cubit/unread_count_cubit.dart';
import 'package:lazurite/features/notifications/data/notification_repository.dart';
import 'package:lazurite/features/profile/presentation/profile_screen.dart';
import 'package:lazurite/features/feed/presentation/saved_posts_screen.dart';
import 'package:lazurite/features/search/presentation/search_screen.dart';
import 'package:lazurite/features/messages/bloc/message_bloc.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:lazurite/features/messages/presentation/message_thread_route_args.dart';
import 'package:lazurite/features/messages/presentation/message_thread_screen.dart';
import 'package:lazurite/features/lists/bloc/list_bloc.dart';
import 'package:lazurite/features/lists/data/list_repository.dart';
import 'package:lazurite/features/lists/presentation/list_detail_screen.dart';
import 'package:lazurite/features/lists/presentation/list_members_screen.dart';
import 'package:lazurite/features/lists/presentation/my_lists_screen.dart';
import 'package:lazurite/features/moderation/presentation/screens/labeler_detail_screen.dart';
import 'package:lazurite/features/moderation/presentation/screens/moderation_settings_screen.dart';
import 'package:lazurite/features/starter_packs/bloc/starter_pack_bloc.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';
import 'package:lazurite/features/starter_packs/presentation/actor_starter_packs_screen.dart';
import 'package:lazurite/features/starter_packs/presentation/create_edit_starter_pack_screen.dart';
import 'package:lazurite/features/starter_packs/presentation/starter_pack_detail_screen.dart';
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
      GoRoute(path: '/notifications', redirect: (_, _) => '/alerts'),
      GoRoute(path: '/messages', redirect: (_, _) => '/alerts/messages'),
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
              initialText: args?.initialText,
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
        path: '/images',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final args = state.extra as ImageViewerRouteArgs;
          return ImageViewerScreen(args: args);
        },
      ),
      GoRoute(
        path: '/video',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final args = state.extra as VideoPlayerRouteArgs;
          return VideoPlayerScreen(args: args);
        },
      ),
      GoRoute(
        path: '/saved',
        builder: (context, state) => SavedPostsScreen(accountDid: context.read<String>()),
      ),
      GoRoute(path: '/lists', builder: (context, state) => const MyListsScreen()),
      GoRoute(
        path: '/create-starter-pack',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => StarterPackBloc(starterPackRepository: context.read<StarterPackRepository>()),
            child: CreateStarterPackScreen(userDid: context.read<String>()),
          );
        },
      ),
      GoRoute(
        path: '/starter-pack',
        builder: (context, state) {
          final uriStr = Uri.decodeComponent(state.uri.queryParameters['uri'] ?? '');
          final packUri = AtUri.parse(uriStr);
          return StarterPackDetailScreen(packUri: packUri);
        },
      ),
      GoRoute(
        path: '/starter-packs',
        builder: (context, state) {
          final actor = state.uri.queryParameters['actor'] ?? '';
          return ActorStarterPacksScreen(actor: actor);
        },
      ),
      GoRoute(
        path: '/list',
        builder: (context, state) {
          final uriStr = Uri.decodeComponent(state.uri.queryParameters['uri'] ?? '');
          final listUri = AtUri.parse(uriStr);
          return ListDetailScreen(listUri: listUri);
        },
        routes: [
          GoRoute(
            path: 'members',
            builder: (context, state) {
              final uriStr = Uri.decodeComponent(state.uri.queryParameters['uri'] ?? '');
              final listUri = AtUri.parse(uriStr);
              return BlocProvider(
                create: (_) =>
                    ListBloc(listRepository: context.read<ListRepository>())..add(ListRequested(listUri: listUri)),
                child: ListMembersScreen(listUri: listUri),
              );
            },
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          if (!context.read<AuthBloc>().state.isAuthenticated) {
            return AppShell(navigationShell: navigationShell);
          }

          UnreadCountCubit? existingUnreadCubit;
          try {
            existingUnreadCubit = context.read<UnreadCountCubit>();
          } catch (_) {
            log.d('UnreadCountCubit not found, creating new one');
          }

          if (existingUnreadCubit != null) {
            return AppShell(navigationShell: navigationShell);
          }

          return MultiBlocProvider(
            providers: [
              if (existingUnreadCubit == null)
                BlocProvider(
                  create: (_) => UnreadCountCubit(notificationRepository: context.read<NotificationRepository>()),
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
                routes: [
                  GoRoute(path: 'feeds', builder: (context, state) => const FeedManagementScreen()),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                    routes: [
                      GoRoute(
                        path: 'moderation',
                        builder: (context, state) => const ModerationSettingsScreen(),
                        routes: [
                          GoRoute(
                            path: 'detail',
                            builder: (context, state) =>
                                LabelerDetailScreen(did: state.uri.queryParameters['did'] ?? ''),
                          ),
                        ],
                      ),
                      GoRoute(path: 'about', builder: (context, state) => const AboutScreen()),
                      GoRoute(path: 'logs', builder: (context, state) => const LogsScreen()),
                      GoRoute(path: 'devtools', builder: (context, state) => const DevToolsScreen()),
                    ],
                  ),
                ],
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
                path: '/alerts',
                builder: (context, state) => _buildAlertsRoute(context, const AlertsScreen()),
                routes: [
                  GoRoute(
                    path: 'messages',
                    builder: (context, state) =>
                        _buildAlertsRoute(context, const AlertsScreen(initialTab: AlertsTab.messages)),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (context, state) {
                          final convoId = state.pathParameters['id']!;
                          final args = state.extra as MessageThreadRouteArgs?;
                          return BlocProvider(
                            create: (_) => MessageBloc(
                              convoRepository: context.read<ConvoRepository>(),
                              currentUserDid: context.read<String>(),
                            ),
                            child: MessageThreadScreen(convoId: convoId, title: args?.title ?? 'Conversation'),
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'requests',
                    builder: (context, state) =>
                        _buildAlertsRoute(context, const AlertsScreen(initialTab: AlertsTab.requests)),
                  ),
                ],
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
        ],
      ),
    ],
  );

  Widget _buildAlertsRoute(BuildContext context, Widget child) {
    NotificationBloc? existingNotificationBloc;
    try {
      existingNotificationBloc = context.read<NotificationBloc>();
    } catch (_) {
      log.d('NotificationBloc not found, creating new one for alerts route');
    }

    if (existingNotificationBloc != null) {
      return child;
    }

    return BlocProvider(
      create: (_) => NotificationBloc(notificationRepository: context.read<NotificationRepository>()),
      child: child,
    );
  }
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
