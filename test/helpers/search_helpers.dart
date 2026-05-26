import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:mocktail/mocktail.dart';

import 'package:lazurite/features/search/data/post_search_filters.dart';
import 'package:lazurite/features/search/data/search_repository.dart';

void stubSearchPosts(SearchRepository repository, {SearchPostsResult? result}) {
  when(
    () => repository.searchPosts(
      query: any(named: 'query'),
      sort: any(named: 'sort'),
      filters: any(named: 'filters'),
      cursor: any(named: 'cursor'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => result ?? SearchPostsResult(posts: const []));
}

void stubSearchPostsError(SearchRepository repository, Object error) {
  when(
    () => repository.searchPosts(
      query: any(named: 'query'),
      sort: any(named: 'sort'),
      filters: any(named: 'filters'),
      cursor: any(named: 'cursor'),
      limit: any(named: 'limit'),
    ),
  ).thenThrow(error);
}

List<PostSearchFilters> captureSearchFilters(SearchRepository repository) {
  final captured = verify(
    () => repository.searchPosts(
      query: any(named: 'query'),
      sort: any(named: 'sort'),
      filters: captureAny(named: 'filters'),
      cursor: any(named: 'cursor'),
      limit: any(named: 'limit'),
    ),
  ).captured;
  return captured.cast<PostSearchFilters>();
}

void stubTypeahead(SearchRepository repository, {List<ProfileViewBasic> actors = const []}) {
  when(
    () => repository.searchActorsTypeahead(
      query: any(named: 'query'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => actors);
}
