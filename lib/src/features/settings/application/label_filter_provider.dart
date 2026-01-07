import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/bluesky_preferences.dart';
import '../domain/label_filter_service.dart';
import 'settings_providers.dart';

part 'label_filter_provider.g.dart';

/// Provides the label filter service with current user preferences.
///
/// Returns null if preferences are still loading or unavailable.
@riverpod
LabelFilterService? labelFilterService(Ref ref) {
  final adultPref = ref.watch(adultContentPrefProvider);
  final labelPrefs = ref.watch(contentLabelPrefsProvider);

  if (adultPref.isLoading || labelPrefs.isLoading) {
    return null;
  }

  final adult = adultPref.maybeWhen(
    data: (data) => data,
    orElse: () => const AdultContentPref(enabled: false),
  );
  final labels = labelPrefs.maybeWhen(data: (data) => data, orElse: () => ContentLabelPrefs.empty);

  return LabelFilterService(adultContentEnabled: adult.enabled, labelPrefs: labels);
}
