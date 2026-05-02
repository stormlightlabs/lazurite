import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/search/data/post_search_filters.dart';

void main() {
  group('PostSearchFilters', () {
    test('normalizes trims and deduplicates tags', () {
      const filters = PostSearchFilters(
        mentions: '  did:plc:alice  ',
        author: '  alice.bsky.social ',
        tags: [' #dart ', 'flutter', '#Dart', ''],
      );

      final normalized = filters.normalized();

      expect(normalized.mentions, 'did:plc:alice');
      expect(normalized.author, 'alice.bsky.social');
      expect(normalized.tags, ['dart', 'flutter']);
    });

    test('fixed author overrides typed author', () {
      const filters = PostSearchFilters(author: 'alice.bsky.social');
      final normalized = filters.normalized(fixedAuthor: 'did:plc:fixed');
      expect(normalized.author, 'did:plc:fixed');
    });

    test('throws when since is after until', () {
      final filters = PostSearchFilters(since: DateTime.utc(2026, 1, 2), until: DateTime.utc(2026, 1, 1));

      expect(() => filters.normalized(), throwsA(isA<PostSearchValidationException>()));
    });
  });

  group('PostSearchRequest', () {
    test('throws for no-op request', () {
      const request = PostSearchRequest(query: '   ', filters: PostSearchFilters());
      expect(() => request.normalized(), throwsA(isA<PostSearchValidationException>()));
    });

    test('accepts filter-only request and normalizes query to empty', () {
      const request = PostSearchRequest(
        query: '   ',
        filters: PostSearchFilters(author: 'alice.bsky.social'),
      );
      final normalized = request.normalized();
      expect(normalized.query, '');
      expect(normalized.filters.author, 'alice.bsky.social');
    });
  });
}
