import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/features/settings/application/settings_providers.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockBlueskyPreferencesRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockBlueskyPreferencesRepository();

    container = ProviderContainer(
      overrides: [blueskyPreferencesRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('settings providers', () {
    test('adultContentPrefProvider calls repository watch method', () {
      const expectedPref = AdultContentPref(enabled: true);
      when(
        () => mockRepository.watchAdultContentPref(),
      ).thenAnswer((_) => Stream.value(expectedPref));

      container.listen(adultContentPrefProvider, (prev, next) {});

      verify(() => mockRepository.watchAdultContentPref()).called(1);
    });

    test('contentLabelPrefsProvider calls repository watch method', () {
      const expectedPrefs = ContentLabelPrefs.empty;
      when(
        () => mockRepository.watchContentLabelPrefs(),
      ).thenAnswer((_) => Stream.value(expectedPrefs));

      container.listen(contentLabelPrefsProvider, (prev, next) {});

      verify(() => mockRepository.watchContentLabelPrefs()).called(1);
    });

    test('labelersPrefProvider calls repository watch method', () {
      const expectedPref = LabelersPref.empty;
      when(() => mockRepository.watchLabelersPref()).thenAnswer((_) => Stream.value(expectedPref));

      container.listen(labelersPrefProvider, (prev, next) {});

      verify(() => mockRepository.watchLabelersPref()).called(1);
    });

    test('feedViewPrefProvider calls repository watch method', () {
      const expectedPref = FeedViewPref.defaultPref;
      when(() => mockRepository.watchFeedViewPref()).thenAnswer((_) => Stream.value(expectedPref));

      container.listen(feedViewPrefProvider, (prev, next) {});

      verify(() => mockRepository.watchFeedViewPref()).called(1);
    });

    test('threadViewPrefProvider calls repository watch method', () {
      const expectedPref = ThreadViewPref.defaultPref;
      when(
        () => mockRepository.watchThreadViewPref(),
      ).thenAnswer((_) => Stream.value(expectedPref));

      container.listen(threadViewPrefProvider, (prev, next) {});

      verify(() => mockRepository.watchThreadViewPref()).called(1);
    });

    test('mutedWordsPrefProvider calls repository watch method', () {
      const expectedPref = MutedWordsPref.empty;
      when(
        () => mockRepository.watchMutedWordsPref(),
      ).thenAnswer((_) => Stream.value(expectedPref));

      container.listen(mutedWordsPrefProvider, (prev, next) {});

      verify(() => mockRepository.watchMutedWordsPref()).called(1);
    });
  });
}
