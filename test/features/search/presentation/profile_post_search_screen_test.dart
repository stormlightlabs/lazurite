import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/search/bloc/search_bloc.dart';
import 'package:lazurite/features/search/data/post_search_filters.dart';
import 'package:lazurite/features/search/data/search_repository.dart';
import 'package:lazurite/features/search/presentation/search_screen.dart';
import 'package:lazurite/features/typeahead/data/typeahead_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

class MockTypeaheadRepository extends Mock implements TypeaheadRepository {}

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late MockSearchRepository searchRepository;
  late MockTypeaheadRepository typeaheadRepository;
  late MockAppDatabase database;

  setUpAll(() {
    registerFallbackValue(const PostSearchFilters());
  });

  setUp(() {
    searchRepository = MockSearchRepository();
    typeaheadRepository = MockTypeaheadRepository();
    database = MockAppDatabase();

    when(
      () => searchRepository.searchPosts(
        query: any(named: 'query'),
        sort: any(named: 'sort'),
        filters: any(named: 'filters'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => SearchPostsResult(
        posts: [
          PostView(
            uri: AtUri.parse('at://did:plc:test/app.bsky.feed.post/1'),
            cid: 'cid1',
            author: const ProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social'),
            record: const {r'$type': 'app.bsky.feed.post', 'text': 'hello', 'createdAt': '2026-01-01T00:00:00.000Z'},
            indexedAt: DateTime.utc(2026, 1, 1),
          ),
        ],
      ),
    );
  });

  testWidgets('uses fixed author in scoped mode and hides jump-to-profile action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => SearchBloc(
            searchRepository: searchRepository,
            typeaheadRepository: typeaheadRepository,
            database: database,
            accountDid: 'did:plc:viewer',
            config: const SearchBlocConfig.profileScoped(fixedPostAuthor: 'did:plc:fixed-author'),
          ),
          child: const SearchScreen(
            postsOnlyMode: true,
            fixedPostAuthor: 'did:plc:fixed-author',
            showBackButton: true,
            title: 'Search @fixed',
            showJumpToProfileAction: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jump to profile'), findsNothing);

    verify(
      () => searchRepository.searchPosts(
        query: '',
        sort: 'latest',
        filters: any(named: 'filters'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).called(1);

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();

    expect(find.text('Author (fixed)'), findsOneWidget);
    expect(find.text('did:plc:fixed-author'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Domain'), 'example.com');
    await tester.ensureVisible(find.text('Apply'));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    final captured = verify(
      () => searchRepository.searchPosts(
        query: any(named: 'query'),
        sort: any(named: 'sort'),
        filters: captureAny(named: 'filters'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).captured;

    final PostSearchFilters filters = captured.last as PostSearchFilters;
    expect(filters.author, 'did:plc:fixed-author');
    expect(filters.domain, 'example.com');
  });
}
