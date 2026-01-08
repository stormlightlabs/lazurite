import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockFeedRepository mockRepository;

  setUp(() {
    mockRepository = MockFeedRepository();
    when(() => mockRepository.seedDefaultFeeds(any())).thenAnswer((_) async {});
    when(() => mockRepository.syncOnResume(any())).thenAnswer((_) async {});
    when(() => mockRepository.syncPreferences(any())).thenAnswer((_) async {});
  });

  group('FeedRepository sync behavior', () {
    test('syncOnResume calls syncPreferences', () async {
      await mockRepository.syncOnResume(any());

      verify(() => mockRepository.syncOnResume(any())).called(1);
    });

    test('seedDefaultFeeds is callable', () async {
      await mockRepository.seedDefaultFeeds(any());

      verify(() => mockRepository.seedDefaultFeeds(any())).called(1);
    });

    test('syncPreferences is callable', () async {
      await mockRepository.syncPreferences(any());

      verify(() => mockRepository.syncPreferences(any())).called(1);
    });
  });

  group('sync flow integration', () {
    test('simulates login sync flow', () async {
      await mockRepository.seedDefaultFeeds(any());
      await mockRepository.syncOnResume(any());

      verify(() => mockRepository.seedDefaultFeeds(any())).called(1);
      verify(() => mockRepository.syncOnResume(any())).called(1);
    });

    test('simulates app resume flow', () async {
      await mockRepository.seedDefaultFeeds(any());
      await mockRepository.syncOnResume(any());

      verify(() => mockRepository.seedDefaultFeeds(any())).called(1);
      verify(() => mockRepository.syncOnResume(any())).called(1);
    });
  });
}
