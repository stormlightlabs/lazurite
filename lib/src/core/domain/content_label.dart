import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_label.freezed.dart';
part 'content_label.g.dart';

/// Behavioral directives for how labeled content should be handled.
enum LabelBehavior {
  /// Content should be hidden behind a warning (click-to-reveal).
  warn,

  /// Content should be completely hidden (no reveal option).
  hide,

  /// Content should be blurred (similar to warn but less severe).
  blur,

  /// Label is informational only (e.g., "spam", "scam" indicators).
  inform,

  /// Label triggers an alert (severe moderation action).
  alert,
}

/// Represents an AT Protocol content label (com.atproto.label.defs#label).
@freezed
abstract class ContentLabel with _$ContentLabel {
  const factory ContentLabel({
    /// DID of the labeler that created this label.
    required String src,

    /// AT URI of the subject (post or profile) this label applies to.
    required String uri,

    /// Short name or type of the label (e.g., "porn", "spam", "scam").
    required String val,

    /// Timestamp when the label was created.
    required DateTime cts,

    /// Optional CID targeting a specific version of the subject.
    @JsonKey(includeIfNull: false) String? cid,

    /// If true, this label negates a previous label with the same src, uri, and val.
    @JsonKey(includeIfNull: false) bool? neg,

    /// Label schema version (currently always 1).
    @JsonKey(includeIfNull: false) int? ver,
  }) = _ContentLabel;

  const ContentLabel._();

  /// Creates a ContentLabel from API JSON response.
  factory ContentLabel.fromJson(Map<String, dynamic> json) => _$ContentLabelFromJson(json);

  /// Parses a list of ContentLabels from a JSON string stored in the database.
  static List<ContentLabel> parseFromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final list = jsonDecode(jsonString) as List;
      return list.whereType<Map<String, dynamic>>().map(ContentLabel.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  /// Known system labels and their behaviors.
  static const Map<String, LabelBehavior> systemLabelBehaviors = {
    '!warn': LabelBehavior.warn,
    '!hide': LabelBehavior.hide,
    '!no-promote': LabelBehavior.inform,
    '!no-unauthenticated': LabelBehavior.inform,
    '!takedown': LabelBehavior.hide,
    '!suspend': LabelBehavior.hide,
  };

  /// Known descriptive labels and their default behaviors.
  static const Map<String, LabelBehavior> descriptiveLabelBehaviors = {
    'porn': LabelBehavior.warn,
    'sexual': LabelBehavior.warn,
    'nudity': LabelBehavior.blur,
    'nsfl': LabelBehavior.warn,
    'gore': LabelBehavior.warn,
    'spam': LabelBehavior.inform,
    'scam': LabelBehavior.alert,
    'impersonation': LabelBehavior.alert,
    'misinformation': LabelBehavior.warn,
  };

  /// Convenience getter for the labeler DID.
  String get labelerDid => src;

  /// Whether this label is a negation of a previous label.
  bool get isNegation => neg == true;

  /// Whether this is a system label (prefixed with !).
  bool get isSystemLabel => val.startsWith('!');

  /// Display-friendly value (strips `!` prefix from system labels).
  String get displayValue => isSystemLabel ? val.substring(1) : val;

  /// The expected behavior for this label.
  LabelBehavior get behavior {
    if (isSystemLabel) {
      return systemLabelBehaviors[val] ?? LabelBehavior.warn;
    }
    return descriptiveLabelBehaviors[val.toLowerCase()] ?? LabelBehavior.inform;
  }

  /// Whether this label should trigger a content warning overlay.
  bool get shouldWarn => behavior == LabelBehavior.warn || behavior == LabelBehavior.blur;

  /// Whether this label should completely hide content.
  bool get shouldHide => behavior == LabelBehavior.hide;
}
