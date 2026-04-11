import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/core/embedding/embedding_service.dart';
import 'package:lazurite/features/search/data/embedding_repository.dart';
import 'package:lazurite/features/search/data/semantic_search_result.dart';

/// Performs on-device semantic (vector) search over a user's saved and liked posts.
///
/// Embeds the query using [EmbeddingService], runs an HNSW nearest-neighbour
/// search via ObjectBox, then joins each result back to [AppDatabase] to
/// hydrate the full post JSON for display.
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
  /// Returns an empty list when [EmbeddingService.isAvailable] is false or
  /// when [query] is blank.
  ///
  /// [source] narrows results to 'saved', 'liked', or both when null.
  /// [maxResults] caps the number of results (default 20).
  Future<List<SemanticSearchResult>> search(
    String query,
    String accountDid, {
    String? source,
    int maxResults = 20,
  }) async {
    if (!_embeddingService.isAvailable) return const [];
    if (query.trim().isEmpty) return const [];

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
      // Cosine distance is in [0, 2]; similarity = 1 - distance, clamped to [0, 1].
      final similarity = (1.0 - result.score).clamp(0.0, 1.0);
      final scorePercent = similarity * 100.0;

      final postJson = await _fetchPostJson(accountDid, post.postUri, post.source);
      if (postJson == null) continue;

      results.add(
        SemanticSearchResult(postUri: post.postUri, score: scorePercent, source: post.source, postJson: postJson),
      );
    }

    return results;
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
