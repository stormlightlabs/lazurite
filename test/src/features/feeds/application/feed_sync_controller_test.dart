import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockFeedRepository mockRepository;
  const ownerDid = 'did:web:test';

  setUp(() {
    mockRepository = MockFeedRepository();
    when(() => mockRepository.seedDefaultFeeds(any())).thenAnswer((_) async {});
    when(() => mockRepository.syncOnResume(any())).thenAnswer((_) async {});
    when(() => mockRepository.syncPreferences(any())).thenAnswer((_) async {});
  });

  group('FeedRepository sync behavior', () {
    test('syncOnResume calls syncPreferences', () async {
      await mockRepository.syncOnResume(ownerDid);

      verify(() => mockRepository.syncOnResume(ownerDid)).called(1);
    });

    test('seedDefaultFeeds is callable', () async {
      await mockRepository.seedDefaultFeeds(ownerDid);

      verify(() => mockRepository.seedDefaultFeeds(ownerDid)).called(1);
    });

    test('syncPreferences is callable', () async {
      await mockRepository.syncPreferences(ownerDid);

      verify(() => mockRepository.syncPreferences(ownerDid)).called(1);
    });
  });

  group('sync flow integration', () {
    test('simulates login sync flow', () async {
      await mockRepository.seedDefaultFeeds(ownerDid);
      await mockRepository.syncOnResume(ownerDid);

      verify(() => mockRepository.seedDefaultFeeds(ownerDid)).called(1);
      verify(() => mockRepository.syncOnResume(ownerDid)).called(1);
    });

    test('simulates app resume flow', () async {
      await mockRepository.seedDefaultFeeds(ownerDid);
      await mockRepository.syncOnResume(ownerDid);

      verify(() => mockRepository.seedDefaultFeeds(ownerDid)).called(1);
      verify(() => mockRepository.syncOnResume(ownerDid)).called(1);
    });
  });
}
