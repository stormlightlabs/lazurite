import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

Future<T?>? navigateToProfile<T>(BuildContext context, String actorDid) {
  final router = GoRouter.maybeOf(context);
  if (router == null) {
    return null;
  }

  return router.push<T>('/profile/view?actor=${Uri.encodeQueryComponent(actorDid)}');
}

Future<T?>? navigateToPost<T>(BuildContext context, String postUri) {
  final router = GoRouter.maybeOf(context);
  if (router == null) {
    return null;
  }

  return router.push<T>('/post?uri=${Uri.encodeQueryComponent(postUri)}');
}
