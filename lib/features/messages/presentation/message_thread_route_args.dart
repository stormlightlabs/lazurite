import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';

class MessageThreadRouteArgs {
  const MessageThreadRouteArgs({required this.title, this.convo});

  final String title;
  final ConvoView? convo;
}
