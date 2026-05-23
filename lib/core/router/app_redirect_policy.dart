import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/router/app_route_paths.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/public/presentation/public_route_state.dart';

/// Applies global authentication and public-browsing redirects for the app.
///
/// This policy sits in front of the route graph. It decides whether a location
/// may be viewed without an authenticated account, where logged-out users should
/// land, and how to keep authenticated users out of the normal login flow.
/// Route builders remain responsible for feature-specific validation after this
/// policy allows navigation to continue.
class AppRedirectPolicy {
  const AppRedirectPolicy({required this.authBloc});

  final AuthBloc authBloc;

  /// Returns a replacement location for [state], or `null` to allow navigation.
  ///
  /// The data flow is intentionally one-way: auth state and URL state are read,
  /// then a canonical location is returned. No repositories or feature widgets
  /// are created here, which keeps redirect behavior cheap and predictable.
  String? redirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = authBloc.state.isAuthenticated;
    final path = state.uri.path;
    final isLoggingIn = path == AppRoutePath.login.path;
    final isReauthLogin = state.uri.queryParameters['reauth'] == '1';
    final isPublicPath = _isPublicPath(path);

    if (!isAuthenticated && path == AppRoutePath.home.path) {
      return const PublicRouteState(
        providerKey: AppViewProviders.blueskyKey,
        contentTab: PublicContentTab.discover,
      ).location;
    }

    if (!isAuthenticated && !isPublicPath) {
      return AppRoutePath.login.path;
    }

    if (isAuthenticated && isLoggingIn && !isReauthLogin) {
      return AppRoutePath.home.path;
    }

    return null;
  }

  bool _isPublicPath(String path) {
    final publicPaths = {
      AppRoutePath.login.path,
      AppRoutePath.settings.path,
      AppRoutePath.settingsAbout.path,
      AppRoutePath.settingsLogs.path,
      AppRoutePath.settingsDevTools.path,
      AppRoutePath.terms.path,
      AppRoutePath.privacy.path,
      AppRoutePath.feed.path,
      AppRoutePath.post.path,
      AppRoutePath.topic.path,
      AppRoutePath.images.path,
      AppRoutePath.video.path,
      AppRoutePath.oauthCallback.path,
      AppRoutePath.oauthCallbackCompatibility.path,
    };
    final isPublicBrowsingPath = path == AppRoutePath.public.path || path.startsWith('${AppRoutePath.public.path}/');
    final isPublicProfilePath = path.startsWith('/profile/') && path != AppRoutePath.profileMe.path;
    return publicPaths.contains(path) || isPublicBrowsingPath || isPublicProfilePath;
  }
}
