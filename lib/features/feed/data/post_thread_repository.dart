import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:bluesky/app_bsky_feed_getpostthread.dart';
import 'package:bluesky/bluesky.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';

class PostThreadRepository {
  PostThreadRepository({
    required Bluesky bluesky,
    ModerationService? moderationService,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
  }) : _bluesky = bluesky,
       _moderationService = moderationService,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       );

  final Bluesky _bluesky;
  final ModerationService? _moderationService;
  final AppViewRequestContext _appViewContext;

  Future<ThreadViewPost> getPostThread(String uri) async {
    final response = await _bluesky.feed.getPostThread(
      uri: AtUri.parse(uri),
      $headers: _appViewContext.appBskyHeaders(await _moderationService?.headersForRequest()),
    );
    final thread = response.data.thread;

    if (thread.isThreadViewPost) {
      final threadViewPost = thread.threadViewPost!;
      if (_moderationService?.shouldFilterPostInView(threadViewPost.post) ?? false) {
        throw Exception('Post hidden by moderation preferences');
      }

      return _pruneThread(threadViewPost);
    }

    if (thread.isNotFoundPost) {
      throw Exception('Post not found');
    }

    if (thread.isBlockedPost) {
      throw Exception('Post is from a blocked account');
    }

    throw Exception('Unable to load thread');
  }

  ThreadViewPost _pruneThread(ThreadViewPost thread) {
    final prunedParent = _pruneParent(thread.parent);
    final prunedReplies = thread.replies?.map(_pruneReply).whereType<UThreadViewPostReplies>().toList();

    return thread.copyWith(parent: prunedParent, replies: prunedReplies);
  }

  UThreadViewPostParent? _pruneParent(UThreadViewPostParent? parent) {
    if (parent == null) {
      return null;
    }
    if (parent.isNotThreadViewPost) {
      return parent;
    }

    final thread = parent.threadViewPost!;
    if (_moderationService?.shouldFilterPostInList(thread.post) ?? false) {
      return _pruneParent(thread.parent);
    }

    return UThreadViewPostParent.threadViewPost(data: _pruneThread(thread));
  }

  UThreadViewPostReplies? _pruneReply(UThreadViewPostReplies reply) {
    if (reply.isNotThreadViewPost) {
      return reply;
    }

    final thread = reply.threadViewPost!;
    if (_moderationService?.shouldFilterPostInList(thread.post) ?? false) {
      return null;
    }

    return UThreadViewPostReplies.threadViewPost(data: _pruneThread(thread));
  }
}
