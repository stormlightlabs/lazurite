import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/search/application/search_providers.dart';
import 'package:lazurite/src/features/search/infrastructure/search_repository.dart';
import 'package:lazurite/src/features/search/presentation/search_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late MockSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockSearchRepository();
  });

  Widget createSubject() {
    return ProviderScope(
      overrides: [searchRepositoryProvider.overrideWithValue(mockRepository)],
      child: const MaterialApp(home: SearchScreen()),
    );
  }

  group('SearchScreen', () {
    testWidgets('renders search bar', (tester) async {
      when(() => mockRepository.watchRecentSearches()).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createSubject());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders search icon', (tester) async {
      when(() => mockRepository.watchRecentSearches()).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createSubject());
      await tester.pump();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}
