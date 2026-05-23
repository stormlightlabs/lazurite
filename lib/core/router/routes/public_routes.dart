import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/router/app_route_page.dart';
import 'package:lazurite/core/router/app_route_paths.dart';
import 'package:lazurite/core/router/route_query.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/public/presentation/public_route_state.dart';

/// Builds public content routes used by the unauthenticated shell.
///
/// This file owns the route shapes, URL normalization, and query/path decoding
/// for public browsing. The actual screen and repository wiring still flows
/// through callbacks supplied by `AppRouter`; that keeps this extraction small
/// while preserving existing provider fallback behavior during the larger router
/// refactor.
List<RouteBase> buildPublicRoutes({
  required AuthBloc authBloc,
  required PublicHomeRouteBuilder buildPublicHomeRoute,
  required FeedDetailRouteBuilder buildFeedDetailRoute,
  required PostThreadRouteBuilder buildPostThreadRoute,
  required TopicRouteBuilder buildTopicRoute,
  required ContextualProfileRouteBuilder buildContextualProfileRoute,
  required ProfileConnectionsRouteBuilder buildProfileConnectionsRoute,
  required ProfileSearchRouteBuilder buildProfileSearchRoute,
  required PublicProfileLocationBuilder publicProfileLocation,
}) {
  return [
    GoRoute(path: AppRoutePath.public.path, redirect: (_, _) => '/public/bluesky/discover'),
    GoRoute(
      path: AppRoutePath.publicProviderTab.path,
      redirect: (_, state) {
        final routeState = PublicRouteState.parse(
          provider: state.pathParameters['provider'],
          tab: state.pathParameters['tab'],
        );
        if (state.uri.path != routeState.location) {
          return routeState.location;
        }
        return null;
      },
      pageBuilder: (context, state) {
        final routeState = PublicRouteState.parse(
          provider: state.pathParameters['provider'],
          tab: state.pathParameters['tab'],
        );
        return MaterialPage<dynamic>(
          key: const ValueKey<String>('public-home-route'),
          child: buildPublicHomeRoute(context, routeState),
        );
      },
    ),
    GoRoute(
      path: AppRoutePath.feed.path,
      pageBuilder: (context, state) {
        final query = RouteQuery(state);
        final feedUri = query.atUri('uri');
        final actor = query.decoded('actor');
        final rkey = query.decoded('rkey');
        final provider = query.decoded('provider');
        return buildAppRoutePage(
          context,
          state,
          buildFeedDetailRoute(context, feedUri: feedUri, actor: actor, rkey: rkey, provider: provider),
        );
      },
    ),
    GoRoute(
      path: AppRoutePath.post.path,
      pageBuilder: (context, state) {
        final query = RouteQuery(state);
        final uri = query.decoded('uri') ?? '';
        final provider = state.uri.queryParameters['provider'];
        return buildAppRoutePage(
          context,
          state,
          buildPostThreadRoute(context, postUri: uri, provider: provider),
        );
      },
    ),
    GoRoute(
      path: AppRoutePath.topic.path,
      pageBuilder: (context, state) {
        final query = RouteQuery(state);
        final topic = query.decodedOrEmpty('topic');
        return buildAppRoutePage(
          context,
          state,
          buildTopicRoute(context, topic: topic, provider: state.uri.queryParameters['provider']),
        );
      },
    ),
    GoRoute(
      path: AppRoutePath.publicProfile.path,
      redirect: (_, state) {
        final actor = (state.pathParameters['actor'] ?? '').trim().toLowerCase();
        if (actor == 'me') {
          return AppRoutePath.profileMe.path;
        }
        return null;
      },
      pageBuilder: (context, state) {
        final provider = state.uri.queryParameters['provider'];
        return buildAppRoutePage(
          context,
          state,
          buildContextualProfileRoute(
            context,
            RouteQuery(state).decodedPathOrEmpty('actor'),
            provider: provider,
          ),
        );
      },
      routes: [
        GoRoute(
          path: 'connections',
          redirect: (_, state) => authBloc.state.isAuthenticated ? null : publicProfileLocation(state),
          pageBuilder: (context, state) => buildAppRoutePage(
            context,
            state,
            buildProfileConnectionsRoute(context, state, RouteQuery(state).decodedPathOrEmpty('actor')),
          ),
        ),
        GoRoute(
          path: 'search-posts',
          redirect: (_, state) => authBloc.state.isAuthenticated ? null : publicProfileLocation(state),
          pageBuilder: (context, state) {
            final actor = RouteQuery(state).decodedPathOrEmpty('actor');
            return buildAppRoutePage(
              context,
              state,
              buildProfileSearchRoute(context, actor),
            );
          },
        ),
      ],
    ),
  ];
}

/// Builds the public home screen once the provider/tab route state is canonical.
typedef PublicHomeRouteBuilder = Widget Function(BuildContext context, PublicRouteState routeState);

/// Builds a feed detail screen with provider-aware repository wiring.
typedef FeedDetailRouteBuilder = Widget Function(
  BuildContext context, {
  required AtUri? feedUri,
  required String? actor,
  required String? rkey,
  required String? provider,
});

/// Builds a post thread screen with provider-aware repository wiring.
typedef PostThreadRouteBuilder = Widget Function(BuildContext context, {required String postUri, required String? provider});

/// Builds a topic timeline with authenticated or public search dependencies.
typedef TopicRouteBuilder = Widget Function(BuildContext context, {required String topic, required String? provider});

/// Builds a profile route, optionally scoped to a public provider.
typedef ContextualProfileRouteBuilder = Widget Function(BuildContext context, String actor, {String? provider});

/// Builds profile relationship routes that remain authenticated-only.
typedef ProfileConnectionsRouteBuilder = Widget Function(BuildContext context, GoRouterState state, String actor);

/// Builds authenticated-only profile-scoped post search.
typedef ProfileSearchRouteBuilder = Widget Function(BuildContext context, String actor);

/// Returns the public profile route to use when blocking authenticated-only child routes.
typedef PublicProfileLocationBuilder = String Function(GoRouterState state);
