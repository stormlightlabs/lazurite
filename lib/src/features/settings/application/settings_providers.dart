import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/core/utils/logger_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:lazurite/src/infrastructure/network/providers.dart';
import 'package:lazurite/src/infrastructure/preferences/bluesky_preferences_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_providers.g.dart';

/// Provides the Bluesky preferences repository.
@Riverpod(keepAlive: true)
BlueskyPreferencesRepository blueskyPreferencesRepository(Ref ref) {
  final api = ref.watch(xrpcClientProvider);
  final db = ref.watch(appDatabaseProvider);
  final logger = ref.watch(loggerProvider('BlueskyPreferencesRepository'));

  return BlueskyPreferencesRepository(
    api,
    db.blueskyPreferencesDao,
    db.preferenceSyncQueueDao,
    logger,
  );
}

/// Watches the adult content preference.
@riverpod
Stream<AdultContentPref> adultContentPref(Ref ref) {
  final repo = ref.watch(blueskyPreferencesRepositoryProvider);
  final authState = ref.watch(authProvider);

  final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

  if (ownerDid == null) return Stream.value(const AdultContentPref(enabled: false));

  return repo.watchAdultContentPref(ownerDid);
}

/// Watches content label preferences.
@riverpod
Stream<ContentLabelPrefs> contentLabelPrefs(Ref ref) {
  final repo = ref.watch(blueskyPreferencesRepositoryProvider);
  final authState = ref.watch(authProvider);

  final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

  if (ownerDid == null) return Stream.value(ContentLabelPrefs.empty);

  return repo.watchContentLabelPrefs(ownerDid);
}

/// Watches the labelers preference.
@riverpod
Stream<LabelersPref> labelersPref(Ref ref) {
  final repo = ref.watch(blueskyPreferencesRepositoryProvider);
  final authState = ref.watch(authProvider);

  final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

  if (ownerDid == null) return Stream.value(LabelersPref.empty);

  return repo.watchLabelersPref(ownerDid);
}

/// Watches the feed view preference.
@riverpod
Stream<FeedViewPref> feedViewPref(Ref ref) {
  final repo = ref.watch(blueskyPreferencesRepositoryProvider);
  final authState = ref.watch(authProvider);

  final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

  if (ownerDid == null) return Stream.value(FeedViewPref.defaultPref);

  return repo.watchFeedViewPref(ownerDid);
}

/// Watches the thread view preference.
@riverpod
Stream<ThreadViewPref> threadViewPref(Ref ref) {
  final repo = ref.watch(blueskyPreferencesRepositoryProvider);
  final authState = ref.watch(authProvider);

  final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

  if (ownerDid == null) return Stream.value(ThreadViewPref.defaultPref);

  return repo.watchThreadViewPref(ownerDid);
}

/// Watches the muted words preference.
@riverpod
Stream<MutedWordsPref> mutedWordsPref(Ref ref) {
  final repo = ref.watch(blueskyPreferencesRepositoryProvider);
  final authState = ref.watch(authProvider);

  final ownerDid = (authState is AuthStateAuthenticated) ? authState.session.did : null;

  if (ownerDid == null) return Stream.value(MutedWordsPref.empty);

  return repo.watchMutedWordsPref(ownerDid);
}
