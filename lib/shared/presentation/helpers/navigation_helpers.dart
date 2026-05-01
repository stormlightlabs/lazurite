import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Profile navigation helper
///
/// Profile routes live inside the stateful app shell. Using imperative `push`
/// for shell destinations can stack a second shell instance and collide
/// navigator keys. Always use declarative `go` for profile navigation.
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
  router.go(location);
  return null;
}

Future<T?>? navigateToPost<T>(BuildContext context, String postUri) {
  final router = GoRouter.maybeOf(context);
  if (router == null) {
    return null;
  }

  return router.push<T>('/post?uri=${Uri.encodeQueryComponent(postUri)}');
}
