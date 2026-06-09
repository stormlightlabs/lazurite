import 'dart:async';

import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/labeler/defs.dart';
import 'package:lazurite/core/cache/poptart_cache_codecs.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/moderation/data/label_detail_models.dart';
import 'package:lazurite/features/moderation/data/moderation_constants.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';

class LabelDetailRepository {
  LabelDetailRepository({required ModerationService moderationService, AppDatabase? database})
    : _moderationService = moderationService,
      _database = database;

  final ModerationService _moderationService;
  final AppDatabase? _database;
  final Map<String, Future<LabelerViewDetailed?>> _labelerLookups = {};

  Future<LabelDetailData> getLabelDetail(LabelContext context, {Iterable<String> preferredLanguages = const []}) async {
    await _moderationService.ensureInitialized();

    final labeler = await _getLabelerDetails(context.labelerDid).catchError((_) => null as LabelerViewDetailed?);
    final livePolicies = labeler?.policies;
    final cachedPolicies = livePolicies == null ? await _loadCachedPolicies(context.labelerDid) : null;
    final effectivePolicies = livePolicies ?? cachedPolicies;
    final definition = _definitionForIdentifier(effectivePolicies, context.identifier);
    final fallbackPreference = _visibilityFromDefaultSetting(definition?.defaultSetting);
    final adultContentEnabled = _adultContentEnabled(_moderationService.currentPreferences);
    final canConfigurePreference = !(definition?.adultOnly ?? false) || adultContentEnabled;

    return LabelDetailData(
      context: context,
      labeler: labeler,
      definition: definition,
      displayName: _localizedName(definition, preferredLanguages) ?? humanizeModerationLabel(context.identifier),
      description: _localizedDescription(definition, preferredLanguages),
      effectivePreference: _resolveLabelPreference(
        _moderationService.currentPreferences,
        label: context.identifier,
        labelerDid: context.labelerDid,
        fallback: fallbackPreference,
      ),
      isSubscribed: _isSubscribed(context.labelerDid),
      adultContentEnabled: adultContentEnabled,
      canConfigurePreference: canConfigurePreference,
    );
  }

  Future<LabelerViewDetailed?> _getLabelerDetails(String did) {
    final existing = _labelerLookups[did];
    if (existing != null) {
      return existing;
    }

    final lookup = _lookupAndRemove(did);
    _labelerLookups[did] = lookup;
    return lookup;
  }

  Future<LabelerViewDetailed?> _lookupAndRemove(String did) async {
    try {
      return await _moderationService.getLabelerDetails(did);
    } finally {
      final _ = _labelerLookups.remove(did);
    }
  }

  Future<LabelerPolicies?> _loadCachedPolicies(String did) async {
    final database = _database;
    if (database == null) {
      return null;
    }

    final cached = await database.getLabelerCache(did);
    if (cached == null) {
      return null;
    }

    return PoptartCacheCodecs.labelerPolicies.decode(cached.policiesJson);
  }

  bool _isSubscribed(String did) {
    if (did == officialBlueskyLabelerDid) {
      return true;
    }

    final labelers = _moderationService.currentPrefs?.labelers ?? const [];
    return labelers.any((labeler) => labeler.did == did);
  }
}

LabelValueDefinition? _definitionForIdentifier(LabelerPolicies? policies, String identifier) {
  if (policies == null) {
    return null;
  }

  for (final definition in policies.labelValueDefinitions ?? const <LabelValueDefinition>[]) {
    if (definition.identifier == identifier) {
      return definition;
    }
  }
  return null;
}

KnownContentLabelPrefVisibility _resolveLabelPreference(
  List<UPreferences> preferences, {
  required String label,
  required String labelerDid,
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

bool _adultContentEnabled(List<UPreferences> preferences) {
  for (final preference in preferences) {
    if (preference.isAdultContentPref) {
      return preference.adultContentPref!.enabled;
    }
  }
  return false;
}

KnownContentLabelPrefVisibility _visibilityFromDefaultSetting(LabelValueDefinitionDefaultSetting? defaultSetting) {
  final raw = defaultSetting?.knownValue;
  return switch (raw) {
    KnownLabelValueDefinitionDefaultSetting.ignore => KnownContentLabelPrefVisibility.ignore,
    KnownLabelValueDefinitionDefaultSetting.hide => KnownContentLabelPrefVisibility.hide,
    KnownLabelValueDefinitionDefaultSetting.warn || null => KnownContentLabelPrefVisibility.warn,
  };
}

String? _localizedName(LabelValueDefinition? definition, Iterable<String> preferredLanguages) {
  final match = _localizedStrings(definition?.locales ?? const [], preferredLanguages);
  return match?.name.isEmpty ?? true ? null : match!.name;
}

String? _localizedDescription(LabelValueDefinition? definition, Iterable<String> preferredLanguages) {
  final match = _localizedStrings(definition?.locales ?? const [], preferredLanguages);
  return match?.description.isEmpty ?? true ? null : match!.description;
}

LabelValueDefinitionStrings? _localizedStrings(
  List<LabelValueDefinitionStrings> locales,
  Iterable<String> preferredLanguages,
) {
  if (locales.isEmpty) {
    return null;
  }

  final normalizedLanguages = preferredLanguages
      .map((language) => language.trim().toLowerCase())
      .where((language) => language.isNotEmpty)
      .toList(growable: false);

  for (final language in normalizedLanguages) {
    for (final entry in locales) {
      if (entry.lang.toLowerCase() == language) {
        return entry;
      }
    }

    final baseLanguage = language.split(RegExp(r'[-_]')).first;
    for (final entry in locales) {
      final entryLanguage = entry.lang.toLowerCase();
      if (entryLanguage == baseLanguage || entryLanguage.startsWith('$baseLanguage-')) {
        return entry;
      }
    }
  }

  return locales.first;
}
