import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/public/data/public_provider_context.dart';

class PublicProviderScope extends InheritedWidget {
  const PublicProviderScope({super.key, required this.providerKey, required super.child});

  final String providerKey;

  static PublicProviderScope? maybeOf(BuildContext context) {
    return context.findAncestorWidgetOfExactType<PublicProviderScope>();
  }

  @override
  bool updateShouldNotify(covariant PublicProviderScope oldWidget) => oldWidget.providerKey != providerKey;
}

Future<Object?> navigateToPublicFeed(BuildContext context, GeneratorView feed, PublicProviderContext providerContext) {
  return context.push(
    Uri(
      path: '/feed',
      queryParameters: {'uri': feed.uri.toString(), 'provider': providerContext.providerKey},
    ).toString(),
  );
}

void navigateToPublicProfile(BuildContext context, String actor, PublicProviderContext providerContext) {
  context.go(providerContext.appendTo(Uri(path: '/profile/$actor')).toString());
}

Future<Object?> navigateToPublicPost(BuildContext context, String postUri, PublicProviderContext providerContext) {
  return context.push(
    Uri(path: '/post', queryParameters: {'uri': postUri, 'provider': providerContext.providerKey}).toString(),
  );
}
