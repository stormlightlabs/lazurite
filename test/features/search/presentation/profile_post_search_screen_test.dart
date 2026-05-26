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

import '../../../helpers/fixtures/feed.dart';
import '../../../helpers/search_helpers.dart';

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

    stubSearchPosts(
      searchRepository,
      result: SearchPostsResult(
        posts: [
          testPostView(
            uri: 'at://did:plc:test/app.bsky.feed.post/1',
            cid: 'cid1',
            author: testProfileViewBasic(did: 'did:plc:test', handle: 'test.bsky.social'),
            record: testPostRecordJson(text: 'hello', createdAt: DateTime.utc(2026, 1, 1)),
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

    final filters = captureSearchFilters(searchRepository).last;
    expect(filters.author, 'did:plc:fixed-author');
    expect(filters.domain, 'example.com');
  });
}
