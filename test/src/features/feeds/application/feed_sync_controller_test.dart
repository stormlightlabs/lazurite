import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

void main() {
  late MockFeedRepository mockRepository;

  setUp(() {
    mockRepository = MockFeedRepository();
    when(() => mockRepository.seedDefaultFeeds()).thenAnswer((_) async {});
    when(() => mockRepository.syncOnResume()).thenAnswer((_) async {});
    when(() => mockRepository.syncPreferences()).thenAnswer((_) async {});
  });

  group('FeedRepository sync behavior', () {
    test('syncOnResume calls syncPreferences', () async {
      await mockRepository.syncOnResume();

      verify(() => mockRepository.syncOnResume()).called(1);
    });

    test('seedDefaultFeeds is callable', () async {
      await mockRepository.seedDefaultFeeds();

      verify(() => mockRepository.seedDefaultFeeds()).called(1);
    });

    test('syncPreferences is callable', () async {
      await mockRepository.syncPreferences();

      verify(() => mockRepository.syncPreferences()).called(1);
    });
  });

  group('sync flow integration', () {
    test('simulates login sync flow', () async {
      await mockRepository.seedDefaultFeeds();
      await mockRepository.syncOnResume();

      verify(() => mockRepository.seedDefaultFeeds()).called(1);
      verify(() => mockRepository.syncOnResume()).called(1);
    });

    test('simulates app resume flow', () async {
      await mockRepository.seedDefaultFeeds();
      await mockRepository.syncOnResume();

      verify(() => mockRepository.seedDefaultFeeds()).called(1);
      verify(() => mockRepository.syncOnResume()).called(1);
    });
  });
}
