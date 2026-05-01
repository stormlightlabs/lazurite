import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Profile navigation helper
///
/// This avoids pushing a second shell stack from top-level routes like `/post`,
/// that can duplicate navigator keys and trip a framework assertion.
Future<T?>? navigateToProfile<T>(BuildContext context, String actorDid) {
  final router = GoRouter.maybeOf(context);
  if (router == null) {
    return null;
  }

  final actor = actorDid.trim();
  if (actor.isEmpty) {
    return null;
  }

  final normalizedActor = actor.startsWith('@') ? actor.substring(1) : actor;
  final location = '/profile/${Uri.encodeComponent(normalizedActor)}';
  final currentPath = _currentPath(context);

  if (!_isStatefulShellPath(currentPath)) {
    router.go(location);
    return null;
  }

  return router.push<T>(location);
}

Future<T?>? navigateToPost<T>(BuildContext context, String postUri) {
  final router = GoRouter.maybeOf(context);
  if (router == null) {
    return null;
  }

  return router.push<T>('/post?uri=${Uri.encodeQueryComponent(postUri)}');
}

String _currentPath(BuildContext context) {
  try {
    return GoRouterState.of(context).uri.path;
  } catch (_) {
    return '';
  }
}

bool _isStatefulShellPath(String path) {
  if (path == '/') {
    return true;
  }

  return path == '/feeds' ||
      path.startsWith('/feeds/') ||
      path == '/feed' ||
      path.startsWith('/feed/') ||
      path == '/trending' ||
      path.startsWith('/trending/') ||
      path == '/settings' ||
      path.startsWith('/settings/') ||
      path == '/search' ||
      path.startsWith('/search/') ||
      path == '/alerts' ||
      path.startsWith('/alerts/') ||
      path.startsWith('/profile/');
}
