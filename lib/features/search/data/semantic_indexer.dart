import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math' show min;
import 'dart:typed_data';

import 'package:poptart_lex/app/bsky/feed/defs.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/embedding/embedding_service.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/objectbox/embedded_post.dart';
import 'package:lazurite/features/search/data/embedding_repository.dart';
import 'package:lazurite/features/search/data/post_text_extractor.dart';

class _IndexRequest {
  const _IndexRequest({required this.postUri, required this.postJson, required this.accountDid, required this.source});

  final String postUri;
  final String postJson;
  final String accountDid;
  final String source;
}

/// Orchestrates text extraction, embedding, and ObjectBox storage for posts.
///
/// Call [indexPost] or [queueIndexPost] when a post is saved/liked.
/// Call [removePost] when a post is un-saved or un-liked.
/// Call [backfill] to index all un-indexed posts for an account.
class SemanticIndexer {
  SemanticIndexer({
    required EmbeddingService embeddingService,
    required EmbeddingRepository embeddingRepository,
    required AppDatabase database,
    PostTextExtractor textExtractor = const PostTextExtractor(),
  }) : _embeddingService = embeddingService,
       _embeddingRepository = embeddingRepository,
       _database = database,
       _textExtractor = textExtractor;

  final EmbeddingService _embeddingService;
  final EmbeddingRepository _embeddingRepository;
  final AppDatabase _database;
  final PostTextExtractor _textExtractor;

  final Queue<_IndexRequest> _queue = Queue();
  bool _draining = false;

  /// Initialize the underlying [EmbeddingService].
  ///
  /// Safe to call multiple times; subsequent calls are no-ops (delegated to
  /// the service). Must be called before [indexPost], [queueIndexPost], or
  /// [backfill] will do anything meaningful.
  Future<void> initialize() => _embeddingService.initialize();

  /// Embed [postJson] and store in ObjectBox.
  ///
  /// A no-op when [EmbeddingService.isAvailable] is false or the extracted
  /// text is empty. Throws if embedding inference fails.
  Future<void> indexPost(String postUri, String postJson, String accountDid, String source) async {
    if (!_embeddingService.isAvailable) return;

    final text = _extractText(postJson);
    if (text.isEmpty) return;

    final embedding = await _embeddingService.embed(text);

    _embeddingRepository.upsert(
      EmbeddedPost(
        postUri: postUri,
        accountDid: accountDid,
        source: source,
        indexedText: text,
        embedding: _toDoubleList(embedding),
        embeddedAt: DateTime.now(),
      ),
    );
  }

  /// Enqueue [postJson] for background indexing without blocking the caller.
  ///
  /// Items are processed serially in arrival order.
  /// A no-op when [EmbeddingService.isAvailable] is false.
  void queueIndexPost(String postUri, String postJson, String accountDid, String source) {
    if (!_embeddingService.isAvailable) return;
    _queue.add(_IndexRequest(postUri: postUri, postJson: postJson, accountDid: accountDid, source: source));
    unawaited(_drainQueue());
  }

  /// Remove [postUri] from the embedding index.
  void removePost(String postUri) {
    _embeddingRepository.deleteByUri(postUri);
  }

  /// Batch-embed all un-indexed saved and liked posts for [accountDid].
  ///
  /// Processes in chunks of 50, yielding to the event loop between chunks.
  /// Emits `(completed, total)` progress tuples as work proceeds.
  /// Completes immediately when [EmbeddingService.isAvailable] is false.
  Stream<(int, int)> backfill(String accountDid) async* {
    if (!_embeddingService.isAvailable) return;

    final savedPosts = await _database.getSavedPosts(accountDid);
    final likedPosts = await _getAllLikedPosts(accountDid);

    final indexed = _embeddingRepository.queryByAccount(accountDid).map((p) => p.postUri).toSet();

    final toIndex = <_IndexRequest>[
      for (final p in savedPosts)
        if (!indexed.contains(p.postUri))
          _IndexRequest(postUri: p.postUri, postJson: p.postJson, accountDid: accountDid, source: 'saved'),
      for (final p in likedPosts)
        if (!indexed.contains(p.postUri))
          _IndexRequest(postUri: p.postUri, postJson: p.postJson, accountDid: accountDid, source: 'liked'),
    ];

    final total = toIndex.length;
    var completed = 0;

    const chunkSize = 50;
    for (var i = 0; i < toIndex.length; i += chunkSize) {
      final chunk = toIndex.sublist(i, min(i + chunkSize, toIndex.length));
      for (final req in chunk) {
        try {
          await indexPost(req.postUri, req.postJson, req.accountDid, req.source);
        } catch (e) {
          log.d('Failed to backfill ${req.postUri}: $e');
        }
        completed++;
        yield (completed, total);
      }
      await Future<void>.delayed(Duration.zero);
    }
  }

  Future<void> _drainQueue() async {
    if (_draining) return;
    _draining = true;
    while (_queue.isNotEmpty) {
      final req = _queue.removeFirst();
      try {
        await indexPost(req.postUri, req.postJson, req.accountDid, req.source);
      } catch (e) {
        log.d('Failed to index ${req.postUri}: $e');
      }
    }
    _draining = false;
  }

  Future<List<LikedPostEntry>> _getAllLikedPosts(String accountDid) async {
    final results = <LikedPostEntry>[];
    var offset = 0;
    const pageSize = 100;
    while (true) {
      final page = await _database.getLikedPosts(accountDid, limit: pageSize, offset: offset);
      results.addAll(page);
      if (page.length < pageSize) break;
      offset += pageSize;
    }
    return results;
  }

  String _extractText(String postJson) {
    try {
      final map = jsonDecode(postJson) as Map<String, dynamic>;
      final postView = _resolvePostView(map);
      if (postView == null) return '';
      return _textExtractor.extract(postView);
    } catch (_) {
      return '';
    }
  }

  /// Resolves a [PostView] from a raw JSON map.
  ///
  /// Handles two formats:
  /// - FeedViewPost JSON (liked posts): top-level `post` key maps to PostView.
  /// - PostView JSON (saved posts): parsed directly.
  PostView? _resolvePostView(Map<String, dynamic> map) {
    final nested = map['post'];
    if (nested is Map<String, dynamic>) {
      try {
        return PostView.fromJson(nested);
      } catch (_) {}
    }
    try {
      return PostView.fromJson(map);
    } catch (_) {}
    return null;
  }

  List<double> _toDoubleList(Float32List embedding) => embedding.toList();
}
