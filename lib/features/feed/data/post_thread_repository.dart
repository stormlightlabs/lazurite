import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_getpostthread.dart';
import 'package:bluesky/bluesky.dart';

class PostThreadRepository {
  PostThreadRepository({required Bluesky bluesky}) : _bluesky = bluesky;

  final Bluesky _bluesky;

  Future<ThreadViewPost> getPostThread(String uri) async {
    final response = await _bluesky.feed.getPostThread(uri: AtUri.parse(uri));
    final thread = response.data.thread;

    if (thread.isThreadViewPost) {
      return thread.threadViewPost!;
    }

    if (thread.isNotFoundPost) {
      throw Exception('Post not found');
    }

    if (thread.isBlockedPost) {
      throw Exception('Post is from a blocked account');
    }

    throw Exception('Unable to load thread');
  }
}
