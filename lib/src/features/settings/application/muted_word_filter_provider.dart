import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/bluesky_preferences.dart';
import '../domain/muted_word_filter_service.dart';
import 'settings_providers.dart';

part 'muted_word_filter_provider.g.dart';

/// Provides the muted word filter service with current user preferences.
///
/// Returns null if preferences are still loading or unavailable.
/// Only includes active (non-expired) muted words.
@riverpod
MutedWordFilterService? mutedWordFilterService(Ref ref) {
  final mutedWordsPref = ref.watch(mutedWordsPrefProvider);

  if (mutedWordsPref.isLoading) {
    return null;
  }

  final pref = mutedWordsPref.maybeWhen(data: (data) => data, orElse: () => MutedWordsPref.empty);

  return MutedWordFilterService(mutedWords: pref.activeItems);
}
