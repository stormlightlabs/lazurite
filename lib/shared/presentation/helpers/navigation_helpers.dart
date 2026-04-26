import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

Future<T?>? navigateToProfile<T>(BuildContext context, String actorDid) {
  final router = GoRouter.maybeOf(context);
  if (router == null) {
    return null;
  }

  final location = '/profile/view?actor=${Uri.encodeQueryComponent(actorDid)}';
  final currentPath = _currentPath(context);

  // Avoid pushing a second shell stack from top-level routes like `/post`.
  // That can duplicate navigator keys and trip a framework assertion.
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
      path == '/settings' ||
      path.startsWith('/settings/') ||
      path == '/search' ||
      path.startsWith('/search/') ||
      path == '/alerts' ||
      path.startsWith('/alerts/') ||
      path == '/profile' ||
      path.startsWith('/profile/');
}
