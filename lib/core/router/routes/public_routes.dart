import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/router/app_route_page.dart';
import 'package:lazurite/core/router/app_route_paths.dart';
import 'package:lazurite/core/router/invalid_route_screen.dart';
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
        if (query.hasNonEmpty('uri') && (feedUri == null || !_isFeedGeneratorUri(feedUri))) {
          return buildAppRoutePage(context, state, const InvalidRouteScreen(message: 'This feed link is invalid.'));
        }
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
      redirect: (_, state) {
        final postUri = RouteQuery(state).tryAtUri('uri');
        return _canonicalPostLocation(postUri, sourceUri: state.uri);
      },
      pageBuilder: (context, state) {
        final postUri = RouteQuery(state).tryAtUri('uri');
        if (postUri == null || !_hasCollection(postUri, _postCollection)) {
          return buildAppRoutePage(context, state, const InvalidRouteScreen(message: 'This post link is invalid.'));
        }
        return buildAppRoutePage(
          context,
          state,
          buildPostThreadRoute(context, postUri: postUri.toString(), provider: state.uri.queryParameters['provider']),
        );
      },
    ),
    GoRoute(
      path: AppRoutePath.postRecord.path,
      pageBuilder: (context, state) {
        final postUri = _postUriFromPath(state);
        if (postUri == null) {
          return buildAppRoutePage(context, state, const InvalidRouteScreen(message: 'This post link is invalid.'));
        }
        return buildAppRoutePage(
          context,
          state,
          buildPostThreadRoute(context, postUri: postUri.toString(), provider: state.uri.queryParameters['provider']),
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
          buildContextualProfileRoute(context, RouteQuery(state).decodedPathOrEmpty('actor'), provider: provider),
        );
      },
      routes: [
        GoRoute(
          path: 'post/:rkey',
          pageBuilder: (context, state) {
            final postUri = _postUriFromPath(state);
            if (postUri == null) {
              return buildAppRoutePage(context, state, const InvalidRouteScreen(message: 'This post link is invalid.'));
            }
            return buildAppRoutePage(
              context,
              state,
              buildPostThreadRoute(
                context,
                postUri: postUri.toString(),
                provider: state.uri.queryParameters['provider'],
              ),
            );
          },
        ),
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
            return buildAppRoutePage(context, state, buildProfileSearchRoute(context, actor));
          },
        ),
      ],
    ),
  ];
}

/// Builds the public home screen once the provider/tab route state is canonical.
typedef PublicHomeRouteBuilder = Widget Function(BuildContext context, PublicRouteState routeState);

/// Builds a feed detail screen with provider-aware repository wiring.
typedef FeedDetailRouteBuilder =
    Widget Function(
      BuildContext context, {
      required AtUri? feedUri,
      required String? actor,
      required String? rkey,
      required String? provider,
    });

/// Builds a post thread screen with provider-aware repository wiring.
typedef PostThreadRouteBuilder =
    Widget Function(BuildContext context, {required String postUri, required String? provider});

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

const _postCollection = 'app.bsky.feed.post';

bool _isFeedGeneratorUri(AtUri uri) => _hasCollection(uri, 'app.bsky.feed.generator') && uri.rkey.isNotEmpty;

bool _hasCollection(AtUri uri, String collection) {
  try {
    return uri.collection.toString() == collection;
  } catch (error, stackTrace) {
    log.d('Invalid AT-URI collection for public route', error: error, stackTrace: stackTrace);
    return false;
  }
}

String? _canonicalPostLocation(AtUri? uri, {required Uri sourceUri}) {
  if (uri == null || !_hasCollection(uri, _postCollection)) {
    return null;
  }

  try {
    final actor = Uri.encodeComponent(uri.hostname);
    final rkey = Uri.encodeComponent(uri.rkey);
    final query = Map<String, String>.from(sourceUri.queryParameters)..remove('uri');
    final queryString = query.isEmpty ? '' : '?${Uri(queryParameters: query).query}';
    return '/profile/$actor/post/$rkey$queryString';
  } catch (error, stackTrace) {
    log.d('Invalid AT-URI record parts for public post route', error: error, stackTrace: stackTrace);
    return null;
  }
}

AtUri? _postUriFromPath(GoRouterState state) {
  final actor = state.pathParameters['actor'];
  final rkey = state.pathParameters['rkey'];
  if (actor == null || actor.trim().isEmpty || rkey == null || rkey.trim().isEmpty) {
    return null;
  }

  try {
    return AtUri.parse('at://${Uri.decodeComponent(actor)}/$_postCollection/${Uri.decodeComponent(rkey)}');
  } catch (error, stackTrace) {
    log.d('Invalid AT-URI record path params for public post route', error: error, stackTrace: stackTrace);
    return null;
  }
}
