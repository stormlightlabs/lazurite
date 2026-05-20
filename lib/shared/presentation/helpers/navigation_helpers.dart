import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/public/presentation/public_navigation.dart';

/// Profile navigation helper
///
/// The current user's profile lives inside the stateful app shell as the
/// Profile tab root. Other profiles are contextual detail routes on the root
/// navigator, so pushing them preserves the caller's back stack.
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
  String? currentUserDid;
  try {
    currentUserDid = context.read<String>();
  } catch (_) {
    currentUserDid = null;
  }

  if (currentUserDid != null && normalizedActor == currentUserDid) {
    router.go('/profile/me');
    return null;
  }

  final encodedActor = Uri.encodeComponent(normalizedActor);
  final publicProviderKey = PublicProviderScope.maybeOf(context)?.providerKey;
  final providerQuery = publicProviderKey == null ? '' : '?provider=${Uri.encodeQueryComponent(publicProviderKey)}';
  final location = '/profile/$encodedActor$providerQuery';
  return router.push<T>(location);
}

Future<T?>? navigateToPost<T>(BuildContext context, String postUri) {
  final router = GoRouter.maybeOf(context);
  if (router == null) {
    return null;
  }

  return router.push<T>('/post?uri=${Uri.encodeQueryComponent(postUri)}');
}

Future<T?>? navigateToSettings<T>(BuildContext context) {
  final router = GoRouter.maybeOf(context);
  if (router == null) {
    return null;
  }

  return router.push<T>('/settings');
}
