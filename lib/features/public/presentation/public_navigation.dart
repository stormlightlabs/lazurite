import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/public/data/public_provider_context.dart';

void navigateToPublicFeed(BuildContext context, GeneratorView feed, PublicProviderContext providerContext) {
  final uri = Uri(
    path: '/feed',
    queryParameters: {'uri': feed.uri.toString(), 'provider': providerContext.providerKey},
  );
  context.push(uri.toString());
}

void navigateToPublicProfile(BuildContext context, String actor, PublicProviderContext providerContext) {
  final uri = providerContext.appendTo(Uri(path: '/profile/$actor'));
  context.push(uri.toString());
}

void navigateToPublicPost(BuildContext context, String postUri, PublicProviderContext providerContext) {
  final uri = Uri(path: '/post', queryParameters: {'uri': postUri, 'provider': providerContext.providerKey});
  context.push(uri.toString());
}
