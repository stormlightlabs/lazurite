import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:lazurite/features/moderation/domain/moderation_models.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/l10n/app_localizations.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';

const officialBlueskyLabelerDid = 'did:plc:ar7c4by46qjdydhdevvrndac';

enum ModerationBadgeTone { alert, inform }

typedef ModerationLabelResolver = String? Function({required String identifier, String? labelerDid});

class ModerationBadgeDescriptor {
  const ModerationBadgeDescriptor({required this.label, required this.description, required this.tone});

  final String label;
  final String description;
  final ModerationBadgeTone tone;
}

ModerationService? maybeModerationService(BuildContext context) {
  try {
    return context.read<ModerationService>();
  } catch (_) {
    return null;
  }
}

String formatLocalizedLabelName(List<LabelValueDefinitionStrings> locales, Locale locale, {required String fallback}) {
  if (locales.isEmpty) {
    return humanizeModerationLabel(fallback);
  }

  final exact = locales.where((entry) => entry.lang.toLowerCase() == locale.languageCode.toLowerCase()).firstOrNull;
  if (exact != null) {
    return exact.name;
  }

  final languageMatch = locales
      .where((entry) => entry.lang.toLowerCase().startsWith(locale.languageCode.toLowerCase()))
      .firstOrNull;
  if (languageMatch != null) {
    return languageMatch.name;
  }

  return locales.first.name;
}

String formatLocalizedLabelDescription(
  List<LabelValueDefinitionStrings> locales,
  Locale locale, {
  String fallback = '',
}) {
  if (locales.isEmpty) {
    return fallback;
  }

  final exact = locales.where((entry) => entry.lang.toLowerCase() == locale.languageCode.toLowerCase()).firstOrNull;
  if (exact != null) {
    return exact.description;
  }

  final languageMatch = locales
      .where((entry) => entry.lang.toLowerCase().startsWith(locale.languageCode.toLowerCase()))
      .firstOrNull;
  if (languageMatch != null) {
    return languageMatch.description;
  }

  return locales.first.description;
}

List<ModerationBadgeDescriptor> moderationBadgesForUi(
  bsky_moderation.ModerationUI ui, {
  ModerationLabelResolver? labelResolver,
  AppLocalizations? l10n,
}) {
  final badges = <ModerationBadgeDescriptor>[];
  final seen = <String>{};

  void addDescriptors(List<bsky_moderation.ModerationCause> causes, ModerationBadgeTone tone) {
    for (final cause in causes) {
      final descriptor = moderationDescriptorForCause(cause, tone: tone, labelResolver: labelResolver, l10n: l10n);
      final key = '${tone.name}:${descriptor.label}:${descriptor.description}';
      if (seen.add(key)) {
        badges.add(descriptor);
      }
    }
  }

  addDescriptors(ui.alerts, ModerationBadgeTone.alert);
  addDescriptors(ui.informs, ModerationBadgeTone.inform);
  return badges;
}

List<String> moderationBlurLabels(
  bsky_moderation.ModerationUI ui, {
  ModerationLabelResolver? labelResolver,
  AppLocalizations? l10n,
}) {
  final labels = <String>[];
  final seen = <String>{};

  for (final cause in ui.blurs) {
    final descriptor = moderationDescriptorForCause(
      cause,
      tone: ModerationBadgeTone.alert,
      labelResolver: labelResolver,
      l10n: l10n,
    );
    if (seen.add(descriptor.label)) {
      labels.add(descriptor.label);
    }
  }

  return labels;
}

