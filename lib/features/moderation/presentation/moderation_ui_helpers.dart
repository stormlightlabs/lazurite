import 'package:atproto/com_atproto_label_defs.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';

const officialBlueskyLabelerDid = 'did:plc:ar7c4by46qjdydhdevvrndac';

enum ModerationBadgeTone { alert, inform }

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

List<ModerationBadgeDescriptor> moderationBadgesForUi(bsky_moderation.ModerationUI ui) {
  final badges = <ModerationBadgeDescriptor>[];
  final seen = <String>{};

  void addDescriptors(List<bsky_moderation.ModerationCause> causes, ModerationBadgeTone tone) {
    for (final cause in causes) {
      final descriptor = moderationDescriptorForCause(cause, tone: tone);
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

List<String> moderationBlurLabels(bsky_moderation.ModerationUI ui) {
  final labels = <String>[];
  final seen = <String>{};

  for (final cause in ui.blurs) {
    final descriptor = moderationDescriptorForCause(cause, tone: ModerationBadgeTone.alert);
    if (seen.add(descriptor.label)) {
      labels.add(descriptor.label);
    }
  }

  return labels;
}

ModerationBadgeDescriptor moderationDescriptorForCause(
  bsky_moderation.ModerationCause cause, {
  required ModerationBadgeTone tone,
}) {
  return cause.maybeWhen(
    label: (data) {
      final label = humanizeModerationLabel(data.labelDef.identifier);
      final source = data.labelDef.definedBy == officialBlueskyLabelerDid ? 'Bluesky' : 'Subscribed labeler';
      return ModerationBadgeDescriptor(label: label, description: '$source label', tone: tone);
    },
    muted: (_) => ModerationBadgeDescriptor(
      label: 'Muted account',
      description: 'Muted content is being downranked here',
      tone: tone,
    ),
    muteWord: (_) => ModerationBadgeDescriptor(
      label: 'Muted phrase',
      description: 'A muted phrase matched this content',
      tone: tone,
    ),
    blocking: (_) =>
        ModerationBadgeDescriptor(label: 'Blocked account', description: 'This account is blocked', tone: tone),
    blockedBy: (_) =>
        ModerationBadgeDescriptor(label: 'Blocked by account', description: 'This account has blocked you', tone: tone),
    blockOther: (_) => ModerationBadgeDescriptor(
      label: 'Blocked relationship',
      description: 'This content is limited by a block relationship',
      tone: tone,
    ),
    hidden: (_) => ModerationBadgeDescriptor(
      label: 'Hidden content',
      description: 'This content is hidden by moderation rules',
      tone: tone,
    ),
    orElse: () => ModerationBadgeDescriptor(
      label: tone == ModerationBadgeTone.alert ? 'Sensitive content' : 'Moderation note',
      description: 'Moderation guidance applies here',
      tone: tone,
    ),
  );
}

String moderationOverlayTitle(bsky_moderation.ModerationUI ui, {String fallback = 'Sensitive content'}) {
  final labels = moderationBlurLabels(ui);
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
