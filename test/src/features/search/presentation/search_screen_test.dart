import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/domain/post.dart';
import 'package:lazurite/src/core/utils/pagination.dart';
import 'package:lazurite/src/features/search/application/search_providers.dart';
import 'package:lazurite/src/features/search/infrastructure/search_repository.dart';
import 'package:lazurite/src/features/search/presentation/search_screen.dart';
import 'package:lazurite/src/features/search/presentation/widgets/search_bar_widget.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart' hide Post;
import 'package:mocktail/mocktail.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

class TestApp extends StatelessWidget {
  const TestApp({required this.home, super.key});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: home);
  }
}

void main() {
  late MockSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockSearchRepository();

    when(() => mockRepository.watchRecentSearches()).thenAnswer((_) => Stream.value([]));
    when(() => mockRepository.saveRecentSearch(any())).thenAnswer((_) async {});
  });

  Widget createSubject({String? initialQuery}) {
    return ProviderScope(
      overrides: [searchRepositoryProvider.overrideWithValue(mockRepository)],
      child: TestApp(home: SearchScreen(initialQuery: initialQuery)),
    );
  }

  group('SearchScreen', () {
    testWidgets('shows recent searches when query is empty', (tester) async {
      when(() => mockRepository.watchRecentSearches()).thenAnswer(
        (_) => Stream.value([
          RecentSearche(
            id: 1,
            query: 'flutter',
            searchedAt: DateTime.now(),
            ownerDid: 'did:plc:test',
          ),
          RecentSearche(
            id: 2,
            query: 'dart',
            searchedAt: DateTime.now(),
            ownerDid: 'did:plc:test',
          ),
        ]),
      );

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Recent Searches'), findsOneWidget);
      expect(find.text('flutter'), findsOneWidget);
      expect(find.text('dart'), findsOneWidget);
      expect(find.byType(SearchBarWidget), findsOneWidget);
    });

    testWidgets('shows empty state when no recent searches', (tester) async {
      when(() => mockRepository.watchRecentSearches()).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Search for posts and people'), findsOneWidget);
      expect(find.text('Type a query to find posts or people'), findsOneWidget);
    });

    testWidgets('performs search and shows results', (tester) async {
      const query = 'bluesky';
      final posts = [
        Post(
          uri: 'at://did:plc:123/app.bsky.feed.post/1',
          cid: 'cid1',
          author: const Author(did: 'did:plc:123', handle: 'alice.test', displayName: 'Alice'),
          record: {},
          text: 'Hello Bluesky!',
          indexedAt: DateTime.now(),
        ),
      ];
      final result = PaginatedResult(items: posts, cursor: null);

      when(() => mockRepository.searchPosts(query, cursor: null)).thenAnswer((_) async => result);
      when(
        () => mockRepository.searchActors(query, cursor: null),
      ).thenAnswer((_) async => const PaginatedResult(items: [], cursor: null));

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), query);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('Posts'), findsOneWidget);
      expect(find.text('People'), findsOneWidget);

      expect(find.text('Hello Bluesky!'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);

      verify(() => mockRepository.searchPosts(query, cursor: null)).called(1);
    });

    testWidgets('initial query populates search bar and results', (tester) async {
      const query = 'initial';
      when(
        () => mockRepository.searchPosts(query, cursor: null),
      ).thenAnswer((_) async => const PaginatedResult(items: [], cursor: null));
      when(
        () => mockRepository.searchActors(query, cursor: null),
      ).thenAnswer((_) async => const PaginatedResult(items: [], cursor: null));

      await tester.pumpWidget(createSubject(initialQuery: query));
      await tester.pumpAndSettle();

      expect(find.text(query), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('clearing search returns to recent searches', (tester) async {
      const query = 'test';
      when(
        () => mockRepository.searchPosts(query, cursor: null),
      ).thenAnswer((_) async => const PaginatedResult(items: [], cursor: null));
      when(
        () => mockRepository.searchActors(query, cursor: null),
      ).thenAnswer((_) async => const PaginatedResult(items: [], cursor: null));

      await tester.pumpWidget(createSubject(initialQuery: query));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.clear), findsOneWidget);
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('Search for posts and people'), findsOneWidget);
      expect(find.byType(TabBar), findsNothing);
    });

    testWidgets('switches between Posts and People tabs', (tester) async {
      const query = 'test';
      when(
        () => mockRepository.searchPosts(query, cursor: null),
      ).thenAnswer((_) async => const PaginatedResult(items: [], cursor: null));
      when(
        () => mockRepository.searchActors(query, cursor: null),
      ).thenAnswer((_) async => const PaginatedResult(items: [], cursor: null));

      await tester.pumpWidget(createSubject(initialQuery: query));
      await tester.pumpAndSettle();

      expect(find.text('No posts found'), findsOneWidget);

      await tester.tap(find.text('People'));
      await tester.pumpAndSettle();

      expect(find.text('No people found'), findsOneWidget);
    });

    testWidgets('retry on error', (tester) async {
      const query = 'error';
      when(() => mockRepository.searchPosts(query, cursor: null)).thenThrow('Network Error');
      when(
        () => mockRepository.searchActors(query, cursor: null),
      ).thenAnswer((_) async => const PaginatedResult(items: [], cursor: null));

      await tester.pumpWidget(createSubject(initialQuery: query));
      await tester.pumpAndSettle();

      expect(find.text('Error: Network Error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump(); // Start retry
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => mockRepository.searchPosts(query, cursor: null)).called(greaterThan(1));
    });
  });
}
