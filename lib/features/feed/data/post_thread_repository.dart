import 'package:poptart_core/poptart_core.dart' as atcore;
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/get_post_thread.dart';
import 'package:lazurite/core/cache/poptart_cache_codecs.dart';
import 'package:lazurite/core/cache/offline_cache_policy.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/unauthorized_recovery_runner.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';

class PostThreadRepository {
  PostThreadRepository({
    required Bluesky bluesky,
    required AppDatabase database,
    required String accountDid,
    ModerationService? moderationService,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
    Future<AuthTokens?> Function()? onUnauthorized,
    Bluesky? Function(AuthTokens tokens)? blueskyClientFactory,
  }) : _database = database,
       _accountDid = accountDid,
       _moderationService = moderationService,
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       ) {
    _authRecovery = UnauthorizedRecoveryRunner<Bluesky>(
      initialClient: bluesky,
      onUnauthorized: onUnauthorized,
      clientFactory: blueskyClientFactory ?? createBlueskyClient,
      onUnauthorizedException: (error, stackTrace) {
        log.w('thread.auth unauthorized; attempting session recovery', error: error, stackTrace: stackTrace);
      },
    );
  }

  late final UnauthorizedRecoveryRunner<Bluesky> _authRecovery;
  final AppDatabase _database;
  final String _accountDid;
  final ModerationService? _moderationService;
  final AppViewRequestContext _appViewContext;

  Future<ThreadViewPost> getPostThread(String uri) async {
    try {
      final headers = _appViewContext.appBskyHeadersForEndpoint(
        'app.bsky.feed.getPostThread',
        await _moderationService?.headersForRequest(),
      );
      final response = await _authRecovery.run(
        (client) => client.feed.getPostThread(uri: atcore.AtUri.parse(uri), $headers: headers),
      );
      final thread = response.data.thread;

      if (thread.isThreadViewPost) {
        final threadViewPost = thread.threadViewPost!;
        if (_moderationService?.shouldFilterPostInView(threadViewPost.post) ?? false) {
          throw Exception('Post hidden by moderation preferences');
        }

        final pruned = _pruneThread(threadViewPost);
        await _cacheThread(pruned);
        return pruned;
      }

      if (thread.isNotFoundPost) {
        throw Exception('Post not found');
      }

      if (thread.isBlockedPost) {
        throw Exception('Post is from a blocked account');
      }
    } catch (error, stackTrace) {
      final cached = await _loadCachedThread(uri);
      if (cached != null) {
        log.w('Using cached thread after request failure: $error', error: error, stackTrace: stackTrace);
        return cached;
      }
      rethrow;
    }

    throw Exception('Unable to load thread');
  }

  Future<void> _cacheThread(ThreadViewPost thread) async {
    final rootUri = _threadRoot(thread).post.uri.toString();
    await _database.cacheThreadRoot(
      accountDid: _accountDid,
      rootUri: rootUri,
      payload: PoptartCacheCodecs.threadViewPost.encode(thread),
    );
    await _database.pruneCachedThreadRoots(_accountDid, OfflineCachePolicy.threadRootLimit);
  }

  Future<ThreadViewPost?> _loadCachedThread(String requestedUri) async {
    final direct = await _database.getCachedThreadRoot(_accountDid, requestedUri);
    if (direct != null) {
      try {
        return PoptartCacheCodecs.threadViewPost.decode(direct.payload);
      } catch (error, stackTrace) {
        log.d(
          'thread.cache failed to decode direct snapshot for requestedUri=$requestedUri',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    final all = await (_database.select(
      _database.cachedThreadRoots,
    )..where((row) => row.accountDid.equals(_accountDid))).get();
    for (final candidate in all) {
      try {
        final decoded = PoptartCacheCodecs.threadViewPost.decode(candidate.payload);
        if (_containsPostUri(decoded, requestedUri)) {
          return decoded;
        }
      } catch (error, stackTrace) {
        log.d(
          'thread.cache failed to decode snapshot while scanning rootUri=${candidate.rootUri} for requestedUri=$requestedUri',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return null;
  }

  bool _containsPostUri(ThreadViewPost thread, String postUri) {
    if (thread.post.uri.toString() == postUri) {
      return true;
    }
    final parent = thread.parent;
    if (parent != null && parent.isThreadViewPost && _containsPostUri(parent.threadViewPost!, postUri)) {
      return true;
    }
    final replies = thread.replies;
    if (replies != null) {
      for (final reply in replies) {
        if (reply.isThreadViewPost && _containsPostUri(reply.threadViewPost!, postUri)) {
          return true;
        }
      }
    }
    return false;
  }

  ThreadViewPost _threadRoot(ThreadViewPost thread) {
    var current = thread;
    while (current.parent != null && current.parent!.isThreadViewPost) {
      current = current.parent!.threadViewPost!;
    }
    return current;
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
