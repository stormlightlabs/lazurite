import 'package:equatable/equatable.dart';

class PostSearchValidationException implements Exception {
  const PostSearchValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PostSearchFilters extends Equatable {
  const PostSearchFilters({
    this.since,
    this.until,
    this.mentions,
    this.author,
    this.lang,
    this.domain,
    this.url,
    this.tags = const <String>[],
  });

  final DateTime? since;
  final DateTime? until;
  final String? mentions;
  final String? author;
  final String? lang;
  final String? domain;
  final String? url;
  final List<String> tags;

  static const Object _unset = Object();

  bool get isEmpty {
    return since == null &&
        until == null &&
        (mentions == null || mentions!.isEmpty) &&
        (author == null || author!.isEmpty) &&
        (lang == null || lang!.isEmpty) &&
        (domain == null || domain!.isEmpty) &&
        (url == null || url!.isEmpty) &&
        tags.isEmpty;
  }

  PostSearchFilters copyWith({
    Object? since = _unset,
    Object? until = _unset,
    Object? mentions = _unset,
    Object? author = _unset,
    Object? lang = _unset,
    Object? domain = _unset,
    Object? url = _unset,
    List<String>? tags,
  }) {
    return PostSearchFilters(
      since: identical(since, _unset) ? this.since : since as DateTime?,
      until: identical(until, _unset) ? this.until : until as DateTime?,
      mentions: identical(mentions, _unset) ? this.mentions : mentions as String?,
      author: identical(author, _unset) ? this.author : author as String?,
      lang: identical(lang, _unset) ? this.lang : lang as String?,
      domain: identical(domain, _unset) ? this.domain : domain as String?,
      url: identical(url, _unset) ? this.url : url as String?,
      tags: tags ?? this.tags,
    );
  }

  PostSearchFilters clearAll() => const PostSearchFilters();

  PostSearchFilters normalized({String? fixedAuthor}) {
    final normalizedSince = since?.toUtc();
    final normalizedUntil = until?.toUtc();
    if (normalizedSince != null && normalizedUntil != null && normalizedSince.isAfter(normalizedUntil)) {
      throw const PostSearchValidationException('"Since" must be before or equal to "Until".');
    }

    final resolvedAuthor = _trimOrNull(fixedAuthor) ?? _trimOrNull(author);

    return PostSearchFilters(
      since: normalizedSince,
      until: normalizedUntil,
      mentions: _trimOrNull(mentions),
      author: resolvedAuthor,
      lang: _trimOrNull(lang),
      domain: _trimOrNull(domain),
      url: _trimOrNull(url),
      tags: _normalizeTags(tags),
    );
  }

  String? get sinceIso => since?.toUtc().toIso8601String();

  String? get untilIso => until?.toUtc().toIso8601String();

  static List<String> _normalizeTags(List<String> raw) {
    final normalized = <String>[];
    final seen = <String>{};
    for (final value in raw) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      final tag = trimmed.startsWith('#') ? trimmed.substring(1).trim() : trimmed;
      if (tag.isEmpty) {
        continue;
      }

      final key = tag.toLowerCase();
      if (seen.add(key)) {
        normalized.add(tag);
      }
    }
    return normalized;
  }

  static String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  @override
  List<Object?> get props => [since, until, mentions, author, lang, domain, url, tags];
}

class PostSearchRequest extends Equatable {
  const PostSearchRequest({
    required this.query,
    this.sort = 'top',
    this.filters = const PostSearchFilters(),
    this.cursor,
    this.limit = 50,
  });

  final String query;
  final String sort;
  final PostSearchFilters filters;
  final String? cursor;
  final int limit;

  PostSearchRequest normalized({String? fixedAuthor}) {
    final normalizedQuery = query.trim();
    final normalizedFilters = filters.normalized(fixedAuthor: fixedAuthor);
    if (normalizedQuery.isEmpty && normalizedFilters.isEmpty) {
      throw const PostSearchValidationException('Enter a query or at least one filter.');
    }

    final normalizedSort = sort == 'latest' ? 'latest' : 'top';
    final normalizedLimit = limit.clamp(1, 100);

    return PostSearchRequest(
      query: normalizedQuery,
      sort: normalizedSort,
      filters: normalizedFilters,
      cursor: cursor,
      limit: normalizedLimit,
    );
  }

  @override
  List<Object?> get props => [query, sort, filters, cursor, limit];
}