ModerationBadgeDescriptor moderationDescriptorForCause(
  bsky_moderation.ModerationCause cause, {
  required ModerationBadgeTone tone,
  ModerationLabelResolver? labelResolver,
  AppLocalizations? l10n,
}) {
  return cause.maybeWhen(
    label: (data) {
      final resolvedLabel = labelResolver?.call(
        identifier: data.labelDef.identifier,
        labelerDid: data.label.src.isEmpty ? null : data.label.src,
      );
      final label = (resolvedLabel == null || resolvedLabel.isEmpty)
          ? humanizeModerationLabel(data.labelDef.identifier)
          : resolvedLabel;
      final source = data.labelDef.definedBy == officialBlueskyLabelerDid
          ? (l10n?.labelModerationSourceBluesky ?? 'Bluesky')
          : (l10n?.labelModerationSourceSubscribedLabeler ?? 'Subscribed labeler');
      return ModerationBadgeDescriptor(
        label: label,
        description: l10n?.formatModerationSourceLabel(source) ?? '$source label',
        tone: tone,
      );
    },
    muted: (_) => ModerationBadgeDescriptor(
      label: l10n?.labelMutedAccount ?? 'Muted account',
      description: l10n?.messageMutedAccountDescription ?? 'Muted content is being downranked here',
      tone: tone,
    ),
    muteWord: (_) => ModerationBadgeDescriptor(
      label: l10n?.labelMutedPhrase ?? 'Muted phrase',
      description: l10n?.messageMutedPhraseDescription ?? 'A muted phrase matched this content',
      tone: tone,
    ),
    blocking: (_) => ModerationBadgeDescriptor(
      label: l10n?.labelBlockedAccount ?? 'Blocked account',
      description: l10n?.messageBlockedAccountDescription ?? 'This account is blocked',
      tone: tone,
    ),
    blockedBy: (_) => ModerationBadgeDescriptor(
      label: l10n?.labelBlockedByAccount ?? 'Blocked by account',
      description: l10n?.messageBlockedByAccountDescription ?? 'This account has blocked you',
      tone: tone,
    ),
    blockOther: (_) => ModerationBadgeDescriptor(
      label: l10n?.labelBlockedRelationship ?? 'Blocked relationship',
      description: l10n?.messageBlockedRelationshipDescription ?? 'This content is limited by a block relationship',
      tone: tone,
    ),
    hidden: (_) => ModerationBadgeDescriptor(
      label: l10n?.labelHiddenContent ?? 'Hidden content',
      description: l10n?.messageHiddenContentDescription ?? 'This content is hidden by moderation rules',
      tone: tone,
    ),
    orElse: () => ModerationBadgeDescriptor(
      label: tone == ModerationBadgeTone.alert
          ? (l10n?.labelSensitiveContent ?? 'Sensitive content')
          : (l10n?.labelModerationNote ?? 'Moderation note'),
      description: l10n?.messageModerationGuidanceApplies ?? 'Moderation guidance applies here',
      tone: tone,
    ),
  );
}

String moderationOverlayTitle(
  bsky_moderation.ModerationUI ui, {
  String fallback = 'Sensitive content',
  ModerationLabelResolver? labelResolver,
  AppLocalizations? l10n,
}) {
  final labels = moderationBlurLabels(ui, labelResolver: labelResolver, l10n: l10n);
  if (labels.isEmpty) {
    return fallback;
  }
  if (labels.length == 1) {
    return labels.first;
  }
  return '${labels.first} +${labels.length - 1}';
}

String humanizeModerationLabel(String value) {
  if (value.isEmpty) {
    return 'Sensitive content';
  }

  final cleaned = value.replaceAll('!', '').replaceAll('-', ' ').trim();
  final words = cleaned.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
  return words.map((word) => '${word[0].toUpperCase()}${word.substring(1)}').join(' ');
}

KnownContentLabelPrefVisibility resolveLabelPreference(
  List<UPreferences> preferences, {
  required String label,
  String? labelerDid,
  required KnownContentLabelPrefVisibility fallback,
}) {
  ContentLabelPref? globalMatch;

  for (final preference in preferences) {
    if (!preference.isContentLabelPref) {
      continue;
    }

    final contentPref = preference.contentLabelPref!;
    if (contentPref.label != label) {
      continue;
    }
    if (contentPref.labelerDid == labelerDid) {
      return contentPref.visibility.knownValue ?? fallback;
    }
    if (contentPref.labelerDid == null) {
      globalMatch = contentPref;
    }
  }

  return globalMatch?.visibility.knownValue ?? fallback;
}

bool adultContentEnabledFromPreferences(List<UPreferences> preferences) {
  for (final preference in preferences) {
    if (preference.isAdultContentPref) {
      return preference.adultContentPref!.enabled;
    }
  }
  return false;
}

KnownContentLabelPrefVisibility visibilityFromDefaultSetting(LabelValueDefinitionDefaultSetting? defaultSetting) {
  final raw = defaultSetting?.knownValue;
  return switch (raw) {
    KnownLabelValueDefinitionDefaultSetting.ignore => KnownContentLabelPrefVisibility.ignore,
    KnownLabelValueDefinitionDefaultSetting.hide => KnownContentLabelPrefVisibility.hide,
    KnownLabelValueDefinitionDefaultSetting.warn || null => KnownContentLabelPrefVisibility.warn,
  };
}
