import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/embedding/embedding_service.dart';
import 'package:lazurite/features/search/data/embedding_repository.dart';
import 'package:lazurite/features/search/data/semantic_search_result.dart';

/// Performs on-device semantic (vector) search over a user's saved and liked posts.
///
/// Runs keyword matching first (handle + content), then augments with
/// semantic nearest-neighbour matches when embeddings are available.
class SemanticSearchRepository {
  SemanticSearchRepository({
    required EmbeddingService embeddingService,
    required EmbeddingRepository embeddingRepository,
    required AppDatabase database,
  }) : _embeddingService = embeddingService,
       _embeddingRepository = embeddingRepository,
       _database = database;

  final EmbeddingService _embeddingService;
  final EmbeddingRepository _embeddingRepository;
  final AppDatabase _database;

  /// Search for posts semantically similar to [query].
  ///
  /// Returns an empty list when [EmbeddingService.isAvailable] is false
  /// or when [query] is blank.
  ///
  /// [source] narrows results to 'saved', 'liked', or both when null.
  /// [maxResults] caps the number of results (default 20).
  Future<List<SemanticSearchResult>> search(
    String query,
    String accountDid, {
    String? source,
    int maxResults = 20,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty || maxResults <= 0) return const [];

    final keywordResults = await _keywordSearch(normalizedQuery, accountDid, source: source, maxResults: maxResults);
    if (!_embeddingService.isAvailable) {
      return keywordResults.take(maxResults).toList(growable: false);
    }

    try {
      final semanticResults = await _semanticSearch(
        normalizedQuery,
        accountDid,
        source: source,
        maxResults: maxResults,
      );
      return _mergeResults(keywordResults, semanticResults, maxResults);
    } catch (_) {
      return keywordResults.take(maxResults).toList(growable: false);
    }
  }

  Future<List<SemanticSearchResult>> _keywordSearch(
    String query,
    String accountDid, {
    String? source,
    required int maxResults,
  }) async {
    final matches = await _database.searchPostsByKeyword(
      accountDid: accountDid,
      query: query,
      source: source,
      limit: maxResults,
    );

    final results = <SemanticSearchResult>[];
    for (var index = 0; index < matches.length; index++) {
      final match = matches[index];
      final postJson = await _fetchPostJson(accountDid, match.postUri, match.source);
      if (postJson == null) {
        continue;
      }

      final score = (90.0 - (index * 2.5)).clamp(55.0, 95.0).toDouble();
      results.add(SemanticSearchResult(postUri: match.postUri, score: score, source: match.source, postJson: postJson));
    }
    return results;
  }

  Future<List<SemanticSearchResult>> _semanticSearch(
    String query,
    String accountDid, {
    String? source,
    required int maxResults,
  }) async {
    final queryVector = await _embeddingService.embed(query);
    final rawResults = _embeddingRepository.nearestNeighbors(
      queryVector,
      accountDid,
      source: source,
      maxResults: maxResults,
    );

    final results = <SemanticSearchResult>[];
    for (final result in rawResults) {
      final post = result.object;
      final similarity = (1.0 - result.score).clamp(0.0, 1.0);
      final scorePercent = (similarity * 99.0) + 1.0;
      final postJson = await _fetchPostJson(accountDid, post.postUri, post.source);
      if (postJson == null) continue;
      results.add(
        SemanticSearchResult(postUri: post.postUri, score: scorePercent, source: post.source, postJson: postJson),
      );
    }
    return results;
  }

  List<SemanticSearchResult> _mergeResults(
    List<SemanticSearchResult> keywordResults,
    List<SemanticSearchResult> semanticResults,
    int maxResults,
  ) {
    final merged = <SemanticSearchResult>[];
    final seen = <String>{};

    void addUnique(SemanticSearchResult result) {
      final key = '${result.source}|${result.postUri}';
      if (!seen.add(key)) return;
      merged.add(result);
    }

    for (final result in keywordResults) {
      addUnique(result);
      if (merged.length >= maxResults) return merged;
    }
    for (final result in semanticResults) {
      addUnique(result);
      if (merged.length >= maxResults) return merged;
    }

    return merged;
  }

  Future<String?> _fetchPostJson(String accountDid, String postUri, String source) async {
    if (source == 'saved') {
      final entry = await _database.getSavedPost(accountDid, postUri);
      return entry?.postJson;
    } else {
      final entry = await _database.getLikedPost(accountDid, postUri);
      return entry?.postJson;
    }
  }
}
