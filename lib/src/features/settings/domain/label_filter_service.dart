import 'package:lazurite/src/core/domain/content_label.dart';

import 'bluesky_preferences.dart';

/// Service for filtering content based on labels and user preferences.
///
/// Combines content labels on posts/profiles with the user's content moderation
/// preferences to determine effective visibility behaviors.
class LabelFilterService {
  const LabelFilterService({required this.adultContentEnabled, required this.labelPrefs});

  /// Whether adult content is enabled in preferences.
  final bool adultContentEnabled;

  /// User's content label visibility preferences.
  final ContentLabelPrefs labelPrefs;

  /// Labels considered adult content that are blocked when adult content is disabled.
  static const adultLabels = {'porn', 'sexual', 'nudity', 'nsfl'};

  /// Gets the effective behavior for a content label based on user preferences.
  ///
  /// For system labels (prefixed with !), uses the label's built-in behavior.
  /// For descriptive labels, checks user preferences first, then falls back to defaults.
  LabelBehavior getEffectiveBehavior(ContentLabel label) {
    if (label.isSystemLabel) {
      return label.behavior;
    }

    if (adultLabels.contains(label.val.toLowerCase()) && !adultContentEnabled) {
      return LabelBehavior.hide;
    }

    final userVisibility = labelPrefs.getVisibility(label.val.toLowerCase());
    if (userVisibility != null) {
      return _visibilityToBehavior(userVisibility);
    }

    return label.behavior;
  }

  /// Whether a label should trigger a warning overlay.
  bool shouldWarn(ContentLabel label) {
    final behavior = getEffectiveBehavior(label);
    return behavior == LabelBehavior.warn || behavior == LabelBehavior.blur;
  }

  /// Whether a label should completely hide content.
  bool shouldHide(ContentLabel label) {
    final behavior = getEffectiveBehavior(label);
    return behavior == LabelBehavior.hide;
  }

  /// Whether any label in the list should hide content.
  bool anyLabelHides(List<ContentLabel> labels) {
    return labels.any((l) => !l.isNegation && shouldHide(l));
  }

  /// Whether any label in the list should warn.
  bool anyLabelWarns(List<ContentLabel> labels) {
    return labels.any((l) => !l.isNegation && shouldWarn(l));
  }

  /// Converts user visibility preference to label behavior.
  LabelBehavior _visibilityToBehavior(LabelVisibility visibility) {
    return switch (visibility) {
      LabelVisibility.ignore => LabelBehavior.inform,
      LabelVisibility.show => LabelBehavior.inform,
      LabelVisibility.warn => LabelBehavior.warn,
      LabelVisibility.hide => LabelBehavior.hide,
    };
  }
}
