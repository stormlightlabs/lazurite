import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/router/app_route_page.dart';
import 'package:lazurite/core/router/app_route_paths.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/core/router/content_route_factory.dart';
import 'package:lazurite/core/router/route_query.dart';
import 'package:lazurite/features/alerts/presentation/alerts_screen.dart';
import 'package:lazurite/features/feed/presentation/feed_management_screen.dart';
import 'package:lazurite/features/feed/presentation/home_feed_screen.dart';
import 'package:lazurite/features/feed/presentation/trending_screen.dart';
import 'package:lazurite/features/messages/bloc/message_bloc.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:lazurite/features/messages/presentation/message_thread_route_args.dart';
import 'package:lazurite/features/messages/presentation/message_thread_screen.dart';
import 'package:lazurite/features/profile/presentation/profile_edit_screen.dart';
import 'package:lazurite/features/profile/presentation/profile_screen.dart';
import 'package:lazurite/features/search/presentation/search_screen.dart';

/// Builds the authenticated tab shell and its branch routes.
///
/// The shell owns branch navigator wiring and top-level tab structure. Feature
/// dependency wiring flows through [contentRouteFactory] or the small callbacks
/// for cross-cutting wrappers such as alerts and developer tools.
StatefulShellRoute buildAuthenticatedShellRoute({
  required List<GlobalKey<NavigatorState>> branchNavigatorKeys,
  required ContentRouteFactory contentRouteFactory,
  required Widget Function(BuildContext context, Widget child) buildAlertsRoute,
  required Widget Function(BuildContext context, GoRouterState state) buildDevToolsRoute,
}) {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return AppShell(navigationShell: navigationShell, branchNavigatorKeys: branchNavigatorKeys);
    },
    branches: [
      StatefulShellBranch(
        navigatorKey: branchNavigatorKeys[0],
        routes: [
          GoRoute(
            path: AppRoutePath.home.path,
            pageBuilder: (context, state) => buildAppRoutePage(context, state, const HomeFeedScreen()),
            routes: [
              GoRoute(
                path: 'feeds',
                pageBuilder: (context, state) => buildAppRoutePage(context, state, const FeedManagementScreen()),
              ),
              GoRoute(
                path: AppRoutePath.feed.childPath,
                pageBuilder: (context, state) {
                  final query = RouteQuery(state);
                  return buildAppRoutePage(
                    context,
                    state,
                    contentRouteFactory.feedDetail(
                      context,
                      feedUri: query.atUri('uri'),
                      actor: query.decoded('actor'),
                      rkey: query.decoded('rkey'),
                      provider: query.decoded('provider'),
                    ),
                  );
                },
              ),
              GoRoute(
                path: 'trending',
                pageBuilder: (context, state) => buildAppRoutePage(context, state, const TrendingScreen()),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: branchNavigatorKeys[1],
        routes: [
          GoRoute(
            path: AppRoutePath.search.path,
            pageBuilder: (context, state) => buildAppRoutePage(context, state, const SearchScreen()),
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: branchNavigatorKeys[2],
        routes: [
          GoRoute(
            path: AppRoutePath.atExplorer.path,
            pageBuilder: (context, state) => buildAppRoutePage(context, state, buildDevToolsRoute(context, state)),
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: branchNavigatorKeys[3],
        routes: [
          GoRoute(
            path: AppRoutePath.alerts.path,
            pageBuilder: (context, state) =>
                buildAppRoutePage(context, state, buildAlertsRoute(context, const AlertsScreen())),
            routes: [
              GoRoute(
                path: 'messages',
                pageBuilder: (context, state) => buildAppRoutePage(
                  context,
                  state,
                  buildAlertsRoute(context, const AlertsScreen(initialTab: AlertsTab.messages)),
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) {
                      final convoId = state.pathParameters['id']!;
                      final args = state.extra as MessageThreadRouteArgs?;
                      return buildAppRoutePage(
                        context,
                        state,
                        BlocProvider(
                          create: (_) => MessageBloc(
                            convoRepository: context.read<ConvoRepository>(),
                            currentUserDid: context.read<String>(),
                          ),
                          child: MessageThreadScreen(convoId: convoId, title: args?.title ?? 'Conversation'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'requests',
                pageBuilder: (context, state) => buildAppRoutePage(
                  context,
                  state,
                  buildAlertsRoute(context, const AlertsScreen(initialTab: AlertsTab.requests)),
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: branchNavigatorKeys[4],
        routes: [
          GoRoute(
            path: AppRoutePath.profileMe.path,
            pageBuilder: (context, state) => buildAppRoutePage(context, state, const ProfileScreen(actor: 'me')),
            routes: [
              GoRoute(
                path: 'connections',
                pageBuilder: (context, state) => buildAppRoutePage(
                  context,
                  state,
                  contentRouteFactory.profileConnections(context, state, context.read<String>()),
                ),
              ),
              GoRoute(
                path: 'edit',
                pageBuilder: (context, state) => buildAppRoutePage(context, state, const ProfileEditScreen()),
              ),
              GoRoute(
                path: 'search-posts',
                pageBuilder: (context, state) {
                  final actor = context.read<String>();
                  return buildAppRoutePage(context, state, contentRouteFactory.profileSearch(context, actor));
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
