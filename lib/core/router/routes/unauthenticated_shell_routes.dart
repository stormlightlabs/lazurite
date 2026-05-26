import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/router/app_route_page.dart';
import 'package:lazurite/core/router/app_route_paths.dart';
import 'package:lazurite/core/router/content_route_factory.dart';
import 'package:lazurite/core/router/routes/public_routes.dart';
import 'package:lazurite/core/router/routes/settings_routes.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/auth/presentation/login_screen.dart';
import 'package:lazurite/features/public/presentation/public_route_state.dart';
import 'package:lazurite/features/public/presentation/unauthenticated_shell.dart';

/// Builds the logged-out shell and its public browsing branches.
///
/// The unauthenticated shell has its own branch navigators and receives enough
/// route state to keep the public home tab/provider selection coherent while
/// blocking authenticated-only child routes back to their public parent.
StatefulShellRoute buildUnauthenticatedShellRoute({
  required AuthBloc authBloc,
  required GlobalKey<NavigatorState> homeNavigatorKey,
  required GlobalKey<NavigatorState> explorerNavigatorKey,
  required GlobalKey<NavigatorState> settingsNavigatorKey,
  required GlobalKey<NavigatorState> loginNavigatorKey,
  required ContentRouteFactory contentRouteFactory,
  required Future<AuthTokens?> Function()? onUnauthorized,
  required Widget Function(BuildContext context, GoRouterState state) buildDevToolsRoute,
}) {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      if (authBloc.state.isAuthenticated) {
        return navigationShell;
      }

      return UnauthenticatedShell(
        location: state.uri.path,
        publicProviderKey: _publicProviderFromState(state),
        publicHomeLocation: _publicHomeLocationForState(state),
        navigationShell: navigationShell,
      );
    },
    branches: [
      StatefulShellBranch(
        navigatorKey: homeNavigatorKey,
        routes: [
          ...buildPublicRoutes(
            authBloc: authBloc,
            buildPublicHomeRoute: contentRouteFactory.publicHome,
            buildFeedDetailRoute: contentRouteFactory.feedDetail,
            buildPostThreadRoute: contentRouteFactory.postThread,
            buildTopicRoute: contentRouteFactory.topic,
            buildContextualProfileRoute: contentRouteFactory.contextualProfile,
            buildProfileConnectionsRoute: contentRouteFactory.profileConnections,
            buildProfileSearchRoute: contentRouteFactory.profileSearch,
            publicProfileLocation: _publicProfileLocation,
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: explorerNavigatorKey,
        routes: [
          GoRoute(
            path: AppRoutePath.settingsDevTools.path,
            pageBuilder: (context, state) => buildAppRoutePage(context, state, buildDevToolsRoute(context, state)),
          ),
        ],
      ),
      StatefulShellBranch(
        navigatorKey: settingsNavigatorKey,
        routes: [...buildSettingsRoutes(onUnauthorized: onUnauthorized)],
      ),
      StatefulShellBranch(
        navigatorKey: loginNavigatorKey,
        routes: [
          GoRoute(
            path: AppRoutePath.login.path,
            pageBuilder: (context, state) {
              final initialHandle = state.uri.queryParameters['handle']?.trim();
              final hasInitialHandle = initialHandle != null && initialHandle.isNotEmpty;
              final autoStartOAuth = state.uri.queryParameters['reauth'] == '1' && hasInitialHandle;
              return buildAppRoutePage(
                context,
                state,
                LoginScreen(
                  initialHandle: hasInitialHandle ? initialHandle : null,
                  initialProviderKey: state.uri.queryParameters['provider'],
                  autoStartOAuth: autoStartOAuth,
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}

String _publicProfileLocation(GoRouterState state) {
  final actor = Uri.decodeComponent(state.pathParameters['actor'] ?? '').trim();
  final encodedActor = Uri.encodeComponent(actor);
  final provider = state.uri.queryParameters['provider'];
  final providerQuery = provider == null ? '' : '?provider=${Uri.encodeQueryComponent(provider)}';
  return '/profile/$encodedActor$providerQuery';
}

String? _publicHomeLocationFromQuery(GoRouterState state) {
  final rawLocation = state.uri.queryParameters['publicHome']?.trim();
  if (rawLocation == null || rawLocation.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(rawLocation);
  final segments = uri?.pathSegments;
  if (segments == null || segments.length != 3 || segments.first != 'public') {
    return null;
  }

  final routeState = PublicRouteState.parse(provider: segments[1], tab: segments[2]);
  return routeState.location;
}

String? _publicHomeLocationForState(GoRouterState state) {
  final queryHome = _publicHomeLocationFromQuery(state);
  if (queryHome != null) {
    return queryHome;
  }

  final segments = state.uri.pathSegments;
  if (segments.length == 3 && segments.first == 'public') {
    return PublicRouteState.parse(provider: segments[1], tab: segments[2]).location;
  }

  final provider = _publicProviderFromState(state);
  if (provider == null) {
    return null;
  }

  return PublicRouteState(providerKey: provider, contentTab: PublicContentTab.discover).location;
}

String? _publicProviderFromState(GoRouterState state) {
  final queryProvider = state.uri.queryParameters['provider'];
  if (PublicRouteState.isSupportedProvider(queryProvider)) {
    return PublicRouteState.normalizeProvider(queryProvider);
  }

  final segments = state.uri.pathSegments;
  if (segments.length >= 2 && segments.first == 'public' && PublicRouteState.isSupportedProvider(segments[1])) {
    return PublicRouteState.normalizeProvider(segments[1]);
  }

  return null;
}
