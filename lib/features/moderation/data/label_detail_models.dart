import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/labeler/defs.dart';
import 'package:poptart_bluesky_moderation/poptart_bluesky_moderation.dart' as bsky_moderation;
import 'package:poptart_lex/com/atproto/label/defs.dart';

/// Protocol and UI context for a label the user selected.
///
/// Applied labels carry the labeler DID and label identifier, but they do not
/// include the labeler's localized policy definition.
///
/// This model preserves the applied label metadata while giving the detail resolver
/// a stable key to look up the publishing labeler and matching definition.
class LabelContext {
  const LabelContext({
    this.appliedLabel,
    required this.labelerDid,
    required this.identifier,
    this.subjectUri,
    this.subjectCid,
    this.createdAt,
    this.expiresAt,
    this.isNegation = false,
    this.version,
  });

  factory LabelContext.fromLabel(Label label, {String? subjectUri, String? subjectCid}) => LabelContext(
    appliedLabel: label,
    labelerDid: label.src,
    identifier: label.val,
    subjectUri: subjectUri ?? label.uri,
    subjectCid: subjectCid ?? label.cid,
    createdAt: label.cts,
    expiresAt: label.exp,
    isNegation: label.neg ?? false,
    version: label.ver,
  );

  factory LabelContext.fromIdentifier({
    required String labelerDid,
    required String identifier,
    String? subjectUri,
    String? subjectCid,
  }) => LabelContext(labelerDid: labelerDid, identifier: identifier, subjectUri: subjectUri, subjectCid: subjectCid);

  static LabelContext? fromModerationCause(bsky_moderation.ModerationCause cause) => cause.maybeWhen(
    label: (data) => LabelContext.fromLabel(
      data.label,
      subjectUri: data.label.uri.isEmpty ? null : data.label.uri,
      subjectCid: data.label.cid,
    ),
    orElse: () => null,
  );

  final Label? appliedLabel;
  final String labelerDid;
  final String identifier;
  final String? subjectUri;
  final String? subjectCid;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final bool isNegation;
  final int? version;

  bool get hasAppliedLabel => appliedLabel != null;
  bool get hasSubjectVersion => subjectCid != null && subjectCid!.isNotEmpty;
  bool get hasExpiry => expiresAt != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelContext &&
          runtimeType == other.runtimeType &&
          appliedLabel == other.appliedLabel &&
          labelerDid == other.labelerDid &&
          identifier == other.identifier &&
          subjectUri == other.subjectUri &&
          subjectCid == other.subjectCid &&
          createdAt == other.createdAt &&
          expiresAt == other.expiresAt &&
          isNegation == other.isNegation &&
          version == other.version;

  @override
  int get hashCode => Object.hash(
    appliedLabel,
    labelerDid,
    identifier,
    subjectUri,
    subjectCid,
    createdAt,
    expiresAt,
    isNegation,
    version,
  );

  @override
  String toString() =>
      'LabelContext(labelerDid: $labelerDid, identifier: $identifier, subjectUri: $subjectUri, '
      'subjectCid: $subjectCid, createdAt: $createdAt, expiresAt: $expiresAt, isNegation: $isNegation, '
      'version: $version, hasAppliedLabel: $hasAppliedLabel)';
}

/// Detail data for a selected moderation label.
///
/// The resolver may not be able to find the labeler service or the service may
/// not publish a definition for the applied value.
class LabelDetailData {
  const LabelDetailData({
    required this.context,
    required this.effectivePreference,
    required this.isSubscribed,
    this.adultContentEnabled = false,
    this.canConfigurePreference = true,
    this.labeler,
    this.definition,
    this.displayName,
    this.description,
  });

  final LabelContext context;
  final LabelerViewDetailed? labeler;
  final LabelValueDefinition? definition;
  final KnownContentLabelPrefVisibility effectivePreference;
  final bool isSubscribed;
  final bool adultContentEnabled;
  final bool canConfigurePreference;
  final String? displayName;
  final String? description;

  bool get hasLabeler => labeler != null;
  bool get hasDefinition => definition != null;
  bool get isPartial => !hasLabeler || !hasDefinition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelDetailData &&
          runtimeType == other.runtimeType &&
          context == other.context &&
          labeler == other.labeler &&
          definition == other.definition &&
          effectivePreference == other.effectivePreference &&
          isSubscribed == other.isSubscribed &&
          adultContentEnabled == other.adultContentEnabled &&
          canConfigurePreference == other.canConfigurePreference &&
          displayName == other.displayName &&
          description == other.description;

  @override
  int get hashCode => Object.hash(
    context,
    labeler,
    definition,
    effectivePreference,
    isSubscribed,
    adultContentEnabled,
    canConfigurePreference,
    displayName,
    description,
  );

  @override
  String toString() =>
      'LabelDetailData(context: $context, hasLabeler: $hasLabeler, hasDefinition: $hasDefinition, '
      'effectivePreference: $effectivePreference, isSubscribed: $isSubscribed, '
      'adultContentEnabled: $adultContentEnabled, canConfigurePreference: $canConfigurePreference, '
      'displayName: $displayName)';
}
