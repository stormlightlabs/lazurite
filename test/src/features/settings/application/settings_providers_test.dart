import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/settings/application/settings_providers.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockBlueskyPreferencesRepository mockRepository;
  late ProviderContainer container;
  late Session testSession;

  setUp(() {
    mockRepository = MockBlueskyPreferencesRepository();
    testSession = Session(
      did: 'did:web:test',
      handle: 'handle',
      pdsUrl: 'https://pds',
      accessJwt: 'access',
      refreshJwt: 'refresh',
      scope: 'scope',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      dpopKey: const <String, dynamic>{},
    );

    container = ProviderContainer(
      overrides: [
        blueskyPreferencesRepositoryProvider.overrideWithValue(mockRepository),
        authProvider.overrideWith(() => _TestAuthNotifier(testSession)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('settings providers', () {
    test('adultContentPrefProvider calls repository watch method', () {
      const expectedPref = AdultContentPref(enabled: true);
      when(
        () => mockRepository.watchAdultContentPref(testSession.did),
      ).thenAnswer((_) => Stream.value(expectedPref));

      container.listen(adultContentPrefProvider, (prev, next) {});

      verify(() => mockRepository.watchAdultContentPref(testSession.did)).called(1);
    });

    test('contentLabelPrefsProvider calls repository watch method', () {
      const expectedPrefs = ContentLabelPrefs.empty;
      when(
        () => mockRepository.watchContentLabelPrefs(testSession.did),
      ).thenAnswer((_) => Stream.value(expectedPrefs));

      container.listen(contentLabelPrefsProvider, (prev, next) {});

      verify(() => mockRepository.watchContentLabelPrefs(testSession.did)).called(1);
    });

    test('labelersPrefProvider calls repository watch method', () {
      const expectedPref = LabelersPref.empty;
      when(
        () => mockRepository.watchLabelersPref(testSession.did),
      ).thenAnswer((_) => Stream.value(expectedPref));

      container.listen(labelersPrefProvider, (prev, next) {});

      verify(() => mockRepository.watchLabelersPref(testSession.did)).called(1);
    });

    test('feedViewPrefProvider calls repository watch method', () {
      const expectedPref = FeedViewPref.defaultPref;
      when(
        () => mockRepository.watchFeedViewPref(testSession.did),
      ).thenAnswer((_) => Stream.value(expectedPref));

      container.listen(feedViewPrefProvider, (prev, next) {});

      verify(() => mockRepository.watchFeedViewPref(testSession.did)).called(1);
    });

    test('threadViewPrefProvider calls repository watch method', () {
      const expectedPref = ThreadViewPref.defaultPref;
      when(
        () => mockRepository.watchThreadViewPref(testSession.did),
      ).thenAnswer((_) => Stream.value(expectedPref));

      container.listen(threadViewPrefProvider, (prev, next) {});

      verify(() => mockRepository.watchThreadViewPref(testSession.did)).called(1);
    });

    test('mutedWordsPrefProvider calls repository watch method', () {
      const expectedPref = MutedWordsPref.empty;
      when(
        () => mockRepository.watchMutedWordsPref(testSession.did),
      ).thenAnswer((_) => Stream.value(expectedPref));

      container.listen(mutedWordsPrefProvider, (prev, next) {});

      verify(() => mockRepository.watchMutedWordsPref(testSession.did)).called(1);
    });
  });
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._session);

  final Session _session;

  @override
  AuthState build() => AuthState.authenticated(_session);
}
