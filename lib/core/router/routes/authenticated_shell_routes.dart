import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/router/app_route_page.dart';
import 'package:lazurite/core/router/app_route_paths.dart';
import 'package:lazurite/core/router/app_shell.dart';
import 'package:lazurite/core/router/content_route_factory.dart';
import 'package:lazurite/core/router/invalid_route_screen.dart';
import 'package:lazurite/core/router/route_query.dart';
import 'package:lazurite/features/alerts/presentation/alerts_screen.dart';
import 'package:lazurite/features/feed/presentation/feed_management_screen.dart';
import 'package:lazurite/features/feed/presentation/home_feed_screen.dart';
import 'package:lazurite/features/feed/presentation/trending_screen.dart';
import 'package:lazurite/features/messages/bloc/group_create_cubit.dart';
import 'package:lazurite/features/messages/bloc/group_details_cubit.dart';
import 'package:lazurite/features/messages/bloc/message_bloc.dart';
import 'package:lazurite/features/messages/data/convo_repository.dart';
import 'package:lazurite/features/messages/presentation/create_group_screen.dart';
import 'package:lazurite/features/messages/presentation/group_details_route_args.dart';
import 'package:lazurite/features/messages/presentation/group_details_screen.dart';
import 'package:lazurite/features/messages/presentation/join_link_preview_screen.dart';
import 'package:lazurite/features/messages/presentation/message_thread_route_args.dart';
import 'package:lazurite/features/messages/presentation/message_thread_screen.dart';
import 'package:lazurite/features/profile/presentation/profile_edit_screen.dart';
import 'package:lazurite/features/profile/presentation/profile_screen.dart';
import 'package:lazurite/features/search/presentation/search_screen.dart';
import 'package:poptart_core/poptart_core.dart';

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
                  final feedUri = query.atUri('uri');
                  if (query.hasNonEmpty('uri') && (feedUri == null || !_isFeedGeneratorUri(feedUri))) {
                    return buildAppRoutePage(
                      context,
                      state,
                      const InvalidRouteScreen(message: 'This feed link is invalid.'),
                    );
                  }
                  return buildAppRoutePage(
                    context,
                    state,
                    contentRouteFactory.feedDetail(
                      context,
                      feedUri: feedUri,
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
                    path: 'new-group',
                    pageBuilder: (context, state) => buildAppRoutePage(
                      context,
                      state,
                      BlocProvider(
                        create: (_) => GroupCreateCubit(
                          convoRepository: context.read<ConvoRepository>(),
                          currentUserDid: context.read<String>(),
                          l10n: context.l10n,
                        ),
                        child: const CreateGroupScreen(),
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'join/:code',
                    pageBuilder: (context, state) {
                      final code = state.pathParameters['code']!;
                      return buildAppRoutePage(context, state, JoinLinkPreviewScreen(code: code));
                    },
                  ),
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
                          child: MessageThreadScreen(
                            convoId: convoId,
                            title: args?.title ?? context.l10n.labelConversation,
                            convo: args?.convo,
                          ),
                        ),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'details',
                        pageBuilder: (context, state) {
                          final convoId = state.pathParameters['id']!;
                          final args = state.extra as GroupDetailsRouteArgs?;
                          return buildAppRoutePage(
                            context,
                            state,
                            BlocProvider(
                              create: (_) => GroupDetailsCubit(
                                convoRepository: context.read<ConvoRepository>(),
                                convoId: convoId,
                                currentUserDid: context.read<String>(),
                                l10n: context.l10n,
                                initialConvo: args?.convo,
                              ),
                              child: GroupDetailsScreen(convoId: convoId),
                            ),
                          );
                        },
                      ),
                    ],
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

bool _isFeedGeneratorUri(AtUri uri) => uri.collection.toString() == 'app.bsky.feed.generator' && uri.rkey.isNotEmpty;
